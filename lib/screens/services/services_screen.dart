import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:karigar_woodwork/services/firestore_service.dart';
import 'package:karigar_woodwork/models/models.dart';
import 'package:karigar_woodwork/providers/auth_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Lists services and provides a "Request Service" and "Request Custom Order" flow
class ServicesScreen extends StatelessWidget {
  const ServicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Services')),
      body: StreamBuilder<List<ServiceItem>>(
        stream: FirestoreService().watchServices(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final items = snapshot.data!;
          if (items.isEmpty) return const Center(child: Text('No services available'));
          final isWide = MediaQuery.of(context).size.width > 700;
          return GridView.count(
            padding: const EdgeInsets.all(12),
            crossAxisCount: isWide ? 3 : 1,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: isWide ? 1.6 : 2.6,
            children: [
              for (final s in items)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(s.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Text(s.description),
                        const Spacer(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('₹${s.price.toStringAsFixed(2)}'),
                            ElevatedButton(
                              onPressed: () => _openRequestSheet(context, preset: s.name),
                              child: const Text('Request'),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              Card(
                child: InkWell(
                  onTap: () => _openRequestSheet(context),
                  child: const Center(child: Text('Request Custom Furniture Order')),
                ),
              )
            ],
          );
        },
      ),
    );
  }

  void _openRequestSheet(BuildContext context, {String? preset}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => _ServiceRequestSheet(preset: preset),
    );
  }
}

class _ServiceRequestSheet extends StatefulWidget {
  final String? preset;
  const _ServiceRequestSheet({required this.preset});

  @override
  State<_ServiceRequestSheet> createState() => _ServiceRequestSheetState();
}

class _ServiceRequestSheetState extends State<_ServiceRequestSheet> {
  final _titleCtrl = TextEditingController();
  final _detailsCtrl = TextEditingController();
  bool _sending = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    if (widget.preset != null) _titleCtrl.text = widget.preset!;
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _detailsCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final auth = context.read<AuthProvider>();
    if (auth.user == null) {
      setState(() => _error = 'Please login first');
      return;
    }
    setState(() {
      _sending = true;
      _error = null;
    });
    try {
      // Store as an order with zero total and notes as details, status NEW
      final db = FirestoreService();
      await db.createOrder(
        Order(
          id: 'new',
          userId: auth.user!.uid,
          items: [],
          total: 0,
          address: (auth.profile?['address'] ?? '') as String? ?? '',
          phone: (auth.profile?['phone'] ?? '') as String? ?? '',
          notes: 'Service/Custom Request: ${_titleCtrl.text}\n${_detailsCtrl.text}',
          status: OrderStatus.newOrder,
          createdAt: Timestamp.now(),
          updatedAt: null,
          adminNotes: null,
          assignedTo: null,
          paymentStatus: 'UNPAID',
          images: const [],
        ),
      );
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Request submitted')),
      );
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        top: 16,
        left: 16,
        right: 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Request Service / Custom Order', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          TextField(controller: _titleCtrl, decoration: const InputDecoration(labelText: 'Title')),
          const SizedBox(height: 8),
          TextField(
            controller: _detailsCtrl,
            decoration: const InputDecoration(labelText: 'Details'),
            maxLines: 4,
          ),
          const SizedBox(height: 8),
          if (_error != null) Text(_error!, style: const TextStyle(color: Colors.red)),
          const SizedBox(height: 8),
          Row(
            children: [
              const Spacer(),
              ElevatedButton(
                onPressed: _sending ? null : _submit,
                child: _sending
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('Submit'),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
