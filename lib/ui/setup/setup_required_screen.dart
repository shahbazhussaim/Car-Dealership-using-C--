import 'package:flutter/material.dart';

class SetupRequiredScreen extends StatelessWidget {
  const SetupRequiredScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Setup Required')),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Text(
            'Firebase is not configured yet.\n\n'
            'Please follow the README to run FlutterFire CLI and replace lib/firebase_options.dart.'
            '\nAfter that, restart the app.',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
