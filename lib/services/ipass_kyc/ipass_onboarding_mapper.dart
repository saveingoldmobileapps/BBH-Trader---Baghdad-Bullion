import 'dart:convert';
import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';

/// Which document the user is scanning — controls field mapping and workflow.
enum IpassScanTarget {
  nationalId,
  residence,
  passport,
}

/// Maps iPass document-scanner JSON into Al-Taif onboarding form values.
///
/// Supports iPass `data.DocDetails.Visual` / `MRZ` (Regula-style keys with spaces).
class IpassOnboardingMapper {
  IpassOnboardingMapper._();

  static const Set<String> allFieldKeys = {
    'mobile',
    'email',
    'branch',
    'arFirst',
    'arFather',
    'arGf',
    'arSurname',
    'arMother',
    'enFirst',
    'enFather',
    'enGf',
    'enSurname',
    'gender',
    'nationality',
    'dob',
    'countryBirth',
    'placeBirth',
    'idPersonal',
    'idSerial',
    'idIssuePlace',
    'idIssueDate',
    'idExpiryDate',
    'resNo',
    'resPlace',
    'resIssue',
    'resExpiry',
    'ppNo',
    'ppPlace',
    'ppIssue',
    'ppExpiry',
  };

  /// Logs which onboarding fields were auto-filled from iPass (debug only).
  static void logMappedFields(Map<String, String> mapped) {
    if (!kDebugMode) return;
    const encoder = JsonEncoder.withIndent('  ');
    developer.log(
      '--- mapped onboarding fields (send with iPass JSON above) ---\n'
      '${encoder.convert(mapped)}',
      name: 'iPassKycData',
    );
  }

  /// Debug-only logs for residence / passport scans.
  /// Search console/logcat for `BBH_RES` or `BBH_PASS` and copy the block between START/END.
  static void logDocumentScanDebug({
    required IpassScanTarget target,
    Map<String, dynamic>? ipassData,
    required Map<String, String> mapped,
    Map<String, String>? formFields,
  }) {
    if (!kDebugMode) return;
    if (target != IpassScanTarget.residence && target != IpassScanTarget.passport) {
      return;
    }

    const encoder = JsonEncoder.withIndent('  ');
    final tag = target == IpassScanTarget.residence ? 'BBH_RES' : 'BBH_PASS';
    final label = target == IpassScanTarget.residence ? 'RESIDENCE' : 'PASSPORT';

    void emit(String line) {
      debugPrint('[$tag] $line');
      developer.log(line, name: tag);
    }

    emit('>>> $label SCAN DATA START <<<  (search: $tag)');
    emit('Copy everything from START to END and send for field mapping fixes.');

    if (ipassData != null && ipassData.isNotEmpty) {
      try {
        emit('--- raw iPass JSON ---\n${encoder.convert(ipassData)}');
      } catch (e) {
        emit('--- raw iPass JSON (encode failed: $e) ---\n$ipassData');
      }
    } else {
      emit('--- raw iPass JSON: null or empty ---');
    }

    if (mapped.isEmpty) {
      emit('--- mapped fields: EMPTY (no fields extracted) ---');
    } else {
      emit('--- mapped fields (camelCase) ---\n${encoder.convert(mapped)}');
    }

    if (formFields == null || formFields.isEmpty) {
      emit('--- form fields (snake_case): EMPTY ---');
    } else {
      emit('--- form fields (snake_case) ---\n${encoder.convert(formFields)}');
    }

    emit('>>> $label SCAN DATA END <<<');
  }

  /// Returns field key → value for non-empty extractions from [ipassData].
  static Map<String, String> extractFieldValues(
    Map<String, dynamic>? ipassData, {
    IpassScanTarget target = IpassScanTarget.nationalId,
  }) {
    if (ipassData == null || ipassData.isEmpty) return {};

    final out = <String, String>{};
    final dataRoot = _resolveDataRoot(ipassData);
    final docSection = _mergeDocSections(dataRoot);
    final docType = _sectionValue(dataRoot, 'DocType')?.toLowerCase() ?? '';
    final isResidenceDoc = _isResidenceDocument(docType, docSection);
    final isPassportDoc = _isPassportDocument(docType, docSection);

    if (docSection != null) {
      _mapFromDocSection(
        out,
        docSection,
        target: target,
        isResidenceDoc: isResidenceDoc,
        isPassportDoc: isPassportDoc,
      );
    }

    // Fallback: flattened keys for older / alternate iPass payloads.
    final flat = _flatten(ipassData);
    _mapFromFlat(out, flat, target: target);

    return out;
  }

  static Map<String, dynamic> _resolveDataRoot(Map<String, dynamic> ipassData) {
    if (ipassData['DocDetails'] != null || ipassData['DocType'] != null) {
      return ipassData;
    }
    final inner = ipassData['data'];
    if (inner is Map<String, dynamic>) {
      return inner;
    }
    if (inner is Map) {
      return Map<String, dynamic>.from(inner);
    }
    return ipassData;
  }

  /// Visual overrides MRZ when both exist (human-readable values).
  static Map<String, dynamic>? _mergeDocSections(Map<String, dynamic> dataRoot) {
    final docDetails = dataRoot['DocDetails'];
    if (docDetails is! Map) return null;

    final merged = <String, dynamic>{};
    final mrz = docDetails['MRZ'];
    final visual = docDetails['Visual'];
    if (mrz is Map) merged.addAll(Map<String, dynamic>.from(mrz));
    if (visual is Map) merged.addAll(Map<String, dynamic>.from(visual));
    return merged.isEmpty ? null : merged;
  }

  static void _mapFromDocSection(
    Map<String, String> out,
    Map<String, dynamic> section, {
    required IpassScanTarget target,
    required bool isResidenceDoc,
    required bool isPassportDoc,
  }) {
    switch (target) {
      case IpassScanTarget.residence:
        _mapResidenceFields(out, section);
        return;
      case IpassScanTarget.passport:
        _mapPassportFields(out, section);
        return;
      case IpassScanTarget.nationalId:
        if (isResidenceDoc) {
          _mapResidenceFields(out, section);
        } else if (isPassportDoc) {
          // Passport scanned from national-ID row — map passport fields only.
          _mapPassportFields(out, section);
        } else {
          _mapNationalIdFields(out, section);
        }
        return;
    }
  }

  static bool _isResidenceDocument(String docType, Map<String, dynamic>? section) {
    final dt = docType.toLowerCase();
    if (dt.contains('resident') || dt.contains('residence')) return true;
    return false;
  }

  static bool _isPassportDocument(String docType, Map<String, dynamic>? section) {
    final dt = docType.toLowerCase();
    if (dt.contains('passport') || dt.contains('travel') || dt.contains('td3')) {
      return true;
    }
    if (section == null) return false;
    final docNo = _firstSectionValue(section, const [
      'Document Number',
      'Passport Number',
    ]);
    if (docNo != null && RegExp(r'^[A-Z]\d{7,9}$').hasMatch(docNo.trim())) {
      return true;
    }
    return false;
  }

  static void _mapResidenceFields(Map<String, String> out, Map<String, dynamic> section) {
    void put(String key, String? value) {
      final v = _clean(value);
      if (v != null && !out.containsKey(key)) out[key] = v;
    }

    final identityNo = _firstSectionValue(section, const [
      'Personal Number',
      'Identity Card Number',
      'Optional Data',
      'Document Number',
    ]);
    final documentNo = _sectionValue(section, 'Document Number');
    final issuePlace = _firstSectionValue(section, const [
      'Place of Issue',
      'Issuing State Name',
    ]);
    final issueDate = _normalizeDate(_sectionValue(section, 'Date of Issue'));
    final expiryDate = _normalizeDate(_sectionValue(section, 'Date of Expiry'));

    put('resNo', identityNo ?? documentNo);
    put('resPlace', issuePlace);
    put('resIssue', issueDate);
    put('resExpiry', expiryDate);
  }

  static void _mapPassportFields(Map<String, String> out, Map<String, dynamic> section) {
    void put(String key, String? value) {
      final v = _clean(value);
      if (v != null && !out.containsKey(key)) out[key] = v;
    }

    _putEnglishNames(out, section);

    final documentNo = _firstSectionValue(section, const [
      'Document Number',
      'Passport Number',
    ]);
    final issuePlace = _firstSectionValue(section, const [
      'Place of Issue',
      'Issuing State Name',
      'Nationality',
    ]);
    final issueDate = _normalizeDate(_sectionValue(section, 'Date of Issue'));
    final expiryDate = _normalizeDate(_sectionValue(section, 'Date of Expiry'));

    put('ppNo', documentNo);
    put('ppPlace', issuePlace);
    put('ppIssue', issueDate);
    put('ppExpiry', expiryDate);

    put(
      'enMother',
      _firstSectionValue(section, const [
        'Mothers Name',
        "Mother's Name",
        'Mother Name',
      ]),
    );

    put(
      'nationality',
      _normalizeNationality(
        _sectionValue(section, 'Nationality') ??
            _nationalityFromCode(_sectionValue(section, 'Nationality Code')),
      ),
    );
    put('dob', _normalizeDate(_sectionValue(section, 'Date of Birth')));
    put('countryBirth', _sectionValue(section, 'Issuing State Name'));
    put('placeBirth', _sectionValue(section, 'Place of Birth'));
    put('gender', _normalizeGender(_firstSectionValue(section, const ['Sex', 'SexAr'])));
  }

  static void _mapNationalIdFields(Map<String, String> out, Map<String, dynamic> section) {
    void put(String key, String? value) {
      final v = _clean(value);
      if (v != null && !out.containsKey(key)) out[key] = v;
    }

    _putEnglishNames(out, section);
    _putArabicNames(out, section);

    put('gender', _normalizeGender(_firstSectionValue(section, const ['Sex', 'SexAr'])));
    put(
      'nationality',
      _normalizeNationality(
        _sectionValue(section, 'Nationality') ??
            _nationalityFromCode(_sectionValue(section, 'Nationality Code')),
      ),
    );
    put('dob', _normalizeDate(_sectionValue(section, 'Date of Birth')));
    put(
      'countryBirth',
      _sectionValue(section, 'Issuing State Name') ??
          _sectionValue(section, 'Place of Birth'),
    );
    put('placeBirth', _sectionValue(section, 'Place of Birth'));

    final identityNo = _firstSectionValue(section, const [
      'Personal Number',
      'Identity Card Number',
      'Optional Data',
    ]);
    final documentNo = _sectionValue(section, 'Document Number');

    final issuePlace = _sectionValue(section, 'Place of Issue');
    final issueDate = _normalizeDate(_sectionValue(section, 'Date of Issue'));
    final expiryDate = _normalizeDate(_sectionValue(section, 'Date of Expiry'));

    put('idPersonal', identityNo);
    put('idSerial', documentNo);
    put('idIssuePlace', issuePlace);
    put('idIssueDate', issueDate);
    put('idExpiryDate', expiryDate);
  }

  static void _putEnglishNames(Map<String, String> out, Map<String, dynamic> section) {
    void put(String key, String? value) {
      final v = _clean(value);
      if (v != null && !out.containsKey(key)) out[key] = v;
    }

    final surname = _titleCase(_sectionValue(section, 'Surname'));
    final givenNames = _sectionValue(section, 'Given Names');

    if (surname != null) put('enSurname', surname);

    if (givenNames != null) {
      final parts = givenNames.split(RegExp(r'\s+'));
      if (parts.isNotEmpty) put('enFirst', _titleCase(parts.first));
      if (parts.length > 1) put('enFather', _titleCase(parts[1]));
      if (parts.length > 2) put('enGf', _titleCase(parts[2]));
      return;
    }

    final visualFull = _sectionValue(section, 'Surname And Given Names');
    if (visualFull != null && !_looksLikeAllCapsMrz(visualFull)) {
      final parts = visualFull.split(RegExp(r'\s+'));
      if (parts.length >= 2) {
        put('enFirst', _titleCase(parts.first));
        if (parts.length == 2) {
          put('enSurname', _titleCase(parts[1]));
        } else {
          put('enSurname', _titleCase(parts.last));
          if (parts.length > 2) {
            put('enFather', _titleCase(parts.sublist(1, parts.length - 1).join(' ')));
          }
        }
      }
      return;
    }

    // MRZ order: SURNAME GIVEN1 GIVEN2…
    final mrzFull = _sectionValue(section, 'Surname And Given Names');
    if (mrzFull != null) {
      final parts = mrzFull.split(RegExp(r'\s+'));
      if (parts.isNotEmpty) put('enSurname', _titleCase(parts.first));
      if (parts.length > 1) put('enFirst', _titleCase(parts[1]));
      if (parts.length > 2) put('enFather', _titleCase(parts[2]));
      if (parts.length > 3) put('enGf', _titleCase(parts[3]));
    }
  }

  static void _putArabicNames(Map<String, String> out, Map<String, dynamic> section) {
    void put(String key, String? value) {
      final v = _clean(value);
      if (v != null && !out.containsKey(key)) out[key] = v;
    }

    // Iraqi national ID Visual layout (split Arabic name fields).
    final surnameAr = _sectionValue(section, 'SurnameAr');
    final givenAr = _firstSectionValue(section, const ['Given NamesAr', 'Given NameAr']);
    final fatherAr = _firstSectionValue(section, const [
      'Fathers NameAr',
      "Father's NameAr",
      'Father NameAr',
    ]);
    final gfAr = _firstSectionValue(section, const [
      'Grandfather NameAr',
      'Grandfathers NameAr',
    ]);

    if (givenAr != null || surnameAr != null || fatherAr != null || gfAr != null) {
      put('arFirst', givenAr);
      put('arSurname', surnameAr);
      put('arFather', fatherAr);
      put('arGf', gfAr);
      put(
        'arMother',
        _firstSectionValue(section, const [
          'Mothers NameAr',
          "Mother's NameAr",
          'Mother NameAr',
        ]),
      );
      return;
    }

    final fullAr = _firstSectionValue(section, const [
      'Surname And Given NamesAr',
      'Surname And Given Names Ar',
    ]);
    if (fullAr == null) return;

    final parts = fullAr.split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return;

    if (parts.length == 1) {
      put('arFirst', parts[0]);
      return;
    }

    put('arSurname', parts.last);
    put('arFirst', parts.first);
    if (parts.length == 3) {
      put('arFather', parts[1]);
    } else if (parts.length > 3) {
      put('arFather', parts[1]);
      put('arGf', parts.sublist(2, parts.length - 1).join(' '));
    } else if (parts.length == 2) {
      put('arFirst', parts[0]);
    }
  }

  static bool _looksLikeAllCapsMrz(String value) {
    final letters = value.replaceAll(RegExp(r'[^A-Za-z]'), '');
    if (letters.isEmpty) return false;
    return letters == letters.toUpperCase();
  }

  /// True when iPass payload contains scanned document fields.
  static bool hasDocumentDetails(Map<String, dynamic>? ipassData) {
    if (ipassData == null || ipassData.isEmpty) return false;
    final root = _resolveDataRoot(ipassData);
    final docDetails = root['DocDetails'];
    return docDetails is Map && docDetails.isNotEmpty;
  }

  static String? _normalizeNationality(String? raw) {
    if (raw == null) return null;
    final v = raw.trim();
    if (v.isEmpty) return null;
    final compact = v.replaceAll(RegExp(r'[\s<]'), '').toUpperCase();
    if (compact == 'IRQ' ||
        compact == 'IQI' ||
        compact == 'IQ' ||
        v.toLowerCase() == 'iraq') {
      return 'Iraqi';
    }
    return _nationalityFromCode(compact) ?? v;
  }

  static String? _nationalityFromCode(String? code) {
    if (code == null) return null;
    const map = {
      'IRQ': 'Iraqi',
      'IND': 'Indian',
      'ARE': 'Emirati',
      'UAE': 'Emirati',
      'JOR': 'Jordanian',
      'EGY': 'Egyptian',
      'SAU': 'Saudi',
    };
    return map[code.toUpperCase()] ?? code;
  }

  static String? _sectionValue(Map<String, dynamic> section, String key) {
    final value = section[key];
    if (value == null) return null;
    final text = value.toString().trim();
    return text.isEmpty ? null : text;
  }

  static String? _firstSectionValue(Map<String, dynamic> section, List<String> keys) {
    for (final key in keys) {
      final value = _sectionValue(section, key);
      if (value != null) return value;
    }
    return null;
  }

  static void _mapFromFlat(
    Map<String, String> out,
    Map<String, String> flat, {
    required IpassScanTarget target,
  }) {
    void put(String key, String? value) {
      final v = _clean(value);
      if (v != null && !out.containsKey(key)) out[key] = v;
    }

    switch (target) {
      case IpassScanTarget.residence:
        put('resNo', _first(flat, const [
          'residencecardnumber',
          'personalnumber',
          'identitycardnumber',
          'documentnumber',
        ]));
        put('resPlace', _first(flat, const ['placeofissue', 'residenceplaceofissue', 'issuingstatename']));
        put('resIssue', _normalizeDate(_first(flat, const ['dateofissue', 'residenceissuedate'])));
        put('resExpiry', _normalizeDate(_first(flat, const ['dateofexpiry', 'residenceexpirydate'])));
        return;
      case IpassScanTarget.passport:
        if (!out.containsKey('enFirst')) {
          put('enFirst', _first(flat, const ['givennames', 'givenname', 'englishfirstname']));
        }
        if (!out.containsKey('enSurname')) {
          put('enSurname', _first(flat, const ['surname', 'englishsurname', 'familyname']));
        }
        if (!out.containsKey('enFather')) {
          put('enFather', _first(flat, const ['fathersname', 'fathername']));
        }
        if (!out.containsKey('enGf')) {
          put('enGf', _first(flat, const ['grandfathername', 'grandfathersname']));
        }
        if (!out.containsKey('enMother')) {
          put('enMother', _first(flat, const ['mothersname', 'mothername']));
        }
        put('ppNo', _first(flat, const ['passportnumber', 'passportno', 'documentnumber']));
        put('ppPlace', _first(flat, const ['passportplaceofissue', 'placeofissue', 'issuingstatename']));
        put('ppIssue', _normalizeDate(_first(flat, const ['passportdateofissue', 'dateofissue'])));
        put('ppExpiry', _normalizeDate(_first(flat, const ['passportdateofexpiry', 'dateofexpiry'])));
        put('gender', _normalizeGender(_first(flat, const ['sex', 'sexar', 'gender'])));
        put(
          'nationality',
          _normalizeNationality(
            _first(flat, const ['nationality', 'nationalityname']) ??
                _nationalityFromCode(_first(flat, const ['nationalitycode'])),
          ),
        );
        put('dob', _normalizeDate(_first(flat, const ['dateofbirth', 'dob', 'birthdate'])));
        put('countryBirth', _first(flat, const ['issuingstatename', 'countryofbirth']));
        put('placeBirth', _first(flat, const ['placeofbirth', 'birthplace']));
        return;
      case IpassScanTarget.nationalId:
        break;
    }

    put('mobile', _first(flat, const ['mobile', 'phone', 'phoneNumber', 'mobileNumber']));
    put('email', _first(flat, const ['email', 'emailAddress']));

    if (!out.containsKey('enFirst')) {
      put('enFirst', _first(flat, const ['givennames', 'givenname', 'englishfirstname']));
    }
    if (!out.containsKey('enSurname')) {
      put('enSurname', _first(flat, const ['surname', 'englishsurname', 'familyname']));
    }
    if (!out.containsKey('arFirst')) {
      put('arFirst', _first(flat, const [
        'givennamesar',
        'givennamear',
        'surnameandgivennamesar',
        'arabicfirstname',
      ]));
    }
    if (!out.containsKey('arSurname')) {
      put('arSurname', _first(flat, const ['surnamear', 'arabicsurname']));
    }
    if (!out.containsKey('arFather')) {
      put('arFather', _first(flat, const ['fathersnamear', 'fathernamear']));
    }
    if (!out.containsKey('arGf')) {
      put('arGf', _first(flat, const ['grandfathernamear', 'grandfathersnamear']));
    }
    if (!out.containsKey('arMother')) {
      put('arMother', _first(flat, const ['mothersnamear', 'mothernamear']));
    }

    put('gender', _normalizeGender(_first(flat, const ['sex', 'sexar', 'gender'])));
    put(
      'nationality',
      _normalizeNationality(
        _first(flat, const ['nationality', 'nationalityname']) ??
            _nationalityFromCode(_first(flat, const ['nationalitycode'])),
      ),
    );
    put('dob', _normalizeDate(_first(flat, const ['dateofbirth', 'dob', 'birthdate'])));
    put('countryBirth', _first(flat, const ['issuingstatename', 'countryofbirth', 'birthcountry']));
    put('placeBirth', _first(flat, const ['placeofbirth', 'birthplace']));

    put(
      'idPersonal',
      _first(flat, const [
        'personalnumber',
        'identitycardnumber',
        'optionaldata',
      ]),
    );
    final looksLikePassport = out.containsKey('ppNo') ||
        _first(flat, const ['passportnumber', 'passportno']) != null;
    if (!looksLikePassport) {
      put('idSerial', _first(flat, const ['documentnumber', 'cardserialnumber', 'idnumber']));
      put('idIssuePlace', _first(flat, const ['placeofissue', 'issueplace', 'issuingauthority']));
      put('idIssueDate', _normalizeDate(_first(flat, const ['dateofissue', 'issuedate'])));
      put('idExpiryDate', _normalizeDate(_first(flat, const ['dateofexpiry', 'expirydate'])));
    }

    put('resNo', _first(flat, const ['residencecardnumber', 'identitycardnumber']));
    put('resPlace', _first(flat, const ['placeofissue', 'residenceplaceofissue']));
    put('resIssue', _normalizeDate(_first(flat, const ['dateofissue', 'residenceissuedate'])));
    put('resExpiry', _normalizeDate(_first(flat, const ['dateofexpiry', 'residenceexpirydate'])));

    put('ppNo', _first(flat, const ['passportnumber', 'passportno']));
    put('ppPlace', _first(flat, const ['passportplaceofissue']));
    put('ppIssue', _normalizeDate(_first(flat, const ['passportdateofissue'])));
    put('ppExpiry', _normalizeDate(_first(flat, const ['passportdateofexpiry'])));
  }

  static Map<String, String> _flatten(
    Map<String, dynamic> source, [
    String prefix = '',
  ]) {
    final out = <String, String>{};
    for (final entry in source.entries) {
      final key = prefix.isEmpty ? entry.key : '$prefix.${entry.key}';
      final normalizedKey = _normalizeKey(entry.key);
      final value = entry.value;
      if (value == null) continue;
      if (value is Map) {
        out.addAll(_flatten(Map<String, dynamic>.from(value), key));
        out.addAll(_flatten(Map<String, dynamic>.from(value)));
      } else if (value is List) {
        for (final item in value) {
          if (item is Map) {
            out.addAll(_flatten(Map<String, dynamic>.from(item), key));
            out.addAll(_flatten(Map<String, dynamic>.from(item)));
          } else if (item is String && item.trim().isNotEmpty) {
            // Skip Reason[].Text noise for flat fallback.
          }
        }
      } else {
        final text = value.toString().trim();
        if (text.isNotEmpty) {
          out[normalizedKey] = text;
          out[_normalizeKey(key)] = text;
        }
      }
    }
    return out;
  }

  static String _normalizeKey(String key) {
    return key.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '').toLowerCase();
  }

  static String? _first(Map<String, String> flat, List<String> keys) {
    for (final key in keys) {
      final direct = flat[_normalizeKey(key)];
      if (direct != null && direct.isNotEmpty) return direct;
    }
    return null;
  }

  static String? _clean(String? value) {
    if (value == null) return null;
    final v = value.trim();
    return v.isEmpty ? null : v;
  }

  static String? _titleCase(String? value) {
    if (value == null) return null;
    if (_looksLikeAllCapsMrz(value)) {
      return value
          .toLowerCase()
          .split(RegExp(r'\s+'))
          .map((w) => w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1)}')
          .join(' ');
    }
    return value;
  }

  static String? _normalizeGender(String? raw) {
    if (raw == null) return null;
    final v = raw.trim().toLowerCase();
    if (v == 'm' || v == 'male' || v == '1' || v == 'ذكر') return 'Male';
    if (v == 'f' || v == 'female' || v == '2' || v == 'أنثى' || v == 'انثى') return 'Female';
    return null;
  }

  static String? _normalizeDate(String? raw) {
    if (raw == null) return null;
    final v = raw.trim();
    if (v.isEmpty) return null;

    final iso = RegExp(r'^(\d{4})-(\d{2})-(\d{2})');
    final isoMatch = iso.firstMatch(v);
    if (isoMatch != null) {
      return '${isoMatch.group(1)}-${isoMatch.group(2)}-${isoMatch.group(3)}';
    }

    final dmy = RegExp(r'^(\d{2})[./-](\d{2})[./-](\d{4})');
    final dmyMatch = dmy.firstMatch(v);
    if (dmyMatch != null) {
      return '${dmyMatch.group(3)}-${dmyMatch.group(2)}-${dmyMatch.group(1)}';
    }

    try {
      final parsed = DateTime.parse(v);
      return '${parsed.year.toString().padLeft(4, '0')}-'
          '${parsed.month.toString().padLeft(2, '0')}-'
          '${parsed.day.toString().padLeft(2, '0')}';
    } catch (_) {
      return v;
    }
  }
}
