import 'package:baghdad_bullion_house/core/theme/const_colors.dart';
import 'package:baghdad_bullion_house/core/kyc/kyc_document_review_status.dart';
import 'package:baghdad_bullion_house/data/models/home_models/GetHomeFeedResponse.dart';
import 'package:baghdad_bullion_house/l10n/app_localizations.dart';
import 'package:baghdad_bullion_house/presentation/screens/auth_screens/al_taif_bank_kyc/native/bbh_native_onboarding_screen.dart';
import 'package:baghdad_bullion_house/presentation/screens/agreement_screens/user_agreement_screen.dart';
import 'package:baghdad_bullion_house/presentation/screens/kyc_document_update/kyc_document_update_screen.dart';
import 'package:baghdad_bullion_house/presentation/widgets/pop_up_widget.dart';
import 'package:flutter/material.dart';

/// Document status message resolved the same way as the home status panel.
class KycDocumentStatusCopy {
  const KycDocumentStatusCopy({
    required this.status,
    required this.message,
    required this.canRetake,
  });

  final ProfileVerificationStatus? status;
  final String message;
  final bool canRetake;
}

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
    return showProfileVerificationPanel(payload: payload, isDemo: isDemo) &&
        profileStatus(payload) == ProfileVerificationStatus.pending;
  }

  /// Home panel when profile is Reviewing, Pending, or Rejected.
  static bool showProfileVerificationPanel({
    required Payload? payload,
    required bool isDemo,
  }) {
    if (payload == null || isDemo) return false;
    if (!usesProfileVerificationApi(payload)) return false;
    if (isProfileVerified(payload)) return false;
    return profileStatus(payload)?.isAwaitingVerification ?? false;
  }

  static List<KycDocumentType> allDocumentsForStatusPanel(Payload? payload) {
    if (payload == null) return const [];
    return KycDocumentType.values;
  }

  static List<KycProfileStatusItemType> allProfileStatusItemsForPanel(
    Payload? payload,
  ) {
    if (payload == null) return const [];
    return KycProfileStatusItemType.values;
  }

  static bool isAgreementSigned(Payload? payload) =>
      payload?.agreementStatus == true;

  static ProfileVerificationStatus agreementStatus(Payload? payload) {
    return isAgreementSigned(payload)
        ? ProfileVerificationStatus.verified
        : ProfileVerificationStatus.pending;
  }

  static ProfileVerificationStatus? profileStatusItemStatus(
    Payload? payload,
    KycProfileStatusItemType item,
  ) {
    if (payload == null) return null;
    return switch (item) {
      KycProfileStatusItemType.nationalId => documentStatus(
        payload,
        KycDocumentType.nationalId,
      ),
      KycProfileStatusItemType.passport => documentStatus(
        payload,
        KycDocumentType.passport,
      ),
      KycProfileStatusItemType.residency => documentStatus(
        payload,
        KycDocumentType.residency,
      ),
      KycProfileStatusItemType.agreement => agreementStatus(payload),
    };
  }

  static bool canNavigateToProfileStatusItem(
    Payload? payload,
    KycProfileStatusItemType item,
  ) {
    if (payload == null) return false;
    return switch (item) {
      KycProfileStatusItemType.agreement => !isAgreementSigned(payload),
      _ =>
        shouldUseFullKycOnDocumentTap(payload) ||
            canResubmitDocument(
              payload,
              documentTypeForProfileStatusItem(item)!,
            ),
    };
  }

  static KycDocumentType? documentTypeForProfileStatusItem(
    KycProfileStatusItemType item,
  ) {
    return switch (item) {
      KycProfileStatusItemType.nationalId => KycDocumentType.nationalId,
      KycProfileStatusItemType.passport => KycDocumentType.passport,
      KycProfileStatusItemType.residency => KycDocumentType.residency,
      KycProfileStatusItemType.agreement => null,
    };
  }

  static String profileStatusItemLabel(
    KycProfileStatusItemType item,
    AppLocalizations l10n,
  ) => switch (item) {
    KycProfileStatusItemType.nationalId => l10n.kyc_doc_national_id,
    KycProfileStatusItemType.passport => l10n.kyc_doc_passport,
    KycProfileStatusItemType.residency => l10n.kyc_doc_residency,
    KycProfileStatusItemType.agreement => l10n.sig_agreement,
  };

  static Future<void> onProfileStatusItemTap(
    BuildContext context,
    Payload payload,
    KycProfileStatusItemType item, {
    Future<void> Function()? onAgreementSigned,
  }) async {
    if (item == KycProfileStatusItemType.agreement) {
      if (!canNavigateToProfileStatusItem(payload, item)) return;
      final signed = await Navigator.push<bool>(
        context,
        MaterialPageRoute(
          builder: (_) => const UserAgreementScreen(),
        ),
      );
      if (signed == true) {
        await onAgreementSigned?.call();
      }
      return;
    }

    final docType = documentTypeForProfileStatusItem(item);
    if (docType != null) {
      onDocumentStatusCardTap(context, payload, docType);
    }
  }

  static bool shouldUseFullKycOnDocumentTap(Payload? payload) {
    if (payload == null || isProfileVerified(payload)) return false;
    return allDocumentsRejected(payload);
  }

  static String profileWarningMessage(
    Payload? payload,
    AppLocalizations l10n,
  ) {
    if (payload != null && allDocumentsRejected(payload)) {
      return l10n.profile_verification_rejected_full_kyc;
    }
    return switch (profileStatus(payload)) {
      ProfileVerificationStatus.reviewing =>
        l10n.profile_verification_reviewing,
      ProfileVerificationStatus.pending => l10n.profile_verification_pending,
      ProfileVerificationStatus.rejected =>
        l10n.profile_verification_rejected_partial,
      _ => l10n.profile_verification_pending,
    };
  }

  static Color profileWarningBorderColor(Payload? payload) {
    return switch (profileStatus(payload)) {
      ProfileVerificationStatus.rejected => const Color(0xffE04c4E),
      _ => AppColors.primaryGold500,
    };
  }

  static bool showProfileWarningAction(Payload? payload) {
    return shouldUseFullKycOnDocumentTap(payload);
  }

  static void onDocumentStatusCardTap(
    BuildContext context,
    Payload payload,
    KycDocumentType type,
  ) {
    if (shouldUseFullKycOnDocumentTap(payload)) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const BbhNativeOnboardingScreen(),
        ),
      );
      return;
    }
    if (canNavigateToDocument(payload, type)) {
      openDocumentUpdate(context, type, payload);
    }
  }

  static void openProfileWarningAction(
    BuildContext context,
    Payload payload,
  ) {
    if (showProfileWarningAction(payload)) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const BbhNativeOnboardingScreen(),
        ),
      );
    }
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
      return profileStatus(payload)?.isAwaitingVerification ?? false;
    }
    for (final type in KycDocumentType.values) {
      if (documentStatus(payload, type) != null) return true;
    }
    return false;
  }

  static ProfileVerificationStatus? documentStatus(
    Payload? payload,
    KycDocumentType type,
  ) {
    if (payload == null) return null;
    return switch (type) {
      KycDocumentType.nationalId => payload.nationalIdDetailsStatus,
      KycDocumentType.passport => payload.passportDetailsStatus,
      KycDocumentType.residency => payload.residencyDetailsStatus,
    };
  }

  static bool isDocumentVerified(ProfileVerificationStatus? status) =>
      status?.isApprovedOrVerified ?? false;

  static bool canNavigateToDocument(
    Payload? payload,
    KycDocumentType type,
  ) {
    return canResubmitDocument(payload, type);
  }

  /// True when the user may open the single-document resubmit flow.
  static bool canResubmitDocument(
    Payload? payload,
    KycDocumentType type,
  ) {
    if (payload == null) return false;
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

  /// Documents still under review while profile verification is pending.
  static List<KycDocumentType> documentsPendingReview(Payload? payload) {
    if (payload == null) return const [];
    if (profileStatus(payload) != ProfileVerificationStatus.pending) {
      return const [];
    }
    final out = <KycDocumentType>[];
    for (final type in KycDocumentType.values) {
      final status = documentStatus(payload, type);
      if (status == ProfileVerificationStatus.pending || status == null) {
        out.add(type);
      }
    }
    if (out.isEmpty) {
      return KycDocumentType.values.toList();
    }
    return out;
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

  /// Rejected documents for full native onboarding retry.
  static List<KycDocumentType> documentsForFullKycRetry(Payload? payload) {
    final rejected = documentsNeedingUpdate(payload);
    if (rejected.isNotEmpty) return rejected;
    if (requiresFullKyc(payload)) {
      return KycDocumentType.values.toList();
    }
    return const [];
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
    for (final type in KycDocumentType.values) {
      if (!isDocumentVerified(documentStatus(payload, type))) {
        out.add(type);
      }
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
      if (shouldUseFullKycOnDocumentTap(payload)) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const BbhNativeOnboardingScreen(),
          ),
        );
        return;
      }
      final status = profileStatus(payload);
      if (status == ProfileVerificationStatus.pending ||
          status == ProfileVerificationStatus.reviewing) {
        return;
      }
      if (status == ProfileVerificationStatus.rejected) {
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
  ) => switch (type) {
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
      if (shouldUseFullKycOnDocumentTap(payload)) {
        return KycBlockedActionCopy(
          heading: l10n.kyc_verification_required,
          subtitle: l10n.profile_verification_rejected_full_kyc,
          noButtonTitle: l10n.later,
          yesButtonTitle: l10n.proceed,
          navigateOnConfirm: true,
        );
      }
      final status = profileStatus(payload);
      if (status == ProfileVerificationStatus.pending ||
          status == ProfileVerificationStatus.reviewing) {
        return KycBlockedActionCopy(
          heading: l10n.kyc_verification_required,
          subtitle: status == ProfileVerificationStatus.reviewing
              ? l10n.profile_verification_reviewing
              : l10n.profile_verification_pending,
          yesButtonTitle: l10n.close,
          navigateOnConfirm: false,
        );
      }
      if (status == ProfileVerificationStatus.rejected) {
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
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => KycDocumentUpdateScreen(documentType: type),
      ),
    );
  }

  /// Same status + user-facing message logic used on home document warnings.
  static KycDocumentStatusCopy documentStatusCopy(
    Payload? payload,
    KycDocumentType type,
    AppLocalizations l10n, {
    bool showRetakeHint = false,
  }) {
    final docLabel = documentLabel(type, l10n);
    final status = documentStatus(payload, type);
    final canRetake = canResubmitDocument(payload, type);

    final message = switch (status) {
      ProfileVerificationStatus.rejected => l10n.kyc_document_rejected(
        docLabel,
      ),
      ProfileVerificationStatus.verified ||
      ProfileVerificationStatus.approved => l10n.kyc_document_verified(
        docLabel,
      ),
      ProfileVerificationStatus.reviewing => l10n.kyc_document_reviewing(
        docLabel,
      ),
      ProfileVerificationStatus.pending =>
        showRetakeHint
            ? l10n.kyc_document_pending(docLabel)
            : l10n.kyc_document_pending_review(docLabel),
      null =>
        showRetakeHint
            ? l10n.kyc_document_pending(docLabel)
            : l10n.kyc_document_pending_review(docLabel),
    };

    return KycDocumentStatusCopy(
      status: status,
      message: message,
      canRetake: canRetake,
    );
  }

  static KycDocumentReviewStatus? reviewStatusFor(
    KycDocumentType type,
    Payload payload,
  ) {
    final docStatus = documentStatus(payload, type);
    if (docStatus == null) return null;
    return switch (docStatus) {
      ProfileVerificationStatus.rejected => KycDocumentReviewStatus.rejected,
      ProfileVerificationStatus.pending => KycDocumentReviewStatus.pending,
      ProfileVerificationStatus.reviewing => KycDocumentReviewStatus.pending,
      ProfileVerificationStatus.verified ||
      ProfileVerificationStatus.approved => KycDocumentReviewStatus.approved,
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
