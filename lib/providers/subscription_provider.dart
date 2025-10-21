import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:karigar_woodwork/models/models.dart';

class SubscriptionProvider extends ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Subscription? _subscription;
  Subscription? get subscription => _subscription;

  Stream<Subscription?> watchUserSubscription(String userId) {
    return _db
        .collection('subscriptions')
        .where('userId', isEqualTo: userId)
        .limit(1)
        .snapshots()
        .map((s) => s.docs.isEmpty ? null : Subscription.fromDoc(s.docs.first));
  }

  Future<void> load(String userId) async {
    final s = await _db
        .collection('subscriptions')
        .where('userId', isEqualTo: userId)
        .limit(1)
        .get();
    _subscription = s.docs.isEmpty ? null : Subscription.fromDoc(s.docs.first);
    notifyListeners();
  }

  Future<void> subscribe({required String userId, required Plan plan}) async {
    final now = Timestamp.now();
    final next = Timestamp.fromDate(now.toDate().add(Duration(days: 30)));
    await _db.collection('subscriptions').add({
      'userId': userId,
      'planId': plan.id,
      'startDate': now,
      'nextBillingDate': next,
      'status': 'ACTIVE',
      'benefits': plan.benefits,
    });
  }

  Future<void> cancel({required String subId}) async {
    await _db.collection('subscriptions').doc(subId).update({'status': 'CANCELLED'});
  }

  Future<void> upgrade({required String subId, required Plan plan}) async {
    await _db.collection('subscriptions').doc(subId).update({'planId': plan.id, 'benefits': plan.benefits});
  }
}
