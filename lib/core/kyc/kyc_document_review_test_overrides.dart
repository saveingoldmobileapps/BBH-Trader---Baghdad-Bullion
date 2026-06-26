import 'package:baghdad_bullion_house/core/kyc/kyc_document_review_status.dart';
import 'package:baghdad_bullion_house/data/models/home_models/GetHomeFeedResponse.dart';

/// Temporary overrides for testing per-document KYC review UI.
/// Set [enabled] to false when the home API returns real review statuses.
class KycDocumentReviewTestOverrides {
  KycDocumentReviewTestOverrides._();

  static const enabled = true;
  static const forcePassportRejected = true;

  static GetHomeFeedResponse apply(GetHomeFeedResponse response) {
    if (!enabled) return response;

    final payload = response.payload;
    if (payload == null) return response;

    return response.copyWith(
      payload: payload.copyWith(
        isUserKYCVerified: true,
        passportReview: forcePassportRejected
            ? KycDocumentReviewStatus.rejected
            : payload.passportReview,
        nationalIdReview:
            payload.nationalIdReview ?? KycDocumentReviewStatus.approved,
        residencyReview:
            payload.residencyReview ?? KycDocumentReviewStatus.approved,
      ),
    );
  }
}
