import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:karigar_woodwork/services/firebase_service.dart';
import 'package:karigar_woodwork/app.dart';
import 'package:karigar_woodwork/providers/auth_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final initState = await FirebaseService.initialize();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: KarigarApp(initState: initState),
    ),
  );
}
