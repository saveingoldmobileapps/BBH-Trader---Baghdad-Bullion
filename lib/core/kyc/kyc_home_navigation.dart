import 'package:baghdad_bullion_house/core/kyc/kyc_document_review_status.dart';
import 'package:baghdad_bullion_house/data/models/home_models/GetHomeFeedResponse.dart';
import 'package:baghdad_bullion_house/presentation/screens/auth_screens/al_taif_bank_kyc/native/bbh_native_onboarding_screen.dart';
import 'package:baghdad_bullion_house/presentation/screens/kyc_document_update/kyc_document_update_screen.dart';
import 'package:flutter/material.dart';

/// Resolves home-feed KYC state into navigation targets.
class KycHomeNavigation {
  KycHomeNavigation._();

  static bool hasPerDocumentReviews(Payload? payload) {
    if (payload == null) return false;
    return payload.nationalIdReview != null ||
        payload.passportReview != null ||
        payload.residencyReview != null;
  }

  static List<KycDocumentType> documentsNeedingAction(Payload? payload) {
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

  static bool showLegacyKycWarning({
    required Payload? payload,
    required bool isDemo,
  }) {
    if (payload == null || isDemo) return false;
    if (hasPerDocumentReviews(payload)) {
      return documentsNeedingAction(payload).isNotEmpty ||
          payload.isUserKYCVerified != true;
    }
    return payload.isBasicUserVerified != true ||
        payload.isUserKYCVerified != true;
  }

  static void openKycFlow(BuildContext context, {Payload? payload}) {
    if (payload == null) return;

    if (payload.isUserKYCVerified != true) {
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
    return switch (type) {
      KycDocumentType.nationalId => payload.nationalIdReview,
      KycDocumentType.passport => payload.passportReview,
      KycDocumentType.residency => payload.residencyReview,
    };
  }
}
