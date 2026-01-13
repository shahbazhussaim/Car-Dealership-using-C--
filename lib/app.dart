import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:karigar_woodwork/theme.dart';
import 'package:karigar_woodwork/services/firebase_service.dart';
import 'package:karigar_woodwork/screens/setup_required_screen.dart';
import 'package:karigar_woodwork/screens/shell/main_shell.dart';
import 'package:karigar_woodwork/screens/splash_screen.dart';
import 'package:karigar_woodwork/providers/auth_provider.dart';
import 'package:karigar_woodwork/screens/auth/login_screen.dart';

class KarigarApp extends StatelessWidget {
  final AppInitState initState;
  const KarigarApp({super.key, required this.initState});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Karigar Woodwork',
      theme: AppTheme.lightTheme,
      home: _homeForState(initState),
      routes: {
        '/login': (_) => const LoginScreen(),
      },
    );
  }

  Widget _homeForState(AppInitState state) {
    switch (state) {
      case AppInitState.configured:
        return const AppBootstrap();
      case AppInitState.setupRequired:
      default:
        return const SetupRequiredScreen();
    }
  }
}

class AppBootstrap extends StatefulWidget {
  const AppBootstrap({super.key});

  @override
  State<AppBootstrap> createState() => _AppBootstrapState();
}

class _AppBootstrapState extends State<AppBootstrap> {
  @override
  void initState() {
    super.initState();
    // Attempt to restore session and load user profile.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthProvider>().initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    if (auth.isInitializing) {
      return const SplashScreen();
    }

    // Show main shell regardless of auth; Profile tab will prompt login.
    return const MainShell();
  }
}
