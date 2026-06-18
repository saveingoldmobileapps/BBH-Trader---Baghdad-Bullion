import 'dart:io' show File, Platform;

import 'package:baghdad_bullion_house/core/theme/const_toasts.dart';
import 'package:baghdad_bullion_house/presentation/screens/auth_screens/auth_kyc_screens/widgets/documets_camera.dart';
import 'package:baghdad_bullion_house/services/bbh_onboarding/bbh_onboarding_otp_service.dart';
import 'package:baghdad_bullion_house/services/ipass_kyc/ipass_onboarding_mapper.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import 'bbh_onboarding_controller.dart';
import 'bbh_onboarding_edit_sheet.dart';
import 'bbh_onboarding_field_scroll.dart';
import 'bbh_onboarding_otp_sheet.dart';
import 'bbh_onboarding_steps.dart';
import 'bbh_onboarding_theme.dart';
import 'bbh_onboarding_widgets.dart';

/// Native Flutter onboarding — visual match to `bbh-onboarding-demo_25.html`.
class BbhNativeOnboardingScreen extends StatefulWidget {
  const BbhNativeOnboardingScreen({super.key});

  @override
  State<BbhNativeOnboardingScreen> createState() =>
      _BbhNativeOnboardingScreenState();
}

class _BbhNativeOnboardingScreenState extends State<BbhNativeOnboardingScreen> {
  late final BbhOnboardingController _controller;
  bool _hydrated = false;

  @override
  void initState() {
    super.initState();
    _controller = BbhOnboardingController();
    _controller.addListener(_onControllerChanged);
    _hydrate();
  }

  Future<void> _hydrate() async {
    await _controller.loadPersistedState();
    if (mounted) setState(() => _hydrated = true);
  }

  void _onControllerChanged() {
    final focusField = _controller.validationFocusField;
    if (focusField != null) {
      _controller.consumeValidationFocus();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        BbhOnboardingFieldScroll.scrollTo(focusField);
      });
    }
    if (_controller.lastError != null) {
      Toasts.getErrorToast(text: _controller.lastError!);
      _controller.lastError = null;
    }
    if (_controller.lastWarning != null) {
      Toasts.getWarningToast(text: _controller.lastWarning!);
      _controller.lastWarning = null;
    }
    if (_controller.lastSuccess != null) {
      Toasts.getSuccessToast(text: _controller.lastSuccess!);
      _controller.lastSuccess = null;
    }
    setState(() {});
  }

  @override
  void dispose() {
    _controller.persist();
    _controller.removeListener(_onControllerChanged);
    _controller.dispose();
    super.dispose();
  }

  Future<bool> _ensureKycMediaPermissions({bool documentOnly = false}) async {
    if (Platform.isIOS) return true;
    final camera = await Permission.camera.request();
    if (documentOnly) {
      if (camera.isGranted) return true;
      Toasts.getErrorToast(
        text: camera.isPermanentlyDenied
            ? 'Enable camera in app settings for document scanning.'
            : 'Camera permission is required for document scanning.',
      );
      return false;
    }
    final mic = await Permission.microphone.request();
    if (camera.isGranted && mic.isGranted) return true;
    Toasts.getErrorToast(
      text: camera.isPermanentlyDenied || mic.isPermanentlyDenied
          ? 'Enable camera and microphone in app settings for identity verification.'
          : 'Camera and microphone permissions are required for identity verification.',
    );
    return false;
  }

  Future<void> _runIpassFromDocuments(IpassScanTarget target) async {
    if (_controller.ipassInProgress) return;

    if (target == IpassScanTarget.residence) {
      if (!await _ensureKycMediaPermissions(documentOnly: true)) return;
      await _runResidenceFormDataCapture();
      return;
    }

    final documentOnly = target != IpassScanTarget.nationalId;
    if (!await _ensureKycMediaPermissions(documentOnly: documentOnly)) return;

    await _controller.runIpassKyc(target);
  }

  Future<File?> _captureResidenceImage(String title) async {
    File? captured;
    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => DocumentCameraScreen(
          resolution: ResolutionPreset.medium,
          onImageCaptured: (file) => captured = file,
        ),
      ),
    );
    return captured;
  }

  Future<void> _runResidenceFormDataCapture() async {
    _controller.clearResidenceCaptureProgress();

    final front = await _captureResidenceImage('Residence document — front');
    if (!mounted || front == null) return;

    final frontOk = await _controller.processResidenceFrontSide(
      frontImage: front,
    );
    if (!mounted || !frontOk) return;

    final back = await _captureResidenceImage('Residence document — back');
    if (!mounted || back == null) return;

    await _controller.processResidenceBackSideAndFinalize(backImage: back);
  }

  Future<void> _pickDate(TextEditingController target, String fieldKey) async {
    final now = DateTime.now();
    final isExpiry = fieldKey.contains('expiry');
    var initialDate = DateTime(now.year - 30);
    final existing = DateTime.tryParse(target.text.trim());
    if (existing != null) initialDate = existing;

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1920),
      lastDate: isExpiry ? DateTime(now.year + 30) : now,
      builder: (context, child) {
        return Theme(
          data: BbhOnboardingTheme.materialTheme(),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
    if (picked != null) {
      target.text =
          '${picked.year.toString().padLeft(4, '0')}-'
          '${picked.month.toString().padLeft(2, '0')}-'
          '${picked.day.toString().padLeft(2, '0')}';
      await _controller.persist();
      setState(() {});
    }
  }

  Future<void> _refresh() async {
    await _controller.persist();
    setState(() {});
  }

  Future<void> _verifyContact(
    BbhOnboardingOtpChannel channel,
  ) async {
    FocusScope.of(context).unfocus();

    final mobile = _controller.form.mobile.text.trim();
    final email = _controller.form.email.text.trim().toLowerCase();

    if (channel == BbhOnboardingOtpChannel.mobile && mobile.isEmpty) {
      Toasts.getErrorToast(
        text: 'Please enter your mobile number.',
      );
      return;
    }

    if (channel == BbhOnboardingOtpChannel.email && email.isEmpty) {
      Toasts.getErrorToast(
        text: 'Please enter your email address.',
      );
      return;
    }

    if (channel == BbhOnboardingOtpChannel.email &&
        !_controller.form.verifiedMobile.value) {
      Toasts.getErrorToast(
        text: 'Verify your mobile number before verifying your email.',
      );
      return;
    }

    final verified = await BbhOnboardingOtpSheet.openForVerification(
      context,
      channel: channel,
      phoneNumber: mobile,
      email: email,
    );

    if (!mounted || verified != true) {
      return;
    }

    if (channel == BbhOnboardingOtpChannel.mobile) {
      _controller.form.verifiedMobile.value = true;
      _controller.lastSuccess = 'Mobile number verified.';
    } else {
      _controller.form.verifiedEmail.value = true;
      _controller.lastSuccess = 'Email address verified.';
    }

    await _refresh();
  }

  String _nextLabel() {
    if (_controller.editReturnStep != null) return 'Done';
    if (_controller.step == BbhOnboardingStep.review) return 'Submit Pack';
    return 'Continue';
  }

  void _editReviewSection(String key) {
    BbhOnboardingEditSheet.open(
      context: context,
      sectionKey: key,
      controller: _controller,
      onChanged: _refresh,
      pickDate: _pickDate,
      onVerify: _verifyContact,
    );
  }

  void _onNext() async {
    if (_controller.step == BbhOnboardingStep.review) {
      await _controller.submitPack();
      return;
    }
    _controller.next();
  }

  Widget _buildStep() {
    final form = _controller.form;
    switch (_controller.step) {
      case BbhOnboardingStep.cover:
        return BbhOnboardingSteps.cover(
          onBegin: () => _controller.goTo(BbhOnboardingStep.preflight),
          onExit: () => Navigator.of(context).maybePop(),
        );
      case BbhOnboardingStep.preflight:
        return BbhOnboardingSteps.preflight();
      case BbhOnboardingStep.purpose:
        return BbhOnboardingSteps.purpose(form, () => _refresh());
      case BbhOnboardingStep.documents:
        return BbhOnboardingSteps.documents(
          form: form,
          onChanged: () => _refresh(),
          onIpassCapture: _runIpassFromDocuments,
          ipassLoadingTarget: _controller.activeIpassScan,
        );
      case BbhOnboardingStep.ocrReview:
        return BbhOnboardingSteps.ocrReview(form, () => _refresh(), _pickDate);
      case BbhOnboardingStep.residenceAddress:
        return BbhOnboardingSteps.residenceAddress(
          form,
          () => _refresh(),
          _pickDate,
        );
      case BbhOnboardingStep.personalDetails:
        return BbhOnboardingSteps.personalDetails(
          form,
          () => _refresh(),
          _pickDate,
        );
      case BbhOnboardingStep.income:
        return BbhOnboardingSteps.income(form, () => _refresh());
      case BbhOnboardingStep.fatca:
        return BbhOnboardingSteps.fatca(form, () => _refresh());
      case BbhOnboardingStep.pep:
        return BbhOnboardingSteps.pep(form, () => _refresh());
      case BbhOnboardingStep.contact:
        return BbhOnboardingSteps.contact(
          form,
          () => _refresh(),
          onVerify: _verifyContact,
        );
      case BbhOnboardingStep.custodian:
        return BbhOnboardingSteps.custodian(form, () => _refresh());
      case BbhOnboardingStep.consent:
        return BbhOnboardingSteps.consent(form, () => _refresh());
      case BbhOnboardingStep.review:
        return BbhOnboardingSteps.review(
          form,
          onEditSection: _editReviewSection,
        );
      case BbhOnboardingStep.success:
        return BbhOnboardingSteps.success(
          kycRef: _controller.kycReference,
          onRestart: _controller.resetAll,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_hydrated) {
      return Theme(
        data: BbhOnboardingTheme.materialTheme(),
        child: const Scaffold(
          backgroundColor: BbhOnboardingColors.cream,
          body: Center(
            child: CircularProgressIndicator(
              color: BbhOnboardingColors.goldDeep,
            ),
          ),
        ),
      );
    }

    final step = _controller.step;

    return Theme(
      data: BbhOnboardingTheme.materialTheme(),
      child: DefaultTextStyle(
        style: BbhOnboardingText.manrope(color: BbhOnboardingColors.ink),
        child: step.hidesChrome ? _buildChromeless(step) : _buildShell(step),
      ),
    );
  }

  Widget _buildChromeless(BbhOnboardingStep step) {
    return PopScope(
      canPop: step == BbhOnboardingStep.cover,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) _controller.persist();
      },
      child: Scaffold(
        backgroundColor: step == BbhOnboardingStep.cover
            ? BbhOnboardingColors.coverDarkBottom
            : BbhOnboardingColors.cream,
        body: _buildStep(),
      ),
    );
  }

  Widget _buildShell(BbhOnboardingStep step) {
    return PopScope(
      canPop: !_controller.ipassInProgress,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) _controller.persist();
      },
      child: BbhOnboardingShell(
        progress: _controller.progressFraction,
        stepLabel: '${_controller.progressIndex}',
        backVisible: step != BbhOnboardingStep.preflight,
        nextLabel: _nextLabel(),
        nextIsGold:
            step == BbhOnboardingStep.review ||
            _controller.editReturnStep != null,
        nextLoading: _controller.ipassInProgress || _controller.submitInProgress,
        onBack: _controller.back,
        onNext: _onNext,
        body: _buildStep(),
      ),
    );
  }
}
