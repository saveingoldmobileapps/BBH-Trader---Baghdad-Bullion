import 'package:baghdad_bullion_house/core/kyc/kyc_document_review_status.dart';
import 'package:baghdad_bullion_house/data/models/home_models/GetHomeFeedResponse.dart';
import 'package:baghdad_bullion_house/presentation/screens/auth_screens/al_taif_bank_kyc/native/bbh_native_onboarding_screen.dart';
import 'package:baghdad_bullion_house/presentation/screens/kyc_document_update/kyc_document_update_screen.dart';
import 'package:flutter/material.dart';

/// Resolves home-feed KYC state into navigation targets.
class KycHomeNavigation {
  KycHomeNavigation._();

  static bool usesProfileVerificationApi(Payload? payload) =>
      payload?.profileVerificationStatus != null;

  static ProfileVerificationStatus? profileStatus(Payload? payload) =>
      payload?.profileVerificationStatus;

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

  static List<KycDocumentType> unverifiedDocuments(Payload? payload) {
    if (payload == null) return const [];
    final out = <KycDocumentType>[];
    if (payload.isNationalIdDetailsVerified != true) {
      out.add(KycDocumentType.nationalId);
    }
    if (payload.isPassportDetailsVerified != true) {
      out.add(KycDocumentType.passport);
    }
    if (payload.isResidencyDetailsVerified != true) {
      out.add(KycDocumentType.residency);
    }
    return out;
  }

  /// All three document flags false — user must repeat full native onboarding.
  static bool requiresFullKyc(Payload? payload) {
    if (payload == null || !usesProfileVerificationApi(payload)) return false;
    if (profileStatus(payload) != ProfileVerificationStatus.rejected) {
      return false;
    }
    return payload.isNationalIdDetailsVerified != true &&
        payload.isPassportDetailsVerified != true &&
        payload.isResidencyDetailsVerified != true;
  }

  static List<KycDocumentType> documentsNeedingAction(Payload? payload) {
    if (payload == null) return const [];

    if (usesProfileVerificationApi(payload)) {
      if (profileStatus(payload) != ProfileVerificationStatus.rejected) {
        return const [];
      }
      if (requiresFullKyc(payload)) return const [];
      return unverifiedDocuments(payload);
    }

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
          payload.isUserKYCVerified != true;
    }
    return payload.isBasicUserVerified != true ||
        payload.isUserKYCVerified != true;
  }

  static bool showCompleteKycWarning({
    required Payload? payload,
    required bool isDemo,
    required bool isUserKycVerified,
  }) {
    if (payload == null || isDemo) return false;
    if (hideProfileVerificationWarnings(payload: payload, isDemo: isDemo)) {
      return false;
    }
    if (usesProfileVerificationApi(payload)) {
      return requiresFullKyc(payload);
    }
    if (isUserKycVerified) return false;
    return documentsNeedingAction(payload).isEmpty;
  }

  static bool showLegacyDocumentsWarning({
    required Payload? payload,
    required bool isDemo,
    required bool isBasicUserVerified,
    required bool isUserKycVerified,
  }) {
    if (payload == null || isDemo) return false;
    if (hideProfileVerificationWarnings(payload: payload, isDemo: isDemo)) {
      return false;
    }
    if (usesProfileVerificationApi(payload)) return false;
    if (isBasicUserVerified && isUserKycVerified) return false;
    return !hasPerDocumentReviews(payload);
  }

  static void openKycFlow(BuildContext context, {Payload? payload}) {
    if (payload == null) return;

    if (requiresFullKyc(payload) || payload.isUserKYCVerified != true) {
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
      return;
    }
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
    if (usesProfileVerificationApi(payload) &&
        profileStatus(payload) == ProfileVerificationStatus.rejected) {
      return KycDocumentReviewStatus.rejected;
    }

    return switch (type) {
      KycDocumentType.nationalId => payload.nationalIdReview,
      KycDocumentType.passport => payload.passportReview,
      KycDocumentType.residency => payload.residencyReview,
    };
  }

  static bool useNotVerifiedDocumentMessage(Payload? payload) {
    if (payload == null) return false;
    return usesProfileVerificationApi(payload) &&
        profileStatus(payload) == ProfileVerificationStatus.rejected;
  }
}
