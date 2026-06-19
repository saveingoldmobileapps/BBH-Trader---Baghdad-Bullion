import 'dart:convert';
import 'dart:io';

import 'package:baghdad_bullion_house/data/models/ipass_model/ipass_formdata_result_response.dart';
import 'package:baghdad_bullion_house/services/ipass_kyc/ipass_kyc_service.dart';
import 'package:baghdad_bullion_house/services/ipass_kyc/ipass_onboarding_mapper.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

/// Persists iPass scan payloads (incl. base64 images) to disk for resume after app kill.
class BbhOnboardingScanStore {
  BbhOnboardingScanStore._();

  static final BbhOnboardingScanStore instance = BbhOnboardingScanStore._();

  static const _dirName = 'bbh_onboarding_scans';
  static const _residenceFrontFile = 'residence_front.json';
  static const _residenceBackFile = 'residence_back.json';

  Future<Directory> _scanDir() async {
    final base = await getApplicationDocumentsDirectory();
    final dir = Directory('${base.path}/$_dirName');
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  String _ipassFileName(IpassScanTarget target) {
    final key = IpassOnboardingMapper.scanTargetKeys[target];
    return '${key ?? target.name}.json';
  }

  Future<void> saveIpassScans(
    Map<IpassScanTarget, IpassKycResult> results,
  ) async {
    try {
      final dir = await _scanDir();
      final activeFiles = <String>{};

      for (final entry in results.entries) {
        final fileName = _ipassFileName(entry.key);
        activeFiles.add(fileName);
        final file = File('${dir.path}/$fileName');
        await file.writeAsString(jsonEncode(entry.value.toJson()));
      }

      await _pruneIpassFiles(dir, activeFiles);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('BbhOnboardingScanStore.saveIpassScans error: $e');
      }
    }
  }

  Future<void> _pruneIpassFiles(
    Directory dir,
    Set<String> activeFiles,
  ) async {
    for (final target in IpassScanTarget.values) {
      if (target == IpassScanTarget.residence) continue;
      final fileName = _ipassFileName(target);
      if (!activeFiles.contains(fileName)) {
        final file = File('${dir.path}/$fileName');
        if (await file.exists()) await file.delete();
      }
    }
  }

  Future<Map<IpassScanTarget, IpassKycResult>> loadIpassScans() async {
    final out = <IpassScanTarget, IpassKycResult>{};
    try {
      final dir = await _scanDir();
      for (final target in IpassScanTarget.values) {
        if (target == IpassScanTarget.residence) continue;
        final file = File('${dir.path}/${_ipassFileName(target)}');
        if (!await file.exists()) continue;
        final decoded = jsonDecode(await file.readAsString());
        if (decoded is! Map) continue;
        final map = decoded is Map<String, dynamic>
            ? decoded
            : Map<String, dynamic>.from(decoded);
        out[target] = IpassKycResult.fromJson(map);
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('BbhOnboardingScanStore.loadIpassScans error: $e');
      }
    }
    return out;
  }

  Future<void> saveResidenceScans({
    IpassFormDataResultResponse? front,
    IpassFormDataResultResponse? back,
  }) async {
    try {
      final dir = await _scanDir();
      await _writeResidenceFile(
        dir,
        _residenceFrontFile,
        front,
      );
      await _writeResidenceFile(
        dir,
        _residenceBackFile,
        back,
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('BbhOnboardingScanStore.saveResidenceScans error: $e');
      }
    }
  }

  Future<void> _writeResidenceFile(
    Directory dir,
    String fileName,
    IpassFormDataResultResponse? value,
  ) async {
    final file = File('${dir.path}/$fileName');
    if (value == null) {
      if (await file.exists()) await file.delete();
      return;
    }
    await file.writeAsString(jsonEncode(value.toJson()));
  }

  Future<
      ({
        IpassFormDataResultResponse? front,
        IpassFormDataResultResponse? back,
      })> loadResidenceScans() async {
    try {
      final dir = await _scanDir();
      return (
        front: await _readResidenceFile(dir, _residenceFrontFile),
        back: await _readResidenceFile(dir, _residenceBackFile),
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('BbhOnboardingScanStore.loadResidenceScans error: $e');
      }
      return (front: null, back: null);
    }
  }

  Future<IpassFormDataResultResponse?> _readResidenceFile(
    Directory dir,
    String fileName,
  ) async {
    final file = File('${dir.path}/$fileName');
    if (!await file.exists()) return null;
    final decoded = jsonDecode(await file.readAsString());
    if (decoded is! Map) return null;
    return IpassFormDataResultResponse.fromJson(decoded);
  }

  Future<void> clear() async {
    try {
      final dir = await _scanDir();
      if (await dir.exists()) {
        await for (final entity in dir.list()) {
          if (entity is File) await entity.delete();
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('BbhOnboardingScanStore.clear error: $e');
      }
    }
  }
}
