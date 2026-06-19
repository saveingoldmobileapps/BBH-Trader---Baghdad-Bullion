import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

/// Persists uploaded iPass image URLs across app restarts.
class BbhOnboardingImageUrlStore {
  BbhOnboardingImageUrlStore._();

  static final BbhOnboardingImageUrlStore instance =
      BbhOnboardingImageUrlStore._();

  static const _dirName = 'bbh_onboarding_scans';
  static const _fileName = 'ipass_image_urls.json';

  Future<File> _file() async {
    final base = await getApplicationDocumentsDirectory();
    final dir = Directory('${base.path}/$_dirName');
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return File('${dir.path}/$_fileName');
  }

  Future<Map<String, String>> load() async {
    try {
      final file = await _file();
      if (!await file.exists()) return {};
      final decoded = jsonDecode(await file.readAsString());
      if (decoded is! Map) return {};
      return decoded.map(
        (key, value) => MapEntry(key.toString(), value.toString()),
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('BbhOnboardingImageUrlStore.load error: $e');
      }
      return {};
    }
  }

  Future<void> save(Map<String, String> urls) async {
    try {
      final file = await _file();
      await file.writeAsString(jsonEncode(urls));
    } catch (e) {
      if (kDebugMode) {
        debugPrint('BbhOnboardingImageUrlStore.save error: $e');
      }
    }
  }

  Future<void> clear() async {
    try {
      final file = await _file();
      if (await file.exists()) await file.delete();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('BbhOnboardingImageUrlStore.clear error: $e');
      }
    }
  }
}
