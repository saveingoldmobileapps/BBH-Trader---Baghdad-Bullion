// import 'package:flutter_dotenv/flutter_dotenv.dart';
// import 'package:hyperpay_sdk/hyperpay_sdk.dart';

// /// OPPWA / HyperPay settings from `.env` (see [HYPERPAY_*] keys).
// abstract final class HyperPayEnvConfig {
//   static String get accessToken =>
//       dotenv.env['HYPERPAY_ACCESS_TOKEN']?.trim() ?? '';

//   static String get entityId =>
//       dotenv.env['HYPERPAY_ENTITY_ID']?.trim() ?? '';

//   static String get apiBaseUrl {
//     final v = dotenv.env['HYPERPAY_API_BASE']?.trim();
//     if (v != null && v.isNotEmpty) return v;
//     return 'https://eu-test.oppwa.com';
//   }

//   static String get currency {
//     final v = dotenv.env['HYPERPAY_CURRENCY']?.trim();
//     if (v != null && v.isNotEmpty) return v;
//     return 'IQD';
//   }

//   /// Base scheme only (no `://result`). Must match Android intent + iOS URL type.
//   static String get shopperResultUrl {
//     final v = dotenv.env['HYPERPAY_SHOPPER_RESULT_URL']?.trim();
//     if (v != null && v.isNotEmpty) return v;
//     return 'com.saveingold.hyperpay.payment';
//   }

//   static PaymentMode get paymentMode {
//     final m = (dotenv.env['HYPERPAY_MODE'] ?? 'test').toLowerCase();
//     return m == 'live' ? PaymentMode.live : PaymentMode.test;
//   }

//   static bool get isConfigured =>
//       accessToken.isNotEmpty && entityId.isNotEmpty;
// }
