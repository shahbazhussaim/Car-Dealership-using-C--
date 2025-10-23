import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:karigar_woodwork/models/models.dart' as model;

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // -------------------- PRODUCTS --------------------
  Stream<List<model.Product>> watchProducts({String? category, bool includeDeleted = false}) {
    Query<Map<String, dynamic>> q = _db.collection('products');
    if (category != null && category.isNotEmpty) {
      q = q.where('category', isEqualTo: category);
    }
    if (!includeDeleted) {
      q = q.where('deleted', isNull: true);
    }

    return q.orderBy('createdAt', descending: true).snapshots().map(
          (s) => s.docs.map((d) => model.Product.fromDoc(d)).toList(),
    );
  }

  Future<void> addOrUpdateProduct(model.Product p) async {
    await _db.collection('products').doc(p.id).set(p.toMap(), SetOptions(merge: true));
  }

  Future<model.Product> getProduct(String id) async {
    final doc = await _db.collection('products').doc(id).get();
    return model.Product.fromDoc(doc);
  }

  Future<String> createProduct(Map<String, dynamic> data) async {
    final ref = await _db.collection('products').add(data);
    return ref.id;
  }

  Future<void> softDeleteProduct(String productId) async {
    await _db.collection('products').doc(productId).set({'deleted': true}, SetOptions(merge: true));
  }

  Future<void> updateStock(String productId, int delta) async {
    final ref = _db.collection('products').doc(productId);
    await _db.runTransaction((tx) async {
      final snap = await tx.get(ref);
      final current = (snap.data()?['stockCount'] ?? 0) as int;
      final next = current + delta;
      if (next < 0) throw Exception('Stock would be negative');
      tx.update(ref, {'stockCount': next});
    });
  }

  // -------------------- CATEGORIES --------------------
  Stream<List<model.Category>> watchCategories() {
    return _db
        .collection('categories')
        .orderBy('name')
        .snapshots()
        .map((s) => s.docs.map((d) => model.Category.fromDoc(d)).toList());
  }

  Future<void> addOrUpdateCategory(model.Category c) async {
    await _db.collection('categories').doc(c.id).set(c.toMap(), SetOptions(merge: true));
  }

  // -------------------- ORDERS --------------------
  Stream<List<model.Order>> watchOrders({String? userId, String? status}) {
    Query<Map<String, dynamic>> q = _db.collection('orders');
    if (userId != null) q = q.where('userId', isEqualTo: userId);
    if (status != null) q = q.where('status', isEqualTo: status);

    return q.orderBy('createdAt', descending: true).snapshots().map(
          (s) => s.docs.map((d) => model.Order.fromDoc(d)).toList(),
    );
  }

  Future<String> createOrder(model.Order order) async {
    final ref = await _db.collection('orders').add(order.toMap());
    return ref.id;
  }

  Future<void> confirmOrderAndDecrementStock({
    required String orderId,
    required String adminId,
    String? adminNotes,
  }) async {
    final orderRef = _db.collection('orders').doc(orderId);
    await _db.runTransaction((tx) async {
      final orderSnap = await tx.get(orderRef);
      final data = orderSnap.data() ?? {};
      if ((data['status'] as String?) == 'CONFIRMED') return;

      final items = (data['items'] as List<dynamic>? ?? [])
          .map((e) => Map<String, dynamic>.from(e))
          .toList();

      // Validate stock
      for (final item in items) {
        final productId = item['productId'] as String? ?? '';
        final qty = (item['qty'] ?? 0) as int;
        final prodRef = _db.collection('products').doc(productId);
        final prodSnap = await tx.get(prodRef);
        final current = (prodSnap.data()?['stockCount'] ?? 0) as int;
        if (current - qty < 0) throw Exception('Low stock for product $productId');
      }

      // Deduct stock
      for (final item in items) {
        final productId = item['productId'] as String? ?? '';
        final qty = (item['qty'] ?? 0) as int;
        final prodRef = _db.collection('products').doc(productId);
        final prodSnap = await tx.get(prodRef);
        final current = (prodSnap.data()?['stockCount'] ?? 0) as int;
        tx.update(prodRef, {'stockCount': current - qty});
      }

      // Log + update
      final logRef = orderRef.collection('logs').doc();
      tx.set(logRef, {
        'from': data['status'] ?? 'NEW',
        'to': 'CONFIRMED',
        'adminId': adminId,
        'adminNotes': adminNotes,
        'timestamp': FieldValue.serverTimestamp(),
      });

      tx.update(orderRef, {
        'status': 'CONFIRMED',
        'updatedAt': FieldValue.serverTimestamp(),
        if (adminNotes != null) 'adminNotes': adminNotes,
      });
    });
  }

  Future<void> updateOrderStatus({
    required String orderId,
    required model.OrderStatus nextStatus,
    required String adminId,
    String? adminNotes,
    String? assignedTo,
  }) async {
    final ref = _db.collection('orders').doc(orderId);
    final statusStr = model.orderStatusToString(nextStatus);

    await _db.runTransaction((tx) async {
      final snap = await tx.get(ref);
      final d = snap.data() ?? {};
      final prevStatus = d['status'] as String? ?? 'NEW';

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

  Future<void> assignTechnician({
    required String orderId,
    required String adminId,
    required String technicianId,
  }) async {
    final ref = _db.collection('orders').doc(orderId);
    await _db.runTransaction((tx) async {
      final logRef = ref.collection('logs').doc();
      tx.set(logRef, {
        'from': 'ASSIGNMENT',
        'to': 'ASSIGNMENT',
        'adminId': adminId,
        'assignedTo': technicianId,
        'timestamp': FieldValue.serverTimestamp(),
      });
      tx.update(ref, {
        'assignedTo': technicianId,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });
  }

  // -------------------- SERVICES --------------------
  Stream<List<model.ServiceItem>> watchServices() {
    return _db
        .collection('services')
        .orderBy('name')
        .snapshots()
        .map((s) => s.docs.map((d) => model.ServiceItem.fromDoc(d)).toList());
  }

  Future<void> addOrUpdateService(model.ServiceItem s) async {
    await _db.collection('services').doc(s.id).set(s.toMap(), SetOptions(merge: true));
  }

  // -------------------- PLANS --------------------
  Stream<List<model.Plan>> watchPlans() {
    return _db
        .collection('plans')
        .orderBy('priceMonthly')
        .snapshots()
        .map((s) => s.docs.map((d) => model.Plan.fromDoc(d)).toList());
  }

  Future<void> addOrUpdatePlan(model.Plan p) async {
    await _db.collection('plans').doc(p.id).set(p.toMap(), SetOptions(merge: true));
  }

  // -------------------- REPORTS --------------------
  Future<int> countOrdersByStatus(String status, {DateTime? start, DateTime? end}) async {
    Query<Map<String, dynamic>> q = _db.collection('orders').where('status', isEqualTo: status);
    if (start != null) q = q.where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(start));
    if (end != null) q = q.where('createdAt', isLessThanOrEqualTo: Timestamp.fromDate(end));
    final s = await q.get();
    return s.docs.length;
  }

  // -------------------- FEEDBACK --------------------
  Stream<QuerySnapshot<Map<String, dynamic>>> watchFeedback({DateTime? start, DateTime? end}) {
    Query<Map<String, dynamic>> q = _db.collection('feedback');
    if (start != null) q = q.where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(start));
    if (end != null) q = q.where('createdAt', isLessThanOrEqualTo: Timestamp.fromDate(end));
    return q.orderBy('createdAt', descending: true).snapshots();
  }

  // -------------------- TECHNICIANS --------------------
  Stream<List<Map<String, dynamic>>> watchTechnicians() {
    return _db.collection('technicians').orderBy('name').snapshots().map(
          (s) => s.docs.map((d) {
        final m = d.data();
        m['id'] = d.id;
        return m;
      }).toList(),
    );
  }
}
