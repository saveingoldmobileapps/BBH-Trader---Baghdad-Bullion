import 'dart:convert';
import 'dart:typed_data';

import 'package:baghdad_bullion_house/data/data_sources/local_database/local_database.dart';
import 'package:baghdad_bullion_house/data/data_sources/network_sources/api_url.dart';
import 'package:baghdad_bullion_house/data/data_sources/network_sources/dio_network_manager.dart';
import 'package:baghdad_bullion_house/data/models/ErrorResponse.dart';
import 'package:baghdad_bullion_house/data/models/SuccessResponse.dart';
import 'package:baghdad_bullion_house/data/models/agreement_models/agreement_link_response.dart';
import 'package:baghdad_bullion_house/presentation/feature_injection.dart';
import 'package:baghdad_bullion_house/services/bbh_onboarding/bbh_onboarding_image_upload_service.dart';
import 'package:logger/logger.dart';

class AgreementSubmitResult {
  final bool success;
  final String? message;

  const AgreementSubmitResult({
    required this.success,
    this.message,
  });
}

class AgreementDocumentSource {
  final String? networkUrl;

  const AgreementDocumentSource({this.networkUrl});

  bool get isValid => networkUrl?.isNotEmpty ?? false;

  bool get isImage =>
      networkUrl != null && AgreementService.isImageUrl(networkUrl!);
}

class AgreementService {
  static bool isImageUrl(String url) {
    final path = Uri.tryParse(url)?.path.toLowerCase() ?? url.toLowerCase();
    return path.endsWith('.png') ||
        path.endsWith('.jpg') ||
        path.endsWith('.jpeg') ||
        path.endsWith('.webp') ||
        path.endsWith('.gif');
  }

  static AgreementDocumentSource resolveDocumentSource(String? link) {
    if (link == null || link.trim().isEmpty) {
      return const AgreementDocumentSource();
    }
    return AgreementDocumentSource(networkUrl: link.trim());
  }

  static Future<Map<String, String>> _loginAuthHeaders() async {
    final token = await LocalDatabase.instance.getLoginToken();
    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
  }

  static Future<String?> fetchAgreementLink() async {
    try {
      final token = await LocalDatabase.instance.getLoginToken();
      final headers = {
        'Authorization': 'Bearer $token',
      };
      final serverResponse = await DioNetworkManager().callAPI(
        url: ApiEndpoints.getAgreementLinkApiUrl,
        httpMethod: HttpMethod.get,
        headers: headers,
      );

      if (serverResponse.responseType != ServerResponseType.success) {
        final errorMessage = _extractErrorMessage(serverResponse.resultData);
        getLocator<Logger>().e('Agreement link error: $errorMessage');
        return null;
      }

      final response = AgreementLinkResponse.fromJson(
        serverResponse.resultData,
      );
      final link = response.payload?.agreementLink?.trim();
      if (link == null || link.isEmpty) {
        getLocator<Logger>().e('Agreement link missing in response');
        return null;
      }

      return link;
    } catch (e) {
      getLocator<Logger>().e('fetchAgreementLink failed: $e');
      return null;
    }
  }

  /// Uploads signature PNG via the same iPass doc endpoint used in onboarding.
  static Future<String?> _uploadSignatureImage(
    Uint8List signaturePngBytes,
  ) async {
    try {
      final base64Image = base64Encode(signaturePngBytes);
      final url =
          await BbhOnboardingImageUploadService.instance.uploadBase64Image(
        base64: base64Image,
        fileNameStem: 'bbh_agreement_signature',
        mimeType: 'image/png',
      );

      if (url == null || url.isEmpty) {
        getLocator<Logger>().e('Signature upload missing imageUrl');
        return null;
      }

      getLocator<Logger>().i('Signature uploaded: $url');
      return url;
    } catch (e) {
      getLocator<Logger>().e('uploadSignatureImage failed: $e');
      return null;
    }
  }

  static Future<AgreementSubmitResult> _updateAgreement({
    required String signatureLink,
    bool signatureOnly = false,
  }) async {
    final headers = await _loginAuthHeaders();
    final body = <String, dynamic>{
      'signatureLink': signatureLink,
      'isSignatureVerified': true,
    };
    if (!signatureOnly) {
      body['agreementStatus'] = true;
    }

    final serverResponse = await DioNetworkManager().callAPI(
      url: ApiEndpoints.updateAgreementApiUrl,
      httpMethod: HttpMethod.post,
      headers: headers,
      body: body,
    );

    switch (serverResponse.responseType) {
      case ServerResponseType.success:
        final successResponse = SuccessResponse.fromJson(
          serverResponse.resultData,
        );
        final message =
            successResponse.payload?.message ??
            successResponse.message ??
            'Agreement updated successfully';
        getLocator<Logger>().i('Agreement updated: $message');
        return AgreementSubmitResult(success: true, message: message);

      case ServerResponseType.error:
        final errorMessage = _extractErrorMessage(serverResponse.resultData);
        getLocator<Logger>().e('Agreement update error: $errorMessage');
        return AgreementSubmitResult(success: false, message: errorMessage);

      case ServerResponseType.exception:
        return const AgreementSubmitResult(
          success: false,
          message: 'Network error. Please try again.',
        );
    }
  }

  static Future<AgreementSubmitResult> submitSignature({
    required Uint8List signaturePngBytes,
  }) async {
    try {
      final signatureUrl = await _uploadSignatureImage(signaturePngBytes);
      if (signatureUrl == null) {
        return const AgreementSubmitResult(
          success: false,
          message: 'Failed to upload signature image',
        );
      }

      return _updateAgreement(signatureLink: signatureUrl);
    } catch (e) {
      getLocator<Logger>().e('submitSignature failed: $e');
      return AgreementSubmitResult(
        success: false,
        message: e.toString(),
      );
    }
  }

  /// Uploads signature without marking the agreement as signed.
  static Future<AgreementSubmitResult> submitSignatureOnly({
    required Uint8List signaturePngBytes,
  }) async {
    try {
      final signatureUrl = await _uploadSignatureImage(signaturePngBytes);
      if (signatureUrl == null) {
        return const AgreementSubmitResult(
          success: false,
          message: 'Failed to upload signature image',
        );
      }

      return _updateAgreement(
        signatureLink: signatureUrl,
        signatureOnly: true,
      );
    } catch (e) {
      getLocator<Logger>().e('submitSignatureOnly failed: $e');
      return AgreementSubmitResult(
        success: false,
        message: e.toString(),
      );
    }
  }

  static String _extractErrorMessage(dynamic resultData) {
    if (resultData == null) return 'Something went wrong';

    try {
      final errorResponse = ErrorResponse.fromJson(resultData);
      return errorResponse.payload?.message?.toString() ??
          errorResponse.message?.toString() ??
          'Something went wrong';
    } catch (_) {
      if (resultData is Map && resultData['message'] != null) {
        return resultData['message'].toString();
      }
      return 'Something went wrong';
    }
  }
}
