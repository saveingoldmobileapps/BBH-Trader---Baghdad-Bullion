import 'dart:io';

import 'package:baghdad_bullion_house/data/data_sources/network_sources/api_url.dart';
import 'package:baghdad_bullion_house/data/data_sources/network_sources/dio_network_manager.dart';
import 'package:baghdad_bullion_house/services/ipass_kyc/ipass_document_image_util.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Single-image upload to BBH iPass doc endpoint.
class BbhOnboardingImageUploadService {
  BbhOnboardingImageUploadService._();

  static final BbhOnboardingImageUploadService instance =
      BbhOnboardingImageUploadService._();

  static const enabled = true;

  static String get uploadUrl => ApiEndpoints.ipassDocUploadApiUrl;

  static const maxAttempts = 3;
  static const retryDelay = Duration(seconds: 2);

  /// Uploads one file; returns hosted URL or null on failure.
  Future<String?> uploadImageFile(
    File file, {
    String? filename,
  }) async {
    if (!enabled) return null;

    final formData = FormData.fromMap({
      'myImage': await MultipartFile.fromFile(
        file.path,
        filename: filename ?? file.path.split(Platform.pathSeparator).last,
      ),
    });

    final response = await DioNetworkManager().callAPI(
      url: uploadUrl,
      httpMethod: HttpMethod.post,
      headers: const {},
      body: formData,
    );

    if (response.responseType != ServerResponseType.success) {
      if (kDebugMode) {
        debugPrint(
          'BbhOnboardingImageUpload: failed ${filename ?? file.path} — '
          '${response.message ?? response.resultData}',
        );
      }
      return null;
    }
    return _parseImageUrl(response.resultData);
  }

  /// Decodes base64 → temp file → upload.
  Future<String?> uploadBase64Image({
    required String base64,
    required String fileNameStem,
    String? mimeType,
  }) async {
    File? tempFile;
    try {
      tempFile = await IpassDocumentImageUtil.writeBase64ToTempFile(
        base64: base64,
        fileNameStem: fileNameStem,
        mimeType: mimeType,
      );
      final ext = IpassDocumentImageUtil.extensionForMime(
        mimeType ?? IpassDocumentImageUtil.guessMimeFromBase64(base64),
      );
      return await uploadImageFile(
        tempFile,
        filename: '$fileNameStem.$ext',
      );
    } finally {
      if (tempFile != null && await tempFile.exists()) {
        try {
          await tempFile.delete();
        } catch (_) {}
      }
    }
  }

  static String? _parseImageUrl(dynamic data) {
    if (data is! Map) return null;
    final map = Map<String, dynamic>.from(data);

    final payload = map['payload'];
    if (payload is Map) {
      final url = payload['imageUrl']?.toString().trim();
      if (url != null && url.isNotEmpty) return url;
    }

    final dataNode = map['data'];
    if (dataNode is Map) {
      final url = dataNode['imageUrl']?.toString().trim();
      if (url != null && url.isNotEmpty) return url;
    }

    return null;
  }
}
