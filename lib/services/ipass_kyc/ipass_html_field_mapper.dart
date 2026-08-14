/// Maps [IpassOnboardingMapper] camelCase keys to HTML `data-field` snake_case keys.
import 'ipass_onboarding_mapper.dart';

class IpassHtmlFieldMapper {
  IpassHtmlFieldMapper._();

  static const Map<String, String> _mapperToHtml = {
    'mobile': 'mobile',
    'email': 'email',
    'gender': 'gender',
    'branch': 'branch',
    'arFirst': 'ar_first',
    'arFather': 'ar_father',
    'arGf': 'ar_gf',
    'arSurname': 'ar_surname',
    'arMother': 'ar_mother',
    'surnameAndGivenNamesAr': 'ar_surname_and_given_names',
    'idEnFirst': 'id_en_first',
    'idEnFather': 'id_en_father',
    'idEnGf': 'id_en_gf',
    'idEnSurname': 'id_en_surname',
    'idEnMother': 'id_en_mother',
    'enFirst': 'en_first',
    'enFather': 'en_father',
    'enGf': 'en_gf',
    'enSurname': 'en_surname',
    'enMother': 'en_mother',
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

  /// Personal fields both National ID and Passport may contribute.
  static const Set<String> sharedPersonalFields = {
    'dob',
    'nationality',
    'gender',
    'country_birth',
    'place_birth',
  };

  /// Bridge English names between ID (`id_en_*`) and passport (`en_*`) sections.
  static const Map<String, String> englishNameBridges = {
    'id_en_first': 'en_first',
    'id_en_father': 'en_father',
    'id_en_gf': 'en_gf',
    'id_en_surname': 'en_surname',
    'id_en_mother': 'en_mother',
  };

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
      ...sharedPersonalFields,
    };
    const nationalIdFields = {
      'ar_first',
      'ar_father',
      'ar_gf',
      'ar_surname',
      'ar_mother',
      'ar_surname_and_given_names',
      'id_en_first',
      'id_en_father',
      'id_en_gf',
      'id_en_surname',
      'id_en_mother',
      'id_personal',
      'id_serial',
      'id_issue_place',
      'id_issue_date',
      'id_expiry_date',
      ...sharedPersonalFields,
    };

    bool allowed(String key) => switch (target) {
          IpassScanTarget.passport =>
            passportFields.contains(key) || passportShared.contains(key),
          IpassScanTarget.nationalId => nationalIdFields.contains(key),
          // Residence OCR is stored for submission only — form fields are manual.
          IpassScanTarget.residence => false,
        };

    return Map.fromEntries(
      htmlValues.entries.where((e) => allowed(e.key)),
    );
  }

  /// Values from [other] that may fill empty form slots after a primary scan.
  /// Includes that document's scoped fields, plus Arabic names from passport
  /// (so empty National ID Arabic fields can be filled from passport OCR).
  static Map<String, String> complementaryFillValues(
    IpassScanTarget other,
    Map<String, String> otherHtmlValues,
  ) {
    final out = Map<String, String>.from(forScanTarget(other, otherHtmlValues));
    if (other == IpassScanTarget.passport) {
      const arabicFromPassport = {
        'ar_first',
        'ar_father',
        'ar_gf',
        'ar_surname',
        'ar_mother',
        'ar_surname_and_given_names',
      };
      for (final e in otherHtmlValues.entries) {
        if (arabicFromPassport.contains(e.key) && e.value.trim().isNotEmpty) {
          out.putIfAbsent(e.key, () => e.value.trim());
        }
      }
    }
    return out;
  }

  /// Bidirectional pairs for empty English name cross-fill (ID ↔ passport).
  static List<({String a, String b})> englishNameBridgePairs() {
    return englishNameBridges.entries
        .map((e) => (a: e.key, b: e.value))
        .toList(growable: false);
  }

  /// Keeps only mapper keys allowed for the scan target (post-extraction safety net).
  static Map<String, String> filterMappedForScan(
    IpassScanTarget target,
    Map<String, String> mapped,
  ) {
    final html = toHtmlFieldValues(mapped);
    final allowed = forScanTarget(target, html);
    final out = <String, String>{};
    for (final entry in _mapperToHtml.entries) {
      final htmlKey = entry.value;
      if (!allowed.containsKey(htmlKey)) continue;
      final value = mapped[entry.key]?.trim();
      if (value != null && value.isNotEmpty) {
        out[entry.key] = value;
      }
    }
    if (allowed.containsKey('gender') && mapped['gender']?.trim().isNotEmpty == true) {
      out['gender'] = mapped['gender']!.trim();
    }
    return out;
  }

  /// National ID overwrites its fields; passport overwrites pp_* and English names.
  /// Shared personal fields (dob/place/…) fill only when empty so a better value
  /// from the other document is not clobbered (e.g. ID city vs passport "IRQ").
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
    }.contains(htmlKey);
  }

  /// Kept for API compat — fields are never locked in the UI.
  static List<String> lockedHtmlFields(Map<String, String> htmlValues) {
    return const [];
  }
}
