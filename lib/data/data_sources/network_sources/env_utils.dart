import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class EnvUtils {
  static bool _isInitialized = false;
  static String? _baseUrl;

  /// Initializes the .env file. Must be called before accessing the base URL.
  static Future<void> init() async {
    if (!_isInitialized) {
      await dotenv.load(fileName: ".env");
      final environment = dotenv.env['ENVIRONMENT'] ?? 'staging';
      final baseUrlStaging = dotenv.env['BASE_URL_STAGING'] ?? '';
      final baseUrlProduction = dotenv.env['BASE_URL_PRODUCTION'] ?? '';

      _baseUrl = environment == 'production' ? baseUrlProduction : baseUrlStaging;

      if (_baseUrl!.isEmpty) {
        throw Exception(
          'Base URL is not defined for environment: $environment',
        );
      }

      if (kDebugMode) {
        debugPrint(
          'Environment: $environment | Base URL: $_baseUrl',
        );
      }

      _isInitialized = true;
    }
  }

  /// Retrieves the base URL. Throws an exception if not initialized.
  static String getBaseUrl() {
    if (!_isInitialized || _baseUrl == null) {
      throw Exception(
        'EnvUtils is not initialized. Call EnvUtils.init() first.',
      );
    }
    return _baseUrl!;
  }
}
