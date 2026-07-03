import 'package:baghdad_bullion_house/services/ipass_kyc/ipass_onboarding_mapper.dart';

/// Overall profile review status from the home feed API.
enum ProfileVerificationStatus {
  verified,
  pending,
  rejected;

  static ProfileVerificationStatus? fromApi(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    switch (value.trim().toLowerCase()) {
      case 'verified':
        return ProfileVerificationStatus.verified;
      case 'pending':
        return ProfileVerificationStatus.pending;
      case 'rejected':
        return ProfileVerificationStatus.rejected;
      default:
        return null;
    }
  }

  bool get isVerified => this == ProfileVerificationStatus.verified;
}

/// Admin review status for an individual KYC document from the home feed API.
enum KycDocumentReviewStatus {
  pending,
  approved,
  rejected;

  static KycDocumentReviewStatus? fromApi(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    switch (value.trim().toLowerCase()) {
      case 'pending':
        return KycDocumentReviewStatus.pending;
      case 'verified':
      case 'approved':
        return KycDocumentReviewStatus.approved;
      case 'rejected':
        return KycDocumentReviewStatus.rejected;
      default:
        return null;
    }
  }

  bool get needsAction => this != KycDocumentReviewStatus.approved;

  bool get isRejected => this == KycDocumentReviewStatus.rejected;
}

/// Which document the user is updating after home-feed review.
enum KycDocumentType {
  nationalId,
  passport,
  residency;

  IpassScanTarget get scanTarget => switch (this) {
        KycDocumentType.nationalId => IpassScanTarget.nationalId,
        KycDocumentType.passport => IpassScanTarget.passport,
        KycDocumentType.residency => IpassScanTarget.residence,
      };

  String get apiKey => switch (this) {
        KycDocumentType.nationalId => 'national_id',
        KycDocumentType.passport => 'passport',
        KycDocumentType.residency => 'residence',
      };
}
