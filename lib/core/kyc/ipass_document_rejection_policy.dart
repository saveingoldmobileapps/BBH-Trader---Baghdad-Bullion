import 'package:baghdad_bullion_house/core/kyc/kyc_document_review_status.dart';
import 'package:baghdad_bullion_house/data/models/ipass_model/ipass_formdata_result_response.dart';
import 'package:baghdad_bullion_house/services/ipass_kyc/ipass_onboarding_mapper.dart';

/// Per-document iPass rejection handling for onboarding and document re-upload.
///
/// When [bypass*Rejection] is `true`, OCR / scan data is still applied even if
/// iPass rejected the document (dev/demo without real cards).
///
/// When `false`, form data is filled only when iPass accepts the document.
class IpassDocumentRejectionPolicy {
  IpassDocumentRejectionPolicy._();

  static const bypassNationalIdRejection = true;
  static const bypassPassportRejection = true;
  static const bypassResidencyRejection = true;

  static bool bypassRejectionFor(IpassScanTarget target) => switch (target) {
    IpassScanTarget.nationalId => bypassNationalIdRejection,
    IpassScanTarget.passport => bypassPassportRejection,
    IpassScanTarget.residence => bypassResidencyRejection,
  };

  static bool bypassRejectionForDocumentType(KycDocumentType type) =>
      bypassRejectionFor(type.scanTarget);

  static bool isResidenceOcrAccepted({
    IpassFormDataResultResponse? front,
    IpassFormDataResultResponse? back,
  }) => (front?.isSucceeded ?? false) && (back?.isSucceeded ?? false);

  static bool isScanRejected(Map<String, dynamic>? data) {
    if (data == null) return false;
    final root = _resolveScanDataRoot(data);
    final overall = root['OverAllStatus']?.toString().toUpperCase();
    if (overall == 'REJECTED') return true;

    final reasons = root['Reason'];
    if (reasons is! List) return false;
    for (final item in reasons) {
      if (item is! Map) continue;
      if (item['Status']?.toString().toUpperCase() == 'REJECTED') return true;
    }
    return false;
  }

  static Map<String, dynamic> _resolveScanDataRoot(Map<String, dynamic> data) {
    var current = data;
    for (var depth = 0; depth < 4; depth++) {
      if (current.containsKey('OverAllStatus') ||
          current.containsKey('DocDetails')) {
        return current;
      }
      final inner = current['data'];
      if (inner is Map<String, dynamic>) {
        current = inner;
      } else if (inner is Map) {
        current = Map<String, dynamic>.from(inner);
      } else {
        break;
      }
    }
    return current;
  }
}
