import 'package:baghdad_bullion_house/services/ipass_kyc/ipass_html_field_mapper.dart';
import 'package:baghdad_bullion_house/services/ipass_kyc/ipass_onboarding_mapper.dart';
import 'package:flutter/material.dart';

/// All onboarding field state — keys align with HTML `data-field` attributes.
class BbhOnboardingForm {
  bool purposeConfirmed = false;
  bool consentConfirmed = false;
  bool noPassport = false;
  String? signature;

  bool get hasSignature => signature != null && signature!.isNotEmpty;

  String fatca = 'No';
  String pep = 'No';
  String foreignRes = 'No';
  String foreignCit = 'No';
  String? gender;
  String? education;
  String? sector;
  String custodian = 'ALTAIF';
  String hasAccount = 'No';

  bool idFrontCaptured = false;
  bool idBackCaptured = false;
  bool resFrontCaptured = false;
  bool resBackCaptured = false;
  bool passportCaptured = false;
  bool foreignResCaptured = false;
  bool foreignCitCaptured = false;

  final verifiedMobile = ValueNotifier<bool>(false);
  final verifiedEmail = ValueNotifier<bool>(false);
  final lockedFields = <String>{};
  final verifiedFields = <String>{};


  final motherCombined = TextEditingController();
  final mobile = TextEditingController();
  final email = TextEditingController();
  final arFirst = TextEditingController();
  final arFather = TextEditingController();
  final arGf = TextEditingController();
  final arSurname = TextEditingController();
  final arMother = TextEditingController();
  final arSurnameAndGivenNames = TextEditingController();
  final idEnFirst = TextEditingController();
  final idEnFather = TextEditingController();
  final idEnGf = TextEditingController();
  final idEnSurname = TextEditingController();
  final idEnMother = TextEditingController();
  final enFirst = TextEditingController();
  final enFather = TextEditingController();
  final enGf = TextEditingController();
  final enSurname = TextEditingController();
  final enMother = TextEditingController();
  final nationality = TextEditingController(text: 'Iraqi');
  final dob = TextEditingController();
  final countryBirth = TextEditingController(text: 'Iraq');
  final placeBirth = TextEditingController();
  final idPersonal = TextEditingController();
  final idSerial = TextEditingController();
  final idIssuePlace = TextEditingController(text: 'Iraq');
  final idIssueDate = TextEditingController();
  final idExpiryDate = TextEditingController();
  final ppNo = TextEditingController();
  final ppPlace = TextEditingController();
  final ppIssue = TextEditingController();
  final ppExpiry = TextEditingController();
  final resNo = TextEditingController();
  final resPlace = TextEditingController();
  final resIssue = TextEditingController();
  final resExpiry = TextEditingController();
  final addrGov = TextEditingController();
  final addrDistrict = TextEditingController();
  final addrCity = TextEditingController();
  final addrMahalla = TextEditingController();
  final addrStreet = TextEditingController();
  final addrHouse = TextEditingController();
  final addrLandmarkAr = TextEditingController();
  final addrLandmarkEn = TextEditingController();
  final foreignResCountry = TextEditingController();
  final foreignCitCountry = TextEditingController();
  final income = TextEditingController();
  final occupation = TextEditingController();
  final employer = TextEditingController();
  final employerAddr = TextEditingController();
  final fatcaTin = TextEditingController();
  final fatcaAddr = TextEditingController();
  final pepPosition = TextEditingController();
  final pepCountry = TextEditingController();
  final pepFrom = TextEditingController();
  final pepTo = TextEditingController();
  final signerName = TextEditingController();
  final iban = TextEditingController();

  /// Auto-filled fields are never locked — users can always edit them.
  bool isLocked(String key) => false;

  bool isVerified(String key) => verifiedFields.contains(key);

  void verifyField(String key) => verifiedFields.add(key);

  TextEditingController? controllerFor(String key) => _controllerFor(key);

  void copyValuesFrom(BbhOnboardingForm source) {
    purposeConfirmed = source.purposeConfirmed;
    consentConfirmed = source.consentConfirmed;
    noPassport = source.noPassport;
    signature = source.signature;
    fatca = source.fatca;
    pep = source.pep;
    foreignRes = source.foreignRes;
    foreignCit = source.foreignCit;
    gender = source.gender;
    education = source.education;
    sector = source.sector;
    custodian = source.custodian;
    hasAccount = source.hasAccount;
    idFrontCaptured = source.idFrontCaptured;
    idBackCaptured = source.idBackCaptured;
    resFrontCaptured = source.resFrontCaptured;
    resBackCaptured = source.resBackCaptured;
    passportCaptured = source.passportCaptured;
    foreignResCaptured = source.foreignResCaptured;
    foreignCitCaptured = source.foreignCitCaptured;
    verifiedMobile.value = source.verifiedMobile.value;
    verifiedEmail.value = source.verifiedEmail.value;
    lockedFields.clear();
    verifiedFields
      ..clear()
      ..addAll(source.verifiedFields);
    for (final e in _allFieldEntries()) {
      final src = source.controllerFor(e.key);
      if (src != null) e.value.text = src.text;
    }
  }

  void applyValues(Map<String, String> values, {bool onlyMissing = false}) {
    for (final entry in values.entries) {
      if (onlyMissing && _hasValue(entry.key)) continue;
      _setField(entry.key, entry.value);
    }
  }

  /// Applies iPass values scoped to the document that was scanned.
  void applyScanValues(
    IpassScanTarget target,
    Map<String, String> values,
  ) {
    for (final entry in values.entries) {
      final force = IpassHtmlFieldMapper.shouldForceApply(target, entry.key);
      if (!force && _hasValue(entry.key)) continue;
      _setScannedField(entry.key, entry.value);
    }
  }

  /// Fills empty fields only (cross-document complement — never overwrites).
  void applyMissingScanValues(Map<String, String> values) {
    for (final entry in values.entries) {
      if (_hasValue(entry.key)) continue;
      final value = entry.value.trim();
      if (value.isEmpty) continue;
      _setScannedField(entry.key, value);
    }
  }

  /// Copies empty English names both ways: `id_en_*` ↔ `en_*`.
  void bridgeMissingEnglishNames() {
    for (final pair in IpassHtmlFieldMapper.englishNameBridgePairs()) {
      final aFilled = _hasValue(pair.a);
      final bFilled = _hasValue(pair.b);
      if (aFilled && !bFilled) {
        final v = _valueOf(pair.a);
        if (v != null) _setScannedField(pair.b, v);
      } else if (bFilled && !aFilled) {
        final v = _valueOf(pair.b);
        if (v != null) _setScannedField(pair.a, v);
      }
    }
  }

  String? _valueOf(String key) {
    final controller = _controllerFor(key);
    if (controller != null) {
      final t = controller.text.trim();
      return t.isEmpty ? null : t;
    }
    if (key == 'gender') {
      final g = gender?.trim();
      return (g == null || g.isEmpty) ? null : g;
    }
    return null;
  }

  void _setField(String key, String value) {
    final controller = _controllerFor(key);
    if (controller != null) {
      controller.text = value;
      verifyField(key);
    } else if (key == 'gender') {
      gender = value;
      verifyField('gender');
    }
  }

  /// Auto-filled from iPass — editable, shown with Verified badge.
  void _setScannedField(String key, String value) {
    final controller = _controllerFor(key);
    if (controller != null) {
      controller.text = value;
      verifyField(key);
    } else if (key == 'gender') {
      gender = value;
      verifyField('gender');
    }
  }

  bool _hasValue(String key) {
    final controller = _controllerFor(key);
    if (controller != null) return controller.text.trim().isNotEmpty;
    if (key == 'gender') return gender != null && gender!.trim().isNotEmpty;
    return false;
  }

  TextEditingController? _controllerFor(String key) => switch (key) {
        'mobile' => mobile,
        'email' => email,
        'ar_first' => arFirst,
        'ar_father' => arFather,
        'ar_gf' => arGf,
        'ar_gf_mom' => motherCombined,
        'ar_surname' => arSurname,
        'ar_mother' => arMother,
        'ar_surname_and_given_names' => arSurnameAndGivenNames,
        'id_en_first' => idEnFirst,
        'id_en_father' => idEnFather,
        'id_en_gf' => idEnGf,
        'id_en_surname' => idEnSurname,
        'id_en_mother' => idEnMother,
        'en_first' => enFirst,
        'en_father' => enFather,
        'en_gf' => enGf,
        'en_surname' => enSurname,
        'en_mother' => enMother,
        'nationality' => nationality,
        'dob' => dob,
        'country_birth' => countryBirth,
        'place_birth' => placeBirth,
        'id_personal' => idPersonal,
        'id_serial' => idSerial,
        'id_issue_place' => idIssuePlace,
        'id_issue_date' => idIssueDate,
        'id_expiry_date' => idExpiryDate,
        'pp_no' => ppNo,
        'pp_place' => ppPlace,
        'pp_issue' => ppIssue,
        'pp_expiry' => ppExpiry,
        'res_no' => resNo,
        'res_place' => resPlace,
        'res_issue' => resIssue,
        'res_expiry' => resExpiry,
        'addr_gov' => addrGov,
        'addr_district' => addrDistrict,
        'addr_city' => addrCity,
        'addr_mahalla' => addrMahalla,
        'addr_street' => addrStreet,
        'addr_house' => addrHouse,
        'addr_landmark_ar' => addrLandmarkAr,
        'addr_landmark_en' => addrLandmarkEn,
        'foreign_res_country' => foreignResCountry,
        'foreign_cit_country' => foreignCitCountry,
        'income' => income,
        'occupation' => occupation,
        'employer' => employer,
        'employer_addr' => employerAddr,
        'fatca_tin' => fatcaTin,
        'fatca_addr' => fatcaAddr,
        'pep_position' => pepPosition,
        'pep_country' => pepCountry,
        'pep_from' => pepFrom,
        'pep_to' => pepTo,
        'iban' => iban,
        _ => null,
      };

  Map<String, dynamic> toJson() => {
        'purposeConfirmed': purposeConfirmed,
        'consentConfirmed': consentConfirmed,
        'noPassport': noPassport,
        if (signature != null) 'signature': signature,
        'fatca': fatca,
        'pep': pep,
        'foreignRes': foreignRes,
        'foreignCit': foreignCit,
        'gender': gender,
        'education': education,
        'sector': sector,
        'custodian': custodian,
        'hasAccount': hasAccount,
        'idFrontCaptured': idFrontCaptured,
        'idBackCaptured': idBackCaptured,
        'resFrontCaptured': resFrontCaptured,
        'resBackCaptured': resBackCaptured,
        'passportCaptured': passportCaptured,
        'foreignResCaptured': foreignResCaptured,
        'foreignCitCaptured': foreignCitCaptured,
        'verifiedMobile': verifiedMobile.value,
        'verifiedEmail': verifiedEmail.value,
        'lockedFields': const <String>[],
        'verifiedFields': verifiedFields.toList(),
        'fields': {
          for (final e in _allFieldEntries()) e.key: e.value.text,
        },
      };

  static BbhOnboardingForm fromJson(Map<String, dynamic> json) {
    final form = BbhOnboardingForm();
    form.purposeConfirmed = json['purposeConfirmed'] == true;
    form.consentConfirmed = json['consentConfirmed'] == true;
    form.noPassport = json['noPassport'] == true;
    form.signature = json['signature']?.toString();
    form.fatca = json['fatca']?.toString() ?? 'No';
    form.pep = json['pep']?.toString() ?? 'No';
    form.foreignRes = json['foreignRes']?.toString() ?? 'No';
    form.foreignCit = json['foreignCit']?.toString() ?? 'No';
    form.gender = json['gender']?.toString();
    form.education = json['education']?.toString();
    form.sector = json['sector']?.toString();
    form.custodian = json['custodian']?.toString() ?? 'ALTAIF';
    form.hasAccount = json['hasAccount']?.toString() ?? 'No';
    form.idFrontCaptured = json['idFrontCaptured'] == true;
    form.idBackCaptured = json['idBackCaptured'] == true;
    form.resFrontCaptured = json['resFrontCaptured'] == true;
    form.resBackCaptured = json['resBackCaptured'] == true;
    form.passportCaptured = json['passportCaptured'] == true;
    form.foreignResCaptured = json['foreignResCaptured'] == true;
    form.foreignCitCaptured = json['foreignCitCaptured'] == true;
    form.verifiedMobile.value = json['verifiedMobile'] == true;
    form.verifiedEmail.value = json['verifiedEmail'] == true;
    final verified = json['verifiedFields'];
    if (verified is List) {
      form.verifiedFields.addAll(verified.map((e) => e.toString()));
    }
    final locked = json['lockedFields'];
    if (locked is List) {
      form.verifiedFields.addAll(locked.map((e) => e.toString()));
    }
    final fields = json['fields'];
    if (fields is Map) {
      fields.forEach((key, value) {
        final c = form.controllerFor(key.toString());
        if (c != null && value != null) c.text = value.toString();
      });
    }
    return form;
  }

  Iterable<MapEntry<String, TextEditingController>> _allFieldEntries() sync* {
    yield MapEntry('mobile', mobile);
    yield MapEntry('email', email);
    yield MapEntry('ar_first', arFirst);
    yield MapEntry('ar_father', arFather);
    yield MapEntry('ar_gf', arGf);
    yield MapEntry('ar_gf_mom', motherCombined);
    yield MapEntry('ar_surname', arSurname);
    yield MapEntry('ar_mother', arMother);
    yield MapEntry('ar_surname_and_given_names', arSurnameAndGivenNames);
    yield MapEntry('id_en_first', idEnFirst);
    yield MapEntry('id_en_father', idEnFather);
    yield MapEntry('id_en_gf', idEnGf);
    yield MapEntry('id_en_surname', idEnSurname);
    yield MapEntry('id_en_mother', idEnMother);
    yield MapEntry('en_first', enFirst);
    yield MapEntry('en_father', enFather);
    yield MapEntry('en_gf', enGf);
    yield MapEntry('en_surname', enSurname);
    yield MapEntry('en_mother', enMother);
    yield MapEntry('nationality', nationality);
    yield MapEntry('dob', dob);
    yield MapEntry('country_birth', countryBirth);
    yield MapEntry('place_birth', placeBirth);
    yield MapEntry('id_personal', idPersonal);
    yield MapEntry('id_serial', idSerial);
    yield MapEntry('id_issue_place', idIssuePlace);
    yield MapEntry('id_issue_date', idIssueDate);
    yield MapEntry('id_expiry_date', idExpiryDate);
    yield MapEntry('pp_no', ppNo);
    yield MapEntry('pp_place', ppPlace);
    yield MapEntry('pp_issue', ppIssue);
    yield MapEntry('pp_expiry', ppExpiry);
    yield MapEntry('res_no', resNo);
    yield MapEntry('res_place', resPlace);
    yield MapEntry('res_issue', resIssue);
    yield MapEntry('res_expiry', resExpiry);
    yield MapEntry('addr_gov', addrGov);
    yield MapEntry('addr_district', addrDistrict);
    yield MapEntry('addr_city', addrCity);
    yield MapEntry('addr_mahalla', addrMahalla);
    yield MapEntry('addr_street', addrStreet);
    yield MapEntry('addr_house', addrHouse);
    yield MapEntry('addr_landmark_ar', addrLandmarkAr);
    yield MapEntry('addr_landmark_en', addrLandmarkEn);
    yield MapEntry('foreign_res_country', foreignResCountry);
    yield MapEntry('foreign_cit_country', foreignCitCountry);
    yield MapEntry('income', income);
    yield MapEntry('occupation', occupation);
    yield MapEntry('employer', employer);
    yield MapEntry('employer_addr', employerAddr);
    yield MapEntry('fatca_tin', fatcaTin);
    yield MapEntry('fatca_addr', fatcaAddr);
    yield MapEntry('pep_position', pepPosition);
    yield MapEntry('pep_country', pepCountry);
    yield MapEntry('pep_from', pepFrom);
    yield MapEntry('pep_to', pepTo);
    yield MapEntry('signer_name', signerName);
    yield MapEntry('iban', iban);
  }

  void dispose() {
    verifiedMobile.dispose();
    verifiedEmail.dispose();
    for (final e in _allFieldEntries()) {
      e.value.dispose();
    }
  }
}
