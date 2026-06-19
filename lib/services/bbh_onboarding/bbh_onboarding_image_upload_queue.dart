import 'dart:async';

import 'package:baghdad_bullion_house/services/bbh_onboarding/bbh_onboarding_image_upload_service.dart';
import 'package:baghdad_bullion_house/services/bbh_onboarding/bbh_onboarding_image_url_store.dart';
import 'package:baghdad_bullion_house/services/ipass_kyc/ipass_onboarding_mapper.dart';
import 'package:flutter/foundation.dart';

typedef OnIpassImageUploaded = void Function(String key, String url);

class _QueuedImage {
  _QueuedImage({
    required this.key,
    required this.entry,
    required this.base64,
    required this.fileNameStem,
  });

  final String key;
  final Map<String, dynamic> entry;
  final String base64;
  final String fileNameStem;
  int attempts = 0;
}

/// Background queue: uploads iPass scan images one-by-one with retry. No UI blocking.
class BbhOnboardingImageUploadQueue {
  BbhOnboardingImageUploadQueue._();

  static final BbhOnboardingImageUploadQueue instance =
      BbhOnboardingImageUploadQueue._();

  final List<_QueuedImage> _queue = [];
  final Set<String> _queuedKeys = {};
  final Set<String> _completedKeys = {};
  final Set<String> _failedKeys = {};
  bool _draining = false;

  OnIpassImageUploaded? onUploaded;

  int get pendingCount => _queue.length;

  Set<String> get pendingKeys => Set.unmodifiable(_queuedKeys);

  Set<String> get failedKeys => Set.unmodifiable(_failedKeys);

  /// Enqueue images that are not already uploaded or queued.
  void enqueue(
    List<Map<String, dynamic>> images, {
    Map<String, String>? alreadyUploaded,
  }) {
    if (!BbhOnboardingImageUploadService.enabled || images.isEmpty) return;

    final uploaded = alreadyUploaded ?? {};
    var added = 0;

    for (var i = 0; i < images.length; i++) {
      final entry = images[i];
      final base64 = entry['base64']?.toString().trim() ?? '';
      if (base64.isEmpty) continue;

      final key = IpassOnboardingMapper.imageEntryKey(entry);
      if (uploaded.containsKey(key) ||
          _completedKeys.contains(key) ||
          _queuedKeys.contains(key)) {
        continue;
      }

      _queue.add(
        _QueuedImage(
          key: key,
          entry: entry,
          base64: base64,
          fileNameStem: _fileNameStem(entry, i),
        ),
      );
      _queuedKeys.add(key);
      _failedKeys.remove(key);
      added++;
    }

    if (added > 0 && kDebugMode) {
      debugPrint(
        'BbhOnboardingImageUploadQueue: enqueued $added image(s) '
        '(pending=${_queue.length})',
      );
    }

    if (added > 0) {
      unawaited(_drain());
    }
  }

  /// Re-enqueue any scan images missing a URL (e.g. after app restart).
  void enqueueMissing({
    required List<Map<String, dynamic>> allImages,
    required Map<String, String> uploaded,
  }) {
    final missing = allImages.where((entry) {
      final key = IpassOnboardingMapper.imageEntryKey(entry);
      return !uploaded.containsKey(key);
    }).toList();
    enqueue(missing, alreadyUploaded: uploaded);
  }

  Future<void> _drain() async {
    if (_draining) return;
    _draining = true;

    try {
      while (_queue.isNotEmpty) {
        final job = _queue.first;
        job.attempts++;

        if (kDebugMode) {
          debugPrint(
            'BbhOnboardingImageUploadQueue: uploading ${job.key} '
            '(attempt ${job.attempts}/${BbhOnboardingImageUploadService.maxAttempts})',
          );
        }

        String? url;
        try {
          url = await BbhOnboardingImageUploadService.instance.uploadBase64Image(
            base64: job.base64,
            fileNameStem: job.fileNameStem,
            mimeType: job.entry['mimeType']?.toString(),
          );
        } catch (e) {
          if (kDebugMode) {
            debugPrint('BbhOnboardingImageUploadQueue: ${job.key} error: $e');
          }
        }

        if (url != null && url.isNotEmpty) {
          _queue.removeAt(0);
          _queuedKeys.remove(job.key);
          _completedKeys.add(job.key);

          await _persistUrl(job.key, url);
          onUploaded?.call(job.key, url);

          if (kDebugMode) {
            debugPrint('BbhOnboardingImageUploadQueue: done ${job.key}');
          }
          continue;
        }

        if (job.attempts >= BbhOnboardingImageUploadService.maxAttempts) {
          _queue.removeAt(0);
          _queuedKeys.remove(job.key);
          _failedKeys.add(job.key);
          if (kDebugMode) {
            debugPrint(
              'BbhOnboardingImageUploadQueue: gave up ${job.key} after '
              '${job.attempts} attempts',
            );
          }
          continue;
        }

        await Future<void>.delayed(BbhOnboardingImageUploadService.retryDelay);
      }
    } finally {
      _draining = false;
      if (_queue.isNotEmpty) {
        unawaited(_drain());
      }
    }
  }

  Future<void> _persistUrl(String key, String url) async {
    final existing = await BbhOnboardingImageUrlStore.instance.load();
    existing[key] = url;
    await BbhOnboardingImageUrlStore.instance.save(existing);
  }

  void markCompleted(String key) {
    _completedKeys.add(key);
    _queuedKeys.remove(key);
    _failedKeys.remove(key);
    _queue.removeWhere((job) => job.key == key);
  }

  void clearForScanKey(String scanKey) {
    final prefix = '$scanKey|';
    _completedKeys.removeWhere((k) => k.startsWith(prefix));
    _queuedKeys.removeWhere((k) => k.startsWith(prefix));
    _failedKeys.removeWhere((k) => k.startsWith(prefix));
    _queue.removeWhere((job) => job.key.startsWith(prefix));
  }

  String _fileNameStem(Map<String, dynamic> entry, int index) {
    final scanTarget = entry['scanTarget']?.toString() ?? 'scan';
    final imageType = entry['imageType']?.toString() ?? 'image';
    final side = entry['side']?.toString();
    final entryIndex = entry['index'];
    final parts = <String>[
      'bbh_ipass',
      scanTarget,
      if (side != null && side.isNotEmpty) side,
      imageType,
      if (entryIndex != null) entryIndex.toString(),
      index.toString(),
    ];
    return parts.join('_').replaceAll(RegExp(r'[^a-zA-Z0-9_]+'), '_');
  }
}
