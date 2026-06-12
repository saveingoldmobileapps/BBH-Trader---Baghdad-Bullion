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

  final mobile = TextEditingController();
  final email = TextEditingController();
  final arFirst = TextEditingController();
  final arFather = TextEditingController();
  final arGf = TextEditingController();
  final arSurname = TextEditingController();
  final arMother = TextEditingController();
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
        'ar_surname' => arSurname,
        'ar_mother' => arMother,
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
        _ => null,
      };

  /// Full onboarding pack for backend — keys match HTML `data-field` / `formData`.
  Map<String, dynamic> buildSubmissionPayload({
    required String kycReference,
    required DateTime submittedAt,
    Map<String, dynamic>? ipassVerification,
  }) {
    String? trimmed(TextEditingController c) {
      final t = c.text.trim();
      return t.isEmpty ? null : t;
    }

    return {
      'flow': 'bbh_native_onboarding',
      'version': '1.0',
      'kyc': kycReference,
      'submitted_at': submittedAt.toIso8601String(),
      'fatca': fatca,
      'pep': pep,
      'foreign_res': foreignRes,
      'foreign_cit': foreignCit,
      'no_passport': noPassport,
      'custodian': custodian,
      'gender': gender,
      'education': education,
      'sector': sector,
      'mobile': trimmed(mobile),
      'email': trimmed(email),
      'ar_first': trimmed(arFirst),
      'ar_father': trimmed(arFather),
      'ar_gf': trimmed(arGf),
      'ar_surname': trimmed(arSurname),
      'ar_mother': trimmed(arMother),
      'en_first': trimmed(enFirst),
      'en_father': trimmed(enFather),
      'en_gf': trimmed(enGf),
      'en_surname': trimmed(enSurname),
      'en_mother': trimmed(enMother),
      'nationality': trimmed(nationality),
      'dob': trimmed(dob),
      'country_birth': trimmed(countryBirth),
      'place_birth': trimmed(placeBirth),
      'id_personal': trimmed(idPersonal),
      'id_serial': trimmed(idSerial),
      'id_issue_place': trimmed(idIssuePlace),
      'id_issue_date': trimmed(idIssueDate),
      'id_expiry_date': trimmed(idExpiryDate),
      'pp_no': trimmed(ppNo),
      'pp_place': trimmed(ppPlace),
      'pp_issue': trimmed(ppIssue),
      'pp_expiry': trimmed(ppExpiry),
      'res_no': trimmed(resNo),
      'res_place': trimmed(resPlace),
      'res_issue': trimmed(resIssue),
      'res_expiry': trimmed(resExpiry),
      'addr_gov': trimmed(addrGov),
      'addr_district': trimmed(addrDistrict),
      'addr_city': trimmed(addrCity),
      'addr_mahalla': trimmed(addrMahalla),
      'addr_street': trimmed(addrStreet),
      'addr_house': trimmed(addrHouse),
      'addr_landmark_ar': trimmed(addrLandmarkAr),
      'addr_landmark_en': trimmed(addrLandmarkEn),
      'foreign_res_country': trimmed(foreignResCountry),
      'foreign_cit_country': trimmed(foreignCitCountry),
      'income': trimmed(income),
      'occupation': trimmed(occupation),
      'employer': trimmed(employer),
      'employer_addr': trimmed(employerAddr),
      'fatca_tin': trimmed(fatcaTin),
      'fatca_addr': trimmed(fatcaAddr),
      'pep_position': trimmed(pepPosition),
      'pep_country': trimmed(pepCountry),
      'pep_from': trimmed(pepFrom),
      'pep_to': trimmed(pepTo),
      'signer_name': trimmed(signerName),
      'signature': ?signature,
      'confirms': {
        'purpose': purposeConfirmed,
        'consent': consentConfirmed,
      },
      'verified': {
        'mobile': verifiedMobile.value,
        'email': verifiedEmail.value,
      },
      'documents': {
        'id_front': idFrontCaptured,
        'id_back': idBackCaptured,
        'res_front': resFrontCaptured,
        'res_back': resBackCaptured,
        'passport': passportCaptured,
        'foreign_res': foreignResCaptured,
        'foreign_cit': foreignCitCaptured,
      },
      'verified_fields': verifiedFields.toList(),
      if (ipassVerification != null) 'ipass_verification': ipassVerification,
    };
  }

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
    yield MapEntry('ar_surname', arSurname);
    yield MapEntry('ar_mother', arMother);
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
  }

  void dispose() {
    verifiedMobile.dispose();
    verifiedEmail.dispose();
    for (final e in _allFieldEntries()) {
      e.value.dispose();
    }
  }
}
