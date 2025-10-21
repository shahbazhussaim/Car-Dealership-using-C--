import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:karigar_woodwork/config.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:karigar_woodwork/models/models.dart';

class EmailService {
  // Generic send with template support and one retry on network error
  static Future<String?> sendWithTemplate({
    required String to,
    required String template,
    Map<String, dynamic>? vars,
    String? subject,
  }) async {
    if (kEmailFunctionUrl.isEmpty) return 'EMAIL_FUNCTION_URL not configured';
    Future<String?> _do() async {
      final res = await http.post(
        Uri.parse(kEmailFunctionUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'to': to,
          'template': template,
          'vars': vars ?? <String, dynamic>{},
          if (subject != null) 'subject': subject,
        }),
      );
      if (res.statusCode >= 200 && res.statusCode < 300) return null;
      return 'HTTP ${res.statusCode}: ${res.body}';
    }
    try {
      final first = await _do();
      if (first == null) return null;
      // Retry once on failure
      return await _do();
    } catch (e) {
      return e.toString();
    }
  }

  static Future<String?> sendOrderStatusChange({
    required Order order,
    required String oldStatus,
    required String newStatus,
    String? userEmail,
  }) async {
    final email = userEmail ?? await getUserEmail(order.userId);
    if (email == null || email.isEmpty) return 'User email not found';
    final template = _templateForOrderStatus(newStatus);
    final items = order.items
        .map((e) => '${e.name} x${e.qty}')
        .take(5)
        .join(', ');
    final vars = {
      'orderId': order.id,
      'oldStatus': oldStatus,
      'newStatus': newStatus,
      'items': items,
      'total': order.total,
      'adminNotes': order.adminNotes ?? '',
    };
    return sendWithTemplate(
      to: email,
      template: template,
      vars: vars,
      subject: 'Order #${order.id} ${newStatus.replaceAll('_', ' ')}',
    );
  }

  static Future<String?> sendSubscriptionChange({
    required Subscription subscription,
    required String oldStatus,
    required String newStatus,
    String? userEmail,
    Plan? plan,
  }) async {
    final email = userEmail ?? await getUserEmail(subscription.userId);
    if (email == null || email.isEmpty) return 'User email not found';
    final template = _templateForSubscriptionStatus(newStatus);
    final vars = {
      'planId': subscription.planId,
      'oldStatus': oldStatus,
      'newStatus': newStatus,
      'nextBillingDate': subscription.nextBillingDate.toDate().toIso8601String(),
      'benefits': plan?.benefits ?? subscription.benefits,
    };
    return sendWithTemplate(
      to: email,
      template: template,
      vars: vars,
      subject: 'Subscription ${newStatus.replaceAll('_', ' ')}',
    );
  }

  static Future<String?> sendTechnicianAssigned({
    required String technicianEmail,
    required String orderId,
  }) {
    return sendWithTemplate(
      to: technicianEmail,
      template: 'technician_assigned',
      vars: {'orderId': orderId},
      subject: 'Assigned to Order #$orderId',
    );
  }

  static Future<String?> getUserEmail(String uid) async {
    final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    return (doc.data()?['email'] as String?) ?? '';
  }

  static String _templateForOrderStatus(String status) {
    switch (status) {
      case 'CONFIRMED':
        return 'order_confirmed';
      case 'IN_PROGRESS':
        return 'order_in_progress';
      case 'AWAITING_SHIPMENT':
        return 'order_shipped';
      case 'DELIVERED':
      case 'COMPLETED':
        return 'order_completed';
      case 'CANCELLED':
        return 'order_cancelled';
      case 'RETURN_REQUESTED':
        return 'order_return_requested';
      case 'RETURNED':
        return 'order_returned';
      case 'NEW':
      default:
        return 'order_new';
    }
  }

  static String _templateForSubscriptionStatus(String status) {
    switch (status) {
      case 'TRIAL':
        return 'subscription_trial_started';
      case 'ACTIVE':
        return 'subscription_activated';
      case 'PAST_DUE':
        return 'subscription_past_due';
      case 'CANCELLED':
        return 'subscription_cancelled';
      case 'EXPIRED':
        return 'subscription_expired';
      default:
        return 'subscription_update';
    }
  }
}
