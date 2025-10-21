import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:karigar_woodwork/providers/auth_provider.dart';
import 'package:karigar_woodwork/screens/tabs/home_tab.dart';
import 'package:karigar_woodwork/screens/tabs/shop_tab.dart';
import 'package:karigar_woodwork/screens/tabs/services_tab.dart';
import 'package:karigar_woodwork/screens/tabs/subscriptions_tab.dart';
import 'package:karigar_woodwork/screens/tabs/profile_tab.dart';
import 'package:karigar_woodwork/screens/admin/admin_dashboard_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final isAdmin = context.select<AuthProvider, bool>((a) => a.isAdmin);

    final tabs = [
      const HomeTab(),
      const ShopTab(),
      const ServicesTab(),
      const SubscriptionsTab(),
      const ProfileTab(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Karigar Woodwork'),
        actions: [
          if (isAdmin)
            IconButton(
              tooltip: 'Admin Dashboard',
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const AdminDashboardScreen()),
                );
              },
              icon: const Icon(Icons.admin_panel_settings),
            )
        ],
      ),
      body: tabs[_index],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.chair), label: 'Shop'),
          BottomNavigationBarItem(icon: Icon(Icons.home_repair_service), label: 'Services'),
          BottomNavigationBarItem(icon: Icon(Icons.subscriptions), label: 'Subscriptions'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
