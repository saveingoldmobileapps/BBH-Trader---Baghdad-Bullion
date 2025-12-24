import 'dart:async';
import 'dart:io' show Platform;

import 'package:app_settings/app_settings.dart' as app_settings;
import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:saveingold_fzco/core/core_export.dart';
import 'package:saveingold_fzco/presentation/widgets/pop_up_widget.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class BiometricUtils {
  static final LocalAuthentication _auth = LocalAuthentication();

  // Check if biometric hardware is supported and any biometric is enrolled
  static Future<bool> _isBiometricReady() async {
    try {
      final bool isSupported = await _auth.isDeviceSupported();
      final List<BiometricType> biometrics = await _auth
          .getAvailableBiometrics();
      final bool hasBiometric = biometrics.isNotEmpty;
      debugPrint(
        'isDeviceSupported: $isSupported, enrolledBiometrics: $biometrics',
      );
      return isSupported && hasBiometric;
    } catch (e, stackTrace) {
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
      );
      debugPrint('Error checking biometric readiness: $e');
      return false;
    }
  }

  //check finger print
  static Future<bool> isFingerprintAvailable() async {
    final auth = LocalAuthentication();
    final canCheck = await auth.canCheckBiometrics;
    final available = await auth.getAvailableBiometrics();
    final hasFingerprint =
        available.contains(BiometricType.fingerprint) ||
        available.contains(BiometricType.strong);
    return canCheck && hasFingerprint;
  }

  //check facelock
  static Future<bool> isFaceLockAvailable() async {
    final auth = LocalAuthentication();
    final canCheck = await auth.canCheckBiometrics;
    final available = await auth.getAvailableBiometrics();

    final hasFaceLock =
        available.contains(BiometricType.face) ||
        available.contains(BiometricType.strong);

    return canCheck && hasFaceLock;
  }

  // Check if fingerprint hardware is available on the device
  static Future<void> hasFingerprintHardware() async {
    try {
      final availableBiometrics = await _auth.getAvailableBiometrics();
      CommonService.hasFingerHardWare = availableBiometrics.contains(
        BiometricType.strong,
      );
      debugPrint('device hardware: ${CommonService.hasFingerHardWare}');
    } catch (e) {
      CommonService.hasFingerHardWare = false;
      debugPrint('device hardware: ${CommonService.hasFingerHardWare}$e');
    }
  }

  // Check if face recognition hardware is available on the device
  static Future<void> hasFaceHardware() async {
    try {
      final availableBiometrics = await _auth.getAvailableBiometrics();
      CommonService.hasFaceHardWare = availableBiometrics.contains(
        BiometricType.strong,
      );
      debugPrint('device hardware: ${CommonService.hasFaceHardWare}');
    } catch (e) {
      CommonService.hasFaceHardWare = false;
      debugPrint('device hardware: ${CommonService.hasFaceHardWare}$e');
    }
  }

  // Open device security settings
  static Future<void> _openSecuritySettings() async {
    if (Platform.isIOS) {
      try {
        final Uri url = Uri.parse('app-settings:'); // More reliable
        if (!await launchUrl(url)) {
          debugPrint('Could not launch iOS settings');
        }
      } catch (e, stackTrace) {
        await Sentry.captureException(
          e,
          stackTrace: stackTrace,
        );
        debugPrint('Error opening iOS settings: $e');
      }
    } else if (Platform.isAndroid) {
      try {
        await app_settings.AppSettings.openAppSettings(
          type: app_settings.AppSettingsType.security,
        );
      } catch (e, stackTrace) {
        await Sentry.captureException(
          e,
          stackTrace: stackTrace,
        );
        debugPrint('Could not open Android settings: $e');
      }
    }
  }

  // Show settings dialog
  static Future<bool> _showSettingsDialog(BuildContext context) async {
    final completer = Completer<bool>();

    await genericPopUpWidget(
      context: context,
      heading: Platform.isAndroid ? "Enable Fingerprint" : "Enable Face ID",
      subtitle: Platform.isAndroid
          ? "Your device doesn't have fingerprint. Please enable to continue."
          : "Your device doesn't have Face ID. Please enable to continue.",
      noButtonTitle: "Cancel",
      yesButtonTitle: "Go to Settings",
      isLoadingState: false,
      onNoPress: () {
        Navigator.pop(context);
        completer.complete(false);
      },
      onYesPress: () async {
        Navigator.pop(context);
        completer.complete(true);
      },
    );

    final result = await completer.future;

    if (result == true) {
      await _openSecuritySettings();
      return await _isBiometricReady();
    }
    return false;
  }

  // Entry point to ensure biometric or passcode is ready
  static Future<bool> checkAndEnableBiometric(BuildContext context) async {
    final bool ready = await _isBiometricReady();
    if (ready) {
      return true;
    } else {
      debugPrint('Biometric not ready, showing settings dialog');
      if (!context.mounted) return false;
      return await _showSettingsDialog(context);
    }
  }
}
