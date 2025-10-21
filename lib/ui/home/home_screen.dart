import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Karigar Woodwork')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          Text('Welcome to Karigar Woodwork', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          SizedBox(height: 12),
          Text('Discover handcrafted furniture, custom orders, and maintenance services.'),
        ],
      ),
    );
  }
}
