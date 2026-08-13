import 'package:baghdad_bullion_house/data/data_sources/network_sources/api_url.dart';
import 'package:baghdad_bullion_house/data/data_sources/network_sources/dio_network_manager.dart';
import 'package:baghdad_bullion_house/data/models/ErrorResponse.dart';
import 'package:baghdad_bullion_house/data/models/SuccessResponse.dart';

class BbhOnboardingSubmissionResult {
  const BbhOnboardingSubmissionResult._({
    required this.success,
    this.message,
    this.responseData,
  });

  final bool success;
  final String? message;
  final Map<String, dynamic>? responseData;

  factory BbhOnboardingSubmissionResult.ok({
    String? message,
    Map<String, dynamic>? responseData,
  }) => BbhOnboardingSubmissionResult._(
    success: true,
    message: message,
    responseData: responseData,
  );

  factory BbhOnboardingSubmissionResult.fail(String message) =>
      BbhOnboardingSubmissionResult._(success: false, message: message);
}

/// Parses `payload.createdUser.iPassData.submissionMeta.kycReference` only.
String? parseSubmissionKycReference(Map<String, dynamic>? response) {
  if (response == null) return null;

  dynamic walk(dynamic node, List<String> keys) {
    var current = node;
    for (final key in keys) {
      if (current is! Map) return null;
      final map = current is Map<String, dynamic>
          ? current
          : Map<String, dynamic>.from(current);
      current = map[key];
    }
    return current;
  }

  final ref = walk(
    response,
    const [
      'payload',
      'createdUser',
      'iPassData',
      'submissionMeta',
      'kycReference',
    ],
  )?.toString().trim();

  return ref == null || ref.isEmpty ? null : ref;
}

/// POST full onboarding JSON to `auth/register/iPass/{lang}`.
class BbhOnboardingSubmissionService {
  BbhOnboardingSubmissionService._();

  static final BbhOnboardingSubmissionService instance =
      BbhOnboardingSubmissionService._();

  Future<BbhOnboardingSubmissionResult> submit(
    Map<String, dynamic> payload,
  ) async {
    final response = await DioNetworkManager().callAPI(
      url: ApiEndpoints.registerIpassApiUrl,
      httpMethod: HttpMethod.post,
      body: payload,
      headers: const {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
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
        return BbhOnboardingSubmissionResult.fail(
          response.message ?? 'Could not submit onboarding pack.',
        );
    }
  }

  BbhOnboardingSubmissionResult _mapSuccess(dynamic data) {
    try {
      final success = SuccessResponse.fromJson(data);
      final payloadMap = data is Map<String, dynamic>
          ? Map<String, dynamic>.from(data)
          : data is Map
          ? Map<String, dynamic>.from(data)
          : null;
      return BbhOnboardingSubmissionResult.ok(
        message:
            success.message ??
            success.payload?.message ??
            'Onboarding pack submitted successfully.',
        responseData: payloadMap,
      );
    } catch (_) {
      return BbhOnboardingSubmissionResult.ok(
        message: 'Onboarding pack submitted successfully.',
        responseData: data is Map ? Map<String, dynamic>.from(data) : null,
      );
    }
  }

  BbhOnboardingSubmissionResult _mapError(ServerResponse<dynamic> response) {
    final data = response.resultData;
    if (data is String) {
      if (data.contains('PayloadTooLargeError') ||
          data.contains('request entity too large')) {
        return BbhOnboardingSubmissionResult.fail(
          'Submission payload is too large. Wait for document uploads to finish, then try again.',
        );
      }
      return BbhOnboardingSubmissionResult.fail(
        response.message ?? 'Submission failed.',
      );
    }
    if (data is! Map) {
      return BbhOnboardingSubmissionResult.fail(
        response.message ?? 'Submission failed.',
      );
    }
    try {
      final error = ErrorResponse.fromJson(response.resultData);
      final msg =
          error.payload?.message?.toString() ??
          error.message?.toString() ??
          response.message ??
          'Submission failed.';
      return BbhOnboardingSubmissionResult.fail(msg);
    } catch (_) {
      return BbhOnboardingSubmissionResult.fail(
        response.message ?? 'Submission failed.',
      );
    }
  }
}
