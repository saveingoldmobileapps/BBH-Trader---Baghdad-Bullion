import 'dart:io' show File, Platform;

import 'package:baghdad_bullion_house/core/kyc/kyc_document_review_status.dart';
import 'package:baghdad_bullion_house/core/theme/const_toasts.dart';
import 'package:baghdad_bullion_house/presentation/screens/auth_screens/auth_kyc_screens/widgets/documets_camera.dart';
import 'package:baghdad_bullion_house/presentation/screens/auth_screens/al_taif_bank_kyc/native/bbh_onboarding_theme.dart';
import 'package:baghdad_bullion_house/presentation/screens/auth_screens/al_taif_bank_kyc/native/bbh_onboarding_widgets.dart';
import 'package:baghdad_bullion_house/presentation/screens/kyc_document_update/kyc_document_update_steps.dart';
import 'package:baghdad_bullion_house/presentation/sharedProviders/providers/home_provider.dart';
import 'package:baghdad_bullion_house/services/kyc_document_update/kyc_document_update_controller.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';

/// Re-submit a single KYC document after admin rejection or pending review.
class KycDocumentUpdateScreen extends ConsumerStatefulWidget {
  const KycDocumentUpdateScreen({
    super.key,
    required this.documentType,
    required this.reviewStatus,
  });

  final KycDocumentType documentType;
  final KycDocumentReviewStatus reviewStatus;

  @override
  ConsumerState<KycDocumentUpdateScreen> createState() =>
      _KycDocumentUpdateScreenState();
}

class _KycDocumentUpdateScreenState
    extends ConsumerState<KycDocumentUpdateScreen> {
  late final KycDocumentUpdateController _controller;
  bool _hydrated = false;

  @override
  void initState() {
    super.initState();
    _controller = KycDocumentUpdateController(
      documentType: widget.documentType,
      reviewStatus: widget.reviewStatus,
    );
    _controller.addListener(_onControllerChanged);
    _hydrate();
  }

  Future<void> _hydrate() async {
    await _controller.loadPersistedState();
    final profile =
        ref.read(homeProvider).getUserProfileResponse.payload?.userProfile;
    _controller.prefillFromProfile(profile);
    if (mounted) setState(() => _hydrated = true);
  }

  void _onControllerChanged() {
    if (_controller.lastError != null) {
      Toasts.getErrorToast(text: _controller.lastError!);
      _controller.lastError = null;
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
    if (documentOnly) return camera.isGranted;
    final mic = await Permission.microphone.request();
    return camera.isGranted && mic.isGranted;
  }

  Future<void> _runCapture() async {
    if (_controller.ipassInProgress) return;

    if (widget.documentType == KycDocumentType.residency) {
      if (!await _ensureKycMediaPermissions(documentOnly: true)) return;
      await _runResidenceCapture();
      return;
    }

    final documentOnly = widget.documentType != KycDocumentType.nationalId;
    if (!await _ensureKycMediaPermissions(documentOnly: documentOnly)) return;

    final ok = await _controller.runIpassKyc();
    if (ok && mounted) {
      _controller.goToReview();
    }
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

  Future<void> _runResidenceCapture() async {
    _controller.clearResidenceCaptureProgress();

    final front = await _captureResidenceImage('Residence document — front');
    if (!mounted || front == null) return;

    final frontOk = await _controller.processResidenceFrontSide(
      frontImage: front,
    );
    if (!mounted || !frontOk) return;

    final back = await _captureResidenceImage('Residence document — back');
    if (!mounted || back == null) return;

    final ok = await _controller.processResidenceBackSideAndFinalize(
      backImage: back,
    );
    if (ok && mounted) {
      _controller.goToReview();
    }
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

  String _primaryLabel() {
    return switch (_controller.step) {
      KycDocumentUpdateStep.rejection => 'Retake scan',
      KycDocumentUpdateStep.scan => 'Continue',
      KycDocumentUpdateStep.review => 'Submit',
      KycDocumentUpdateStep.success => 'Back to Home',
    };
  }

  Future<void> _onPrimary() async {
    switch (_controller.step) {
      case KycDocumentUpdateStep.rejection:
        _controller.goToScan();
      case KycDocumentUpdateStep.scan:
        if (_controller.documentCaptured) {
          _controller.goToReview();
        } else {
          await _runCapture();
        }
      case KycDocumentUpdateStep.review:
        final ok = await _controller.submitDocument();
        if (ok && mounted) {
          await ref
              .read(homeProvider.notifier)
              .getHomeFeed(context: context, showLoading: false);
        }
      case KycDocumentUpdateStep.success:
        if (mounted) Navigator.of(context).pop(true);
    }
  }

  Widget _buildBody() {
    if (!_hydrated) {
      return const Center(child: CircularProgressIndicator());
    }

    return switch (_controller.step) {
      KycDocumentUpdateStep.rejection => KycDocumentUpdateSteps.rejection(
          documentType: widget.documentType,
          onRetake: _controller.goToScan,
        ),
      KycDocumentUpdateStep.scan => KycDocumentUpdateSteps.scan(
          documentType: widget.documentType,
          form: _controller.form,
          onChanged: () => setState(() {}),
          onCapture: _runCapture,
          loading: _controller.ipassInProgress,
        ),
      KycDocumentUpdateStep.review => KycDocumentUpdateSteps.review(
          documentType: widget.documentType,
          form: _controller.form,
          onChanged: () => setState(() {}),
          pickDate: _pickDate,
        ),
      KycDocumentUpdateStep.success => KycDocumentUpdateSteps.success(
          documentType: widget.documentType,
        ),
    };
  }

  @override
  Widget build(BuildContext context) {
    final title = KycDocumentUpdateSteps.documentTitle(widget.documentType);

    return Theme(
      data: BbhOnboardingTheme.materialTheme(),
      child: Scaffold(
        backgroundColor: BbhOnboardingColors.cream,
        appBar: AppBar(
          backgroundColor: BbhOnboardingColors.cream,
          elevation: 0,
          foregroundColor: BbhOnboardingColors.ink,
          title: Text(
            'Update $title',
            style: BbhOnboardingText.manrope(
              size: 16,
              weight: FontWeight.w600,
            ),
          ),
        ),
        body: _buildBody(),
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
            child: BbhPrimaryButton(
              label: _primaryLabel(),
              loading: _controller.submitInProgress || _controller.ipassInProgress,
              onPressed: _onPrimary,
            ),
          ),
        ),
      ),
    );
  }
}
