import 'package:baghdad_bullion_house/core/kyc/kyc_document_review_status.dart';
import 'package:baghdad_bullion_house/presentation/screens/auth_screens/al_taif_bank_kyc/native/bbh_onboarding_form.dart';
import 'package:baghdad_bullion_house/presentation/screens/auth_screens/al_taif_bank_kyc/native/bbh_onboarding_steps.dart';
import 'package:baghdad_bullion_house/presentation/screens/auth_screens/al_taif_bank_kyc/native/bbh_onboarding_widgets.dart';
import 'package:flutter/material.dart';

/// Document-specific UI for the post-login KYC update flow.
class KycDocumentUpdateSteps {
  KycDocumentUpdateSteps._();

  static String documentTitle(KycDocumentType type) => switch (type) {
        KycDocumentType.nationalId => 'National ID',
        KycDocumentType.passport => 'Passport',
        KycDocumentType.residency => 'Residence Card',
      };

  static Widget rejection({
    required KycDocumentType documentType,
    required VoidCallback onRetake,
    String? message,
  }) {
    final title = documentTitle(documentType);
    return _scroll([
      BbhStepHeader(
        eyebrow: 'Document Review',
        title: '$title rejected',
        lede: message ??
            'Your ${title.toLowerCase()} was not approved. '
                'Please retake a clear scan and submit updated details.',
      ),
      const SizedBox(height: 12),
      const BbhInfoBanner(
        text:
            'Make sure the document is well lit, fully visible, and not expired.',
      ),
      const SizedBox(height: 24),
      BbhPrimaryButton(label: 'Retake scan', onPressed: onRetake),
    ]);
  }

  static Widget statusBlocked({
    required KycDocumentType documentType,
    required String message,
  }) {
    final title = documentTitle(documentType);
    return _scroll([
      BbhStepHeader(
        eyebrow: 'Document Review',
        title: title,
        lede: message,
      ),
      const SizedBox(height: 16),
      const BbhInfoBanner(
        text:
            'Pull to refresh on the home screen after review completes, or return later.',
      ),
    ]);
  }

  static Widget scan({
    required KycDocumentType documentType,
    required BbhOnboardingForm form,
    required VoidCallback onChanged,
    required Future<void> Function() onCapture,
    required bool loading,
  }) {
    final captured = switch (documentType) {
      KycDocumentType.nationalId =>
        form.idFrontCaptured && form.idBackCaptured,
      KycDocumentType.passport => form.passportCaptured,
      KycDocumentType.residency =>
        form.resFrontCaptured && form.resBackCaptured,
    };

    final title = switch (documentType) {
      KycDocumentType.nationalId => 'Identity Verification',
      KycDocumentType.passport => 'Passport — Photo Page',
      KycDocumentType.residency => 'Residence Card (Front and Back)',
    };

    return _scroll([
      BbhStepHeader(
        eyebrow: 'Update ${documentTitle(documentType)}',
        title: 'Scan your ${documentTitle(documentType).toLowerCase()}',
        lede:
            'Capture the document clearly. We will read your details automatically so you can review them before submitting.',
      ),
      const SizedBox(height: 20),
      BbhDocCaptureRow(
        badge: '1',
        title: title,
        captured: captured,
        loading: loading && !captured,
        onCapture: onCapture,
        onReplace: captured ? onCapture : null,
      ),
    ]);
  }

  static Widget review({
    required KycDocumentType documentType,
    required BbhOnboardingForm form,
    required VoidCallback onChanged,
    required Future<void> Function(TextEditingController, String) pickDate,
  }) {
    return switch (documentType) {
      KycDocumentType.nationalId => _nationalIdReview(form, pickDate),
      KycDocumentType.passport => _passportReview(form, pickDate),
      KycDocumentType.residency => BbhOnboardingSteps.residenceAddress(
          form,
          onChanged,
          pickDate,
        ),
    };
  }

  static Widget success({required KycDocumentType documentType}) {
    return _scroll([
      BbhStepHeader(
        eyebrow: 'Submitted',
        title: '${documentTitle(documentType)} sent for review',
        lede:
            'Your updated ${documentTitle(documentType).toLowerCase()} has been submitted. '
            'We will notify you once the review is complete.',
      ),
      const SizedBox(height: 16),
      const BbhInfoBanner(
        text: 'You can return to the home screen while we process your document.',
      ),
    ]);
  }

  static Widget _nationalIdReview(
    BbhOnboardingForm form,
    Future<void> Function(TextEditingController, String) pickDate,
  ) {
    return BbhOnboardingSteps.ocrReview(
      form,
      () {},
      pickDate,
      showNationalIdFields: true,
      showPassportFields: false,
    );
  }

  static Widget _passportReview(
    BbhOnboardingForm form,
    Future<void> Function(TextEditingController, String) pickDate,
  ) {
    return BbhOnboardingSteps.ocrReview(
      form,
      () {},
      pickDate,
      showNationalIdFields: false,
      showPassportFields: true,
    );
  }

  static Widget _scroll(List<Widget> children) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 120),
      children: children,
    );
  }
}
