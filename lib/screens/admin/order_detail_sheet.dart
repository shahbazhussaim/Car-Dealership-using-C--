import 'package:flutter/material.dart';
import 'package:karigar_woodwork/models/models.dart';

class OrderDetailSheet extends StatelessWidget {
  final Order order;
  final VoidCallback onConfirm;
  final VoidCallback onStart;
  final VoidCallback onDeliver;
  final VoidCallback onCancel;
  final VoidCallback onRefund;
  final void Function(String technicianId)? onAssign;
  final VoidCallback? onSendEmail;

  const OrderDetailSheet({
    super.key,
    required this.order,
    required this.onConfirm,
    required this.onStart,
    required this.onDeliver,
    required this.onCancel,
    required this.onRefund,
    this.onAssign,
    this.onSendEmail,
  });

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      builder: (context, controller) {
        return SingleChildScrollView(
          controller: controller,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Order #${order.id}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 8),
              Text('Status: ${orderStatusToString(order.status)}'),
              const SizedBox(height: 8),
              const Text('Items:'),
              const SizedBox(height: 6),
              for (final it in order.items)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [Text('${it.name} x${it.qty}'), Text('₹${(it.price * it.qty).toStringAsFixed(2)}')],
                ),
              const Divider(height: 24),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ElevatedButton(onPressed: onConfirm, child: const Text('Accept (Confirm)')),
                  ElevatedButton(onPressed: onStart, child: const Text('Start (In Progress)')),
                  ElevatedButton(onPressed: onDeliver, child: const Text('Mark Delivered')),
                  ElevatedButton(onPressed: onCancel, child: const Text('Cancel')),
                  OutlinedButton(onPressed: onRefund, child: const Text('Refund (UI)')),
                  if (onAssign != null)
                    OutlinedButton(
                      onPressed: () => _openAssign(context),
                      child: const Text('Assign Technician'),
                    ),
                  if (onSendEmail != null)
                    OutlinedButton(
                      onPressed: onSendEmail,
                      child: const Text('Send Email'),
                    ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _openAssign(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => _AssignDialog(onAssign: onAssign!),
    );
  }
}

class _AssignDialog extends StatefulWidget {
  final void Function(String technicianId) onAssign;
  const _AssignDialog({required this.onAssign});

  @override
  State<_AssignDialog> createState() => _AssignDialogState();
}

class _AssignDialogState extends State<_AssignDialog> {
  String? _selected;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Assign Technician'),
      content: SizedBox(
        width: 360,
        child: StreamBuilder(
          stream: FirebaseFirestore.instance.collection('technicians').orderBy('name').snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
            final docs = (snapshot.data as QuerySnapshot).docs;
            return DropdownButton<String>(
              isExpanded: true,
              value: _selected,
              items: [
                for (final d in docs) DropdownMenuItem(value: d.id, child: Text(d['name'] ?? d.id)),
              ],
              onChanged: (v) => setState(() => _selected = v),
            );
          },
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        TextButton(
          onPressed: _selected == null
              ? null
              : () {
                  widget.onAssign(_selected!);
                  Navigator.pop(context);
                },
          child: const Text('Assign'),
        ),
      ],
    );
  }
}
