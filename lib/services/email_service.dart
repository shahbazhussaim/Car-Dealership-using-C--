import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:karigar_woodwork/config.dart';

class EmailService {
  static Future<String?> send({
    required String to,
    required String subject,
    required String html,
    String? text,
  }) async {
    if (kEmailFunctionUrl.isEmpty) {
      return 'EMAIL_FUNCTION_URL not configured';
    }
    try {
      final res = await http.post(
        Uri.parse(kEmailFunctionUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'to': to,
          'subject': subject,
          'html': html,
          'text': text ?? _stripHtml(html),
        }),
      );
      if (res.statusCode >= 200 && res.statusCode < 300) {
        return null;
      }
      return 'HTTP ${res.statusCode}: ${res.body}';
    } catch (e) {
      return e.toString();
    }
  }

  static String _stripHtml(String html) => html.replaceAll(RegExp(r'<[^>]*>'), '');
}

class EmailTemplates {
  static String orderConfirmed({required String orderId}) =>
      '<h2>Order Confirmed</h2><p>Your order <b>#$orderId</b> has been confirmed. We\'ll start processing it shortly.</p>';

  static String orderShipped({required String orderId}) =>
      '<h2>Order Shipped</h2><p>Your order <b>#$orderId</b> is on the way.</p>';

  static String subscriptionActivated({required String planName}) =>
      '<h2>Subscription Activated</h2><p>Your <b>$planName</b> subscription is now active.</p>';
}
