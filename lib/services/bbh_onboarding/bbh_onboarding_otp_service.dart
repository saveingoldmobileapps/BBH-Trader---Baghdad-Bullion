import 'package:baghdad_bullion_house/data/data_sources/network_sources/api_url.dart';
import 'package:baghdad_bullion_house/data/data_sources/network_sources/dio_network_manager.dart';
import 'package:baghdad_bullion_house/data/models/ErrorResponse.dart';
import 'package:baghdad_bullion_house/data/models/SuccessResponse.dart';
import 'package:flutter/foundation.dart';

import 'bbh_phone_number_util.dart';

enum BbhOnboardingOtpChannel { mobile, email }

class BbhOnboardingOtpResult {
  const BbhOnboardingOtpResult._({
    required this.success,
    this.message,
    this.oneTimePassword,
  });

  final bool success;
  final String? message;
  final String? oneTimePassword;

  factory BbhOnboardingOtpResult.ok({
    String? message,
    String? oneTimePassword,
  }) =>
      BbhOnboardingOtpResult._(
        success: true,
        message: message,
        oneTimePassword: oneTimePassword,
      );

  factory BbhOnboardingOtpResult.fail(String message) =>
      BbhOnboardingOtpResult._(success: false, message: message);
}

/// Onboarding contact OTP — email and phone via register/preVerify (`sendOn`: email | phone).
class BbhOnboardingOtpService {
  BbhOnboardingOtpService._();

  static final BbhOnboardingOtpService instance = BbhOnboardingOtpService._();

  Future<BbhOnboardingOtpResult> sendOtp({
    required BbhOnboardingOtpChannel channel,
    required String phoneNumber,
    required String email,
  }) async {
    final phone = BbhPhoneNumberUtil.toApiFormat(phoneNumber);
    final mail = email.trim().toLowerCase();

    if (phone.isEmpty) {
      return BbhOnboardingOtpResult.fail('Enter your mobile number first.');
    }
    if (!BbhPhoneNumberUtil.isValidInput(phoneNumber)) {
      return BbhOnboardingOtpResult.fail(
        'Enter a valid mobile number starting with 00 or +.',
      );
    }
    // if (mail.isEmpty) {
    //   return BbhOnboardingOtpResult.fail('Enter your email address first.');
    // }

    final sendOn =
        channel == BbhOnboardingOtpChannel.mobile ? 'phone' : 'email';

    return _postOtp(
      url: ApiEndpoints.preVerifyApiUrl,
      body: {
        'email': mail,
        'phoneNumber': phone,
        'sendOn': sendOn,
      },
    );
  }

  Future<BbhOnboardingOtpResult> _postOtp({
    required String url,
    required Map<String, dynamic> body,
  }) async {
    final response = await DioNetworkManager().callAPI(
      url: url,
      body: body,
      httpMethod: HttpMethod.post,
    );
    return _mapSendResponse(response);
  }

  Future<BbhOnboardingOtpResult> verifyPasscode({
    required BbhOnboardingOtpChannel channel,
    required String phoneNumber,
    required String email,
    required String passcode,
    String? expectedOtp,
  }) async {
    final code = passcode.trim();
    if (code.length != 6) {
      return BbhOnboardingOtpResult.fail('Enter the 6-digit code.');
    }

    final phone = BbhPhoneNumberUtil.toApiFormat(phoneNumber);
    final mail = email.trim().toLowerCase();

    final url = channel == BbhOnboardingOtpChannel.mobile
        ? ApiEndpoints.registerPhoneVerifyPasscodeApiUrl
        : ApiEndpoints.registerEmailVerifyPasscodeApiUrl;

    final body = channel == BbhOnboardingOtpChannel.mobile
        ? {'phoneNumber': phone, 'passcode': code}
        : {'email': mail, 'passcode': code};

    final response = await DioNetworkManager().callAPI(
      url: url,
      body: body,
      httpMethod: HttpMethod.patch,
    );

    if (response.responseType == ServerResponseType.success) {
      final success = SuccessResponse.fromJson(response.resultData);
      return BbhOnboardingOtpResult.ok(
        message: success.message ?? success.payload?.message,
      );
    }

    if (expectedOtp != null && expectedOtp.trim() == code) {
      return BbhOnboardingOtpResult.ok(message: 'Verified');
    }

    // Debug builds: accept any 6-digit code for email/phone (wrong OTP included).
    if (kDebugMode) {
      return BbhOnboardingOtpResult.ok(message: 'Verified (debug)');
    }

    return _mapErrorResponse(response);
  }

  BbhOnboardingOtpResult _mapSendResponse(ServerResponse<dynamic> response) {
    switch (response.responseType) {
      case ServerResponseType.success:
        final data = response.resultData;
        final success = SuccessResponse.fromJson(data);
        final payload = data is Map ? data['payload'] : null;
        final otp = payload is Map
            ? (payload['oneTimePassword'] ?? payload['otp'])?.toString()
            : success.payload?.otp;
        return BbhOnboardingOtpResult.ok(
          message: success.message ?? success.payload?.message,
          oneTimePassword: otp,
        );
      case ServerResponseType.error:
        return _mapErrorResponse(response);
      case ServerResponseType.exception:
        return BbhOnboardingOtpResult.fail(
          response.message ?? 'Could not send verification code.',
        );
    }
  }

  BbhOnboardingOtpResult _mapErrorResponse(ServerResponse<dynamic> response) {
    try {
      final error = ErrorResponse.fromJson(response.resultData);
      final msg = error.payload?.message?.toString() ??
          error.message?.toString() ??
          'Verification failed.';
      return BbhOnboardingOtpResult.fail(msg);
    } catch (_) {
      return BbhOnboardingOtpResult.fail(
        response.message ?? 'Verification failed.',
      );
    }
  }
}
