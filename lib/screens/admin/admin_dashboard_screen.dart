import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:karigar_woodwork/services/firestore_service.dart';
import 'package:karigar_woodwork/models/models.dart';
import 'package:karigar_woodwork/providers/auth_provider.dart';
import 'package:karigar_woodwork/screens/admin/order_detail_sheet.dart';
import 'package:karigar_woodwork/services/email_service.dart';
import 'package:karigar_woodwork/screens/admin/products_admin_screen.dart';
import 'package:karigar_woodwork/screens/admin/categories_admin_screen.dart';
import 'package:karigar_woodwork/screens/admin/services_admin_screen.dart';
import 'package:karigar_woodwork/screens/admin/plans_admin_screen.dart';
import 'package:karigar_woodwork/screens/admin/reports_screen.dart';
import 'package:karigar_woodwork/screens/admin/technicians_admin_screen.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final service = FirestoreService();
    final auth = context.read<AuthProvider>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (v) {
              if (v == 'products') {
                Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ProductsAdminScreen()));
              } else if (v == 'categories') {
                Navigator.of(context).push(MaterialPageRoute(builder: (_) => const CategoriesAdminScreen()));
              } else if (v == 'services') {
                Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ServicesAdminScreen()));
              } else if (v == 'plans') {
                Navigator.of(context).push(MaterialPageRoute(builder: (_) => const PlansAdminScreen()));
              } else if (v == 'reports') {
                Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ReportsScreen()));
              } else if (v == 'technicians') {
                Navigator.of(context).push(MaterialPageRoute(builder: (_) => const TechniciansAdminScreen()));
              }
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'products', child: Text('Manage Products')),
              PopupMenuItem(value: 'categories', child: Text('Manage Categories')),
              PopupMenuItem(value: 'services', child: Text('Manage Services')),
              PopupMenuItem(value: 'plans', child: Text('Manage Plans')),
              PopupMenuItem(value: 'reports', child: Text('Reports')),
              PopupMenuItem(value: 'technicians', child: Text('Technicians')),
            ],
          )
        ],
      ),
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
                            // Optional email
                            await EmailService.send(
                              to: o.userId, // Ideally lookup user email via users/{uid}
                              subject: 'Order Confirmed #${o.id}',
                              html: EmailTemplates.orderConfirmed(orderId: o.id),
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
                          await EmailService.sendOrderStatusChange(
                            order: o,
                            oldStatus: orderStatusToString(o.status),
                            newStatus: 'IN_PROGRESS',
                          );
                        },
                        onDeliver: () async {
                          Navigator.pop(context);
                          await service.updateOrderStatus(
                            orderId: o.id,
                            nextStatus: OrderStatus.delivered,
                            adminId: auth.user?.uid ?? 'admin',
                          );
                          await EmailService.sendOrderStatusChange(
                            order: o,
                            oldStatus: orderStatusToString(o.status),
                            newStatus: 'DELIVERED',
                          );
                        },
                        onCancel: () async {
                          Navigator.pop(context);
                          await service.updateOrderStatus(
                            orderId: o.id,
                            nextStatus: OrderStatus.cancelled,
                            adminId: auth.user?.uid ?? 'admin',
                          );
                          await EmailService.sendOrderStatusChange(
                            order: o,
                            oldStatus: orderStatusToString(o.status),
                            newStatus: 'CANCELLED',
                          );
                        },
                        onRefund: () {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Refund is UI placeholder.')),
                          );
                        },
                        onAssign: (techId) async {
                          await service.assignTechnician(
                            orderId: o.id,
                            adminId: auth.user?.uid ?? 'admin',
                            technicianId: techId,
                          );
                        },
                        onSendEmail: () async {
                          final err = await EmailService.sendOrderStatusChange(
                            order: o,
                            oldStatus: orderStatusToString(o.status),
                            newStatus: orderStatusToString(o.status),
                          );
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(err == null ? 'Email sent' : 'Email failed: $err')),
                            );
                          }
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
