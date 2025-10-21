import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:karigar_woodwork/services/firestore_service.dart';
import 'package:karigar_woodwork/models/models.dart';
import 'package:karigar_woodwork/providers/auth_provider.dart';
import 'package:karigar_woodwork/providers/subscription_provider.dart';

class SubscriptionsScreen extends StatelessWidget {
  const SubscriptionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('Subscriptions')),
      body: auth.user == null
          ? Center(
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pushNamed('/login'),
                child: const Text('Login to manage subscription'),
              ),
            )
          : _SubscriptionsBody(userId: auth.user!.uid),
    );
  }
}

class _SubscriptionsBody extends StatefulWidget {
  final String userId;
  const _SubscriptionsBody({required this.userId});

  @override
  State<_SubscriptionsBody> createState() => _SubscriptionsBodyState();
}

class _SubscriptionsBodyState extends State<_SubscriptionsBody> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SubscriptionProvider>().load(widget.userId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final service = FirestoreService();
    final subProv = context.watch<SubscriptionProvider>();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: StreamBuilder<List<Plan>>(
            stream: service.watchPlans(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
              final plans = snapshot.data!;
              if (plans.isEmpty) return const Center(child: Text('No plans'));
              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      for (final p in plans)
                        SizedBox(
                          width: 320,
                          child: Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(p.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 4),
                                  Text('₹${p.priceMonthly.toStringAsFixed(2)}/mo • ₹${p.priceYearly.toStringAsFixed(2)}/yr'),
                                  const SizedBox(height: 8),
                                  for (final b in p.benefits) Text('• $b'),
                                  const SizedBox(height: 12),
                                  ElevatedButton(
                                    onPressed: () async {
                                      final auth = context.read<AuthProvider>();
                                      if (auth.user == null) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(content: Text('Login first')));
                                        return;
                                      }
                                      await subProv.subscribe(userId: auth.user!.uid, plan: p);
                                      if (!mounted) return;
                                      ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text('Subscribed to ${p.name}')));
                                    },
                                    child: const Text('Subscribe'),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                    ],
                  )
                ],
              );
            },
          ),
        ),
        SizedBox(
          width: 360,
          child: Card(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Your Subscription', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  if (subProv.subscription == null)
                    const Text('No active subscription')
                  else ...[
                    Text('Status: ${subStatusToString(subProv.subscription!.status)}'),
                    const SizedBox(height: 6),
                    Text('Plan: ${subProv.subscription!.planId}'),
                    const SizedBox(height: 6),
                    Wrap(
                      children: [for (final b in subProv.subscription!.benefits) Padding(
                        padding: const EdgeInsets.only(right: 8.0, bottom: 4.0),
                        child: Chip(label: Text(b)),
                      )],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        ElevatedButton(
                          onPressed: () async {
                            await subProv.cancel(subId: subProv.subscription!.id);
                            if (!mounted) return;
                            ScaffoldMessenger.of(context)
                                .showSnackBar(const SnackBar(content: Text('Subscription cancelled')));
                          },
                          child: const Text('Cancel'),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () async {
                            // Upgrade to the first plan for demo
                            final plans = await service.watchPlans().first;
                            if (plans.isNotEmpty) {
                              await subProv.upgrade(subId: subProv.subscription!.id, plan: plans.first);
                              if (!mounted) return;
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(const SnackBar(content: Text('Plan updated')));
                            }
                          },
                          child: const Text('Change Plan'),
                        ),
                      ],
                    )
                  ]
                ],
              ),
            ),
          ),
        )
      ],
    );
  }
}
