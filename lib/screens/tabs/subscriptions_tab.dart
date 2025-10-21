import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:karigar_woodwork/screens/subscriptions/subscriptions_screen.dart';
import 'package:karigar_woodwork/providers/subscription_provider.dart';

class SubscriptionsTab extends StatelessWidget {
  const SubscriptionsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SubscriptionProvider(),
      child: const SubscriptionsScreen(),
    );
  }
}
