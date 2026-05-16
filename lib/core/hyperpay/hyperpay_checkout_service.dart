import 'dart:convert';

import 'package:http/http.dart' as http;

import 'hyperpay_env_config.dart';

/// Creates OPPWA checkouts and reads payment status (REST).
abstract final class HyperPayCheckoutService {
  static Uri _checkoutCreateUri() =>
      Uri.parse('${HyperPayEnvConfig.apiBaseUrl}/v1/checkouts');

  static Uri _checkoutPaymentUri(String checkoutId) => Uri.parse(
        '${HyperPayEnvConfig.apiBaseUrl}/v1/checkouts/$checkoutId/payment',
      ).replace(queryParameters: {'entityId': HyperPayEnvConfig.entityId});

  static Map<String, dynamic> _decodeBody(String body) {
    final decoded = json.decode(body);
    if (decoded is Map<String, dynamic>) return decoded;
    if (decoded is Map) return Map<String, dynamic>.from(decoded);
    throw FormatException('Unexpected JSON: $body');
  }

  /// Registers a checkout session and returns the checkout id for the mobile SDK.
  ///
  /// Do not send `shopperResultUrl` on create: the SDK sets the return URL for Ready UI.
  static Future<String> createCheckoutId({
    required String amount,
    String? currency,
  }) async {
    final response = await http.post(
      _checkoutCreateUri(),
      headers: {
        'Authorization': 'Bearer ${HyperPayEnvConfig.accessToken}',
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: <String, String>{
        'entityId': HyperPayEnvConfig.entityId,
        'amount': amount,
        'currency': currency ?? HyperPayEnvConfig.currency,
        'paymentType': 'DB',
        'merchantTransactionId': 'mtr-${DateTime.now().millisecondsSinceEpoch}',
      },
    );

    final data = _decodeBody(response.body);
    final id = data['id'] as String?;
    if (id != null && id.isNotEmpty) return id;

    final result = data['result'];
    final desc = result is Map ? result['description'] : null;
    final code = result is Map ? result['code'] : null;
    throw Exception(
      'No checkout id (HTTP ${response.statusCode}): $code $desc — ${response.body}',
    );
  }

  static String _paymentStatusLine(Map<String, dynamic> data) {
    final result = data['result'];
    if (result is Map) {
      final code = result['code']?.toString() ?? '';
      final desc = result['description']?.toString() ?? '';
      if (code.isEmpty && desc.isEmpty) return data.toString();
      return '$code — $desc'.trim();
    }
    return result?.toString() ?? data.toString();
  }

  static Future<String> fetchPaymentStatusLine(String checkoutId) async {
    final response = await http.get(
      _checkoutPaymentUri(checkoutId),
      headers: {
        'Authorization': 'Bearer ${HyperPayEnvConfig.accessToken}',
      },
    );
    final data = _decodeBody(response.body);
    return _paymentStatusLine(data);
  }
}
