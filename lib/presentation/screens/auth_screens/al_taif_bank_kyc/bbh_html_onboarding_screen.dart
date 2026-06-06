import 'dart:convert';
import 'dart:io' show Platform;

import 'package:baghdad_bullion_house/core/theme/const_toasts.dart';
import 'package:baghdad_bullion_house/l10n/app_localizations.dart';
import 'package:baghdad_bullion_house/services/ipass_kyc/bbh_onboarding_state_store.dart';
import 'package:baghdad_bullion_house/services/ipass_kyc/ipass_html_field_mapper.dart';
import 'package:baghdad_bullion_house/services/ipass_kyc/ipass_kyc_service.dart';
import 'package:baghdad_bullion_house/services/ipass_kyc/ipass_onboarding_mapper.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// Loads the BBH onboarding HTML (single source of truth for UI) and bridges
/// iPass KYC at the National ID document capture step.
class BbhHtmlOnboardingScreen extends StatefulWidget {
  const BbhHtmlOnboardingScreen({super.key});

  @override
  State<BbhHtmlOnboardingScreen> createState() =>
      _BbhHtmlOnboardingScreenState();
}

class _BbhHtmlOnboardingScreenState extends State<BbhHtmlOnboardingScreen> {
  static const _htmlAsset = 'assets/html/bbh-onboarding-demo.html';

  late final WebViewController _controller;
  bool _pageReady = false;
  bool _ipassInProgress = false;

  @override
  void initState() {
    super.initState();
    _controller =
        WebViewController()
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..setBackgroundColor(const Color(0xFFF6F0E2))
          ..addJavaScriptChannel(
            'BBHFlutter',
            onMessageReceived: _onJsMessage,
          )
          ..setNavigationDelegate(
            NavigationDelegate(
              onPageFinished: (_) => _onPageFinished(),
            ),
          )
          ..loadFlutterAsset(_htmlAsset);
  }

  Future<void> _onPageFinished() async {
    if (!mounted) return;
    setState(() => _pageReady = true);
    await _restorePersistedState();
  }

  Future<void> _restorePersistedState() async {
    final saved = BbhOnboardingStateStore.instance.load();
    if (saved == null || saved.isEmpty) return;
    await _runJs(
      'window.bbhRestorePersistedState(${jsonEncode(saved)});',
    );
  }

  Future<void> _onJsMessage(JavaScriptMessage message) async {
    Map<String, dynamic>? payload;
    try {
      final decoded = jsonDecode(message.message);
      if (decoded is Map<String, dynamic>) {
        payload = decoded;
      } else if (decoded is Map) {
        payload = Map<String, dynamic>.from(decoded);
      }
    } catch (_) {
      return;
    }
    if (payload == null) return;

    switch (payload['action']) {
      case 'ready':
        await _restorePersistedState();
        break;
      case 'persistState':
        final state = payload['state'];
        if (state is Map) {
          await BbhOnboardingStateStore.instance.save(
            Map<String, dynamic>.from(state),
          );
        }
        break;
      case 'startIpassKyc':
        await _runIpassKyc(replace: payload['replace'] == true);
        break;
      case 'clearState':
        await BbhOnboardingStateStore.instance.clear();
        break;
      default:
        break;
    }
  }

  Future<bool> _ensureKycMediaPermissions() async {
    if (Platform.isIOS) return true;

    final camera = await Permission.camera.request();
    final mic = await Permission.microphone.request();
    if (camera.isGranted && mic.isGranted) return true;

    Toasts.getErrorToast(
      text:
          camera.isPermanentlyDenied || mic.isPermanentlyDenied
              ? 'Enable camera and microphone in app settings for identity verification.'
              : 'Camera and microphone permissions are required for identity verification.',
    );
    return false;
  }

  Future<void> _runIpassKyc({required bool replace}) async {
    if (_ipassInProgress) return;

    setState(() => _ipassInProgress = true);
    await _runJs('window.bbhSetIpassLoading(true);');

    try {
      final config = IpassKycService.instance.loadConfigFromEnv();
      if (!config.isValid) {
        Toasts.getErrorToast(
          text:
              'Identity verification is not configured. Please try again later.',
        );
        return;
      }

      if (!await _ensureKycMediaPermissions()) return;

      final ipassResult = await IpassKycService.instance.startKycVerification(
        email: config.email,
        password: config.password,
        appToken: config.appToken,
        workflowId: config.workflowId,
        socialMediaEmail:
            config.socialMediaEmail.isNotEmpty
                ? config.socialMediaEmail
                : config.email,
        phoneNumber: config.phoneNumber,
        serverUrl: config.serverUrl,
        dbType: config.dbType,
        useDynamicDb: config.useDynamicDb,
        enableHologram: config.enableHologram,
      );

      if (!ipassResult.success || !ipassResult.apiStatus) {
        if (!mounted) return;
        Toasts.getErrorToast(
          text: AppLocalizations.of(context)!.shufti_pro_verification_failed,
        );
        return;
      }

      final mapped = IpassOnboardingMapper.extractFieldValues(ipassResult.data);
      if (kDebugMode) {
        IpassOnboardingMapper.logMappedFields(mapped);
      }

      final htmlFields = IpassHtmlFieldMapper.toHtmlFieldValues(mapped);
      final lockedFields = IpassHtmlFieldMapper.lockedHtmlFields(htmlFields);

      final bridgePayload = jsonEncode({
        'fields': htmlFields,
        'lockedFields': lockedFields,
        'replace': replace,
        'transactionId': ipassResult.transactionId,
      });

      await _runJs('window.bbhApplyIpassResult($bridgePayload);');
    } on IpassKycException catch (e, stackTrace) {
      await Sentry.captureException(e, stackTrace: stackTrace);
      Toasts.getErrorToast(text: e.message);
    } on PlatformException catch (e, stackTrace) {
      await Sentry.captureException(e, stackTrace: stackTrace);
      if (!mounted) return;
      Toasts.getErrorToast(
        text:
            e.message ??
            AppLocalizations.of(context)!.kyc_verification_failed,
      );
    } catch (e, stackTrace) {
      await Sentry.captureException(e, stackTrace: stackTrace);
      if (!mounted) return;
      Toasts.getErrorToast(
        text: AppLocalizations.of(context)!.kyc_verification_failed,
      );
    } finally {
      await _runJs('window.bbhSetIpassLoading(false);');
      if (mounted) setState(() => _ipassInProgress = false);
    }
  }

  Future<void> _runJs(String script) async {
    if (!_pageReady) return;
    try {
      await _controller.runJavaScript(script);
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('BBH onboarding JS error: $e');
      }
      await Sentry.captureException(e, stackTrace: stackTrace);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_ipassInProgress,
      child: Scaffold(
        backgroundColor: const Color(0xFFF6F0E2),
        body: SafeArea(
          top: false,
          bottom: false,
          child: Stack(
            fit: StackFit.expand,
            children: [
              WebViewWidget(controller: _controller),
              if (_ipassInProgress)
                Container(
                  color: Colors.black.withValues(alpha: 0.35),
                  alignment: Alignment.center,
                  child: const _IpassLoadingCard(),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _IpassLoadingCard extends StatelessWidget {
  const _IpassLoadingCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 32),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
      decoration: BoxDecoration(
        color: const Color(0xFFFBF8F1),
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Color(0x2E1C2638),
            blurRadius: 24,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(
            color: Color(0xFFB8924A),
            strokeWidth: 2.5,
          ),
          const SizedBox(height: 18),
          Text(
            'Verifying your identity…',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Manrope',
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1C2638),
            ),
          ),
        ],
      ),
    );
  }
}
