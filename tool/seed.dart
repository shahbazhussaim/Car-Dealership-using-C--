// Simple seed script (run with dart run tool/seed.dart) after configuring Firebase in app context.
// For production, prefer a secure admin path or Cloud Functions.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:karigar_woodwork/firebase_options.dart';

Future<void> main() async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  final db = FirebaseFirestore.instance;

  final categories = [
    {'name': 'Chairs', 'description': 'Comfortable wooden chairs'},
    {'name': 'Tables', 'description': 'Dining and coffee tables'},
    {'name': 'Cabinets', 'description': 'Storage cabinets'},
  ];
  for (final c in categories) {
    await db.collection('categories').add(c);
  }

  final now = Timestamp.now();
  final products = [
    {
      'name': 'Oak Dining Table',
      'category': 'Tables',
      'description': 'Elegant oak table',
      'price': 29999.0,
      'stockCount': 5,
      'imageUrl': '',
      'createdAt': now,
      'sku': 'TAB-OAK-001'
    },
    {
      'name': 'Walnut Chair',
      'category': 'Chairs',
      'description': 'Sturdy walnut chair',
      'price': 6999.0,
      'stockCount': 12,
      'imageUrl': '',
      'createdAt': now,
      'sku': 'CHR-WAL-002'
    }
  ];
  for (final p in products) {
    await db.collection('products').add(p);
  }

  print('Seed complete');
}
