import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:karigar_woodwork/services/firestore_service.dart';
import 'package:karigar_woodwork/models/models.dart';
import 'package:karigar_woodwork/providers/auth_provider.dart';
import 'package:karigar_woodwork/screens/admin/order_detail_sheet.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final service = FirestoreService();
    final auth = context.read<AuthProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('Admin Dashboard')),
      body: StreamBuilder<List<Order>>(
        stream: service.watchOrders(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final orders = snapshot.data!;
          if (orders.isEmpty) return const Center(child: Text('No orders yet'));
          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: orders.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final o = orders[index];
              return Card(
                child: ListTile(
                  title: Text('Order #${o.id}  •  ${o.items.length} items'),
                  subtitle: Text('Status: ${orderStatusToString(o.status)}  •  Total: ₹${o.total.toStringAsFixed(2)}'),
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      builder: (_) => OrderDetailSheet(
                        order: o,
                        onConfirm: () async {
                          Navigator.pop(context);
                          try {
                            await service.confirmOrderAndDecrementStock(
                              orderId: o.id,
                              adminId: auth.user?.uid ?? 'admin',
                            );
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Cannot confirm: $e')),
                            );
                          }
                        },
                        onStart: () async {
                          Navigator.pop(context);
                          await service.updateOrderStatus(
                            orderId: o.id,
                            nextStatus: OrderStatus.inProgress,
                            adminId: auth.user?.uid ?? 'admin',
                          );
                        },
                        onDeliver: () async {
                          Navigator.pop(context);
                          await service.updateOrderStatus(
                            orderId: o.id,
                            nextStatus: OrderStatus.delivered,
                            adminId: auth.user?.uid ?? 'admin',
                          );
                        },
                        onCancel: () async {
                          Navigator.pop(context);
                          await service.updateOrderStatus(
                            orderId: o.id,
                            nextStatus: OrderStatus.cancelled,
                            adminId: auth.user?.uid ?? 'admin',
                          );
                        },
                        onRefund: () {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Refund is UI placeholder.')),
                          );
                        },
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
