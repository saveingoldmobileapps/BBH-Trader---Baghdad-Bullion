import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:math' show min;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'ipass_onboarding_mapper.dart';

/// Flutter bridge to native iPass KYC SDK via method channel.
/// @see https://devdocs.ipass-mena.com/sdkDocumentation-v4.html
class IpassKycService {
  IpassKycService._();

  static final IpassKycService instance = IpassKycService._();

  static const MethodChannel _channel = MethodChannel(
    'com.baghdadbullion.bbhtrader/ipass_kyc',
  );

  bool _databaseInitialized = false;

  void _listenNativeCallbacks() {
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'onDatabaseProgress') {
        final progress = call.arguments is Map
            ? (call.arguments as Map)['progress'] as int? ?? 0
            : 0;
        if (kDebugMode) {
          debugPrint('[iPass] database download progress: $progress%');
        }
      }
    });
  }

  /// Reads iPass configuration from `.env`.
  IpassKycConfig loadConfigFromEnv() {
    final workflowRaw = dotenv.env['IPASS_WORKFLOW_ID'] ?? '10032';
    final workflowId = int.tryParse(workflowRaw) ?? 10032;
    final documentWorkflowRaw = dotenv.env['IPASS_WORKFLOW_ID_DOCUMENT'] ?? '10016';
    final documentOnlyWorkflowId = int.tryParse(documentWorkflowRaw) ?? 10016;

    return IpassKycConfig(
      email: dotenv.env['IPASS_EMAIL'] ?? '',
      password: dotenv.env['IPASS_PASSWORD'] ?? '',
      appToken: dotenv.env['IPASS_APP_TOKEN'] ?? '',
      workflowId: workflowId,
      documentOnlyWorkflowId: documentOnlyWorkflowId,
      serverUrl: dotenv.env['IPASS_SERVER_URL'] ?? '',
      dbType: dotenv.env['IPASS_DB_TYPE'] ?? 'FULL_DB',
      useDynamicDb: _parseBool(dotenv.env['IPASS_USE_DYNAMIC_DB'], false),
      enableHologram: _parseBool(dotenv.env['IPASS_ENABLE_HOLOGRAM'], false),
      socialMediaEmail: dotenv.env['IPASS_SOCIAL_MEDIA_EMAIL'] ?? '',
      phoneNumber: dotenv.env['IPASS_PHONE_NUMBER'] ?? '',
    );
  }

  bool _parseBool(String? value, bool defaultValue) {
    if (value == null) return defaultValue;
    final normalized = value.trim().toLowerCase();
    return normalized == 'true' || normalized == '1' || normalized == 'yes';
  }

  Future<void> initializeDatabase({
    IpassKycConfig? config,
  }) async {
    _listenNativeCallbacks();
    final cfg = config ?? loadConfigFromEnv();

    final result = await _channel.invokeMethod<Map<dynamic, dynamic>>(
      'initializeDatabase',
      {
        'dbType': cfg.dbType,
        'serverUrl': cfg.serverUrl,
        'useDynamicDb': cfg.useDynamicDb,
      },
    );

    if (result?['success'] == true) {
      _databaseInitialized = true;
    } else {
      throw IpassKycException(
        'Database initialization failed',
        code: 'DB_INIT_FAILED',
      );
    }
  }

  Future<List<Map<String, String>>> getWorkflows() async {
    final raw = await _channel.invokeMethod<List<dynamic>>('getWorkflows');
    if (raw == null) return [];

    return raw.map((item) {
      final map = Map<String, dynamic>.from(item as Map);
      return map.map((key, value) => MapEntry(key, value?.toString() ?? ''));
    }).toList();
  }

  /// Runs the full iPass flow: DB init (if needed) → login → scan → fetch result.
  Future<IpassKycResult> startKycVerification({
    required String email,
    required String password,
    required String appToken,
    required int workflowId,
    String socialMediaEmail = '',
    String phoneNumber = '',
    String serverUrl = '',
    String dbType = 'FULL_DB',
    bool useDynamicDb = false,
    bool enableHologram = false,
    bool skipDatabaseInit = false,
  }) async {
    _listenNativeCallbacks();

    try {
      final response = await _channel.invokeMethod<Map<dynamic, dynamic>>(
        'startKycVerification',
        {
          'email': email,
          'password': password,
          'appToken': appToken,
          'workflowId': workflowId.toString(),
          'socialMediaEmail': socialMediaEmail,
          'phoneNumber': phoneNumber,
          'serverUrl': serverUrl,
          'dbType': dbType,
          'useDynamicDb': useDynamicDb,
          'enableHologram': enableHologram,
          'skipDatabaseInit': skipDatabaseInit || _databaseInitialized,
        },
      );

      if (response == null) {
        throw const IpassKycException('Empty response from iPass SDK');
      }

      final result = _parseChannelResponse(response);
      _databaseInitialized = true;
      logResultForMapping(result);
      return result;
    } on PlatformException catch (e) {
      final recovered = _parseDataFromPlatformException(e);
      if (recovered != null) {
        _databaseInitialized = true;
        final result = IpassKycResult(
          success: false,
          apiStatus: false,
          scanMessage: e.message,
          data: recovered,
          rawResponse: e.details?.toString(),
        );
        logResultForMapping(result);
        return result;
      }
      throw IpassKycException(
        e.message ?? 'iPass verification failed',
        code: e.code,
      );
    }
  }

  IpassKycResult _parseChannelResponse(Map<dynamic, dynamic> response) {
    final dataRaw = response['data'];
    final parsedData = _parseDataPayload(dataRaw);

    return IpassKycResult(
      success: response['success'] == true,
      apiStatus: response['apiStatus'] == true,
      transactionId: response['transactionId']?.toString(),
      scanMessage: response['scanMessage']?.toString(),
      data: parsedData,
      rawResponse: response['rawResponse']?.toString(),
    );
  }

  static Map<String, dynamic>? _parseDataPayload(Object? dataRaw) {
    if (dataRaw is String && dataRaw.isNotEmpty) {
      try {
        final decoded = jsonDecode(dataRaw);
        if (decoded is Map<String, dynamic>) {
          return decoded;
        }
        if (decoded is Map) {
          return Map<String, dynamic>.from(decoded);
        }
      } catch (_) {
        return {'raw': dataRaw};
      }
    } else if (dataRaw is Map) {
      return Map<String, dynamic>.from(dataRaw);
    }
    return null;
  }

  /// Some Android builds return [PlatformException.details] with the full scan payload.
  static Map<String, dynamic>? _parseDataFromPlatformException(
    PlatformException exception,
  ) {
    final details = exception.details;
    if (details == null) return null;

    Map<String, dynamic>? envelope;
    if (details is String && details.isNotEmpty) {
      try {
        final decoded = jsonDecode(details);
        if (decoded is Map<String, dynamic>) {
          envelope = decoded;
        } else if (decoded is Map) {
          envelope = Map<String, dynamic>.from(decoded);
        }
      } catch (_) {
        return null;
      }
    } else if (details is Map) {
      envelope = Map<String, dynamic>.from(details);
    }

    if (envelope == null) return null;

    final nested = _parseDataPayload(envelope['data']);
    if (nested != null && IpassOnboardingMapper.hasDocumentDetails(nested)) {
      return nested;
    }
    if (IpassOnboardingMapper.hasDocumentDetails(envelope)) {
      return envelope;
    }
    return null;
  }

  /// Pretty-prints iPass JSON to the debug console so you can copy it for field mapping.
  /// Look for `iPassKycData` in Android Logcat / Xcode / VS Code Debug Console.
  static void logResultForMapping(IpassKycResult result) {
    if (!kDebugMode) return;

    const encoder = JsonEncoder.withIndent('  ');
    const banner =
        '========== iPass KYC JSON (copy everything below) ==========';

    developer.log(banner, name: 'iPassKycData');

    if (result.transactionId != null) {
      _logChunk('transactionId: ${result.transactionId}', 'iPassKycData');
    }

    if (result.data != null && result.data!.isNotEmpty) {
      try {
        _logChunk(
          '--- parsed data ---\n${encoder.convert(result.data)}',
          'iPassKycData',
        );
      } catch (e) {
        _logChunk(
          '--- parsed data (encode failed: $e) ---\n${result.data}',
          'iPassKycData',
        );
      }
    } else {
      _logChunk('--- parsed data: null or empty ---', 'iPassKycData');
    }

    final raw = result.rawResponse;
    if (raw != null && raw.isNotEmpty) {
      try {
        final decoded = jsonDecode(raw);
        _logChunk(
          '--- rawResponse ---\n${encoder.convert(decoded)}',
          'iPassKycData',
        );
      } catch (_) {
        _logChunk('--- rawResponse (string) ---\n$raw', 'iPassKycData');
      }
    }

    developer.log(
      '========== END iPass KYC JSON ==========',
      name: 'iPassKycData',
    );
  }

  static void _logChunk(String text, String name) {
    const chunkSize = 800;
    for (var i = 0; i < text.length; i += chunkSize) {
      developer.log(
        text.substring(i, min(i + chunkSize, text.length)),
        name: name,
      );
    }
  }

  /// Builds KYC payload for backend `service/kyc/saveData` endpoint.
  Map<String, dynamic> buildBackendKycPayload({
    required String userId,
    required String countryCode,
    required IpassKycResult ipassResult,
    Map<String, dynamic>? bankOnboardingData,
  }) {
    return {
      'userId': userId,
      'kycData': {
        'provider': 'ipass',
        'event': 'verification.accepted',
        'country': countryCode,
        'reference': ipassResult.transactionId,
        'ipassData': ipassResult.toJson(),
      },
      'bankOnboardingData': ?bankOnboardingData,
    };
  }

  /// Requests camera + microphone before native iPass flow (Android 13/14).
  Future<bool> ensurePermissions() async {
    final result = await _channel.invokeMethod<Map<dynamic, dynamic>>(
      'checkPermissions',
    );
    if (result?['granted'] == true) {
      return true;
    }
    return false;
  }
}

class IpassKycConfig {
  const IpassKycConfig({
    required this.email,
    required this.password,
    required this.appToken,
    required this.workflowId,
    this.documentOnlyWorkflowId = 10016,
    this.serverUrl = '',
    this.dbType = 'FULL_DB',
    this.useDynamicDb = false,
    this.enableHologram = false,
    this.socialMediaEmail = '',
    this.phoneNumber = '',
  });

  final String email;
  final String password;
  final String appToken;
  final int workflowId;
  /// Document-only workflow (no liveness/selfie) — residence & passport scans.
  final int documentOnlyWorkflowId;
  final String serverUrl;
  final String dbType;
  final bool useDynamicDb;
  final bool enableHologram;
  final String socialMediaEmail;
  final String phoneNumber;

  bool get isValid =>
      email.isNotEmpty && password.isNotEmpty && appToken.isNotEmpty;

  int workflowIdFor(IpassScanTarget target) =>
      target == IpassScanTarget.nationalId ? workflowId : documentOnlyWorkflowId;
}

class IpassKycResult {
  const IpassKycResult({
    required this.success,
    required this.apiStatus,
    this.transactionId,
    this.scanMessage,
    this.data,
    this.rawResponse,
  });

  final bool success;
  final bool apiStatus;
  final String? transactionId;
  final String? scanMessage;
  final Map<String, dynamic>? data;
  final String? rawResponse;

  Map<String, dynamic> toJson() => {
    'success': success,
    'apiStatus': apiStatus,
    if (transactionId != null) 'transactionId': transactionId,
    if (scanMessage != null) 'scanMessage': scanMessage,
    if (data != null) 'data': data,
    if (rawResponse != null) 'rawResponse': rawResponse,
  };
}

class IpassKycException implements Exception {
  const IpassKycException(this.message, {this.code});

  final String message;
  final String? code;

  factory IpassKycException.fromPlatform(PlatformException e) {
    return IpassKycException(
      e.message ?? 'iPass KYC failed',
      code: e.code,
    );
  }

  @override
  String toString() => 'IpassKycException($code): $message';
}
