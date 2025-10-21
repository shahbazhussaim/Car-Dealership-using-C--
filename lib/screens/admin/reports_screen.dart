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
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: FutureBuilder<int>(
                future: _service.countOrdersByStatus(
                  _statusFilter == 'ALL' ? 'NEW' : _statusFilter,
                  start: _range?.start,
                  end: _range?.end,
                ),
                builder: (context, snapshot) {
                  final count = snapshot.data;
                  return Text('Orders count (${_statusFilter == 'ALL' ? 'NEW' : _statusFilter}): ${count ?? '...'}');
                },
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Additional cards for top products, low stock, feedback, subscriptions etc. (stubs)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: const Text('More detailed reports can be implemented here with Firestore queries.'),
            ),
          ),
        ],
      ),
    );
  }
}
