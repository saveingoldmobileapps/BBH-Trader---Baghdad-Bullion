import 'package:baghdad_bullion_house/core/kyc/kyc_document_review_status.dart';
import 'package:baghdad_bullion_house/data/models/home_models/GetHomeFeedResponse.dart';
import 'package:baghdad_bullion_house/l10n/app_localizations.dart';
import 'package:baghdad_bullion_house/presentation/screens/auth_screens/al_taif_bank_kyc/native/bbh_native_onboarding_screen.dart';
import 'package:baghdad_bullion_house/presentation/screens/kyc_document_update/kyc_document_update_screen.dart';
import 'package:baghdad_bullion_house/presentation/widgets/pop_up_widget.dart';
import 'package:flutter/material.dart';

/// Copy shown when a gated action is blocked by KYC / profile verification.
class KycBlockedActionCopy {
  const KycBlockedActionCopy({
    required this.heading,
    required this.subtitle,
    required this.yesButtonTitle,
    this.noButtonTitle,
    this.navigateOnConfirm = false,
  });

  final String heading;
  final String subtitle;
  final String? noButtonTitle;
  final String yesButtonTitle;
  final bool navigateOnConfirm;
}

/// Resolves home-feed KYC state into navigation targets.
class KycHomeNavigation {
  KycHomeNavigation._();

  static bool usesProfileVerificationApi(Payload? payload) =>
      payload?.profileVerificationStatus != null;

  static ProfileVerificationStatus? profileStatus(Payload? payload) =>
      payload?.profileVerificationStatus;

  /// Whether the user may access features previously gated by
  /// [Payload.isBasicUserVerified] and [Payload.isUserKYCVerified].
  static bool isProfileVerified(Payload? payload) {
    if (payload == null) return false;
    if (usesProfileVerificationApi(payload)) {
      return profileStatus(payload)?.isApprovedOrVerified ?? false;
    }
    // Legacy fallback only when API does not send profileVerificationStatus.
    return payload.isBasicUserVerified == true &&
        payload.isUserKYCVerified == true;
  }

  /// Whether trading/funding actions should be blocked for this payload.
  static bool blocksVerifiedActions(Payload? payload) {
    return !isProfileVerified(payload);
  }

  static bool showProfilePendingWarning({
    required Payload? payload,
    required bool isDemo,
  }) {
    if (payload == null || isDemo) return false;
    if (!usesProfileVerificationApi(payload)) return false;
    return profileStatus(payload) == ProfileVerificationStatus.pending;
  }

  static bool hideProfileVerificationWarnings({
    required Payload? payload,
    required bool isDemo,
  }) {
    if (payload == null || isDemo) return false;
    if (!usesProfileVerificationApi(payload)) return false;
    return profileStatus(payload)?.isVerified ?? false;
  }

  static bool hasPerDocumentReviews(Payload? payload) {
    if (payload == null) return false;
    if (usesProfileVerificationApi(payload)) {
      return profileStatus(payload) == ProfileVerificationStatus.rejected;
    }
    return payload.nationalIdReview != null ||
        payload.passportReview != null ||
        payload.residencyReview != null;
  }

  static ProfileVerificationStatus? documentStatus(
    Payload? payload,
    KycDocumentType type,
  ) {
    if (payload == null) return null;
    return switch (type) {
      KycDocumentType.nationalId => payload.nationalIdVerificationStatus,
      KycDocumentType.passport => payload.passportVerificationStatus,
      KycDocumentType.residency => payload.residencyVerificationStatus,
    };
  }

  static bool isDocumentVerified(ProfileVerificationStatus? status) =>
      status?.isApprovedOrVerified ?? false;

  static bool canNavigateToDocument(
    Payload? payload,
    KycDocumentType type,
  ) {
    return documentStatus(payload, type) == ProfileVerificationStatus.rejected;
  }

  static List<KycDocumentType> unverifiedDocuments(Payload? payload) {
    if (payload == null) return const [];
    final out = <KycDocumentType>[];
    for (final type in KycDocumentType.values) {
      if (!isDocumentVerified(documentStatus(payload, type))) {
        out.add(type);
      }
    }
    return out;
  }

  /// All three documents explicitly rejected.
  static bool allDocumentsRejected(Payload? payload) {
    if (payload == null) return false;
    for (final type in KycDocumentType.values) {
      if (documentStatus(payload, type) != ProfileVerificationStatus.rejected) {
        return false;
      }
    }
    return true;
  }

  /// Profile rejected and user must repeat full native onboarding (all 3 docs rejected).
  static bool requiresFullKyc(Payload? payload) {
    if (payload == null || !usesProfileVerificationApi(payload)) return false;
    if (profileStatus(payload) != ProfileVerificationStatus.rejected) {
      return false;
    }
    if (allDocumentsRejected(payload)) return true;

    // Partial rejection — show per-document banners, not full KYC.
    for (final type in KycDocumentType.values) {
      if (documentStatus(payload, type) == ProfileVerificationStatus.rejected) {
        return false;
      }
    }

    // Legacy: all three unverified with none pending (e.g. bool false flags).
    var anyPending = false;
    var allNotApproved = true;
    for (final type in KycDocumentType.values) {
      final status = documentStatus(payload, type);
      if (status == ProfileVerificationStatus.pending) {
        anyPending = true;
      }
      if (isDocumentVerified(status)) {
        allNotApproved = false;
      }
    }
    if (anyPending) return false;
    return allNotApproved;
  }

  static bool showProfileRejectedFullKycWarning({
    required Payload? payload,
    required bool isDemo,
  }) {
    if (payload == null || isDemo) return false;
    if (!usesProfileVerificationApi(payload)) return false;
    return requiresFullKyc(payload);
  }

  /// Documents the user must update after a rejected profile review.
  static List<KycDocumentType> documentsNeedingUpdate(Payload? payload) {
    if (payload == null) return const [];
    final out = <KycDocumentType>[];
    for (final type in KycDocumentType.values) {
      if (documentStatus(payload, type) == ProfileVerificationStatus.rejected) {
        out.add(type);
      }
    }
    return out;
  }

  /// Home banners — rejected docs only. When profile is pending, only the profile banner is shown.
  static List<KycDocumentType> documentsForHomeWarnings(Payload? payload) {
    if (payload == null) return const [];

    if (usesProfileVerificationApi(payload)) {
      final profile = profileStatus(payload);
      if (profile == ProfileVerificationStatus.pending) {
        return const [];
      }
      if (profile == ProfileVerificationStatus.rejected) {
        if (requiresFullKyc(payload)) return const [];
        return documentsNeedingUpdate(payload);
      }
      return const [];
    }

    return documentsNeedingActionLegacy(payload);
  }

  static List<KycDocumentType> documentsNeedingActionLegacy(Payload? payload) {
    if (payload == null) return const [];
    final out = <KycDocumentType>[];
    if (payload.nationalIdReview?.needsAction == true) {
      out.add(KycDocumentType.nationalId);
    }
    if (payload.passportReview?.needsAction == true) {
      out.add(KycDocumentType.passport);
    }
    if (payload.residencyReview?.needsAction == true) {
      out.add(KycDocumentType.residency);
    }
    return out;
  }

  static List<KycDocumentType> documentsNeedingAction(Payload? payload) {
    return documentsForHomeWarnings(payload);
  }

  static bool showLegacyKycWarning({
    required Payload? payload,
    required bool isDemo,
  }) {
    if (payload == null || isDemo) return false;
    if (hideProfileVerificationWarnings(payload: payload, isDemo: isDemo)) {
      return false;
    }
    if (usesProfileVerificationApi(payload)) {
      return false;
    }
    if (hasPerDocumentReviews(payload)) {
      return documentsNeedingAction(payload).isNotEmpty ||
          !isProfileVerified(payload);
    }
    return !isProfileVerified(payload);
  }

  static bool showCompleteKycWarning({
    required Payload? payload,
    required bool isDemo,
  }) {
    if (payload == null || isDemo) return false;
    if (hideProfileVerificationWarnings(payload: payload, isDemo: isDemo)) {
      return false;
    }
    if (usesProfileVerificationApi(payload)) {
      return showProfileRejectedFullKycWarning(
        payload: payload,
        isDemo: isDemo,
      );
    }
    if (isProfileVerified(payload)) return false;
    return documentsNeedingAction(payload).isEmpty;
  }

  static bool showLegacyDocumentsWarning({
    required Payload? payload,
    required bool isDemo,
  }) {
    if (payload == null || isDemo) return false;
    if (hideProfileVerificationWarnings(payload: payload, isDemo: isDemo)) {
      return false;
    }
    if (usesProfileVerificationApi(payload)) return false;
    if (isProfileVerified(payload)) return false;
    return !hasPerDocumentReviews(payload);
  }

  static void openKycFlow(BuildContext context, {Payload? payload}) {
    if (payload == null) return;

    if (usesProfileVerificationApi(payload)) {
      final status = profileStatus(payload);
      if (status == ProfileVerificationStatus.pending) {
        return;
      }
      if (status == ProfileVerificationStatus.rejected) {
        if (requiresFullKyc(payload)) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const BbhNativeOnboardingScreen(),
            ),
          );
          return;
        }
        final docs = documentsNeedingUpdate(payload);
        if (docs.isNotEmpty) {
          openDocumentUpdate(context, docs.first, payload);
        }
        return;
      }
      if (!isProfileVerified(payload)) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const BbhNativeOnboardingScreen(),
          ),
        );
      }
      return;
    }

    if (!isProfileVerified(payload)) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const BbhNativeOnboardingScreen(),
        ),
      );
      return;
    }

    final docs = documentsNeedingAction(payload);
    if (docs.isNotEmpty) {
      openDocumentUpdate(context, docs.first, payload);
    }
  }

  static String documentLabel(
    KycDocumentType type,
    AppLocalizations l10n,
  ) =>
      switch (type) {
        KycDocumentType.nationalId => l10n.kyc_doc_national_id,
        KycDocumentType.passport => l10n.kyc_doc_passport,
        KycDocumentType.residency => l10n.kyc_doc_residency,
      };

  static KycBlockedActionCopy blockedActionCopy(
    Payload? payload,
    AppLocalizations l10n,
  ) {
    if (payload == null) {
      return KycBlockedActionCopy(
        heading: l10n.kyc_verification_required,
        subtitle: l10n.kyc_verification_message,
        noButtonTitle: l10n.later,
        yesButtonTitle: l10n.proceed,
        navigateOnConfirm: true,
      );
    }

    if (usesProfileVerificationApi(payload)) {
      final status = profileStatus(payload);
      if (status == ProfileVerificationStatus.pending) {
        return KycBlockedActionCopy(
          heading: l10n.kyc_verification_required,
          subtitle: l10n.profile_verification_pending,
          yesButtonTitle: l10n.close,
          navigateOnConfirm: false,
        );
      }
      if (status == ProfileVerificationStatus.rejected) {
        if (requiresFullKyc(payload)) {
          return KycBlockedActionCopy(
            heading: l10n.kyc_verification_required,
            subtitle: l10n.profile_verification_rejected_full_kyc,
            noButtonTitle: l10n.later,
            yesButtonTitle: l10n.proceed,
            navigateOnConfirm: true,
          );
        }
        final docs = documentsNeedingUpdate(payload);
        if (docs.isNotEmpty) {
          final doc = docs.first;
          final label = documentLabel(doc, l10n);
          final notVerified = useNotVerifiedDocumentMessage(payload, doc);
          final subtitle = notVerified
              ? l10n.kyc_document_not_verified(label)
              : l10n.kyc_document_rejected(label);
          return KycBlockedActionCopy(
            heading: l10n.kyc_verification_required,
            subtitle: subtitle,
            noButtonTitle: l10n.later,
            yesButtonTitle: l10n.kyc_retake_document,
            navigateOnConfirm: true,
          );
        }
      }
    }

    return KycBlockedActionCopy(
      heading: l10n.kyc_verification_required,
      subtitle: l10n.kyc_verification_message,
      noButtonTitle: l10n.later,
      yesButtonTitle: l10n.proceed,
      navigateOnConfirm: true,
    );
  }

  static Future<void> showBlockedActionPopup(
    BuildContext context, {
    Payload? payload,
  }) async {
    final l10n = AppLocalizations.of(context)!;
    final copy = blockedActionCopy(payload, l10n);
    await genericPopUpWidget(
      isLoadingState: false,
      context: context,
      heading: copy.heading,
      subtitle: copy.subtitle,
      noButtonTitle: copy.noButtonTitle,
      yesButtonTitle: copy.yesButtonTitle,
      onNoPress: () => Navigator.pop(context),
      onYesPress: () async {
        Navigator.pop(context);
        if (copy.navigateOnConfirm) {
          openKycFlow(context, payload: payload);
        }
      },
    );
  }

  static void openDocumentUpdate(
    BuildContext context,
    KycDocumentType type,
    Payload payload,
  ) {
    final status = reviewStatusFor(type, payload);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => KycDocumentUpdateScreen(
          documentType: type,
          reviewStatus: status ?? KycDocumentReviewStatus.pending,
        ),
      ),
    );
  }

  static KycDocumentReviewStatus? reviewStatusFor(
    KycDocumentType type,
    Payload payload,
  ) {
    final docStatus = documentStatus(payload, type);
    if (usesProfileVerificationApi(payload) && docStatus != null) {
      return switch (docStatus) {
        ProfileVerificationStatus.rejected => KycDocumentReviewStatus.rejected,
        ProfileVerificationStatus.pending => KycDocumentReviewStatus.pending,
        ProfileVerificationStatus.verified ||
        ProfileVerificationStatus.approved =>
          KycDocumentReviewStatus.approved,
      };
    }

    return switch (type) {
      KycDocumentType.nationalId => payload.nationalIdReview,
      KycDocumentType.passport => payload.passportReview,
      KycDocumentType.residency => payload.residencyReview,
    };
  }

  static bool useNotVerifiedDocumentMessage(
    Payload? payload,
    KycDocumentType type,
  ) {
    if (payload == null) return false;
    if (!usesProfileVerificationApi(payload)) return false;
    if (profileStatus(payload) != ProfileVerificationStatus.rejected) {
      return false;
    }
    final docStatus = documentStatus(payload, type);
    return docStatus != ProfileVerificationStatus.rejected;
  }
}
