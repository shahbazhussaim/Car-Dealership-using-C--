import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:karigar_woodwork/providers/auth_provider.dart';
import 'package:karigar_woodwork/services/firestore_service.dart';
import 'package:karigar_woodwork/models/models.dart';

// Displays user's past orders and a simple status timeline per order
class OrderHistoryScreen extends StatelessWidget {
  const OrderHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final uid = auth.user?.uid;
    if (uid == null) {
      return const Scaffold(body: Center(child: Text('Please login')));
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Order History')),
      body: StreamBuilder<List<Order>>(
        stream: FirestoreService().watchOrders(userId: uid),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final orders = snapshot.data!;
          if (orders.isEmpty) return const Center(child: Text('No orders yet'));
          return ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final o = orders[index];
              return Card(
                margin: const EdgeInsets.all(12),
                child: ExpansionTile(
                  title: Text('Order #${o.id} - ₹${o.total.toStringAsFixed(2)}'),
                  subtitle: Text('Status: ${orderStatusToString(o.status)}'),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Items', style: TextStyle(fontWeight: FontWeight.bold)),
                          for (final it in o.items)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [Text('${it.name} x${it.qty}'), Text('₹${(it.price * it.qty).toStringAsFixed(2)}')],
                            ),
                          const SizedBox(height: 12),
                          const Text('Timeline', style: TextStyle(fontWeight: FontWeight.bold)),
                          _StatusTimeline(orderId: o.id),
                          const SizedBox(height: 12),
                          _FeedbackButton(orderId: o.id, status: o.status),
                        ],
                      ),
                    )
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _StatusTimeline extends StatelessWidget {
  final String orderId;
  const _StatusTimeline({required this.orderId});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirestoreService()
          .watchOrders() // not ideal; fetch subcollection
          .asyncMap((_) async => await _fetchLogs(orderId)),
      builder: (context, snapshot) {
        final logs = snapshot.data as List<Map<String, dynamic>>?;
        if (logs == null) return const SizedBox();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final log in logs)
              Text('${log['from']} → ${log['to']} @ ${log['timestamp'] ?? ''}')
          ],
        );
      },
    );
  }

  Future<List<Map<String, dynamic>>> _fetchLogs(String orderId) async {
    final snaps = await FirebaseFirestore.instance
        .collection('orders')
        .doc(orderId)
        .collection('logs')
        .orderBy('timestamp')
        .get();
    return snaps.docs.map((d) => d.data()).toList();
  }
}

class _FeedbackButton extends StatelessWidget {
  final String orderId;
  final OrderStatus status;
  const _FeedbackButton({required this.orderId, required this.status});

  @override
  Widget build(BuildContext context) {
    if (status != OrderStatus.delivered) return const SizedBox();
    return Align(
      alignment: Alignment.centerLeft,
      child: OutlinedButton(
        onPressed: () => _openFeedbackDialog(context),
        child: const Text('Leave Feedback'),
      ),
    );
  }

  void _openFeedbackDialog(BuildContext context) {
    final ratingCtrl = TextEditingController();
    final messageCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Feedback'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: ratingCtrl, decoration: const InputDecoration(labelText: 'Rating (1-5)')),
            TextField(controller: messageCtrl, decoration: const InputDecoration(labelText: 'Message')),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              final rating = int.tryParse(ratingCtrl.text) ?? 5;
              await FirebaseFirestore.instance.collection('feedback').add({
                'orderId': orderId,
                'userId': FirebaseFirestore.instance.app.options.projectId, // placeholder not used
                'rating': rating,
                'message': messageCtrl.text,
                'createdAt': Timestamp.now(),
              });
              if (Navigator.canPop(context)) Navigator.pop(context);
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }
}
