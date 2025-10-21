import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:karigar_woodwork/providers/cart_provider.dart';
import 'package:karigar_woodwork/providers/auth_provider.dart';
import 'package:karigar_woodwork/models/models.dart';
import 'package:karigar_woodwork/services/firestore_service.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _addressCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  bool _placing = false;
  String? _error;

  @override
  void dispose() {
    _addressCtrl.dispose();
    _phoneCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _placeOrder() async {
    final cart = context.read<CartProvider>();
    final auth = context.read<AuthProvider>();

    if (auth.user == null) {
      setState(() => _error = 'Please login to place an order');
      return;
    }

    if (cart.isEmpty) {
      setState(() => _error = 'Cart is empty');
      return;
    }

    setState(() {
      _placing = true;
      _error = null;
    });

    try {
      final items = cart.items
          .map((e) => OrderItem(productId: e.productId, name: e.name, qty: e.quantity, price: e.price))
          .toList();
      final order = Order(
        id: 'new',
        userId: auth.user!.uid,
        items: items,
        total: cart.totalPrice,
        address: _addressCtrl.text.trim(),
        phone: _phoneCtrl.text.trim(),
        notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
        status: OrderStatus.newOrder,
        createdAt: Timestamp.now(),
        updatedAt: null,
        adminNotes: null,
        assignedTo: null,
      );

      final id = await FirestoreService().createOrder(order);
      cart.clear();

      if (!mounted) return;
      await showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Order placed'),
          content: Text('Your order (#$id) has been submitted.'),
          actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK'))],
        ),
      );
      if (mounted) Navigator.pop(context);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _placing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Shipping Information',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  TextField(controller: _addressCtrl, decoration: const InputDecoration(labelText: 'Address')),
                  const SizedBox(height: 8),
                  TextField(controller: _phoneCtrl, decoration: const InputDecoration(labelText: 'Phone')),
                  const SizedBox(height: 8),
                  TextField(controller: _notesCtrl, decoration: const InputDecoration(labelText: 'Notes (optional)')),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Order Summary', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  for (final it in cart.items)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('${it.name} x${it.quantity}'),
                          Text('₹${(it.price * it.quantity).toStringAsFixed(2)}'),
                        ],
                      ),
                    ),
                  const Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total', style: TextStyle(fontWeight: FontWeight.bold)),
                      Text('₹${cart.totalPrice.toStringAsFixed(2)}',
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          if (_error != null) Text(_error!, style: const TextStyle(color: Colors.red)),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: _placing ? null : _placeOrder,
            child: _placing
                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                : const Text('Place Order'),
          ),
        ],
      ),
    );
  }
}
