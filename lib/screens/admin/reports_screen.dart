import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:karigar_woodwork/services/firestore_service.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  DateTimeRange? _range;
  String _statusFilter = 'ALL';
  final int _lowStockThreshold = 5;
  final _service = FirestoreService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reports')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              OutlinedButton(
                onPressed: () async {
                  final now = DateTime.now();
                  final picked = await showDateRangePicker(
                    context: context,
                    firstDate: DateTime(now.year - 2),
                    lastDate: DateTime(now.year + 1),
                  );
                  if (picked != null) setState(() => _range = picked);
                },
                child: Text(_range == null ? 'Pick range' : '${_range!.start.toString().split(' ').first} → ${_range!.end.toString().split(' ').first}'),
              ),
              const SizedBox(width: 12),
              DropdownButton<String>(
                value: _statusFilter,
                items: const [
                  DropdownMenuItem(value: 'ALL', child: Text('All statuses')),
                  DropdownMenuItem(value: 'NEW', child: Text('NEW')),
                  DropdownMenuItem(value: 'CONFIRMED', child: Text('CONFIRMED')),
                  DropdownMenuItem(value: 'IN_PROGRESS', child: Text('IN_PROGRESS')),
                  DropdownMenuItem(value: 'DELIVERED', child: Text('DELIVERED')),
                  DropdownMenuItem(value: 'CANCELLED', child: Text('CANCELLED')),
                ],
                onChanged: (v) => setState(() => _statusFilter = v ?? 'ALL'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _SalesSummary(range: _range),
          const SizedBox(height: 12),
          _TopProducts(range: _range),
          const SizedBox(height: 12),
          _LowStock(threshold: _lowStockThreshold),
          const SizedBox(height: 12),
          _OrdersByStatus(range: _range),
          const SizedBox(height: 12),
          _FeedbackSummary(range: _range),
          const SizedBox(height: 12),
          _SubscriptionsSummary(),
          const SizedBox(height: 12),
          _DailyOrders(range: _range),
          const SizedBox(height: 12),
          // End of reports
        ],
      ),
    );
  }
}

class _SalesSummary extends StatelessWidget {
  final DateTimeRange? range;
  const _SalesSummary({required this.range});

  @override
  Widget build(BuildContext context) {
    final db = FirebaseFirestore.instance;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder<QuerySnapshot<Map<String, dynamic>>>(
          future: _ordersQuery(db, range).get(),
          builder: (context, snapshot) {
            final docs = snapshot.data?.docs ?? [];
            final totalOrders = docs.length;
            final revenue = docs.fold<double>(0, (s, d) => s + ((d.data()['total'] ?? 0).toDouble()));
            final aov = totalOrders == 0 ? 0 : revenue / totalOrders;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Sales Summary', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text('Total Orders: $totalOrders'),
                Text('Total Revenue: ₹${revenue.toStringAsFixed(2)}'),
                Text('Avg Order Value: ₹${aov.toStringAsFixed(2)}'),
              ],
            );
          },
        ),
      ),
    );
  }

  static Query<Map<String, dynamic>> _ordersQuery(FirebaseFirestore db, DateTimeRange? range) {
    Query<Map<String, dynamic>> q = db.collection('orders');
    if (range != null) {
      q = q
          .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(range.start))
          .where('createdAt', isLessThanOrEqualTo: Timestamp.fromDate(range.end));
    }
    return q;
  }
}

class _TopProducts extends StatelessWidget {
  final DateTimeRange? range;
  const _TopProducts({required this.range});

  @override
  Widget build(BuildContext context) {
    final db = FirebaseFirestore.instance;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder<QuerySnapshot<Map<String, dynamic>>>(
          future: _SalesSummary._ordersQuery(db, range).get(),
          builder: (context, snapshot) {
            final docs = snapshot.data?.docs ?? [];
            final Map<String, int> counts = {};
            for (final d in docs) {
              final items = (d.data()['items'] as List<dynamic>? ?? []).cast<Map<String, dynamic>>();
              for (final it in items) {
                final pid = it['productId'] ?? '';
                final qty = (it['qty'] ?? 0) as int;
                counts[pid] = (counts[pid] ?? 0) + qty;
              }
            }
            final top = counts.entries.toList()
              ..sort((a, b) => b.value.compareTo(a.value));
            final top5 = top.take(5).toList();
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Top Selling Products', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                for (final e in top5) Text('${e.key}: ${e.value} sold'),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _LowStock extends StatelessWidget {
  final int threshold;
  const _LowStock({required this.threshold});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance
              .collection('products')
              .where('stockCount', isLessThanOrEqualTo: threshold)
              .snapshots(),
          builder: (context, snapshot) {
            final docs = snapshot.data?.docs ?? [];
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Low Stock (≤ $threshold)', style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                for (final d in docs) Text('${d['name']} — ${d['stockCount']} left')
              ],
            );
          },
        ),
      ),
    );
  }
}

class _OrdersByStatus extends StatelessWidget {
  final DateTimeRange? range;
  const _OrdersByStatus({required this.range});

  @override
  Widget build(BuildContext context) {
    const statuses = ['NEW', 'CONFIRMED', 'IN_PROGRESS', 'AWAITING_SHIPMENT', 'DELIVERED', 'CANCELLED'];
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder<List<MapEntry<String, int>>>(
          future: _fetchCounts(statuses, range),
          builder: (context, snapshot) {
            final list = snapshot.data ?? [];
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Orders by Status', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                for (final e in list) Text('${e.key}: ${e.value}')
              ],
            );
          },
        ),
      ),
    );
  }

  Future<List<MapEntry<String, int>>> _fetchCounts(List<String> statuses, DateTimeRange? r) async {
    final db = FirebaseFirestore.instance;
    final results = <MapEntry<String, int>>[];
    for (final s in statuses) {
      Query<Map<String, dynamic>> q = db.collection('orders').where('status', isEqualTo: s);
      if (r != null) {
        q = q
            .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(r.start))
            .where('createdAt', isLessThanOrEqualTo: Timestamp.fromDate(r.end));
      }
      final snap = await q.get();
      results.add(MapEntry(s, snap.docs.length));
    }
    return results;
  }
}

class _FeedbackSummary extends StatelessWidget {
  final DateTimeRange? range;
  const _FeedbackSummary({required this.range});

  @override
  Widget build(BuildContext context) {
    final db = FirebaseFirestore.instance;
    Query<Map<String, dynamic>> q = db.collection('feedback');
    if (range != null) {
      q = q
          .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(range!.start))
          .where('createdAt', isLessThanOrEqualTo: Timestamp.fromDate(range!.end));
    }
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder<QuerySnapshot<Map<String, dynamic>>>(
          future: q.get(),
          builder: (context, snapshot) {
            final docs = snapshot.data?.docs ?? [];
            double avg = 0;
            if (docs.isNotEmpty) {
              avg = docs
                      .map((d) => (d.data()['rating'] ?? 0) as int)
                      .fold<int>(0, (a, b) => a + b) /
                  docs.length;
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Customer Feedback', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text('Average rating: ${avg.toStringAsFixed(1)}'),
                const SizedBox(height: 8),
                for (final d in docs.take(5)) Text('• ${d.data()['message'] ?? ''}')
              ],
            );
          },
        ),
      ),
    );
  }
}

class _SubscriptionsSummary extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final db = FirebaseFirestore.instance;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder<QuerySnapshot<Map<String, dynamic>>>(
          future: db.collection('subscriptions').get(),
          builder: (context, snapshot) {
            final docs = snapshot.data?.docs ?? [];
            final active = docs.where((d) => d.data()['status'] == 'ACTIVE').length;
            final cancelled = docs.where((d) => d.data()['status'] == 'CANCELLED').length;
            final expired = docs.where((d) => d.data()['status'] == 'EXPIRED').length;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Subscriptions Summary', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text('Active: $active'),
                Text('Cancelled: $cancelled'),
                Text('Expired: $expired'),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _DailyOrders extends StatelessWidget {
  final DateTimeRange? range;
  const _DailyOrders({required this.range});

  @override
  Widget build(BuildContext context) {
    final db = FirebaseFirestore.instance;
    final end = DateTime.now();
    final start = end.subtract(const Duration(days: 30));
    Query<Map<String, dynamic>> q = db.collection('orders').where('createdAt',
        isGreaterThanOrEqualTo: Timestamp.fromDate(range?.start ?? start));
    if (range != null) {
      q = q.where('createdAt', isLessThanOrEqualTo: Timestamp.fromDate(range!.end));
    }
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder<QuerySnapshot<Map<String, dynamic>>>(
          future: q.get(),
          builder: (context, snapshot) {
            final docs = snapshot.data?.docs ?? [];
            final Map<String, int> perDay = {};
            for (final d in docs) {
              final ts = d.data()['createdAt'] as Timestamp? ?? Timestamp.now();
              final key = ts.toDate().toString().substring(0, 10);
              perDay[key] = (perDay[key] ?? 0) + 1;
            }
            final keys = perDay.keys.toList()..sort();
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Daily Orders (last 30 days)', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                for (final k in keys) Text('$k: ${perDay[k]}')
              ],
            );
          },
        ),
      ),
    );
  }
}
