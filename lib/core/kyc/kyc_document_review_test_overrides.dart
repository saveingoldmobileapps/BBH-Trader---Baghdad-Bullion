import 'package:baghdad_bullion_house/core/kyc/kyc_document_review_status.dart';

import 'package:baghdad_bullion_house/data/models/home_models/GetHomeFeedResponse.dart';



/// Temporary overrides for testing profile verification UI on home.

/// Set [enabled] to false when using live home feed data.

class KycDocumentReviewTestOverrides {

  KycDocumentReviewTestOverrides._();



  static const enabled = false;



  static GetHomeFeedResponse apply(GetHomeFeedResponse response) {

    if (!enabled) return response;



    final payload = response.payload;

    if (payload == null) return response;



    return response.copyWith(

      payload: payload.copyWith(

        isUserKYCVerified: true,

        profileVerificationStatus: ProfileVerificationStatus.rejected,

        nationalIdVerificationStatus: ProfileVerificationStatus.verified,

        passportVerificationStatus: ProfileVerificationStatus.verified,

        residencyVerificationStatus: ProfileVerificationStatus.rejected,

      ),

    );

  }

}


