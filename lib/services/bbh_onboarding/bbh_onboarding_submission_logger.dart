import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

/// Logs the final KYC submission JSON once per submit (debug only).
class BbhOnboardingSubmissionLogger {
  BbhOnboardingSubmissionLogger._();

  static String? lastSavedFilePath;
  static String? _lastLoggedJson;
  static DateTime? _lastLoggedAt;

  static const _base64Keys = {
    'base64',
    'signatureImage',
    'imageBase64',
    'sourceImageBase64',
    'targetImageBase64',
    'faceImage',
    'Portrait',
    'Ghost portrait',
    'documentFrontSide',
    'documentBackSide',
    'documentFrontSideRaw',
    'documentBackSideRaw',
    'Signature',
  };

  /// One indented JSON block per submit. Full payload saved to disk.
  static void logFinalSubmissionOnce(Map<String, dynamic> payload) {
    if (!kDebugMode) return;

    const encoder = JsonEncoder.withIndent('  ');
    String fullJson;
    try {
      fullJson = encoder.convert(payload);
    } catch (_) {
      fullJson = payload.toString();
    }

    final now = DateTime.now();
    if (_lastLoggedJson == fullJson &&
        _lastLoggedAt != null &&
        now.difference(_lastLoggedAt!) < const Duration(seconds: 5)) {
      return;
    }
    _lastLoggedJson = fullJson;
    _lastLoggedAt = now;

    unawaited(_saveFullJsonFile(fullJson));

    final consolePayload = _shortenHeavyFields(payload);
    final consoleJson = encoder.convert(consolePayload);

    developer.log(
      '========== BBH_KYC_FINAL_JSON ==========\n'
      '$consoleJson\n'
      '========== END BBH_KYC_FINAL_JSON ==========\n'
      'NOTE: Console JSON is valid — large base64 fields shortened for readability.\n'
      'Full payload with ALL base64 saved to: ${lastSavedFilePath ?? '(saving...)'}',
      name: 'BBH_KYC_FINAL_JSON',
    );
  }
  

  static Future<void> _saveFullJsonFile(String fullJson) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final stamp = DateTime.now().toIso8601String().replaceAll(':', '-');
      final file = File('${dir.path}/BBH_KYC_FINAL-$stamp.json');
      await file.writeAsString(fullJson);
      lastSavedFilePath = file.path;
    } catch (e) {
      developer.log('BBH_KYC_FINAL_FILE_ERROR: $e', name: 'BBH_KYC_FINAL_JSON');
    }
  }

  static Map<String, dynamic> _shortenHeavyFields(Map<String, dynamic> source) {
    return _walk(source) as Map<String, dynamic>;
  }

  static dynamic _walk(dynamic value) {
    if (value is Map) {
      return {
        for (final entry in value.entries)
          entry.key: _walkValue(entry.key.toString(), entry.value),
      };
    }
    if (value is List) {
      return value.map(_walk).toList();
    }
    return value;
  }

  static dynamic _walkValue(String key, dynamic value) {
    if (value is String && _shouldShorten(key, value)) {
      return '<base64 retained: ${value.length} chars>';
    }
    return _walk(value);
  }

  static bool _shouldShorten(String key, String value) {
    if (value.length <= 120) return false;
    if (_base64Keys.contains(key)) return true;
    if (key.toLowerCase().contains('base64')) return true;
    if (key.toLowerCase().contains('image')) return true;
    if (value.startsWith('/9j/') ||
        value.startsWith('iVBORw0KGgo') ||
        value.startsWith('data:image')) {
      return true;
    }
    return false;
  }
}
