import 'package:baghdad_bullion_house/core/kyc/kyc_document_review_status.dart';
import 'package:baghdad_bullion_house/data/models/ipass_model/ipass_formdata_result_response.dart';
import 'package:baghdad_bullion_house/presentation/screens/auth_screens/al_taif_bank_kyc/native/bbh_onboarding_form.dart';
import 'package:baghdad_bullion_house/services/bbh_onboarding/bbh_onboarding_submission_builder.dart';
import 'package:baghdad_bullion_house/services/ipass_kyc/ipass_kyc_service.dart';
import 'package:baghdad_bullion_house/services/ipass_kyc/ipass_onboarding_mapper.dart';

/// Builds `auth/update/iPass/{lang}` body for a single rejected document.
class KycDocumentUpdatePayloadBuilder {
  KycDocumentUpdatePayloadBuilder._();

  static Map<String, dynamic> build({
    required KycDocumentType documentType,
    required BbhOnboardingForm form,
    required Map<String, String> imageUrlsByKey,
    IpassKycResult? nationalIdOrPassportScan,
    IpassFormDataResultResponse? residenceFront,
    IpassFormDataResultResponse? residenceBack,
  }) {
    final full = BbhOnboardingSubmissionBuilder.build(
      form: form,
      kycReference:
          'BBH-DOC-${documentType.apiKey}-${DateTime.now().millisecondsSinceEpoch}',
      submittedAt: DateTime.now(),
    );

    switch (documentType) {
      case KycDocumentType.nationalId:
        final details = Map<String, dynamic>.from(
          full['nationalIdDetails'] as Map<String, dynamic>,
        );
        details['documents'] = _documentsForScan(
          scanTarget: IpassScanTarget.nationalId,
          scanResult: nationalIdOrPassportScan,
          imageUrlsByKey: imageUrlsByKey,
        );
        return {
          'isNationalIdDetailsVerified': true,
          'nationalIdDetails': details,
        };

      case KycDocumentType.passport:
        final details = Map<String, dynamic>.from(
          full['passportDetails'] as Map<String, dynamic>,
        );
        details['documents'] = _documentsForScan(
          scanTarget: IpassScanTarget.passport,
          scanResult: nationalIdOrPassportScan,
          imageUrlsByKey: imageUrlsByKey,
        );
        return {
          'isPassportDetailsVerified': true,
          'passportDetails': details,
        };

      case KycDocumentType.residency:
        final details = Map<String, dynamic>.from(
          full['residencyDetails'] as Map<String, dynamic>,
        );
        details['documents'] = _documentsForResidence(
          imageUrlsByKey: imageUrlsByKey,
          front: residenceFront,
          back: residenceBack,
        );
        return {
          'isResidencyDetailsVerified': true,
          'residencyDetails': details,
        };
    }
  }

  static List<Map<String, dynamic>> _documentsForScan({
    required IpassScanTarget scanTarget,
    required IpassKycResult? scanResult,
    required Map<String, String> imageUrlsByKey,
  }) {
    if (scanResult == null) return const [];

    final scanKey = IpassOnboardingMapper.scanTargetKeys[scanTarget] ?? '';
    final rawImages = IpassOnboardingMapper.extractAllImagesFromScanResult(
      scanResult,
      scanTarget: scanKey,
    );
    final resolved = IpassOnboardingMapper.resolveSubmissionImages(
      rawImages,
      imageUrlsByKey: imageUrlsByKey,
      preferImageUrls: true,
      omitUnuploaded: true,
    );

    final overAllStatus = _scanOverAllStatus(scanResult.data);

    return resolved
        .where((doc) => _isHostedUrl(doc['base64']?.toString()))
        .map(
          (doc) => {
            'scanTarget': doc['scanTarget'] ?? scanKey,
            'documentType': doc['documentType'] ?? _defaultDocumentType(scanTarget),
            'overAllStatus': overAllStatus,
            'category': doc['category'] ?? '',
            'imageType': doc['imageType'] ?? '',
            'mimeType': doc['mimeType'] ?? 'image/jpeg',
            'sizeChars': (doc['base64']?.toString() ?? '').length,
            'base64': doc['base64'],
          },
        )
        .toList();
  }

  static List<Map<String, dynamic>> _documentsForResidence({
    required Map<String, String> imageUrlsByKey,
    IpassFormDataResultResponse? front,
    IpassFormDataResultResponse? back,
  }) {
    final bundle = IpassOnboardingMapper.buildResidenceSubmissionPayload(
      front: front,
      back: back,
      imageUrlsByKey: imageUrlsByKey,
      preferImageUrls: true,
      omitUnuploaded: true,
    );
    final images = bundle['ipass_residence_images'];
    if (images is! List) return const [];

    return images
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .where((doc) => _isHostedUrl(doc['base64']?.toString()))
        .map(
          (doc) => {
            'scanTarget': doc['scanTarget'] ?? 'residence',
            'documentType': doc['documentType'] ?? 'Residence Form',
            'overAllStatus': 'PENDING',
            if (doc['side'] != null) 'side': doc['side'],
            'category': doc['category'] ?? 'formdata',
            'imageType': doc['imageType'] ?? '',
            'mimeType': doc['mimeType'] ?? 'image/jpeg',
            'sizeChars': (doc['base64']?.toString() ?? '').length,
            'base64': doc['base64'],
          },
        )
        .toList();
  }

  static String _scanOverAllStatus(Map<String, dynamic>? data) {
    if (data == null) return 'PENDING';
    var current = data;
    for (var i = 0; i < 4; i++) {
      final status = current['OverAllStatus']?.toString().trim();
      if (status != null && status.isNotEmpty) return status.toUpperCase();
      final inner = current['data'];
      if (inner is Map<String, dynamic>) {
        current = inner;
      } else if (inner is Map) {
        current = Map<String, dynamic>.from(inner);
      } else {
        break;
      }
    }
    return 'PENDING';
  }

  static String _defaultDocumentType(IpassScanTarget target) => switch (target) {
        IpassScanTarget.nationalId => 'Identity Card',
        IpassScanTarget.passport => 'Passport',
        IpassScanTarget.residence => 'Residence Form',
      };

  static bool _isHostedUrl(String? value) {
    if (value == null || value.isEmpty) return false;
    final trimmed = value.trim();
    return trimmed.startsWith('http://') || trimmed.startsWith('https://');
  }

  static bool hasUploadedDocuments(List<Map<String, dynamic>> documents) =>
      documents.isNotEmpty;
}
