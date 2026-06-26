import 'dart:convert';
import 'dart:io';

import 'package:baghdad_bullion_house/core/kyc/kyc_document_review_status.dart';
import 'package:baghdad_bullion_house/data/models/ipass_model/ipass_formdata_result_response.dart';
import 'package:baghdad_bullion_house/services/ipass_kyc/ipass_kyc_service.dart';
import 'package:baghdad_bullion_house/services/ipass_kyc/ipass_onboarding_mapper.dart';
import 'package:flutter/foundation.dart';
import 'package:get_storage/get_storage.dart';
import 'package:path_provider/path_provider.dart';

/// Persists in-progress document re-submission (separate from onboarding).
class KycDocumentUpdateStore {
  KycDocumentUpdateStore._();

  static final KycDocumentUpdateStore instance = KycDocumentUpdateStore._();

  static const _stateKey = 'kyc_document_update_state_v1';
  static const _imageUrlKey = 'kyc_document_update_image_urls_v1';
  static const _dirName = 'kyc_document_update_scans';

  final _box = GetStorage();

  Future<Directory> _scanDir() async {
    final base = await getApplicationDocumentsDirectory();
    final dir = Directory('${base.path}/$_dirName');
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  String _stateFileKey(KycDocumentType type) => '${type.name}_state.json';
  String _scanFileName(KycDocumentType type) {
    final key = IpassOnboardingMapper.scanTargetKeys[type.scanTarget];
    return '${key ?? type.name}.json';
  }

  Future<void> saveState({
    required KycDocumentType type,
    required Map<String, dynamic> formJson,
    required String step,
  }) async {
    try {
      final dir = await _scanDir();
      final file = File('${dir.path}/${_stateFileKey(type)}');
      await file.writeAsString(
        jsonEncode({
          'documentType': type.name,
          'step': step,
          'form': formJson,
          'savedAt': DateTime.now().toUtc().toIso8601String(),
        }),
      );
      _box.write('$_stateKey|${type.name}', step);
    } catch (e) {
      if (kDebugMode) debugPrint('KycDocumentUpdateStore.saveState: $e');
    }
  }

  Future<Map<String, dynamic>?> loadState(KycDocumentType type) async {
    try {
      final dir = await _scanDir();
      final file = File('${dir.path}/${_stateFileKey(type)}');
      if (!await file.exists()) return null;
      final decoded = jsonDecode(await file.readAsString());
      if (decoded is! Map) return null;
      return Map<String, dynamic>.from(decoded);
    } catch (e) {
      if (kDebugMode) debugPrint('KycDocumentUpdateStore.loadState: $e');
      return null;
    }
  }

  Future<void> saveIpassScan(
    KycDocumentType type,
    IpassKycResult result,
  ) async {
    try {
      final dir = await _scanDir();
      final file = File('${dir.path}/${_scanFileName(type)}');
      await file.writeAsString(jsonEncode(result.toJson()));
    } catch (e) {
      if (kDebugMode) debugPrint('KycDocumentUpdateStore.saveIpassScan: $e');
    }
  }

  Future<IpassKycResult?> loadIpassScan(KycDocumentType type) async {
    if (type == KycDocumentType.residency) return null;
    try {
      final dir = await _scanDir();
      final file = File('${dir.path}/${_scanFileName(type)}');
      if (!await file.exists()) return null;
      final decoded = jsonDecode(await file.readAsString());
      if (decoded is! Map) return null;
      final map = decoded is Map<String, dynamic>
          ? decoded
          : Map<String, dynamic>.from(decoded);
      return IpassKycResult.fromJson(map);
    } catch (e) {
      if (kDebugMode) debugPrint('KycDocumentUpdateStore.loadIpassScan: $e');
      return null;
    }
  }

  Future<void> saveResidenceScans({
    IpassFormDataResultResponse? front,
    IpassFormDataResultResponse? back,
  }) async {
    try {
      final dir = await _scanDir();
      if (front != null) {
        await File('${dir.path}/residence_front.json').writeAsString(
          jsonEncode(front.toJson()),
        );
      }
      if (back != null) {
        await File('${dir.path}/residence_back.json').writeAsString(
          jsonEncode(back.toJson()),
        );
      }
    } catch (e) {
      if (kDebugMode) debugPrint('KycDocumentUpdateStore.saveResidence: $e');
    }
  }

  Future<({IpassFormDataResultResponse? front, IpassFormDataResultResponse? back})>
      loadResidenceScans() async {
    try {
      final dir = await _scanDir();
      IpassFormDataResultResponse? front;
      IpassFormDataResultResponse? back;

      final frontFile = File('${dir.path}/residence_front.json');
      if (await frontFile.exists()) {
        final decoded = jsonDecode(await frontFile.readAsString());
        if (decoded is Map) {
          front = IpassFormDataResultResponse.fromJson(
            Map<String, dynamic>.from(decoded),
          );
        }
      }

      final backFile = File('${dir.path}/residence_back.json');
      if (await backFile.exists()) {
        final decoded = jsonDecode(await backFile.readAsString());
        if (decoded is Map) {
          back = IpassFormDataResultResponse.fromJson(
            Map<String, dynamic>.from(decoded),
          );
        }
      }

      return (front: front, back: back);
    } catch (e) {
      if (kDebugMode) debugPrint('KycDocumentUpdateStore.loadResidence: $e');
      return (front: null, back: null);
    }
  }

  Future<void> saveImageUrls(Map<String, String> urls) async {
    try {
      _box.write(_imageUrlKey, urls);
    } catch (e) {
      if (kDebugMode) debugPrint('KycDocumentUpdateStore.saveImageUrls: $e');
    }
  }

  Future<Map<String, String>> loadImageUrls() async {
    try {
      final raw = _box.read(_imageUrlKey);
      if (raw is! Map) return {};
      return raw.map((k, v) => MapEntry(k.toString(), v.toString()));
    } catch (e) {
      return {};
    }
  }

  Future<void> clear(KycDocumentType type) async {
    try {
      final dir = await _scanDir();
      for (final name in [
        _stateFileKey(type),
        _scanFileName(type),
        if (type == KycDocumentType.residency) ...[
          'residence_front.json',
          'residence_back.json',
        ],
      ]) {
        final file = File('${dir.path}/$name');
        if (await file.exists()) await file.delete();
      }
      _box.remove('$_stateKey|${type.name}');

      final urls = await loadImageUrls();
      final scanKey = type.apiKey;
      urls.removeWhere((key, _) => key.startsWith('$scanKey|'));
      await saveImageUrls(urls);
    } catch (e) {
      if (kDebugMode) debugPrint('KycDocumentUpdateStore.clear: $e');
    }
  }
}
