import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../../data/models/ipass_model/ipass_formdata_result_response.dart';
import '../../data/models/ipass_model/ipass_formdata_submit_response.dart';
import '../../data/models/ipass_model/ipass_login_response.dart';
import 'ipass_document_image_util.dart';

/// iPass Web API for handwritten / residency document OCR (Form 3, etc.).
/// Flow: login → submit image → poll analyze result.
class IpassFormDataService {
  IpassFormDataService._();

  static final IpassFormDataService instance = IpassFormDataService._();

  static const _defaultBaseUrl = 'https://plusapi.ipass-mena.com/api/v1/ipass';

  final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 45),
      receiveTimeout: const Duration(seconds: 90),
      sendTimeout: const Duration(seconds: 90),
      headers: {
        'accept': 'application/json',
        'content-type': 'application/json',
      },
    ),
  );

  IpassLoginUser? _cachedUser;
  DateTime? _sessionCachedAt;

  String get _baseUrl =>
      dotenv.env['IPASS_PLUS_API_BASE']?.trim().isNotEmpty == true
          ? dotenv.env['IPASS_PLUS_API_BASE']!.trim()
          : _defaultBaseUrl;

  /// Clears cached login (e.g. on auth error).
  void clearSession() {
    _cachedUser = null;
    _sessionCachedAt = null;
  }

  Future<IpassLoginUser> login({String? email, String? password}) async {
    final loginEmail = email ?? dotenv.env['IPASS_EMAIL'] ?? '';
    final loginPassword = password ?? dotenv.env['IPASS_PASSWORD'] ?? '';
    if (loginEmail.isEmpty || loginPassword.isEmpty) {
      throw IpassFormDataException(
        'IPASS_EMAIL and IPASS_PASSWORD are required in .env',
        code: 'MISSING_CREDENTIALS',
      );
    }

    if (_cachedUser != null &&
        _sessionCachedAt != null &&
        DateTime.now().difference(_sessionCachedAt!) <
            const Duration(minutes: 25)) {
      return _cachedUser!;
    }

    final response = await _dio.post<Map<String, dynamic>>(
      '$_baseUrl/create/authenticate/login',
      data: {
        'email': loginEmail,
        'password': loginPassword,
      },
    );

    final parsed = IpassLoginResponse.fromJson(response.data);
    final user = parsed.user;
    if (user == null ||
        user.token == null ||
        user.token!.isEmpty ||
        user.appToken == null ||
        user.appToken!.isEmpty) {
      throw IpassFormDataException(
        'iPass login succeeded but tokens are missing',
        code: 'LOGIN_INVALID',
      );
    }

    _cachedUser = user;
    _sessionCachedAt = DateTime.now();
    return user;
  }

  /// Submits one document image and polls until OCR completes.
  Future<IpassFormDataResultResponse> scanImageFile(
    File imageFile, {
    required String sideLabel,
    String? email,
    String? precomputedBase64,
    String sid = 'string',
    int maxPollAttempts = 20,
    Duration pollInterval = const Duration(seconds: 2),
  }) async {
    final user = await login();
    final base64Image = precomputedBase64?.isNotEmpty == true
        ? precomputedBase64!
        : await IpassDocumentImageUtil.encodeToBase64(imageFile);
    final submitEmail = email ?? user.email ?? dotenv.env['IPASS_EMAIL'] ?? '';

    final submitResponse = await _submitFormData(
      appToken: user.appToken!,
      authToken: user.token!,
      base64Image: base64Image,
      email: submitEmail,
      name: 'residence_$sideLabel',
    );

    final requestId = submitResponse.apiRequestId;
    if (requestId == null || requestId.isEmpty) {
      throw IpassFormDataException(
        submitResponse.message ?? 'Missing apim-request-id from iPass',
        code: 'SUBMIT_FAILED',
      );
    }

    for (var attempt = 0; attempt < maxPollAttempts; attempt++) {
      if (attempt > 0) {
        await Future<void>.delayed(pollInterval);
      }

      final result = await _fetchFormDataResult(
        appToken: user.appToken!,
        authToken: user.token!,
        apiRequestId: requestId,
        sid: sid,
      );

      if (result.isSucceeded) {
        final raw = result.rawJson;
        if (raw != null && raw.isNotEmpty) {
          return IpassFormDataResultResponse.fromApiJson(
            raw,
            scanSide: sideLabel,
            imageBase64: base64Image,
          );
        }
        return IpassFormDataResultResponse(
          result: result.result,
          rawJson: result.rawJson,
          scanSide: sideLabel,
          imageBase64: base64Image,
        );
      }

      final status = result.result?.status?.toLowerCase() ?? '';
      if (status == 'failed' || status == 'canceled' || status == 'cancelled') {
        throw IpassFormDataException(
          'Document OCR failed (status: $status)',
          code: 'OCR_FAILED',
        );
      }
    }

    throw IpassFormDataException(
      'Document OCR timed out — try again with a clearer photo',
      code: 'OCR_TIMEOUT',
    );
  }

  Future<IpassFormDataSubmitResponse> _submitFormData({
    required String appToken,
    required String authToken,
    required String base64Image,
    required String email,
    required String name,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '$_baseUrl/web/get/formdata',
      queryParameters: {'token': appToken},
      data: {
        'auth_token': authToken,
        'image': base64Image,
        'email': email,
        'name': name,
        'filetype': 'image',
        'markdown': true,
      },
    );

    final parsed = IpassFormDataSubmitResponse.fromJson(
      Map<String, dynamic>.from(response.data ?? {}),
    );
    if (!parsed.status) {
      throw IpassFormDataException(
        parsed.message ?? 'formdata submit failed',
        code: 'SUBMIT_FAILED',
      );
    }
    return parsed;
  }

  Future<IpassFormDataResultResponse> _fetchFormDataResult({
    required String appToken,
    required String authToken,
    required String apiRequestId,
    required String sid,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '$_baseUrl/web/get/all/formdata',
      queryParameters: {'token': appToken},
      data: {
        'auth_token': authToken,
        'sid': sid,
        'apiurl': apiRequestId,
      },
    );

    return IpassFormDataResultResponse.fromApiJson(
      Map<String, dynamic>.from(response.data ?? {}),
    );
  }

}

class IpassFormDataException implements Exception {
  const IpassFormDataException(this.message, {this.code});

  final String message;
  final String? code;

  @override
  String toString() => 'IpassFormDataException($code): $message';
}
