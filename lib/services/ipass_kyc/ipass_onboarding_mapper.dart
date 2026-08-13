import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

/// Which document the user is scanning — controls field mapping and workflow.
enum IpassScanTarget {
  nationalId,
  residence,
  passport,
}

/// Maps iPass document-scanner JSON into Al-Taif onboarding form values.
///
/// Supports iPass `data.DocDetails.Visual` / `MRZ` (Regula-style keys with spaces).
class IpassOnboardingMapper {
  IpassOnboardingMapper._();


  static String? _lastLoggedPayload;
  static DateTime? _lastLoggedAt;
  static String? lastSavedResponsePath;
  static String? lastSavedImagesPath;
  static List<Map<String, dynamic>> lastExtractedImages = [];

  static const Map<IpassScanTarget, String> scanTargetKeys = {
    IpassScanTarget.nationalId: 'national_id',
    IpassScanTarget.passport: 'passport',
    IpassScanTarget.residence: 'residence',
  };

  /// Pulls every base64 image from an iPass scan with document + image type labels.
  static List<Map<String, dynamic>> extractIpassImages(
    Map<String, dynamic> data, {
    String? scanTarget,
  }) {
    final documentType = data['DocType']?.toString() ?? 'Unknown';
    final overAllStatus = data['OverAllStatus']?.toString();
    final images = <Map<String, dynamic>>[];

    void add({
      required String category,
      required String imageType,
      required dynamic value,
      int? index,
    }) {
      if (value is! String || value.trim().isEmpty) return;
      final base64 = value.trim();
      images.add({
        if (scanTarget != null) 'scanTarget': scanTarget,
        'documentType': documentType,
        'overAllStatus': overAllStatus,
        'category': category,
        'imageType': imageType,
        if (index != null) 'index': index,
        'mimeType': _guessMimeFromBase64(base64),
        'sizeChars': base64.length,
        'base64': base64,
      });
    }

    final docImages = data['DocImages'];
    if (docImages is Map) {
      for (final entry in docImages.entries) {
        add(
          category: 'DocImages',
          imageType: entry.key.toString(),
          value: entry.value,
        );
      }
    }

    final liveness = data['livenessResult'];
    if (liveness is Map) {
      add(
        category: 'livenessResult',
        imageType: 'faceImage',
        value: liveness['faceImage'],
      );
      final audit = liveness['AuditImages'];
      if (audit is List) {
        for (var i = 0; i < audit.length; i++) {
          final item = audit[i];
          if (item is! Map) continue;
          for (final entry in item.entries) {
            add(
              category: 'livenessResult.AuditImages',
              imageType: entry.key.toString(),
              value: entry.value,
              index: i,
            );
          }
        }
      }
    }

    final faceMatch = data['faceMatchngResult'] ?? data['faceMatchingResult'];
    if (faceMatch is List) {
      for (var i = 0; i < faceMatch.length; i++) {
        final item = faceMatch[i];
        if (item is! Map) continue;
        add(
          category: 'faceMatchngResult',
          imageType: 'sourceImageBase64',
          value: item['sourceImageBase64'],
          index: i,
        );
        add(
          category: 'faceMatchngResult',
          imageType: 'targetImageBase64',
          value: item['targetImageBase64'],
          index: i,
        );
      }
    }

    final faceMatchNfc =
        data['faceMatchngResultNfc'] ?? data['faceMatchingResultNfc'];
    if (faceMatchNfc is Map) {
      add(
        category: 'faceMatchngResultNfc',
        imageType: 'sourceImageBase64',
        value: faceMatchNfc['sourceImageBase64'],
      );
      add(
        category: 'faceMatchngResultNfc',
        imageType: 'targetImageBase64',
        value: faceMatchNfc['targetImageBase64'],
      );
    }

    return images;
  }

  static const _knownImageFieldKeys = {
    'base64',
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
    'rawResponse',
  };

  /// Collects images from envelope, [result.data], and [rawResponse] (deduped).
  static List<Map<String, dynamic>> extractAllImagesFromScanResult(
    dynamic result, {
    String? scanTarget,
  }) {
    final roots = <Map<String, dynamic>>[];
    final seenRoots = <String>{};

    void addRoot(Map<String, dynamic>? map) {
      if (map == null || map.isEmpty) return;
      final resolved = resolveDataRoot(map);
      if (resolved.isEmpty) return;
      final sig = resolved.keys.join(',');
      if (seenRoots.add(sig)) roots.add(resolved);
    }

    final envelope = buildApiEnvelopeFromResult(result);
    addRoot(envelope);

    addRoot(_readMapField(result, 'data'));

    final raw = _readStringField(result, 'rawResponse');
    if (raw != null && raw.isNotEmpty) {
      try {
        final decoded = jsonDecode(raw);
        if (decoded is Map) {
          addRoot(Map<String, dynamic>.from(decoded));
        }
      } catch (_) {}
    }

    final seenKeys = <String>{};
    final out = <Map<String, dynamic>>[];

    void absorb(Iterable<Map<String, dynamic>> batch) {
      for (final img in batch) {
        final key = imageEntryKey(img);
        if (seenKeys.add(key)) out.add(img);
      }
    }

    for (final root in roots) {
      absorb(extractIpassImages(root, scanTarget: scanTarget));
    }

    if (out.isEmpty) {
      for (final root in roots) {
        absorb(extractIpassImagesDeep(root, scanTarget: scanTarget));
      }
    }

    return out;
  }

  /// Fallback when structured [DocImages] / liveness blocks are missing.
  static List<Map<String, dynamic>> extractIpassImagesDeep(
    Map<String, dynamic> data, {
    String? scanTarget,
  }) {
    final images = <Map<String, dynamic>>[];
    final documentType = data['DocType']?.toString() ?? 'Unknown';
    final overAllStatus = data['OverAllStatus']?.toString();

    void walk(dynamic node, {required String category, String? imageType, int? index}) {
      if (node is Map) {
        for (final entry in node.entries) {
          final key = entry.key.toString();
          walk(
            entry.value,
            category: category.isEmpty ? key : '$category.$key',
            imageType: key,
          );
        }
        return;
      }
      if (node is List) {
        for (var i = 0; i < node.length; i++) {
          walk(node[i], category: category, imageType: imageType, index: i);
        }
        return;
      }
      if (node is! String || !_looksLikeBase64Image(node, imageType)) return;

      images.add({
        if (scanTarget != null) 'scanTarget': scanTarget,
        'documentType': documentType,
        'overAllStatus': overAllStatus,
        'category': category,
        'imageType': imageType ?? category,
        if (index != null) 'index': index,
        'mimeType': _guessMimeFromBase64(node.trim()),
        'sizeChars': node.trim().length,
        'base64': node.trim(),
      });
    }

    walk(data, category: 'deep');
    return images;
  }

  static bool _looksLikeBase64Image(String value, String? key) {
    final v = value.trim();
    if (v.length < 200) return false;
    if (key != null &&
        (_knownImageFieldKeys.contains(key) ||
            key.toLowerCase().contains('base64') ||
            key.toLowerCase().contains('image') ||
            key.toLowerCase().contains('portrait'))) {
      return true;
    }
    return v.startsWith('/9j/') ||
        v.startsWith('iVBORw0KGgo') ||
        v.startsWith('data:image');
  }

  /// Debug helper — why upload queue may be empty.
  static String describeScanImageDiagnostics(dynamic result, {String? scanTarget}) {
    final images = extractAllImagesFromScanResult(result, scanTarget: scanTarget);
    final data = _readMapField(result, 'data');
    final dataKeys = data?.keys.join(', ') ?? '(no data map)';
    final hasDocImages = data?['DocImages'] != null;
    final hasLiveness = data?['livenessResult'] != null;
    return 'images=${images.length}, dataKeys=[$dataKeys], '
        'DocImages=$hasDocImages, livenessResult=$hasLiveness';
  }

  /// Stable key for matching an extracted image entry to an uploaded URL.
  static String imageEntryKey(Map<String, dynamic> entry) {
    final parts = <String>[
      entry['scanTarget']?.toString() ?? '',
      entry['side']?.toString() ?? '',
      entry['category']?.toString() ?? '',
      entry['imageType']?.toString() ?? '',
      if (entry['index'] != null) entry['index'].toString(),
    ];
    return parts.join('|');
  }

  /// Hosted URL for submit, or empty when upload pending/failed/missing (never binary).
  static String _submissionImageValue(String? url) =>
      url != null && url.isNotEmpty ? url : '';

  /// Replaces binary in [base64] with hosted URL when available (same key name).
  /// Pending/failed/missing uploads → empty string (no base64 in API).
  static List<Map<String, dynamic>> resolveSubmissionImages(
    List<Map<String, dynamic>> images, {
    Map<String, String>? imageUrlsByKey,
    bool preferImageUrls = true,
    bool omitUnuploaded = false,
  }) {
    if (!preferImageUrls) return images;

    final resolved = <Map<String, dynamic>>[];
    for (final image in images) {
      final copy = Map<String, dynamic>.from(image);
      final url = _lookupUploadedUrl(
        imageUrlsByKey,
        scanTarget: copy['scanTarget']?.toString() ?? '',
        category: copy['category']?.toString() ?? '',
        imageType: copy['imageType']?.toString() ?? '',
        side: copy['side']?.toString(),
        index: copy['index'] is int ? copy['index'] as int : null,
      );
      final value = _submissionImageValue(url);
      copy['base64'] = value;
      copy.remove('imageUrl');
      copy['sizeChars'] = value.length;
      if (omitUnuploaded && value.isEmpty) continue;
      resolved.add(copy);
    }
    return resolved;
  }

  static String? _lookupUploadedUrl(
    Map<String, String>? imageUrlsByKey, {
    required String scanTarget,
    required String category,
    required String imageType,
    String? side,
    int? index,
  }) {
    if (imageUrlsByKey == null || imageUrlsByKey.isEmpty) return null;
    final key = imageEntryKey({
      'scanTarget': scanTarget,
      if (side != null && side.isNotEmpty) 'side': side,
      'category': category,
      'imageType': imageType,
      if (index != null) 'index': index,
    });
    final url = imageUrlsByKey[key]?.trim();
    return url != null && url.isNotEmpty ? url : null;
  }

  /// Full iPass API body as returned after scan: `{ Apistatus, Apimessage, data }`.
  /// Images remain embedded under `data.DocImages`, `data.livenessResult`, etc.
  static Map<String, dynamic>? buildApiEnvelope(Map<String, dynamic>? source) {
    if (source == null || source.isEmpty) return null;

    if (_looksLikeApiEnvelope(source)) {
      return _normalizeApiEnvelope(source);
    }

    final inner = resolveDataRoot(source);
    if (inner.isEmpty) return null;

    return {
      'Apistatus': source['Apistatus'] == true || source['apiStatus'] == true,
      'Apimessage': _clean(source['Apimessage']?.toString()) ??
          _clean(source['apiMessage']?.toString()) ??
          _clean(source['scanMessage']?.toString()) ??
          'Success',
      'data': inner,
    };
  }

  /// Builds envelope from [IpassKycResult], preferring native `rawResponse`.
  static Map<String, dynamic>? buildApiEnvelopeFromResult(
    dynamic result, {
    bool? apiStatus,
    String? apiMessage,
  }) {
    if (result == null) return null;

    final raw = _readStringField(result, 'rawResponse');
    if (raw != null && raw.isNotEmpty) {
      try {
        final decoded = jsonDecode(raw);
        if (decoded is Map) {
          final map = Map<String, dynamic>.from(decoded);
          if (_looksLikeApiEnvelope(map)) {
            return _normalizeApiEnvelope(map);
          }
          if (map.containsKey('DocDetails') || map.containsKey('OverAllStatus')) {
            return {
              'Apistatus': apiStatus ?? true,
              'Apimessage': apiMessage ?? 'Success',
              'data': map,
            };
          }
        }
      } catch (_) {}
    }

    final data = _readMapField(result, 'data');
    if (data != null) {
      return buildApiEnvelope({
        if (apiStatus != null) 'Apistatus': apiStatus,
        if (apiMessage != null) 'Apimessage': apiMessage,
        'data': data,
      });
    }

    return buildApiEnvelope(data);
  }

  static bool _looksLikeApiEnvelope(Map<String, dynamic> map) {
    final hasApiKeys =
        map.containsKey('Apistatus') ||
        map.containsKey('apiStatus') ||
        map.containsKey('Apimessage') ||
        map.containsKey('apiMessage');
    final data = map['data'];
    return hasApiKeys && data is Map;
  }

  static Map<String, dynamic> _normalizeApiEnvelope(Map<String, dynamic> map) {
    final dataRaw = map['data'];
    Map<String, dynamic> inner;
    if (dataRaw is Map<String, dynamic>) {
      inner = dataRaw;
    } else if (dataRaw is Map) {
      inner = Map<String, dynamic>.from(dataRaw);
    } else if (dataRaw is String && dataRaw.isNotEmpty) {
      try {
        final decoded = jsonDecode(dataRaw);
        inner = decoded is Map
            ? Map<String, dynamic>.from(decoded)
            : <String, dynamic>{};
      } catch (_) {
        inner = <String, dynamic>{};
      }
    } else {
      inner = <String, dynamic>{};
    }

    return {
      'Apistatus': map['Apistatus'] == true || map['apiStatus'] == true,
      'Apimessage':
          _clean(map['Apimessage']?.toString()) ??
          _clean(map['apiMessage']?.toString()) ??
          'Success',
      'data': inner,
    };
  }

  static dynamic _readField(dynamic source, String key) {
    if (source is Map) return source[key];
    try {
      switch (key) {
        case 'data':
          return (source as dynamic).data;
        case 'rawResponse':
          return (source as dynamic).rawResponse;
        case 'scanMessage':
          return (source as dynamic).scanMessage;
        case 'apiStatus':
          return (source as dynamic).apiStatus;
        case 'success':
          return (source as dynamic).success;
        default:
          return null;
      }
    } catch (_) {
      return null;
    }
  }

  static String? _readStringField(dynamic source, String key) {
    final value = _readField(source, key);
    if (value is String) return value;
    return value?.toString();
  }

  static Map<String, dynamic>? _readMapField(dynamic source, String key) {
    final value = _readField(source, key);
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    if (value is String && value.isNotEmpty) {
      try {
        final decoded = jsonDecode(value);
        if (decoded is Map<String, dynamic>) return decoded;
        if (decoded is Map) return Map<String, dynamic>.from(decoded);
      } catch (_) {}
    }
    return null;
  }

  /// Inner scan payload (`OverAllStatus`, `DocDetails`, `DocImages`, …).
  static Map<String, dynamic> resolveDataRoot(Map<String, dynamic>? ipassData) {
    if (ipassData == null || ipassData.isEmpty) return {};
    return _resolveDataRoot(ipassData);
  }

  /// Builds backend-ready iPass payload from one or more scan results.
  static Map<String, dynamic> buildSubmissionIpassBundle(
    Map<IpassScanTarget, dynamic> results, {
    Map<String, String>? imageUrlsByKey,
    bool preferImageUrls = true,
    bool omitUnuploaded = false,
  }) {
    final scans = <String, dynamic>{};
    final verifications = <String, dynamic>{};
    final images = <Map<String, dynamic>>[];

    for (final entry in results.entries) {
      final scanKey = scanTargetKeys[entry.key];
      if (scanKey == null) continue;

      final result = entry.value;
      if (result == null) continue;

      final envelope = buildApiEnvelopeFromResult(
        result,
        apiStatus: _readApiStatus(result) ?? true,
        apiMessage: _readScanMessage(result),
      );
      if (envelope == null) continue;

      scans[scanKey] = envelope;
      final verificationJson = _resultToJson(result);
      if (verificationJson != null) {
        verifications[scanKey] = verificationJson;
      }

      images.addAll(
        extractAllImagesFromScanResult(result, scanTarget: scanKey),
      );
    }

    final primaryVerification = verifications['national_id'] ?? verifications['passport'];

    final resolvedImages = resolveSubmissionImages(
      images,
      imageUrlsByKey: imageUrlsByKey,
      preferImageUrls: preferImageUrls,
      omitUnuploaded: omitUnuploaded,
    );

    return {
      if (scans.isNotEmpty) 'ipass_scans': scans,
      if (resolvedImages.isNotEmpty) 'ipass_images': resolvedImages,
      if (verifications.isNotEmpty) 'ipass_verifications': verifications,
      if (primaryVerification != null) 'ipass_verification': primaryVerification,
    };
  }

  /// Residence form OCR — front + back Azure `analyzeResult` responses.
  static Map<String, dynamic> buildResidenceSubmissionPayload({
    dynamic front,
    dynamic back,
    Map<String, String>? imageUrlsByKey,
    bool preferImageUrls = true,
    bool omitUnuploaded = false,
  }) {
    Map<String, dynamic>? frontJson;
    Map<String, dynamic>? backJson;

    if (front != null) {
      frontJson = _resultToJson(front);
    }
    if (back != null) {
      backJson = _resultToJson(back);
    }
    if (frontJson == null && backJson == null) return {};

    final sides = <String, dynamic>{
      if (frontJson != null) 'front': frontJson,
      if (backJson != null) 'back': backJson,
    };

    final residenceImages = <Map<String, dynamic>>[];
    void addImage(String side, Map<String, dynamic>? payload) {
      final base64 = payload?['imageBase64']?.toString();
      if (base64 == null || base64.trim().isEmpty) return;
      residenceImages.add({
        'scanTarget': 'residence',
        'side': side,
        'documentType': 'Residence Form',
        'category': 'formdata',
        'imageType': 'document_${side}Side',
        'mimeType': _guessMimeFromBase64(base64.trim()),
        'sizeChars': base64.trim().length,
        'base64': base64.trim(),
      });
    }

    addImage('front', frontJson);
    addImage('back', backJson);

    void applyUrlToSide(String side, Map<String, dynamic>? payload) {
      if (payload == null || !preferImageUrls) return;
      final url = _lookupUploadedUrl(
        imageUrlsByKey,
        scanTarget: 'residence',
        category: 'formdata',
        imageType: 'document_${side}Side',
        side: side,
      );
      payload['imageBase64'] = _submissionImageValue(url);
    }

    applyUrlToSide('front', frontJson);
    applyUrlToSide('back', backJson);

    final envelope = {
      'Apistatus': true,
      'Apimessage': 'Success',
      'data': {
        'DocType': 'Residence Form',
        'OverAllStatus': 'PASSED',
        ...sides,
      },
    };

    final resolvedResidenceImages = resolveSubmissionImages(
      residenceImages,
      imageUrlsByKey: imageUrlsByKey,
      preferImageUrls: preferImageUrls,
      omitUnuploaded: omitUnuploaded,
    );

    return {
      'ipass_residence_scan_data': sides,
      'ipass_scans': {'residence': envelope},
      if (resolvedResidenceImages.isNotEmpty)
        'ipass_residence_images': resolvedResidenceImages,
    };
  }

  /// Upload-ready image entries from current scan state (SDK + residence).
  static List<Map<String, dynamic>> collectUploadableImages({
    Map<IpassScanTarget, dynamic>? scanResults,
    dynamic residenceFront,
    dynamic residenceBack,
  }) {
    final images = <Map<String, dynamic>>[];

    if (scanResults != null) {
      for (final entry in scanResults.entries) {
        final scanKey = scanTargetKeys[entry.key];
        if (scanKey == null || entry.value == null) continue;
        images.addAll(
          extractAllImagesFromScanResult(entry.value, scanTarget: scanKey),
        );
      }
    }

    final residenceBundle = buildResidenceSubmissionPayload(
      front: residenceFront,
      back: residenceBack,
      preferImageUrls: false,
    );
    final residenceImages = residenceBundle['ipass_residence_images'];
    if (residenceImages is List) {
      for (final item in residenceImages) {
        if (item is Map) {
          images.add(Map<String, dynamic>.from(item));
        }
      }
    }

    return images;
  }

  /// Applies hosted URLs to all image arrays inside a merged submission bundle.
  static Map<String, dynamic> applyImageUrlsToBundle(
    Map<String, dynamic> bundle, {
    required Map<String, String> imageUrlsByKey,
    bool preferImageUrls = true,
  }) {
    if (!preferImageUrls || imageUrlsByKey.isEmpty) return bundle;

    final merged = Map<String, dynamic>.from(bundle);
    for (final key in ['ipass_images', 'ipass_residence_images']) {
      final value = merged[key];
      if (value is! List) continue;
      final resolved = <Map<String, dynamic>>[];
      for (final item in value) {
        if (item is Map) {
          resolved.addAll(
            resolveSubmissionImages(
              [Map<String, dynamic>.from(item)],
              imageUrlsByKey: imageUrlsByKey,
              preferImageUrls: preferImageUrls,
            ),
          );
        }
      }
      if (resolved.isNotEmpty) merged[key] = resolved;
    }
    return merged;
  }

  /// Merges KYC SDK scans with residence FormData OCR for one submit payload.
  static Map<String, dynamic> mergeSubmissionBundles(
    Map<String, dynamic> kycBundle,
    Map<String, dynamic> residenceBundle,
  ) {
    if (residenceBundle.isEmpty) return kycBundle;
    if (kycBundle.isEmpty) return residenceBundle;

    final merged = Map<String, dynamic>.from(kycBundle);
    final kycScans = kycBundle['ipass_scans'];
    final residenceScans = residenceBundle['ipass_scans'];
    if (kycScans is Map || residenceScans is Map) {
      merged['ipass_scans'] = {
        if (kycScans is Map) ...Map<String, dynamic>.from(kycScans),
        if (residenceScans is Map) ...Map<String, dynamic>.from(residenceScans),
      };
    }

    for (final key in ['ipass_residence_scan_data', 'ipass_residence_images']) {
      final value = residenceBundle[key];
      if (value != null) merged[key] = value;
    }

    final residenceImages = residenceBundle['ipass_residence_images'];
    if (residenceImages is List) {
      final combined = <Map<String, dynamic>>[];
      final kycImages = merged['ipass_images'];
      if (kycImages is List) {
        for (final item in kycImages) {
          if (item is Map) combined.add(Map<String, dynamic>.from(item));
        }
      }
      for (final item in residenceImages) {
        if (item is Map) combined.add(Map<String, dynamic>.from(item));
      }
      if (combined.isNotEmpty) merged['ipass_images'] = combined;
    }

    return merged;
  }

  /// Replaces embedded base64 in scan envelopes with hosted URLs (same field names).
  /// OCR / metadata preserved; [rawResponse] stripped from verifications only.
  static Map<String, dynamic> sanitizeBundleForSubmission(
    Map<String, dynamic> bundle, {
    Map<String, String>? imageUrlsByKey,
  }) {
    final out = Map<String, dynamic>.from(bundle);

    final scans = out['ipass_scans'];
    if (scans is Map) {
      final cleaned = <String, dynamic>{};
      for (final entry in scans.entries) {
        if (entry.value is Map) {
          cleaned[entry.key] = _sanitizeApiEnvelope(
            Map<String, dynamic>.from(entry.value),
            scanTarget: entry.key.toString(),
            imageUrlsByKey: imageUrlsByKey,
          );
        }
      }
      out['ipass_scans'] = cleaned;

      if (cleaned['national_id'] is Map) {
        out['ipass_scan_data'] = _emptyDataEnvelope(
          Map<String, dynamic>.from(cleaned['national_id']),
        );
      }
      if (cleaned['passport'] is Map) {
        out['ipass_passport_scan_data'] = _emptyDataEnvelope(
          Map<String, dynamic>.from(cleaned['passport']),
        );
      }
    }

    if (out['ipass_residence_scan_data'] is Map) {
      out['ipass_residence_scan_data'] = _sanitizeResidenceSides(
        Map<String, dynamic>.from(out['ipass_residence_scan_data']),
        imageUrlsByKey: imageUrlsByKey,
      );
    }

    final residenceScans = out['ipass_scans'];
    if (residenceScans is Map && residenceScans['residence'] is Map) {
      final residenceEnvelope = Map<String, dynamic>.from(residenceScans['residence']);
      final data = residenceEnvelope['data'];
      if (data is Map) {
        final sides = <String, dynamic>{};
        for (final side in ['front', 'back']) {
          final sideData = data[side];
          if (sideData is Map) {
            final copy = Map<String, dynamic>.from(sideData);
            final url = _lookupUploadedUrl(
              imageUrlsByKey,
              scanTarget: 'residence',
              category: 'formdata',
              imageType: 'document_${side}Side',
              side: side,
            );
            copy['imageBase64'] = _submissionImageValue(url);
            sides[side] = copy;
          }
        }
        out['ipass_residence_scan_data'] = sides;
      }
    }

    if (out['ipass_verifications'] is Map) {
      out['ipass_verifications'] = _sanitizeVerificationMap(
        Map<String, dynamic>.from(out['ipass_verifications']),
      );
    }
    if (out['ipass_verification'] != null) {
      out['ipass_verification'] = _sanitizeVerificationEntry(out['ipass_verification']);
    }

    for (final listKey in ['ipass_images', 'ipass_residence_images']) {
      final list = out[listKey];
      if (list is! List) continue;
      final images = <Map<String, dynamic>>[];
      for (final item in list) {
        if (item is Map) images.add(Map<String, dynamic>.from(item));
      }
      if (images.isNotEmpty) {
        out[listKey] = resolveSubmissionImages(
          images,
          imageUrlsByKey: imageUrlsByKey,
        );
      }
    }

    // API contract: duplicate residence OCR lives under ipass_scans.residence only.
    out['ipass_residence_scan_data'] = {'front': {}, 'back': {}};

    return _deepScrubBinaryFields(out, imageUrlsByKey: imageUrlsByKey);
  }

  /// Safety net: removes any remaining rawResponse / base64 anywhere in the bundle.
  static Map<String, dynamic> _deepScrubBinaryFields(
    Map<String, dynamic> node, {
    Map<String, String>? imageUrlsByKey,
  }) {
    final out = <String, dynamic>{};
    for (final entry in node.entries) {
      final key = entry.key;
      final value = entry.value;

      if (key == 'rawResponse') continue;

      if (value is String) {
        out[key] = _isHeavyBinaryField(key, value)
            ? _submissionImageValue(null)
            : value;
        continue;
      }

      if (value is Map) {
        out[key] = _deepScrubBinaryFields(
          Map<String, dynamic>.from(value),
          imageUrlsByKey: imageUrlsByKey,
        );
        continue;
      }

      if (value is List) {
        out[key] = value.map((item) {
          if (item is Map) {
            return _deepScrubBinaryFields(
              Map<String, dynamic>.from(item),
              imageUrlsByKey: imageUrlsByKey,
            );
          }
          if (item is String && _isHeavyBinaryField(key, item)) {
            return _submissionImageValue(null);
          }
          return item;
        }).toList();
        continue;
      }

      out[key] = value;
    }
    return out;
  }

  /// Approximate UTF-8 size of JSON for debug (submit payload checks).
  static int estimateJsonBytes(Map<String, dynamic> payload) {
    try {
      return utf8.encode(jsonEncode(payload)).length;
    } catch (_) {
      return payload.toString().length;
    }
  }

  static Map<String, dynamic> _sanitizeApiEnvelope(
    Map<String, dynamic> envelope, {
    required String scanTarget,
    Map<String, String>? imageUrlsByKey,
  }) {
    final data = envelope['data'];
    return {
      'Apistatus': envelope['Apistatus'] == true || envelope['apiStatus'] == true,
      'Apimessage': envelope['Apimessage']?.toString() ??
          envelope['apiMessage']?.toString() ??
          'Success',
      'data': data is Map
          ? _applyUrlsToScanData(
              Map<String, dynamic>.from(data),
              scanTarget: scanTarget,
              imageUrlsByKey: imageUrlsByKey,
            )
          : <String, dynamic>{},
    };
  }

  /// Swaps binary image fields for hosted URLs while keeping the same JSON keys.
  static Map<String, dynamic> _applyUrlsToScanData(
    Map<String, dynamic> data, {
    required String scanTarget,
    Map<String, String>? imageUrlsByKey,
  }) {
    final out = Map<String, dynamic>.from(data);

    String withUrl(
      String original,
      String category,
      String imageType, {
      int? index,
    }) {
      final url = _lookupUploadedUrl(
        imageUrlsByKey,
        scanTarget: scanTarget,
        category: category,
        imageType: imageType,
        index: index,
      );
      return _submissionImageValue(url);
    }

    final docImages = out['DocImages'];
    if (docImages is Map) {
      final resolved = <String, dynamic>{};
      for (final entry in docImages.entries) {
        final value = entry.value?.toString() ?? '';
        if (value.isEmpty) continue;
        resolved[entry.key] = withUrl(value, 'DocImages', entry.key.toString());
      }
      out['DocImages'] = resolved;
    }

    final liveness = out['livenessResult'];
    if (liveness is Map) {
      final copy = Map<String, dynamic>.from(liveness);
      final face = copy['faceImage']?.toString();
      if (copy.containsKey('faceImage')) {
        copy['faceImage'] = face == null || face.isEmpty
            ? ''
            : withUrl(face, 'livenessResult', 'faceImage');
      }
      final audit = copy['AuditImages'];
      if (audit is List) {
        final resolvedAudit = <Map<String, dynamic>>[];
        for (var i = 0; i < audit.length; i++) {
          final item = audit[i];
          if (item is! Map) continue;
          final itemCopy = <String, dynamic>{};
          for (final entry in item.entries) {
            final value = entry.value?.toString() ?? '';
            if (value.isEmpty) continue;
            itemCopy[entry.key] = withUrl(
              value,
              'livenessResult.AuditImages',
              entry.key.toString(),
              index: i,
            );
          }
          if (itemCopy.isNotEmpty) resolvedAudit.add(itemCopy);
        }
        copy['AuditImages'] = resolvedAudit;
      }
      out['livenessResult'] = copy;
    }

    final faceMatch = out['faceMatchngResult'] ?? out['faceMatchingResult'];
    if (faceMatch is List) {
      final resolved = <Map<String, dynamic>>[];
      for (var i = 0; i < faceMatch.length; i++) {
        final item = faceMatch[i];
        if (item is! Map) continue;
        final itemCopy = Map<String, dynamic>.from(item);
        for (final field in ['sourceImageBase64', 'targetImageBase64']) {
          if (itemCopy.containsKey(field)) {
            final value = itemCopy[field]?.toString() ?? '';
            itemCopy[field] = value.isEmpty
                ? ''
                : withUrl(value, 'faceMatchngResult', field, index: i);
          }
        }
        resolved.add(itemCopy);
      }
      if (out.containsKey('faceMatchngResult')) {
        out['faceMatchngResult'] = resolved;
      } else {
        out['faceMatchingResult'] = resolved;
      }
    }

    final faceMatchNfc = out['faceMatchngResultNfc'] ?? out['faceMatchingResultNfc'];
    if (faceMatchNfc is Map) {
      final itemCopy = Map<String, dynamic>.from(faceMatchNfc);
      for (final field in ['sourceImageBase64', 'targetImageBase64']) {
        if (itemCopy.containsKey(field)) {
          final value = itemCopy[field]?.toString() ?? '';
          itemCopy[field] = value.isEmpty
              ? ''
              : withUrl(value, 'faceMatchngResultNfc', field);
        }
      }
      if (out.containsKey('faceMatchngResultNfc')) {
        out['faceMatchngResultNfc'] = itemCopy;
      } else {
        out['faceMatchingResultNfc'] = itemCopy;
      }
    }

    for (final side in ['front', 'back']) {
      final sideData = out[side];
      if (sideData is! Map) continue;
      final copy = Map<String, dynamic>.from(sideData);
      final imageBase64 = copy['imageBase64']?.toString();
      if (copy.containsKey('imageBase64')) {
        copy['imageBase64'] = imageBase64 == null || imageBase64.isEmpty
            ? ''
            : _submissionImageValue(
                _lookupUploadedUrl(
                  imageUrlsByKey,
                  scanTarget: scanTarget,
                  category: 'formdata',
                  imageType: 'document_${side}Side',
                  side: side,
                ),
              );
      }
      out[side] = copy;
    }

    return out;
  }

  static Map<String, dynamic> _emptyDataEnvelope(Map<String, dynamic> envelope) {
    return {
      'Apistatus': envelope['Apistatus'] == true || envelope['apiStatus'] == true,
      'Apimessage': envelope['Apimessage']?.toString() ??
          envelope['apiMessage']?.toString() ??
          'Success',
      'data': <String, dynamic>{},
    };
  }

  static Map<String, dynamic> _sanitizeResidenceSides(
    Map<String, dynamic> sides, {
    Map<String, String>? imageUrlsByKey,
  }) {
    final out = <String, dynamic>{};
    for (final entry in sides.entries) {
      if (entry.value is Map) {
        final copy = Map<String, dynamic>.from(entry.value);
        final side = entry.key.toString();
        final imageBase64 = copy['imageBase64']?.toString();
        if (copy.containsKey('imageBase64')) {
          copy['imageBase64'] = imageBase64 == null || imageBase64.isEmpty
              ? ''
              : _submissionImageValue(
                  _lookupUploadedUrl(
                    imageUrlsByKey,
                    scanTarget: 'residence',
                    category: 'formdata',
                    imageType: 'document_${side}Side',
                    side: side,
                  ),
                );
        }
        out[entry.key] = copy;
      } else {
        out[entry.key] = entry.value;
      }
    }
    return out;
  }

  static Map<String, dynamic> _sanitizeVerificationMap(Map<String, dynamic> map) {
    final out = <String, dynamic>{};
    for (final entry in map.entries) {
      final cleaned = _sanitizeVerificationEntry(entry.value);
      if (cleaned != null) out[entry.key] = cleaned;
    }
    return out;
  }

  static Map<String, dynamic>? _sanitizeVerificationEntry(dynamic entry) {
    if (entry is! Map) return null;
    final map = Map<String, dynamic>.from(entry);
    return {
      'success': map['success'] == true,
      'apiStatus': map['apiStatus'] == true,
      'scanMessage': map['scanMessage']?.toString() ?? 'Success',
      'data': <String, dynamic>{},
    };
  }

  static Map<String, dynamic> _stripHeavyBinaryFields(Map<String, dynamic> node) {
    final out = <String, dynamic>{};
    for (final entry in node.entries) {
      final key = entry.key;
      final value = entry.value;

      if (value is String && _isHeavyBinaryField(key, value)) continue;

      if (value is Map) {
        if (key == 'DocImages') continue;
        final nested = _stripHeavyBinaryFields(Map<String, dynamic>.from(value));
        if (nested.isNotEmpty) out[key] = nested;
        continue;
      }

      if (value is List) {
        final list = _sanitizeListForSubmit(value, key);
        if (list.isNotEmpty) out[key] = list;
        continue;
      }

      out[key] = value;
    }
    return out;
  }

  static List<dynamic> _sanitizeListForSubmit(List list, String parentKey) {
    if (parentKey == 'AuditImages') return [];
    final out = <dynamic>[];
    for (final item in list) {
      if (item is Map) {
        final nested = _stripHeavyBinaryFields(Map<String, dynamic>.from(item));
        if (nested.isNotEmpty) out.add(nested);
      } else if (item is! String || !_isHeavyBinaryField(parentKey, item)) {
        out.add(item);
      }
    }
    return out;
  }

  static bool _isHeavyBinaryField(String key, String value) {
    if (value.startsWith('http://') || value.startsWith('https://')) {
      return false;
    }
    if (value.length < 200) return false;
    if (_knownImageFieldKeys.contains(key)) return true;
    final lower = key.toLowerCase();
    if (lower.contains('base64')) return true;
    if (key == 'rawResponse') return true;
    if (lower.contains('image') && !lower.contains('url')) return true;
    if (value.startsWith('/9j/') ||
        value.startsWith('iVBORw0KGgo') ||
        value.startsWith('data:image')) {
      return true;
    }
    return false;
  }

  static bool? _readApiStatus(dynamic result) {
    if (result is Map) {
      return result['apiStatus'] == true || result['success'] == true;
    }
    try {
      final value = (result as dynamic).apiStatus;
      if (value is bool) return value;
    } catch (_) {}
    return null;
  }

  static String? _readScanMessage(dynamic result) {
    if (result is Map) return result['scanMessage']?.toString();
    try {
      final value = (result as dynamic).scanMessage;
      if (value is String) return value;
    } catch (_) {}
    return null;
  }

  static Map<String, dynamic>? _resultToJson(dynamic result) {
    if (result == null) return null;
    if (result is Map<String, dynamic>) return result;
    if (result is Map) return Map<String, dynamic>.from(result);
    try {
      final json = (result as dynamic).toJson();
      if (json is Map<String, dynamic>) return json;
      if (json is Map) return Map<String, dynamic>.from(json);
    } catch (_) {}
    return null;
  }

  static String _guessMimeFromBase64(String base64) {
    if (base64.startsWith('/9j/') || base64.startsWith('data:image/jpeg')) {
      return 'image/jpeg';
    }
    if (base64.startsWith('iVBORw0KGgo') || base64.startsWith('data:image/png')) {
      return 'image/png';
    }
    return 'application/octet-stream';
  }

  /// One export per iPass completion: console summary + full JSON file on disk.
  static void logIpassResponseOnce(
    Map<String, dynamic>? data, {
    String label = 'IPASS_RESPONSE',
  }) {
    if (!kDebugMode || data == null || data.isEmpty) return;

    final envelope = buildApiEnvelope(data) ?? data;
    final dataRoot = resolveDataRoot(envelope);
    final images = extractIpassImages(dataRoot);
    lastExtractedImages = images;

    String fullJson;
    try {
      fullJson = const JsonEncoder.withIndent('  ').convert(envelope);
    } catch (_) {
      fullJson = envelope.toString();
    }

    final now = DateTime.now();
    if (_lastLoggedPayload == fullJson &&
        _lastLoggedAt != null &&
        now.difference(_lastLoggedAt!) < const Duration(seconds: 3)) {
      return;
    }
    _lastLoggedPayload = fullJson;
    _lastLoggedAt = now;

    unawaited(_saveFullResponseFiles(fullJson, images, label));

    final totalImageChars = images.fold<int>(
      0,
      (sum, img) => sum + (img['sizeChars'] as int? ?? 0),
    );

    debugPrint('========== $label ==========');
    debugPrint('Apistatus: ${envelope['Apistatus']}');
    debugPrint('OverAllStatus: ${dataRoot['OverAllStatus']}');
    debugPrint('DocType: ${dataRoot['DocType']}');
    debugPrint('NFC data stored: ${hasNfcInScanData(envelope)}');
    debugPrint(
      'Field mapping source: ${hasNfcInScanData(envelope) ? 'NFC (chip) + Visual/MRZ fallback' : 'Visual + MRZ'}',
    );
    debugPrint(
      'NOTE: Log preview only — backend/files keep FULL base64 (not shortened).',
    );
    debugPrint('Full JSON: ${fullJson.length} chars | Images: ${images.length} ($totalImageChars chars base64)');
    debugPrint('--- IPASS IMAGES (${dataRoot['DocType'] ?? 'Unknown'}) ---');
    if (images.isEmpty) {
      debugPrint('(no images found)');
    } else {
      for (final img in images) {
        final idx = img['index'];
        final indexSuffix = idx == null ? '' : ' #$idx';
        debugPrint(
          '  [${img['category']}] ${img['imageType']}$indexSuffix'
          ' — ${img['documentType']} / ${img['mimeType']} / ${img['sizeChars']} chars',
        );
      }
    }
    debugPrint('Full JSON + images saved to files (see IPASS_RESPONSE_FILE below).');
    debugPrint('========== END $label ==========');
  }

  static Future<void> _saveFullResponseFiles(
    String fullJson,
    List<Map<String, dynamic>> images,
    String label,
  ) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final stamp = DateTime.now().toIso8601String().replaceAll(':', '-');
      final responseFile = File('${dir.path}/$label-$stamp.json');
      await responseFile.writeAsString(fullJson);
      lastSavedResponsePath = responseFile.path;
      debugPrint(
        'IPASS_RESPONSE_FILE: ${responseFile.path} (${responseFile.lengthSync()} bytes)',
      );

      if (images.isNotEmpty) {
        final imagesFile = File('${dir.path}/$label-images-$stamp.json');
        await imagesFile.writeAsString(
          const JsonEncoder.withIndent('  ').convert(images),
        );
        lastSavedImagesPath = imagesFile.path;
        debugPrint(
          'IPASS_IMAGES_FILE: ${imagesFile.path} (${images.length} images)',
        );
      }
    } catch (e) {
      debugPrint('IPASS_RESPONSE_FILE_ERROR: $e');
    }
  }

  static const Set<String> allFieldKeys = {
    'mobile',
    'email',
    'branch',
    'arFirst',
    'arFather',
    'arGf',
    'arSurname',
    'arMother',
    'enFirst',
    'enFather',
    'enGf',
    'enSurname',
    'gender',
    'nationality',
    'dob',
    'countryBirth',
    'placeBirth',
    'idPersonal',
    'idSerial',
    'idIssuePlace',
    'idIssueDate',
    'idExpiryDate',
    'resNo',
    'resPlace',
    'resIssue',
    'resExpiry',
    'ppNo',
    'ppPlace',
    'ppIssue',
    'ppExpiry',
  };

  /// Logs which onboarding fields were auto-filled from iPass (debug only).
  static void logMappedFields(Map<String, String> mapped) {
    if (!kDebugMode) return;
    const encoder = JsonEncoder.withIndent('  ');
    developer.log(
      '--- mapped onboarding fields (send with iPass JSON above) ---\n'
      '${encoder.convert(mapped)}',
      name: 'iPassKycData',
    );
  }

  /// Debug-only: single raw JSON log per scan (search console for `IPASS_RESPONSE`).
  static void logDocumentScanDebug({
    required IpassScanTarget target,
    Map<String, dynamic>? ipassData,
    required Map<String, String> mapped,
    Map<String, String>? formFields,
  }) {
    if (!kDebugMode) return;
    if (target != IpassScanTarget.residence &&
        target != IpassScanTarget.passport &&
        target != IpassScanTarget.nationalId) {
      return;
    }

    final label = switch (target) {
      IpassScanTarget.residence => 'IPASS_RESPONSE_RESIDENCE',
      IpassScanTarget.passport => 'IPASS_RESPONSE_PASSPORT',
      IpassScanTarget.nationalId => 'IPASS_RESPONSE_NATIONAL_ID',
    };
    logIpassResponseOnce(ipassData, label: label);
  }

  /// Returns field key → value for non-empty extractions from [ipassData].
  static Map<String, String> extractFieldValues(
    Map<String, dynamic>? ipassData, {
    IpassScanTarget target = IpassScanTarget.nationalId,
  }) {
    if (ipassData == null || ipassData.isEmpty) return {};

    final out = <String, String>{};
    final dataRoot = _resolveDataRoot(ipassData);
    final docSection = _mergeDocSections(dataRoot, target: target);
    final docType = _sectionValue(dataRoot, 'DocType')?.toLowerCase() ?? '';
    final isResidenceDoc = _isResidenceDocument(docType, docSection);
    final isPassportDoc = _isPassportDocument(docType, docSection);

    if (docSection != null) {
      _mapFromDocSection(
        out,
        docSection,
        target: target,
        isResidenceDoc: isResidenceDoc,
        isPassportDoc: isPassportDoc,
      );
    }

    // Fallback: flattened keys for older / alternate iPass payloads.
    final flat = _flatten(ipassData);
    _mapFromFlat(out, flat, target: target);

    if (target == IpassScanTarget.nationalId) {
      _mirrorArabicNamesToEnglish(out);
    }

    return out;
  }

  /// When MRZ/Visual English names are missing, use Arabic ID names for English fields.
  static void _mirrorArabicNamesToEnglish(Map<String, String> out) {
    void copyIfEmpty(String enKey, String arKey) {
      if ((out[enKey]?.trim().isNotEmpty ?? false)) return;
      final ar = out[arKey]?.trim();
      if (ar != null && ar.isNotEmpty) out[enKey] = ar;
    }

    copyIfEmpty('idEnFirst', 'arFirst');
    copyIfEmpty('idEnFather', 'arFather');
    copyIfEmpty('idEnGf', 'arGf');
    copyIfEmpty('idEnSurname', 'arSurname');
    copyIfEmpty('idEnMother', 'arMother');
  }

  static Map<String, dynamic> _resolveDataRoot(Map<String, dynamic> ipassData) {
    var current = ipassData;
    for (var depth = 0; depth < 4; depth++) {
      if (current['DocDetails'] != null || current['DocType'] != null) {
        return current;
      }
      final inner = current['data'];
      if (inner is Map<String, dynamic>) {
        current = inner;
      } else if (inner is Map) {
        current = Map<String, dynamic>.from(inner);
      } else {
        break;
      }
    }
    return current;
  }

  /// MRZ → Visual → NFC (chip wins on national ID when NFC data is present).
  static Map<String, dynamic>? _mergeDocSections(
    Map<String, dynamic> dataRoot, {
    IpassScanTarget target = IpassScanTarget.nationalId,
  }) {
    final docDetails = dataRoot['DocDetails'];
    if (docDetails is! Map) return null;

    final merged = <String, dynamic>{};
    final mrz = docDetails['MRZ'];
    final nfc = docDetails['NFC'];
    final visual = docDetails['Visual'];
    if (mrz is Map) merged.addAll(Map<String, dynamic>.from(mrz));
    if (visual is Map) merged.addAll(Map<String, dynamic>.from(visual));

    final nfcMap = nfc is Map ? Map<String, dynamic>.from(nfc) : null;
    final useNfc = target == IpassScanTarget.nationalId &&
        nfcMap != null &&
        hasMeaningfulNfcData(nfcMap);
    if (useNfc) {
      merged.addAll(nfcMap);
    } else if (nfcMap != null && target != IpassScanTarget.nationalId) {
      merged.addAll(nfcMap);
    }

    return merged.isEmpty ? null : merged;
  }

  /// True when chip-read NFC block contains identity fields.
  static bool hasMeaningfulNfcData(Map<String, dynamic> nfc) {
    if (nfc.isEmpty) return false;
    const signalKeys = [
      'Document Number',
      'Personal Number',
      'MRZ Strings',
      'Surname',
      'SurnameAr',
      'Given Names',
      'Given NamesAr',
      'Surname And Given NamesAr',
      'DS Certificate Valid From',
    ];
    for (final key in signalKeys) {
      final v = nfc[key]?.toString().trim();
      if (v != null && v.isNotEmpty) return true;
    }
    return false;
  }

  static bool hasNfcInScanData(Map<String, dynamic>? ipassData) {
    if (ipassData == null) return false;
    final root = _resolveDataRoot(ipassData);
    final docDetails = root['DocDetails'];
    if (docDetails is! Map) return false;
    final nfc = docDetails['NFC'];
    return nfc is Map && hasMeaningfulNfcData(Map<String, dynamic>.from(nfc));
  }

  static void _mapFromDocSection(
    Map<String, String> out,
    Map<String, dynamic> section, {
    required IpassScanTarget target,
    required bool isResidenceDoc,
    required bool isPassportDoc,
  }) {
    switch (target) {
      case IpassScanTarget.residence:
        _mapResidenceFields(out, section);
        return;
      case IpassScanTarget.passport:
        _mapPassportFields(out, section);
        return;
      case IpassScanTarget.nationalId:
        if (isResidenceDoc) {
          _mapResidenceFields(out, section);
        } else {
          // Always map as national ID when user scanned from the ID row — Iraqi
          // document numbers (e.g. E12350562) match the passport number pattern.
          _mapNationalIdFields(out, section);
        }
        return;
    }
  }

  static bool _isResidenceDocument(String docType, Map<String, dynamic>? section) {
    final dt = docType.toLowerCase();
    if (dt.contains('resident') || dt.contains('residence')) return true;
    return false;
  }

  static bool _isPassportDocument(String docType, Map<String, dynamic>? section) {
    final dt = docType.toLowerCase();
    if (dt.contains('passport') || dt.contains('travel') || dt.contains('td3')) {
      return true;
    }
    if (section == null) return false;
    final docNo = _firstSectionValue(section, const [
      'Document Number',
      'Passport Number',
    ]);
    if (docNo != null && RegExp(r'^[A-Z]\d{7,9}$').hasMatch(docNo.trim())) {
      return true;
    }
    return false;
  }

  static void _mapResidenceFields(Map<String, String> out, Map<String, dynamic> section) {
    void put(String key, String? value) {
      final v = _clean(value);
      if (v != null && !out.containsKey(key)) out[key] = v;
    }

    final identityNo = _firstSectionValue(section, const [
      'Personal Number',
      'Identity Card Number',
      'Optional Data',
      'Document Number',
    ]);
    final documentNo = _sectionValue(section, 'Document Number');
    final issuePlace = _firstSectionValue(section, const [
      'Place of Issue',
      'Issuing State Name',
    ]);
    final issueDate = _normalizeDate(_sectionValue(section, 'Date of Issue'));
    final expiryDate = _normalizeDate(_sectionValue(section, 'Date of Expiry'));

    put('resNo', identityNo ?? documentNo);
    put('resPlace', issuePlace);
    put('resIssue', issueDate);
    put('resExpiry', expiryDate);
  }

  static void _mapPassportFields(Map<String, String> out, Map<String, dynamic> section) {
    void put(String key, String? value) {
      final v = _clean(value);
      if (v != null && !out.containsKey(key)) out[key] = v;
    }

    _putEnglishNames(out, section);

    final documentNo = _firstSectionValue(section, const [
      'Document Number',
      'Passport Number',
    ]);
    final issuePlace = _meaningfulSectionValue(section, const [
      'Authority',
      'Place of Issue',
      'Issuing State Name',
      'AuthorityAr',
    ]);
    final issueDate = _normalizeDate(_sectionValue(section, 'Date of Issue'));
    final expiryDate = _normalizeDate(_sectionValue(section, 'Date of Expiry'));

    put('ppNo', documentNo);
    put('ppPlace', issuePlace);
    put('ppIssue', issueDate);
    put('ppExpiry', expiryDate);

    put(
      'enMother',
      _motherNameWithMaternalGrandfather(section, arabic: false) ??
          _firstSectionValue(section, const [
            'Mothers Name',
            "Mother's Name",
            'Mother Name',
            'Mothers NameAr',
          ]),
    );

    put(
      'nationality',
      _normalizeNationality(
        _firstSectionValue(section, const [
          'Nationality',
          'NationalityAr',
          'Nationality Code',
        ]) ??
            _nationalityFromCode(_sectionValue(section, 'Nationality Code')),
      ),
    );
    put('dob', _normalizeDate(_sectionValue(section, 'Date of Birth')));
    put(
      'countryBirth',
      _meaningfulSectionValue(section, const [
        'Issuing State Name',
        'Country of Birth',
      ]),
    );
    put(
      'placeBirth',
      _meaningfulSectionValue(section, const [
        'Place of Birth',
        'Place of BirthAr',
      ]),
    );
    put('gender', _normalizeGender(_firstSectionValue(section, const ['Sex', 'SexAr'])));
  }

  // static void _mapNationalIdFields(Map<String, String> out, Map<String, dynamic> section) {
  //   void put(String key, String? value) {
  //     final v = _clean(value);
  //     if (v != null && !out.containsKey(key)) out[key] = v;
  //   }

  //   _putArabicNames(out, section);

  //   put('gender', _normalizeGender(_firstSectionValue(section, const ['Sex', 'SexAr'])));
  //   put(
  //     'nationality',
  //     _normalizeNationality(
  //       _sectionValue(section, 'Nationality') ??
  //           _nationalityFromCode(_sectionValue(section, 'Nationality Code')),
  //     ),
  //   );
  //   put('dob', _normalizeDate(_sectionValue(section, 'Date of Birth')));
  //   put(
  //     'countryBirth',
  //     _meaningfulSectionValue(section, const [
  //       'Country of Birth',
  //       'Issuing State Name',
  //     ]),
  //   );
  //   put(
  //     'placeBirth',
  //     _truncatePlaceBirth(
  //       _meaningfulSectionValue(section, const [
  //         'Place of Birth',
  //         'Place of BirthAr',
  //       ]),
  //     ),
  //   );

  //   put(
  //     'idPersonal',
  //     _firstSectionValue(section, const [
  //       'Personal Number',
  //       'Optional Data',
  //     ]),
  //   );
  //   put(
  //     'idSerial',
  //     _firstSectionValue(section, const [
  //       'Document Number',
  //       'Identity Card Number',
  //     ]),
  //   );
  //   put(
  //     'idIssuePlace',
  //     _meaningfulSectionValue(section, const [
  //       'Place of Issue',
  //       'Place of IssueAr',
  //       'AuthorityAr',
  //       'Issuing State Name',
  //     ]),
  //   );
  //   put('idIssueDate', _normalizeDate(_sectionValue(section, 'Date of Issue')));
  //   put('idExpiryDate', _normalizeDate(_sectionValue(section, 'Date of Expiry')));
  // }
  static void _mapNationalIdFields(Map<String, String> out, Map<String, dynamic> section) {
    void put(String key, String? value) {
      final v = _clean(value);
      if (v != null && !out.containsKey(key)) out[key] = v;
    }

    _putNationalIdEnglishNames(out, section);
    _putArabicNames(out, section);

  // Ensure mother name with maternal grandfather is set even if _putArabicNames didn't handle it
  if (!out.containsKey('arMother')) {
    final motherName = _firstSectionValue(section, const [
      'Mothers NameAr',
      "Mother's NameAr",
      'Mother NameAr',
    ]);
    final maternalGf = _firstSectionValue(section, const [
      'Grandfather Name (maternal)Ar',
      'Mothers Father NameAr',
      "Mother's Father NameAr",
      'Maternal Grandfather NameAr',
      'Maternal Grandfathers NameAr',
      'Mother Father NameAr',
    ]);
    if (motherName != null || maternalGf != null) {
      final combined = _joinNameParts([motherName, maternalGf]);
      if (combined != null) {
        put('arMother', combined);
      }
    }
  }

  put('gender', _normalizeGender(_firstSectionValue(section, const ['Sex', 'SexAr'])));
  put(
    'nationality',
    _normalizeNationality(
      _sectionValue(section, 'Nationality') ??
          _nationalityFromCode(_sectionValue(section, 'Nationality Code')),
    ),
  );
  put('dob', _normalizeDate(_sectionValue(section, 'Date of Birth')));
  put(
    'countryBirth',
    _meaningfulSectionValue(section, const [
      'Country of Birth',
      'Issuing State Name',
    ]),
  );
  put(
    'placeBirth',
    _truncatePlaceBirth(
      _meaningfulSectionValue(section, const [
        'Place of Birth',
        'Place of BirthAr',
      ]),
    ),
  );

  put(
    'idPersonal',
    _firstSectionValue(section, const [
      'Personal Number',
      'Optional Data',
    ]),
  );
  put(
    'idSerial',
    _firstSectionValue(section, const [
      'Document Number',
      'Identity Card Number',
    ]),
  );
  put(
    'idIssuePlace',
    _meaningfulSectionValue(section, const [
      'Place of Issue',
      'Place of IssueAr',
      'AuthorityAr',
      'Issuing State Name',
    ]),
  );
  put('idIssueDate', _normalizeDate(_sectionValue(section, 'Date of Issue')));
  put('idExpiryDate', _normalizeDate(_sectionValue(section, 'Date of Expiry')));
  _mirrorArabicNamesToEnglish(out);
}

  static void _putNationalIdEnglishNames(
    Map<String, String> out,
    Map<String, dynamic> section,
  ) {
    void put(String key, String? value) {
      final v = _clean(value);
      if (v != null && !out.containsKey(key)) out[key] = v;
    }

    final rawSurname = _sectionValue(section, 'Surname');
    final givenNamesAr = _sectionValue(section, 'Given NamesAr');
    final hasSurnameGivenArPair =
        rawSurname != null && givenNamesAr != null;

    // Iraqi NFC / visual: prefer Latin surname + Arabic given name for backend.
    if (hasSurnameGivenArPair) {
      put('idEnSurname', _titleCase(rawSurname));
      put('idEnFirst', givenNamesAr);
    } else {
      final surname = _titleCase(rawSurname);
      final givenNames = _sectionValue(section, 'Given Names');

      if (surname != null) put('idEnSurname', surname);

      if (givenNames != null) {
        final parts = givenNames.split(RegExp(r'\s+'));
        if (parts.isNotEmpty) put('idEnFirst', _titleCase(parts.first));
        if (parts.length > 1) put('idEnFather', _titleCase(parts[1]));
        if (parts.length > 2) put('idEnGf', _titleCase(parts[2]));
      } else {
        final visualFull = _sectionValue(section, 'Surname And Given Names');
        if (visualFull != null && !_looksLikeAllCapsMrz(visualFull)) {
          final parts = visualFull.split(RegExp(r'\s+'));
          if (parts.length >= 2) {
            put('idEnFirst', _titleCase(parts.first));
            if (parts.length == 2) {
              put('idEnSurname', _titleCase(parts[1]));
            } else {
              put('idEnSurname', _titleCase(parts.last));
              if (parts.length > 2) {
                put(
                  'idEnFather',
                  _titleCase(parts.sublist(1, parts.length - 1).join(' ')),
                );
              }
            }
          }
        } else {
          final mrzFull = _sectionValue(section, 'Surname And Given Names');
          if (mrzFull != null) {
            final parts = mrzFull.split(RegExp(r'\s+'));
            if (parts.isNotEmpty) put('idEnSurname', _titleCase(parts.first));
            if (parts.length > 1) put('idEnFirst', _titleCase(parts[1]));
            if (parts.length > 2) put('idEnFather', _titleCase(parts[2]));
            if (parts.length > 3) put('idEnGf', _titleCase(parts[3]));
          }
        }
      }
    }

    put(
      'idEnMother',
      _motherNameWithMaternalGrandfather(section, arabic: false) ??
          _firstSectionValue(section, const [
            'Mothers Name',
            "Mother's Name",
            'Mother Name',
            'Mothers NameAr',
          ]),
    );
  }

  static void _putEnglishNames(Map<String, String> out, Map<String, dynamic> section) {
    void put(String key, String? value) {
      final v = _clean(value);
      if (v != null && !out.containsKey(key)) out[key] = v;
    }

    final surname = _titleCase(_sectionValue(section, 'Surname'));
    final givenNames = _sectionValue(section, 'Given Names');

    if (surname != null) put('enSurname', surname);

    if (givenNames != null) {
      final parts = givenNames.split(RegExp(r'\s+'));
      if (parts.isNotEmpty) put('enFirst', _titleCase(parts.first));
      if (parts.length > 1) put('enFather', _titleCase(parts[1]));
      if (parts.length > 2) put('enGf', _titleCase(parts[2]));
      return;
    }

    final visualFull = _sectionValue(section, 'Surname And Given Names');
    if (visualFull != null && !_looksLikeAllCapsMrz(visualFull)) {
      final parts = visualFull.split(RegExp(r'\s+'));
      if (parts.length >= 2) {
        put('enFirst', _titleCase(parts.first));
        if (parts.length == 2) {
          put('enSurname', _titleCase(parts[1]));
        } else {
          put('enSurname', _titleCase(parts.last));
          if (parts.length > 2) {
            put('enFather', _titleCase(parts.sublist(1, parts.length - 1).join(' ')));
          }
        }
      }
      return;
    }

    // MRZ order: SURNAME GIVEN1 GIVEN2…
    final mrzFull = _sectionValue(section, 'Surname And Given Names');
    if (mrzFull != null) {
      final parts = mrzFull.split(RegExp(r'\s+'));
      if (parts.isNotEmpty) put('enSurname', _titleCase(parts.first));
      if (parts.length > 1) put('enFirst', _titleCase(parts[1]));
      if (parts.length > 2) put('enFather', _titleCase(parts[2]));
      if (parts.length > 3) put('enGf', _titleCase(parts[3]));
    }
  }

  // static void _putArabicNames(Map<String, String> out, Map<String, dynamic> section) {
  //   void put(String key, String? value) {
  //     final v = _clean(value);
  //     if (v != null && !out.containsKey(key)) out[key] = v;
  //   }

  //   // Iraqi national ID Visual layout (split Arabic name fields).
  //   final surnameAr = _sectionValue(section, 'SurnameAr');
  //   final givenAr = _firstSectionValue(section, const ['Given NamesAr', 'Given NameAr']);
  //   final fatherAr = _firstSectionValue(section, const [
  //     'Fathers NameAr',
  //     "Father's NameAr",
  //     'Father NameAr',
  //   ]);
  //   final gfAr = _firstSectionValue(section, const [
  //     'Grandfather NameAr',
  //     'Grandfathers NameAr',
  //   ]);

  //   if (givenAr != null || surnameAr != null || fatherAr != null || gfAr != null) {
  //     put('arFirst', givenAr);
  //     put('arSurname', surnameAr);
  //     put('arFather', fatherAr);
  //     put('arGf', gfAr);
  //     put(
  //       'arMother',
  //       _motherNameWithMaternalGrandfather(section, arabic: true),
  //     );
  //     return;
  //   }

  //   final fullAr = _firstSectionValue(section, const [
  //     'Surname And Given NamesAr',
  //     'Surname And Given Names Ar',
  //   ]);
  //   if (fullAr == null) return;

  //   final parts = fullAr.split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
  //   if (parts.isEmpty) return;

  //   if (parts.length == 1) {
  //     put('arFirst', parts[0]);
  //     return;
  //   }

  //   put('arSurname', parts.last);
  //   put('arFirst', parts.first);
  //   if (parts.length == 3) {
  //     put('arFather', parts[1]);
  //   } else if (parts.length > 3) {
  //     put('arFather', parts[1]);
  //     put('arGf', parts.sublist(2, parts.length - 1).join(' '));
  //   } else if (parts.length == 2) {
  //     put('arFirst', parts[0]);
  //   }
  // }
  static void _putArabicNames(Map<String, String> out, Map<String, dynamic> section) {
  void put(String key, String? value) {
    final v = _clean(value);
    if (v != null && !out.containsKey(key)) out[key] = v;
  }

  // NFC full Arabic name — preserve for backend when chip provides it.
  final surnameAndGivenNamesAr = _firstSectionValue(section, const [
    'Surname And Given NamesAr',
    'Surname And Given Names Ar',
  ]);
  if (surnameAndGivenNamesAr != null) {
    put('surnameAndGivenNamesAr', surnameAndGivenNamesAr);
  }

  // Iraqi national ID Visual layout (split Arabic name fields).
  final surnameAr = _sectionValue(section, 'SurnameAr');
  final givenAr = _firstSectionValue(section, const [
    'Given NamesAr',
    'Given NameAr',
  ]);
  final fatherAr = _firstSectionValue(section, const [
    'Fathers NameAr',
    "Father's NameAr",
    'Father NameAr',
  ]);
  final gfAr = _firstSectionValue(section, const [
    'Grandfather NameAr',
    'Grandfathers NameAr',
  ]);

  // Handle mother + maternal grandfather from NFC
  final motherName = _firstSectionValue(section, const [
    'Mothers NameAr',
    "Mother's NameAr",
    'Mother NameAr',
  ]);
  final maternalGf = _firstSectionValue(section, const [
    'Grandfather Name (maternal)Ar', // NFC key
    'Mothers Father NameAr',
    "Mother's Father NameAr",
    'Maternal Grandfather NameAr',
    'Maternal Grandfathers NameAr',
    'Mother Father NameAr',
  ]);

  if (givenAr != null || surnameAr != null || fatherAr != null || gfAr != null) {
    put('arFirst', givenAr);
    put('arSurname', surnameAr);
    put('arFather', fatherAr);
    put('arGf', gfAr);
    
    // Handle mother name with maternal grandfather
    if (motherName != null || maternalGf != null) {
      final combined = _joinNameParts([motherName, maternalGf]);
      if (combined != null) {
        put('arMother', combined);
      }
    }
    return;
  }

  // If we have full name in Arabic (Surname And Given NamesAr)
  final fullAr = _firstSectionValue(section, const [
    'Surname And Given NamesAr',
    'Surname And Given Names Ar',
  ]);
  if (fullAr != null) {
    final parts = fullAr.split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isNotEmpty) {
      if (parts.length == 1) {
        put('arFirst', parts[0]);
      } else {
        put('arSurname', parts.last);
        put('arFirst', parts.first);
        if (parts.length >= 3) {
          put('arFather', parts[1]);
          if (parts.length > 3) {
            put('arGf', parts.sublist(2, parts.length - 1).join(' '));
          }
        } else if (parts.length == 2) {
          put('arFirst', parts[0]);
        }
      }
      
      // Handle mother name with maternal grandfather
      if (motherName != null || maternalGf != null) {
        final combined = _joinNameParts([motherName, maternalGf]);
        if (combined != null) {
          put('arMother', combined);
        }
      }
      return;
    }
  }

  // Last resort: try to extract from individual fields
  if (motherName != null || maternalGf != null) {
    final combined = _joinNameParts([motherName, maternalGf]);
    if (combined != null) {
      put('arMother', combined);
    }
  }
}

  /// Iraqi ID: mother's name field = mother + maternal grandfather.
  // static String? _motherNameWithMaternalGrandfather(
  //   Map<String, dynamic> section, {
  //   required bool arabic,
  // }) {
  //   final motherKeys = arabic
  //       ? const [
  //           'Mothers NameAr',
  //           "Mother's NameAr",
  //           'Mother NameAr',
  //         ]
  //       : const [
  //           'Mothers Name',
  //           "Mother's Name",
  //           'Mother Name',
  //         ];
  //   final maternalGfKeys = arabic
  //       ? const [
  //           'Mothers Father NameAr',
  //           "Mother's Father NameAr",
  //           'Mothers Fathers NameAr',
  //           'Maternal Grandfather NameAr',
  //           'Maternal Grandfathers NameAr',
  //           'Mother Father NameAr',
  //         ]
  //       : const [
  //           'Mothers Father Name',
  //           "Mother's Father Name",
  //           'Maternal Grandfather Name',
  //           'Maternal Grandfathers Name',
  //           'Mother Father Name',
  //         ];

  //   return _joinNameParts([
  //     _firstSectionValue(section, motherKeys),
  //     _firstSectionValue(section, maternalGfKeys),
  //   ]);
  // }
  static String? _motherNameWithMaternalGrandfather(
  Map<String, dynamic> section, {
  required bool arabic,
}) {
  final motherKeys = arabic
      ? const [
          'Mothers NameAr',
          "Mother's NameAr",
          'Mother NameAr',
          'Mothers Name', // Fallback to English if Arabic not found
          "Mother's Name",
          'Mother Name',
        ]
      : const [
          'Mothers Name',
          "Mother's Name",
          'Mother Name',
          'Mothers NameAr', // Fallback to Arabic if English not found
          "Mother's NameAr",
          'Mother NameAr',
        ];
  
  final maternalGfKeys = arabic
      ? const [
          'Grandfather Name (maternal)Ar', // NFC key
          'Mothers Father NameAr',
          "Mother's Father NameAr",
          'Mothers Fathers NameAr',
          'Maternal Grandfather NameAr',
          'Maternal Grandfathers NameAr',
          'Mother Father NameAr',
          'Mothers Father Name', // Fallback to English
          "Mother's Father Name",
          'Maternal Grandfather Name',
          'Maternal Grandfathers Name',
          'Mother Father Name',
        ]
      : const [
          'Grandfather Name (maternal)Ar', // NFC key
          'Mothers Father Name',
          "Mother's Father Name",
          'Maternal Grandfather Name',
          'Maternal Grandfathers Name',
          'Mother Father Name',
          'Mothers Father NameAr', // Fallback to Arabic
          "Mother's Father NameAr",
          'Maternal Grandfather NameAr',
          'Maternal Grandfathers NameAr',
          'Mother Father NameAr',
        ];

  final mother = _firstSectionValue(section, motherKeys);
  final maternalGf = _firstSectionValue(section, maternalGfKeys);
  
  // Special handling for the exact NFC keys
  if (!arabic && mother == null && maternalGf == null) {
    // Try the Arabic keys as last resort
    final arabicMother = _firstSectionValue(section, const ['Mothers NameAr', "Mother's NameAr", 'Mother NameAr']);
    final arabicGf = _firstSectionValue(section, const ['Grandfather Name (maternal)Ar', 'Mothers Father NameAr']);
    if (arabicMother != null || arabicGf != null) {
      return _joinNameParts([arabicMother, arabicGf]);
    }
  }
  
  return _joinNameParts([mother, maternalGf]);
}

  static String? _joinNameParts(List<String?> parts) {
    final tokens = parts
        .map((p) => p?.trim())
        .whereType<String>()
        .where((p) => p.isNotEmpty && !_isPlaceholderValue(p))
        .toList();
    if (tokens.isEmpty) return null;
    return tokens.join(' ');
  }

  static bool _looksLikeAllCapsMrz(String value) {
    final letters = value.replaceAll(RegExp(r'[^A-Za-z]'), '');
    if (letters.isEmpty) return false;
    return letters == letters.toUpperCase();
  }

  /// True when iPass payload contains scanned document fields.
  static bool hasDocumentDetails(Map<String, dynamic>? ipassData) {
    if (ipassData == null || ipassData.isEmpty) return false;
    final root = _resolveDataRoot(ipassData);
    final docDetails = root['DocDetails'];
    return docDetails is Map && docDetails.isNotEmpty;
  }

  static String? _normalizeNationality(String? raw) {
    if (raw == null) return null;
    final v = raw.trim();
    if (v.isEmpty) return null;
    final compact = v.replaceAll(RegExp(r'[\s<]'), '').toUpperCase();
    final lower = v.toLowerCase();
    if (compact == 'IRQ' ||
        compact == 'IQI' ||
        compact == 'IQ' ||
        compact == 'RAQI' ||
        lower == 'iraq' ||
        lower == 'iraqi' ||
        lower == 'raqi' ||
        lower.contains('iraq') ||
        v == 'عراقي' ||
        v.contains('عراق')) {
      return 'Iraqi';
    }
    return _nationalityFromCode(compact) ?? v;
  }

  static String? _nationalityFromCode(String? code) {
    if (code == null) return null;
    const map = {
      'IRQ': 'Iraqi',
      'IND': 'Indian',
      'ARE': 'Emirati',
      'UAE': 'Emirati',
      'JOR': 'Jordanian',
      'EGY': 'Egyptian',
      'SAU': 'Saudi',
    };
    return map[code.toUpperCase()] ?? code;
  }

  static String? _sectionValue(Map<String, dynamic> section, String key) {
    final value = section[key];
    if (value == null) return null;
    final text = value.toString().trim();
    return text.isEmpty ? null : text;
  }

  static String? _firstSectionValue(Map<String, dynamic> section, List<String> keys) {
    for (final key in keys) {
      final value = _sectionValue(section, key);
      if (value != null) return value;
    }
    return null;
  }

  static String? _meaningfulSectionValue(Map<String, dynamic> section, List<String> keys) {
    for (final key in keys) {
      final value = _sectionValue(section, key);
      if (value != null && !_isPlaceholderValue(value)) return value;
    }
    return null;
  }

  static bool _isPlaceholderValue(String value) {
    final v = value.trim();
    if (v.isEmpty || v == '?' || v == '-' || v.toLowerCase() == 'n/a') return true;
    return false;
  }

  static String? _truncatePlaceBirth(String? value) {
    if (value == null) return null;
    if (value.length <= 20) return value;
    return value.substring(0, 20);
  }

  static void _mapFromFlat(
    Map<String, String> out,
    Map<String, String> flat, {
    required IpassScanTarget target,
  }) {
    void put(String key, String? value) {
      final v = _clean(value);
      if (v != null && !out.containsKey(key)) out[key] = v;
    }

    switch (target) {
      case IpassScanTarget.residence:
        put('resNo', _first(flat, const [
          'residencecardnumber',
          'personalnumber',
          'identitycardnumber',
          'documentnumber',
        ]));
        put('resPlace', _first(flat, const ['placeofissue', 'residenceplaceofissue', 'issuingstatename']));
        put('resIssue', _normalizeDate(_first(flat, const ['dateofissue', 'residenceissuedate'])));
        put('resExpiry', _normalizeDate(_first(flat, const ['dateofexpiry', 'residenceexpirydate'])));
        return;
      case IpassScanTarget.passport:
        if (!out.containsKey('enFirst')) {
          put('enFirst', _first(flat, const ['givennames', 'givenname', 'englishfirstname']));
        }
        if (!out.containsKey('enSurname')) {
          put('enSurname', _first(flat, const ['surname', 'englishsurname', 'familyname']));
        }
        if (!out.containsKey('enFather')) {
          put('enFather', _first(flat, const ['fathersname', 'fathername']));
        }
        if (!out.containsKey('enGf')) {
          put('enGf', _first(flat, const ['grandfathername', 'grandfathersname']));
        }
        if (!out.containsKey('enMother')) {
          put(
            'enMother',
            _joinNameParts([
              _first(flat, const ['mothersname', 'mothername']),
              _first(flat, const [
                'mothersfathername',
                'motherfathername',
                'maternalgrandfathername',
              ]),
            ]),
          );
        }
        put('ppNo', _first(flat, const ['passportnumber', 'passportno', 'documentnumber']));
        put('ppPlace', _first(flat, const ['passportplaceofissue', 'placeofissue', 'issuingstatename']));
        put('ppIssue', _normalizeDate(_first(flat, const ['passportdateofissue', 'dateofissue'])));
        put('ppExpiry', _normalizeDate(_first(flat, const ['passportdateofexpiry', 'dateofexpiry'])));
        put('gender', _normalizeGender(_first(flat, const ['sex', 'sexar', 'gender'])));
        put(
          'nationality',
          _normalizeNationality(
            _first(flat, const ['nationality', 'nationalityname']) ??
                _nationalityFromCode(_first(flat, const ['nationalitycode'])),
          ),
        );
        put('dob', _normalizeDate(_first(flat, const ['dateofbirth', 'dob', 'birthdate'])));
        put('countryBirth', _first(flat, const ['issuingstatename', 'countryofbirth']));
        put('placeBirth', _first(flat, const ['placeofbirth', 'birthplace']));
        return;
      case IpassScanTarget.nationalId:
        _mapFromFlatNationalId(out, flat, put);
        return;
    }
  }

  static void _mapFromFlatNationalId(
    Map<String, String> out,
    Map<String, String> flat,
    void Function(String key, String? value) put,
  ) {
    if (!out.containsKey('idEnFirst')) {
      put('idEnFirst', _first(flat, const ['givennames', 'givenname', 'englishfirstname']));
    }
    if (!out.containsKey('idEnSurname')) {
      put('idEnSurname', _first(flat, const ['surname', 'englishsurname', 'familyname']));
    }
    if (!out.containsKey('idEnFather')) {
      put('idEnFather', _first(flat, const ['fathersname', 'fathername']));
    }
    if (!out.containsKey('idEnGf')) {
      put('idEnGf', _first(flat, const ['grandfathername', 'grandfathersname']));
    }
    if (!out.containsKey('idEnMother')) {
      put(
        'idEnMother',
        _joinNameParts([
          _first(flat, const ['mothersname', 'mothername']),
          _first(flat, const [
            'mothersfathername',
            'motherfathername',
            'maternalgrandfathername',
          ]),
        ]),
      );
    }
    if (!out.containsKey('arFirst')) {
      put('arFirst', _first(flat, const [
        'givennamesar',
        'givennamear',
        'surnameandgivennamesar',
        'arabicfirstname',
      ]));
    }
    if (!out.containsKey('arSurname')) {
      put('arSurname', _first(flat, const ['surnamear', 'arabicsurname']));
    }
    if (!out.containsKey('arFather')) {
      put('arFather', _first(flat, const ['fathersnamear', 'fathernamear']));
    }
    if (!out.containsKey('arGf')) {
      put('arGf', _first(flat, const ['grandfathernamear', 'grandfathersnamear']));
    }
    if (!out.containsKey('arMother')) {
      put(
        'arMother',
        _joinNameParts([
          _first(flat, const ['mothersnamear', 'mothernamear']),
          _first(flat, const [
            'mothersfathernamear',
            'motherfathernamear',
            'maternalgrandfathernamear',
            'mothersfathersnamear',
          ]),
        ]),
      );
    }
    put(
      'surnameAndGivenNamesAr',
      _first(flat, const ['surnameandgivennamesar', 'surnameandgivennames']),
    );

    put('gender', _normalizeGender(_first(flat, const ['sex', 'sexar', 'gender'])));
    put(
      'nationality',
      _normalizeNationality(
        _first(flat, const ['nationality', 'nationalityname']) ??
            _nationalityFromCode(_first(flat, const ['nationalitycode'])),
      ),
    );
    put('dob', _normalizeDate(_first(flat, const ['dateofbirth', 'dob', 'birthdate'])));
    put('countryBirth', _first(flat, const ['issuingstatename', 'countryofbirth', 'birthcountry']));
    put('placeBirth', _truncatePlaceBirth(_first(flat, const [
      'placeofbirth',
      'placeofbirthar',
      'birthplace',
    ])));

    put(
      'idPersonal',
      _first(flat, const [
        'personalnumber',
        'identitycardnumber',
        'optionaldata',
      ]),
    );
    put('idSerial', _first(flat, const ['documentnumber', 'identitycardnumber', 'cardserialnumber', 'idnumber']));
    put('idIssuePlace', _first(flat, const [
      'placeofissue',
      'placeofissuear',
      'issueplace',
      'issuingauthority',
      'issuingstatename',
    ]));
    put('idIssueDate', _normalizeDate(_first(flat, const ['dateofissue', 'issuedate'])));
    put('idExpiryDate', _normalizeDate(_first(flat, const ['dateofexpiry', 'expirydate'])));
  }

  static Map<String, String> _flatten(
    Map<String, dynamic> source, [
    String prefix = '',
  ]) {
    final out = <String, String>{};
    for (final entry in source.entries) {
      final key = prefix.isEmpty ? entry.key : '$prefix.${entry.key}';
      final normalizedKey = _normalizeKey(entry.key);
      final value = entry.value;
      if (value == null) continue;
      if (value is Map) {
        out.addAll(_flatten(Map<String, dynamic>.from(value), key));
        out.addAll(_flatten(Map<String, dynamic>.from(value)));
      } else if (value is List) {
        for (final item in value) {
          if (item is Map) {
            out.addAll(_flatten(Map<String, dynamic>.from(item), key));
            out.addAll(_flatten(Map<String, dynamic>.from(item)));
          } else if (item is String && item.trim().isNotEmpty) {
            // Skip Reason[].Text noise for flat fallback.
          }
        }
      } else {
        final text = value.toString().trim();
        if (text.isNotEmpty) {
          out[normalizedKey] = text;
          out[_normalizeKey(key)] = text;
        }
      }
    }
    return out;
  }

  static String _normalizeKey(String key) {
    return key.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '').toLowerCase();
  }

  static String? _first(Map<String, String> flat, List<String> keys) {
    for (final key in keys) {
      final direct = flat[_normalizeKey(key)];
      if (direct != null && direct.isNotEmpty) return direct;
    }
    return null;
  }

  static String? _clean(String? value) {
    if (value == null) return null;
    final v = value.trim();
    return v.isEmpty ? null : v;
  }

  static String? _titleCase(String? value) {
    if (value == null) return null;
    if (_looksLikeAllCapsMrz(value)) {
      return value
          .toLowerCase()
          .split(RegExp(r'\s+'))
          .map((w) => w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1)}')
          .join(' ');
    }
    return value;
  }

  static String? _normalizeGender(String? raw) {
    if (raw == null) return null;
    final v = raw.trim().toLowerCase();
    if (v == 'm' || v == 'male' || v == '1' || v == 'ذكر') return 'Male';
    if (v == 'f' || v == 'female' || v == '2' || v == 'أنثى' || v == 'انثى') return 'Female';
    return null;
  }

  static String? _normalizeDate(String? raw) {
    if (raw == null) return null;
    final v = raw.trim();
    if (v.isEmpty) return null;

    final iso = RegExp(r'^(\d{4})-(\d{2})-(\d{2})');
    final isoMatch = iso.firstMatch(v);
    if (isoMatch != null) {
      return '${isoMatch.group(1)}-${isoMatch.group(2)}-${isoMatch.group(3)}';
    }

    final dmy = RegExp(r'^(\d{2})[./-](\d{2})[./-](\d{4})');
    final dmyMatch = dmy.firstMatch(v);
    if (dmyMatch != null) {
      return '${dmyMatch.group(3)}-${dmyMatch.group(2)}-${dmyMatch.group(1)}';
    }

    try {
      final parsed = DateTime.parse(v);
      return '${parsed.year.toString().padLeft(4, '0')}-'
          '${parsed.month.toString().padLeft(2, '0')}-'
          '${parsed.day.toString().padLeft(2, '0')}';
    } catch (_) {
      return v;
    }
  }

  /// Accepted sample scan used when iPass returns [OverAllStatus] REJECTED but demo
  /// bypass is enabled and the rejected payload has no mappable fields.
  static Map<String, dynamic> demoAcceptedScanEnvelope(IpassScanTarget target) {
    switch (target) {
      case IpassScanTarget.nationalId:
        return {
          'Apistatus': true,
          'Apimessage': 'Success',
          'data': {
            'OverAllStatus': 'PASSED',
            'DocType': 'Identity Card',
            'DocDetails': {
              'MRZ': {
                'Document Number': 'E12350562',
                'Personal Number': '196776318202',
                'Date of Birth': '03-07-1967',
                'Date of Expiry': '17-04-2034',
                'Sex': 'M',
                'Nationality': 'Iraq',
                'Nationality Code': 'IRQ',
                'Issuing State Name': 'Iraq',
                'Given Names': 'ZYD',
                'Surname': 'ALSMYSM',
                'Surname And Given Names': 'ALSMYSM ZYD',
              },
              'Visual': {
                'Document Number': 'E12350562',
                'Personal Number': '196776318202',
                'Given NamesAr': 'زيد',
                'Fathers NameAr': 'عبد الكريم',
                'SexAr': 'ذكر',
                'Mothers NameAr': 'ملكه',
                'SurnameAr': 'السميسم',
                'Grandfather NameAr': 'مهدي',
                'Date of Issue': '18-04-2024',
                'Place of BirthAr': 'كر-بداد',
                'Identity Card Number': '1012L000M710008503',
                'AuthorityAr': 'Iraq',
              },
            },
          },
        };
      case IpassScanTarget.passport:
        return {
          'Apistatus': true,
          'Apimessage': 'Success',
          'data': {
            'OverAllStatus': 'PASSED',
            'DocType': 'Passport',
            'DocDetails': {
              'MRZ': {
                'Document Number': 'B25909628',
                'Date of Birth': '15-03-1990',
                'Date of Expiry': '14-03-2030',
                'Sex': 'M',
                'Nationality': 'Iraq',
                'Nationality Code': 'IRQ',
                'Issuing State Name': 'Iraq',
                'Given Names': 'HUSSEIN',
                'Surname': 'ALI',
              },
              'Visual': {
                'Document Number': 'B25909628',
                'Given Names': 'Hussein',
                'Surname': 'Ali',
                'Fathers Name': 'Mahdi',
                'Grandfather Name': 'Hassan',
                'Mothers Name': 'Fatima',
                'Date of Issue': '15-03-2020',
                'Date of Expiry': '14-03-2030',
                'Place of Birth': 'Baghdad',
              },
            },
          },
        };
      case IpassScanTarget.residence:
        return {};
    }
  }

  /// Mapped form values from [demoAcceptedScanEnvelope] for the given scan target.
  static Map<String, String> demoAcceptedMappedFields(IpassScanTarget target) {
    final envelope = demoAcceptedScanEnvelope(target);
    if (envelope.isEmpty) return {};
    return extractFieldValues(envelope, target: target);
  }
}
