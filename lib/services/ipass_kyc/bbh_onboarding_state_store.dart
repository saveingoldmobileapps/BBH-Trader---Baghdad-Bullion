import 'dart:convert';

import 'package:get_storage/get_storage.dart';

/// Persists HTML onboarding progress so users can resume after app restart.
class BbhOnboardingStateStore {
  BbhOnboardingStateStore._();

  static final BbhOnboardingStateStore instance = BbhOnboardingStateStore._();

  static const _storageKey = 'bbh_native_onboarding_state_v1';
  final GetStorage _box = GetStorage();

  Map<String, dynamic>? load() {
    final raw = _box.read(_storageKey);
    if (raw is Map) {
      return Map<String, dynamic>.from(raw);
    }
    if (raw is String && raw.isNotEmpty) {
      try {
        final decoded = jsonDecode(raw);
        if (decoded is Map<String, dynamic>) return decoded;
        if (decoded is Map) return Map<String, dynamic>.from(decoded);
      } catch (_) {}
    }
    return null;
  }

  Future<void> save(Map<String, dynamic> state) async {
    await _box.write(_storageKey, state);
  }

  Future<void> clear() async {
    await _box.remove(_storageKey);
  }
}
