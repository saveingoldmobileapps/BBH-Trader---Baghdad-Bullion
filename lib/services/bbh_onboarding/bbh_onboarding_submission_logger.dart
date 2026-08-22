import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io';

import 'package:baghdad_bullion_house/data/data_sources/network_sources/api_url.dart';
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

  /// Logs image summary + full JSON for Postman (exact body sent to API).
  static Future<void> logFinalSubmissionOnce(Map<String, dynamic> payload) async {
    if (!kDebugMode) return;

    try {
      _logImageSummary(payload);
    } catch (_) {}

    try {
      _logCopyableFormSections(payload);
    } catch (_) {}

    await logPostmanCopyablePayload(payload);
  }

  /// Compact form JSON (no iPass/images) — easy to copy from console and check names.
  static void _logCopyableFormSections(Map<String, dynamic> payload) {
    Map<String, dynamic>? asMap(dynamic value) {
      if (value is Map<String, dynamic>) return value;
      if (value is Map) return Map<String, dynamic>.from(value);
      return null;
    }

    final signature = asMap(payload['signature']);
    final signatureForCheck = signature == null
        ? null
        : {
            'signerName': signature['signerName'],
            'signatureImage':
                (signature['signatureImage']?.toString().trim().isNotEmpty ??
                        false)
                    ? '(present)'
                    : '',
          };

    final checkPayload = <String, dynamic>{
      if (payload['submissionMeta'] != null)
        'submissionMeta': payload['submissionMeta'],
      if (payload['nationalIdDetails'] != null)
        'nationalIdDetails': payload['nationalIdDetails'],
      if (payload['passportDetails'] != null)
        'passportDetails': payload['passportDetails'],
      if (payload['residencyDetails'] != null)
        'residencyDetails': payload['residencyDetails'],
      if (payload['contactInformation'] != null)
        'contactInformation': payload['contactInformation'],
      if (signatureForCheck != null) 'signature': signatureForCheck,
    };

    const encoder = JsonEncoder.withIndent('  ');
    final json = encoder.convert(checkPayload);

    debugPrint('');
    debugPrint('========== BBH_KYC_CHECK_JSON (copy this) ==========');
    debugPrint(json);
    debugPrint('========== END BBH_KYC_CHECK_JSON ==========');
    debugPrint('');

    developer.log(json, name: 'BBH_KYC_CHECK_JSON');
  }

  /// Prints the exact submit JSON — copy from logcat / Flutter console into Postman.
  static Future<void> logPostmanCopyablePayload(
    Map<String, dynamic> payload,
  ) async {
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

    await _saveFullJsonFile(fullJson);

    final apiUrl = ApiEndpoints.registerIpassApiUrl;
    final sizeKb = (fullJson.length / 1024).toStringAsFixed(1);

    debugPrint('');
    debugPrint('========== BBH_KYC_POSTMAN (copy to Postman) ==========');
    debugPrint('POST $apiUrl');
    debugPrint('Header: Content-Type: application/json');
    debugPrint('Body size: $sizeKb KB (${fullJson.length} chars)');
    debugPrint('Saved on device: ${lastSavedFilePath ?? "(unknown)"}');
    debugPrint('--- JSON BODY START ---');

    // Logcat truncates long lines — emit in chunks for copy/paste.
    const chunkSize = 3500;
    for (var i = 0; i < fullJson.length; i += chunkSize) {
      final end = i + chunkSize < fullJson.length ? i + chunkSize : fullJson.length;
      debugPrint(fullJson.substring(i, end));
    }

    debugPrint('--- JSON BODY END ---');
    debugPrint('========== END BBH_KYC_POSTMAN ==========');
    debugPrint('');

    developer.log(
      'POST $apiUrl | ${fullJson.length} chars | file: ${lastSavedFilePath ?? "(saving…)"}',
      name: 'BBH_KYC_POSTMAN',
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

  static bool _shouldShorten(String key, String value) {
    if (key == 'imageUrl' || key.endsWith('Url')) return false;
    if (value.startsWith('http://') || value.startsWith('https://')) return false;
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

  /// Logs every image entry in the final submit payload (URLs vs base64).
  static void _logImageSummary(Map<String, dynamic> payload) {
    final ipass = payload['ipassVerificationData'];
    final ipassMap = ipass is Map
        ? Map<String, dynamic>.from(ipass)
        : <String, dynamic>{};

    final lines = <String>[
      '========== BBH_KYC_FINAL_IMAGES ==========',
    ];

    var urlCount = 0;
    var base64Count = 0;
    var index = 0;

    void logImageList(String listName, dynamic list) {
      if (list is! List || list.isEmpty) {
        lines.add('$listName: (empty or missing)');
        return;
      }

      lines.add('$listName: ${list.length} item(s)');
      for (final item in list) {
        if (item is! Map) continue;
        index++;
        final map = Map<String, dynamic>.from(item);
        final url = map['imageUrl']?.toString().trim();
        final base64 = map['base64']?.toString().trim();
        final hostedInBase64 = base64 != null &&
            base64.isNotEmpty &&
            (base64.startsWith('http://') || base64.startsWith('https://'));
        final hasUrl = (url != null && url.isNotEmpty) || hostedInBase64;
        final hasBinaryBase64 = base64 != null &&
            base64.isNotEmpty &&
            !hostedInBase64;

        if (hasUrl) urlCount++;
        if (hasBinaryBase64) base64Count++;

        final scanTarget = map['scanTarget'] ?? '?';
        final imageType = map['imageType'] ?? '?';
        final category = map['category'] ?? '?';
        final side = map['side'];
        final sideLabel = side != null ? ' side=$side' : '';

        lines.add(
          '  [$index] scanTarget=$scanTarget$sideLabel '
          'type=$imageType category=$category',
        );
        if (hasUrl) {
          final displayUrl = hostedInBase64 ? base64 : url;
          lines.add('       base64 (hosted URL): $displayUrl');
        } else if (base64 != null && base64.isEmpty) {
          lines.add('       base64: (empty — upload pending/failed)');
        } else {
          lines.add('       base64: (none)');
        }
        if (hasBinaryBase64) {
          lines.add('       WARNING binary base64: ${base64.length} chars');
        }
      }
    }

    logImageList('ipass_images', ipassMap['ipass_images']);
    logImageList('ipass_residence_images', ipassMap['ipass_residence_images']);

    // Flag embedded base64 still inside ipass_scans envelopes.
    final scans = ipassMap['ipass_scans'];
    if (scans is Map) {
      scans.forEach((scanKey, envelope) {
        if (envelope is! Map) return;
        final embedded = _countEmbeddedBase64(envelope);
        if (embedded > 0) {
          lines.add(
            'WARNING: ipass_scans.$scanKey still contains $embedded '
            'embedded base64 field(s) (OCR envelope — separate from ipass_images)',
          );
        }
      });
    }

    lines.add(
      'SUMMARY: $index image(s) in arrays — '
      '$urlCount with hosted URL (in base64 key), $base64Count with binary base64',
    );
    lines.add('========== END BBH_KYC_FINAL_IMAGES ==========');

    developer.log(lines.join('\n'), name: 'BBH_KYC_FINAL_IMAGES');
  }

  static int _countEmbeddedBase64(dynamic node) {
    var count = 0;
    void walk(dynamic value, String key) {
      if (value is Map) {
        for (final e in value.entries) {
          walk(e.value, e.key.toString());
        }
        return;
      }
      if (value is List) {
        for (final item in value) {
          walk(item, key);
        }
        return;
      }
      if (value is String &&
          _shouldShorten(key, value) &&
          key != 'imageUrl') {
        count++;
      }
    }

    walk(node, '');
    return count;
  }
}
