import 'package:flutter/material.dart';
import 'package:karigar_woodwork/models/models.dart';

class OrderDetailSheet extends StatelessWidget {
  final Order order;
  final VoidCallback onConfirm;
  final VoidCallback onStart;
  final VoidCallback onDeliver;
  final VoidCallback onCancel;
  final VoidCallback onRefund;

  const OrderDetailSheet({
    super.key,
    required this.order,
    required this.onConfirm,
    required this.onStart,
    required this.onDeliver,
    required this.onCancel,
    required this.onRefund,
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
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
