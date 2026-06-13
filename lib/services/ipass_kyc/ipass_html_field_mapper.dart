/// Maps [IpassOnboardingMapper] camelCase keys to HTML `data-field` snake_case keys.
import 'ipass_onboarding_mapper.dart';

class IpassHtmlFieldMapper {
  IpassHtmlFieldMapper._();

  static const Map<String, String> _mapperToHtml = {
    'mobile': 'mobile',
    'email': 'email',
    'branch': 'branch',
    'arFirst': 'ar_first',
    'arFather': 'ar_father',
    'arGf': 'ar_gf',
    'arSurname': 'ar_surname',
    'arMother': 'ar_mother',
    'enFirst': 'en_first',
    'enFather': 'en_father',
    'enGf': 'en_gf',
    'enSurname': 'en_surname',
    'enMother': 'en_mother',
    'gender': 'gender',
    'nationality': 'nationality',
    'dob': 'dob',
    'countryBirth': 'country_birth',
    'placeBirth': 'place_birth',
    'idPersonal': 'id_personal',
    'idSerial': 'id_serial',
    'idIssuePlace': 'id_issue_place',
    'idIssueDate': 'id_issue_date',
    'idExpiryDate': 'id_expiry_date',
    'resNo': 'res_no',
    'resPlace': 'res_place',
    'resIssue': 'res_issue',
    'resExpiry': 'res_expiry',
    'addrHouse': 'addr_house',
    'addrMahalla': 'addr_mahalla',
    'addrStreet': 'addr_street',
    'ppNo': 'pp_no',
    'ppPlace': 'pp_place',
    'ppIssue': 'pp_issue',
    'ppExpiry': 'pp_expiry',
  };

  /// Returns HTML field key → value for non-empty mapped iPass values.
  static Map<String, String> toHtmlFieldValues(Map<String, String> mapped) {
    final out = <String, String>{};
    for (final entry in mapped.entries) {
      final htmlKey = _mapperToHtml[entry.key];
      if (htmlKey == null) continue;
      final value = entry.value.trim();
      if (value.isNotEmpty) out[htmlKey] = value;
    }
    return out;
  }

  /// Keeps only form keys allowed for each scan type (prevents passport dates on ID fields).
  static Map<String, String> forScanTarget(
    IpassScanTarget target,
    Map<String, String> htmlValues,
  ) {
    const passportFields = {'pp_no', 'pp_place', 'pp_issue', 'pp_expiry'};
    const passportShared = {
      'en_first',
      'en_father',
      'en_gf',
      'en_surname',
      'en_mother',
      'dob',
      'nationality',
      'gender',
      'country_birth',
      'place_birth',
    };
    const nationalIdFields = {
      'ar_first',
      'ar_father',
      'ar_gf',
      'ar_surname',
      'ar_mother',
      'en_first',
      'en_father',
      'en_gf',
      'en_surname',
      'en_mother',
      'id_personal',
      'id_serial',
      'id_issue_place',
      'id_issue_date',
      'id_expiry_date',
      'dob',
      'nationality',
      'gender',
      'country_birth',
      'place_birth',
      'mobile',
      'email',
    };
    const residenceFields = {
      'res_no',
      'res_place',
      'res_issue',
      'res_expiry',
      'addr_house',
      'addr_mahalla',
      'addr_street',
    };

    bool allowed(String key) => switch (target) {
          IpassScanTarget.passport =>
            passportFields.contains(key) || passportShared.contains(key),
          IpassScanTarget.nationalId => nationalIdFields.contains(key),
          IpassScanTarget.residence => residenceFields.contains(key),
        };

    return Map.fromEntries(
      htmlValues.entries.where((e) => allowed(e.key)),
    );
  }

  /// National ID overwrites its fields; passport overwrites pp_* and English/personal
  /// fields (UI: "As it appears on the passport").
  static bool shouldForceApply(IpassScanTarget target, String htmlKey) {
    if (target != IpassScanTarget.passport) return true;
    return const {
      'pp_no',
      'pp_place',
      'pp_issue',
      'pp_expiry',
      'en_first',
      'en_father',
      'en_gf',
      'en_surname',
      'en_mother',
      'dob',
      'gender',
      'nationality',
      'country_birth',
      'place_birth',
    }.contains(htmlKey);
  }

  /// Kept for API compat — fields are never locked in the UI.
  static List<String> lockedHtmlFields(Map<String, String> htmlValues) {
    return const [];
  }
}
