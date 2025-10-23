import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:karigar_woodwork/config.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:karigar_woodwork/models/models.dart' as model;

class EmailService {
  /// Generic send with template support and one retry on network error
  static Future<String?> sendWithTemplate({
    required String to,
    required String template,
    Map<String, dynamic>? vars,
    String? subject,
  }) async {
    if (kEmailFunctionUrl.isEmpty) {
      return 'EMAIL_FUNCTION_URL not configured';
    }

    // Helper function for sending request
    Future<String?> _send() async {
      try {
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
      } catch (e) {
        return e.toString();
      }
    }

    // Try first time
    final firstAttempt = await _send();
    if (firstAttempt == null) return null;

    // Retry once if failed
    final secondAttempt = await _send();
    return secondAttempt;
  }

  /// Send order status change email
  static Future<String?> sendOrderStatusChange({
    required model.Order order,
    required String oldStatus,
    required String newStatus,
    String? userEmail,
  }) async {
    final email = userEmail ?? await getUserEmail(order.userId);
    if (email == null || email.isEmpty) return 'User email not found';

    final template = _templateForOrderStatus(newStatus);
    final items = order.items.map((e) => '${e.name} x${e.qty}').take(5).join(', ');

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

  /// Send subscription status change email
  static Future<String?> sendSubscriptionChange({
    required model.Subscription subscription,
    required String oldStatus,
    required String newStatus,
    String? userEmail,
    model.Plan? plan,
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

  /// Send technician assignment email
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

  /// Helper to get user email from Firestore
  static Future<String?> getUserEmail(String uid) async {
    final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    return (doc.data()?['email'] as String?) ?? '';
  }

  /// Template for order status
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

  /// Template for subscription status
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
