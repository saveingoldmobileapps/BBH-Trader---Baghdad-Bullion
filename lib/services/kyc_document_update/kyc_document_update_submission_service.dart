import 'dart:convert';
import 'dart:io';

import 'package:baghdad_bullion_house/data/data_sources/local_database/local_database.dart';
import 'package:baghdad_bullion_house/data/data_sources/network_sources/api_url.dart';
import 'package:baghdad_bullion_house/data/data_sources/network_sources/dio_network_manager.dart';
import 'package:baghdad_bullion_house/data/models/ErrorResponse.dart';
import 'package:baghdad_bullion_house/data/models/SuccessResponse.dart';
import 'package:baghdad_bullion_house/services/bbh_onboarding/bbh_onboarding_submission_logger.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

class KycDocumentUpdateSubmissionResult {
  const KycDocumentUpdateSubmissionResult._({
    required this.success,
    this.message,
    this.responseData,
  });

  final bool success;
  final String? message;
  final Map<String, dynamic>? responseData;

  factory KycDocumentUpdateSubmissionResult.ok({
    String? message,
    Map<String, dynamic>? responseData,
  }) =>
      KycDocumentUpdateSubmissionResult._(
        success: true,
        message: message,
        responseData: responseData,
      );

  factory KycDocumentUpdateSubmissionResult.fail(String message) =>
      KycDocumentUpdateSubmissionResult._(success: false, message: message);
}

/// POST document-specific iPass JSON to the update endpoint.
class KycDocumentUpdateSubmissionService {
  KycDocumentUpdateSubmissionService._();

  static final KycDocumentUpdateSubmissionService instance =
      KycDocumentUpdateSubmissionService._();

  Future<KycDocumentUpdateSubmissionResult> submit(
    Map<String, dynamic> payload,
  ) async {
    if (kDebugMode) {
      await _saveDebugJson(payload);
      await BbhOnboardingSubmissionLogger.logPostmanCopyablePayload(payload);
    }

    final token = await LocalDatabase.instance.getLoginToken();
    final userId = await LocalDatabase.instance.getUserId();

    final body = Map<String, dynamic>.from(payload);
    if (userId != null && userId.isNotEmpty) {
      body['userId'] = userId;
    }

    final response = await DioNetworkManager().callAPI(
      url: ApiEndpoints.updateIpassDocumentApiUrl,
      httpMethod: HttpMethod.post,
      body: body,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
      },
      sendTimeout: const Duration(minutes: 3),
      receiveTimeout: const Duration(minutes: 3),
    );

    switch (response.responseType) {
      case ServerResponseType.success:
        return _mapSuccess(response.resultData);
      case ServerResponseType.error:
        return _mapError(response);
      case ServerResponseType.exception:
        return KycDocumentUpdateSubmissionResult.fail(
          response.message ?? 'Could not submit document update.',
        );
    }
  }

  Future<void> _saveDebugJson(Map<String, dynamic> payload) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final stamp = DateTime.now().toIso8601String().replaceAll(':', '-');
      final docType = payload['documentType'] ?? 'document';
      final file = File('${dir.path}/KYC_DOC_UPDATE-$docType-$stamp.json');
      await file.writeAsString(
        const JsonEncoder.withIndent('  ').convert(payload),
      );
    } catch (_) {}
  }

  KycDocumentUpdateSubmissionResult _mapSuccess(dynamic data) {
    try {
      final success = SuccessResponse.fromJson(data);
      final payloadMap = data is Map<String, dynamic>
          ? Map<String, dynamic>.from(data)
          : data is Map
              ? Map<String, dynamic>.from(data)
              : null;
      return KycDocumentUpdateSubmissionResult.ok(
        message: success.message ??
            success.payload?.message ??
            'Document submitted successfully.',
        responseData: payloadMap,
      );
    } catch (_) {
      return KycDocumentUpdateSubmissionResult.ok(
        message: 'Document submitted successfully.',
        responseData: data is Map ? Map<String, dynamic>.from(data) : null,
      );
    }
  }

  KycDocumentUpdateSubmissionResult _mapError(ServerResponse<dynamic> response) {
    final data = response.resultData;
    if (data is! Map) {
      return KycDocumentUpdateSubmissionResult.fail(
        response.message ?? 'Submission failed.',
      );
    }
    try {
      final error = ErrorResponse.fromJson(response.resultData);
      final msg = error.payload?.message?.toString() ??
          error.message?.toString() ??
          response.message ??
          'Submission failed.';
      return KycDocumentUpdateSubmissionResult.fail(msg);
    } catch (_) {
      return KycDocumentUpdateSubmissionResult.fail(
        response.message ?? 'Submission failed.',
      );
    }
  }
}
