import 'package:baghdad_bullion_house/services/ipass_kyc/ipass_onboarding_mapper.dart';

/// Overall profile review status from the home feed API.
enum ProfileVerificationStatus {
  verified,
  approved,
  reviewing,
  pending,
  rejected
  ;

  static ProfileVerificationStatus? fromApi(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    switch (value.trim().toLowerCase()) {
      case 'verified':
        return ProfileVerificationStatus.verified;
      case 'approved':
      case 'accepted':
        return ProfileVerificationStatus.approved;
      case 'reviewing':
        return ProfileVerificationStatus.reviewing;
      case 'pending':
        return ProfileVerificationStatus.pending;
      case 'rejected':
        return ProfileVerificationStatus.rejected;
      default:
        return null;
    }
  }

  bool get isApprovedOrVerified =>
      this == ProfileVerificationStatus.verified ||
      this == ProfileVerificationStatus.approved;

  bool get isVerified => isApprovedOrVerified;

  bool get isReviewing => this == ProfileVerificationStatus.reviewing;

  bool get isAwaitingVerification =>
      this == ProfileVerificationStatus.reviewing ||
      this == ProfileVerificationStatus.pending ||
      this == ProfileVerificationStatus.rejected;

  /// Parses a home-feed verification status field (camelCase or PascalCase key).
  static ProfileVerificationStatus? fromJsonField(
    dynamic json,
    String camelKey,
    String pascalKey,
  ) {
    final raw = json[camelKey] ?? json[pascalKey];
    if (raw == null) return null;
    return fromApi(raw.toString()) ?? ProfileVerificationStatus.pending;
  }

  /// Parses API values that may be a bool (legacy) or status string.
  static ProfileVerificationStatus? parseFlexible(dynamic raw) {
    if (raw == null) return null;
    if (raw is bool) {
      return raw
          ? ProfileVerificationStatus.verified
          : ProfileVerificationStatus.rejected;
    }
    return fromApi(raw.toString());
  }

  /// Resolves a document status from `is*DetailsVerified` or `*VerificationStatus`.
  ///
  /// The home API may send both; `is*DetailsVerified` is preferred because it is
  /// the field updated during profile review.
  static ProfileVerificationStatus? resolveDocumentStatus(
    dynamic json, {
    required String verificationCamel,
    required String verificationPascal,
    required String detailsCamel,
    required String detailsPascal,
  }) {
    final fromDetails = parseFlexible(
      json[detailsCamel] ?? json[detailsPascal],
    );
    if (fromDetails != null) return fromDetails;
    return fromJsonField(json, verificationCamel, verificationPascal);
  }

  String get apiLabel => switch (this) {
    ProfileVerificationStatus.verified => 'Verified',
    ProfileVerificationStatus.approved => 'Approved',
    ProfileVerificationStatus.reviewing => 'Reviewing',
    ProfileVerificationStatus.pending => 'Pending',
    ProfileVerificationStatus.rejected => 'Rejected',
  };
}

/// Admin review status for an individual KYC document from the home feed API.
enum KycDocumentReviewStatus {
  pending,
  approved,
  rejected
  ;

  static KycDocumentReviewStatus? fromApi(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    switch (value.trim().toLowerCase()) {
      case 'pending':
        return KycDocumentReviewStatus.pending;
      case 'reviewing':
        return KycDocumentReviewStatus.pending;
      case 'verified':
      case 'approved':
      case 'accepted':
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
  residency
  ;

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

/// Rows shown in the home profile verification status panel.
enum KycProfileStatusItemType { nationalId, passport, residency, agreement }
