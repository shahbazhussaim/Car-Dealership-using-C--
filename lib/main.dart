import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:karigar_woodwork/services/firebase_service.dart';
import 'package:karigar_woodwork/app.dart';
import 'package:karigar_woodwork/providers/auth_provider.dart';
import 'package:karigar_woodwork/providers/cart_provider.dart';

Future<void> main() async {

  WidgetsFlutterBinding.ensureInitialized();

  final initState = await FirebaseService.initialize();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
      ],
      child: KarigarApp(initState: initState),
    ),
  );
}
