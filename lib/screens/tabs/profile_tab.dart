import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:karigar_woodwork/providers/auth_provider.dart';
import 'package:karigar_woodwork/screens/checkout/checkout_screen.dart';
import 'package:karigar_woodwork/providers/cart_provider.dart';

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final cart = context.watch<CartProvider>();
    if (auth.user == null) {
      return Center(
        child: ElevatedButton(
          onPressed: () => Navigator.of(context).pushNamed('/login'),
          child: const Text('Login / Register'),
        ),
      );
    }

    final profile = auth.profile;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(profile?['name'] ?? auth.user!.email ?? 'User',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text('Email: ${auth.user!.email}')
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        if (!cart.isEmpty)
          ElevatedButton.icon(
            onPressed: () => Navigator.of(context)
                .push(MaterialPageRoute(builder: (_) => const CheckoutScreen())),
            icon: const Icon(Icons.shopping_cart_checkout),
            label: Text('Checkout (${cart.totalItems} items)'),
          ),
        const SizedBox(height: 8),
        ElevatedButton(
          onPressed: auth.signOut,
          child: const Text('Sign out'),
        ),
      ],
    );
  }
}
