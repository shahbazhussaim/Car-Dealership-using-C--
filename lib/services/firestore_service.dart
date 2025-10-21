import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:karigar_woodwork/models/models.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Products
  Stream<List<Product>> watchProducts({String? category}) {
    Query<Map<String, dynamic>> q = _db.collection('products');
    if (category != null && category.isNotEmpty) {
      q = q.where('category', isEqualTo: category);
    }
    return q.orderBy('createdAt', descending: true).snapshots().map(
          (s) => s.docs.map(Product.fromDoc).toList(),
        );
  }

  Future<Product> getProduct(String id) async {
    final doc = await _db.collection('products').doc(id).get();
    return Product.fromDoc(doc);
  }

  Future<void> addOrUpdateProduct(Product p) async {
    final data = p.toMap();
    await _db.collection('products').doc(p.id).set(data, SetOptions(merge: true));
  }

  Future<void> updateStock(String productId, int delta) async {
    final ref = _db.collection('products').doc(productId);
    await _db.runTransaction((tx) async {
      final snap = await tx.get(ref);
      final current = (snap.data()?['stockCount'] ?? 0) as int;
      final next = current + delta;
      if (next < 0) {
        throw Exception('Stock would be negative');
      }
      tx.update(ref, {'stockCount': next});
    });
  }

  // Orders
  Stream<List<Order>> watchOrders({String? userId, String? status}) {
    Query<Map<String, dynamic>> q = _db.collection('orders');
    if (userId != null) q = q.where('userId', isEqualTo: userId);
    if (status != null) q = q.where('status', isEqualTo: status);
    return q.orderBy('createdAt', descending: true).snapshots().map(
          (s) => s.docs.map(Order.fromDoc).toList(),
        );
  }

  Future<String> createOrder(Order order) async {
    final ref = await _db.collection('orders').add(order.toMap());
    return ref.id;
  }

  Future<void> updateOrderStatus({
    required String orderId,
    required OrderStatus nextStatus,
    required String adminId,
    String? adminNotes,
    String? assignedTo,
  }) async {
    final ref = _db.collection('orders').doc(orderId);
    final statusStr = orderStatusToString(nextStatus);
    await _db.runTransaction((tx) async {
      final snap = await tx.get(ref);
      final d = snap.data() ?? {};
      final prevStatus = d['status'] as String? ?? 'NEW';
      // Append status change log
      final logRef = ref.collection('logs').doc();
      tx.set(logRef, {
        'from': prevStatus,
        'to': statusStr,
        'adminId': adminId,
        'adminNotes': adminNotes,
        'assignedTo': assignedTo,
        'timestamp': FieldValue.serverTimestamp(),
      });
      tx.update(ref, {
        'status': statusStr,
        'updatedAt': FieldValue.serverTimestamp(),
        if (adminNotes != null) 'adminNotes': adminNotes,
        if (assignedTo != null) 'assignedTo': assignedTo,
      });
    });
  }

  // Reports helpers (examples)
  Future<int> countOrdersByStatus(String status,
      {DateTime? start, DateTime? end}) async {
    Query<Map<String, dynamic>> q = _db.collection('orders').where('status', isEqualTo: status);
    if (start != null) q = q.where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(start));
    if (end != null) q = q.where('createdAt', isLessThanOrEqualTo: Timestamp.fromDate(end));
    final s = await q.get();
    return s.docs.length;
  }
}
