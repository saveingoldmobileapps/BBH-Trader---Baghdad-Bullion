import 'dart:convert';

ShuftiProApiResponseModel shuftiProApiResponseModelFromJson(String str) =>
    ShuftiProApiResponseModel.fromJson(json.decode(str));

String shuftiProApiResponseModelToJson(ShuftiProApiResponseModel data) =>
    json.encode(data.toJson());

class ShuftiProApiResponseModel {
  ShuftiProApiResponseModel({
    String? reference,
    String? country,
    VerificationData? verificationData,
    AdditionalData? additionalData,
    Proofs? proofs,
    VerificationResult? verificationResult,
    String? event,
    Info? info,
  }) {
    _reference = reference;
    _country = country;
    _verificationData = verificationData;
    _additionalData = additionalData;
    _proofs = proofs;
    _verificationResult = verificationResult;
    _event = event;
    _info = info;
  }

  ShuftiProApiResponseModel.fromJson(dynamic json) {
    _reference = json['reference'];
    _country = json['country'];
    _verificationData = json['verification_data'] != null
        ? VerificationData.fromJson(json['verification_data'])
        : null;
    _additionalData = json['additional_data'] != null
        ? AdditionalData.fromJson(json['additional_data'])
        : null;
    _proofs = json['proofs'] != null ? Proofs.fromJson(json['proofs']) : null;
    _verificationResult = json['verification_result'] != null
        ? VerificationResult.fromJson(json['verification_result'])
        : null;
    _event = json['event'];
    _info = json['info'] != null ? Info.fromJson(json['info']) : null;
  }

  String? _reference;
  String? _country;
  VerificationData? _verificationData;
  AdditionalData? _additionalData;
  Proofs? _proofs;
  VerificationResult? _verificationResult;
  String? _event;
  Info? _info;

  ShuftiProApiResponseModel copyWith({
    String? reference,
    String? country,
    VerificationData? verificationData,
    AdditionalData? additionalData,
    Proofs? proofs,
    VerificationResult? verificationResult,
    String? event,
    Info? info,
  }) =>
      ShuftiProApiResponseModel(
        reference: reference ?? _reference,
        country: country ?? _country,
        verificationData: verificationData ?? _verificationData,
        additionalData: additionalData ?? _additionalData,
        proofs: proofs ?? _proofs,
        verificationResult: verificationResult ?? _verificationResult,
        event: event ?? _event,
        info: info ?? _info,
      );

  String? get reference => _reference;
  String? get country => _country;
  VerificationData? get verificationData => _verificationData;
  AdditionalData? get additionalData => _additionalData;
  Proofs? get proofs => _proofs;
  VerificationResult? get verificationResult => _verificationResult;
  String? get event => _event;
  Info? get info => _info;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['reference'] = _reference;
    map['country'] = _country;
    if (_verificationData != null) {
      map['verification_data'] = _verificationData?.toJson();
    }
    if (_additionalData != null) {
      map['additional_data'] = _additionalData?.toJson();
    }
    if (_proofs != null) {
      map['proofs'] = _proofs?.toJson();
    }
    if (_verificationResult != null) {
      map['verification_result'] = _verificationResult?.toJson();
    }
    map['event'] = _event;
    if (_info != null) {
      map['info'] = _info?.toJson();
    }
    return map;
  }
}

// Add the missing AdditionalData class
class AdditionalData {
  AdditionalData({
    DocumentAdditional? document,
  }) {
    _document = document;
  }

  AdditionalData.fromJson(dynamic json) {
    _document = json['document'] != null
        ? DocumentAdditional.fromJson(json['document'])
        : null;
  }

  DocumentAdditional? _document;

  AdditionalData copyWith({
    DocumentAdditional? document,
  }) =>
      AdditionalData(
        document: document ?? _document,
      );

  DocumentAdditional? get document => _document;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (_document != null) {
      map['document'] = _document?.toJson();
    }
    return map;
  }
}

// Add the missing DocumentAdditional class
class DocumentAdditional {
  DocumentAdditional({
    ProofDetails? proof,
    AdditionalProofDetails? additionalProof,
  }) {
    _proof = proof;
    _additionalProof = additionalProof;
  }

  DocumentAdditional.fromJson(dynamic json) {
    _proof = json['proof'] != null ? ProofDetails.fromJson(json['proof']) : null;
    _additionalProof = json['additional_proof'] != null
        ? AdditionalProofDetails.fromJson(json['additional_proof'])
        : null;
  }

  ProofDetails? _proof;
  AdditionalProofDetails? _additionalProof;

  DocumentAdditional copyWith({
    ProofDetails? proof,
    AdditionalProofDetails? additionalProof,
  }) =>
      DocumentAdditional(
        proof: proof ?? _proof,
        additionalProof: additionalProof ?? _additionalProof,
      );

  ProofDetails? get proof => _proof;
  AdditionalProofDetails? get additionalProof => _additionalProof;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (_proof != null) {
      map['proof'] = _proof?.toJson();
    }
    if (_additionalProof != null) {
      map['additional_proof'] = _additionalProof?.toJson();
    }
    return map;
  }
}

// Add the missing ProofDetails class
class ProofDetails {
  ProofDetails({
    String? issueDate,
    String? expiryDate,
    String? dob,
    String? documentNumber,
    String? gender,
    String? country,
    String? countryNative,
    String? countryCode,
    String? nationality,
    String? nationalityNative,
    String? guardianName,
    String? fullName,
    String? fullNameNative,
    String? countryOfStay,
    String? documentOfficialName,
    String? signature,
    String? face,
    String? documentCountry,
    String? documentCountryCode,
  }) {
    _issueDate = issueDate;
    _expiryDate = expiryDate;
    _dob = dob;
    _documentNumber = documentNumber;
    _gender = gender;
    _country = country;
    _countryNative = countryNative;
    _countryCode = countryCode;
    _nationality = nationality;
    _nationalityNative = nationalityNative;
    _guardianName = guardianName;
    _fullName = fullName;
    _fullNameNative = fullNameNative;
    _countryOfStay = countryOfStay;
    _documentOfficialName = documentOfficialName;
    _signature = signature;
    _face = face;
    _documentCountry = documentCountry;
    _documentCountryCode = documentCountryCode;
  }

  ProofDetails.fromJson(dynamic json) {
    _issueDate = json['issue_date'];
    _expiryDate = json['expiry_date'];
    _dob = json['dob'];
    _documentNumber = json['document_number'];
    _gender = json['gender'];
    _country = json['country'];
    _countryNative = json['country_native'];
    _countryCode = json['country_code'];
    _nationality = json['nationality'];
    _nationalityNative = json['nationality_native'];
    _guardianName = json['guardian_name'];
    _fullName = json['full_name'];
    _fullNameNative = json['full_name_native'];
    _countryOfStay = json['country_of_stay'];
    _documentOfficialName = json['document_official_name'];
    _signature = json['signature'];
    _face = json['face'];
    _documentCountry = json['document_country'];
    _documentCountryCode = json['document_country_code'];
  }

  String? _issueDate;
  String? _expiryDate;
  String? _dob;
  String? _documentNumber;
  String? _gender;
  String? _country;
  String? _countryNative;
  String? _countryCode;
  String? _nationality;
  String? _nationalityNative;
  String? _guardianName;
  String? _fullName;
  String? _fullNameNative;
  String? _countryOfStay;
  String? _documentOfficialName;
  String? _signature;
  String? _face;
  String? _documentCountry;
  String? _documentCountryCode;

  ProofDetails copyWith({
    String? issueDate,
    String? expiryDate,
    String? dob,
    String? documentNumber,
    String? gender,
    String? country,
    String? countryNative,
    String? countryCode,
    String? nationality,
    String? nationalityNative,
    String? guardianName,
    String? fullName,
    String? fullNameNative,
    String? countryOfStay,
    String? documentOfficialName,
    String? signature,
    String? face,
    String? documentCountry,
    String? documentCountryCode,
  }) =>
      ProofDetails(
        issueDate: issueDate ?? _issueDate,
        expiryDate: expiryDate ?? _expiryDate,
        dob: dob ?? _dob,
        documentNumber: documentNumber ?? _documentNumber,
        gender: gender ?? _gender,
        country: country ?? _country,
        countryNative: countryNative ?? _countryNative,
        countryCode: countryCode ?? _countryCode,
        nationality: nationality ?? _nationality,
        nationalityNative: nationalityNative ?? _nationalityNative,
        guardianName: guardianName ?? _guardianName,
        fullName: fullName ?? _fullName,
        fullNameNative: fullNameNative ?? _fullNameNative,
        countryOfStay: countryOfStay ?? _countryOfStay,
        documentOfficialName: documentOfficialName ?? _documentOfficialName,
        signature: signature ?? _signature,
        face: face ?? _face,
        documentCountry: documentCountry ?? _documentCountry,
        documentCountryCode: documentCountryCode ?? _documentCountryCode,
      );

  String? get issueDate => _issueDate;
  String? get expiryDate => _expiryDate;
  String? get dob => _dob;
  String? get documentNumber => _documentNumber;
  String? get gender => _gender;
  String? get country => _country;
  String? get countryNative => _countryNative;
  String? get countryCode => _countryCode;
  String? get nationality => _nationality;
  String? get nationalityNative => _nationalityNative;
  String? get guardianName => _guardianName;
  String? get fullName => _fullName;
  String? get fullNameNative => _fullNameNative;
  String? get countryOfStay => _countryOfStay;
  String? get documentOfficialName => _documentOfficialName;
  String? get signature => _signature;
  String? get face => _face;
  String? get documentCountry => _documentCountry;
  String? get documentCountryCode => _documentCountryCode;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['issue_date'] = _issueDate;
    map['expiry_date'] = _expiryDate;
    map['dob'] = _dob;
    map['document_number'] = _documentNumber;
    map['gender'] = _gender;
    map['country'] = _country;
    map['country_native'] = _countryNative;
    map['country_code'] = _countryCode;
    map['nationality'] = _nationality;
    map['nationality_native'] = _nationalityNative;
    map['guardian_name'] = _guardianName;
    map['full_name'] = _fullName;
    map['full_name_native'] = _fullNameNative;
    map['country_of_stay'] = _countryOfStay;
    map['document_official_name'] = _documentOfficialName;
    map['signature'] = _signature;
    map['face'] = _face;
    map['document_country'] = _documentCountry;
    map['document_country_code'] = _documentCountryCode;
    return map;
  }
}

// Add the missing AdditionalProofDetails class
class AdditionalProofDetails {
  AdditionalProofDetails({
    String? documentNumber,
    String? personalNumber,
    String? country,
    String? countryNative,
    String? countryCode,
    String? presentAddress,
    String? permanentAddress,
    String? documentCountryCode,
    String? authoritySignature,
    String? documentOfficialName,
    String? documentCountry,
  }) {
    _documentNumber = documentNumber;
    _personalNumber = personalNumber;
    _country = country;
    _countryNative = countryNative;
    _countryCode = countryCode;
    _presentAddress = presentAddress;
    _permanentAddress = permanentAddress;
    _documentCountryCode = documentCountryCode;
    _authoritySignature = authoritySignature;
    _documentOfficialName = documentOfficialName;
    _documentCountry = documentCountry;
  }

  AdditionalProofDetails.fromJson(dynamic json) {
    _documentNumber = json['document_number'];
    _personalNumber = json['personal_number'];
    _country = json['country'];
    _countryNative = json['country_native'];
    _countryCode = json['country_code'];
    _presentAddress = json['present_address'];
    _permanentAddress = json['permanent_address'];
    _documentCountryCode = json['document_country_code'];
    _authoritySignature = json['authority_signature'];
    _documentOfficialName = json['document_official_name'];
    _documentCountry = json['document_country'];
  }

  String? _documentNumber;
  String? _personalNumber;
  String? _country;
  String? _countryNative;
  String? _countryCode;
  String? _presentAddress;
  String? _permanentAddress;
  String? _documentCountryCode;
  String? _authoritySignature;
  String? _documentOfficialName;
  String? _documentCountry;

  AdditionalProofDetails copyWith({
    String? documentNumber,
    String? personalNumber,
    String? country,
    String? countryNative,
    String? countryCode,
    String? presentAddress,
    String? permanentAddress,
    String? documentCountryCode,
    String? authoritySignature,
    String? documentOfficialName,
    String? documentCountry,
  }) =>
      AdditionalProofDetails(
        documentNumber: documentNumber ?? _documentNumber,
        personalNumber: personalNumber ?? _personalNumber,
        country: country ?? _country,
        countryNative: countryNative ?? _countryNative,
        countryCode: countryCode ?? _countryCode,
        presentAddress: presentAddress ?? _presentAddress,
        permanentAddress: permanentAddress ?? _permanentAddress,
        documentCountryCode: documentCountryCode ?? _documentCountryCode,
        authoritySignature: authoritySignature ?? _authoritySignature,
        documentOfficialName: documentOfficialName ?? _documentOfficialName,
        documentCountry: documentCountry ?? _documentCountry,
      );

  String? get documentNumber => _documentNumber;
  String? get personalNumber => _personalNumber;
  String? get country => _country;
  String? get countryNative => _countryNative;
  String? get countryCode => _countryCode;
  String? get presentAddress => _presentAddress;
  String? get permanentAddress => _permanentAddress;
  String? get documentCountryCode => _documentCountryCode;
  String? get authoritySignature => _authoritySignature;
  String? get documentOfficialName => _documentOfficialName;
  String? get documentCountry => _documentCountry;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['document_number'] = _documentNumber;
    map['personal_number'] = _personalNumber;
    map['country'] = _country;
    map['country_native'] = _countryNative;
    map['country_code'] = _countryCode;
    map['present_address'] = _presentAddress;
    map['permanent_address'] = _permanentAddress;
    map['document_country_code'] = _documentCountryCode;
    map['authority_signature'] = _authoritySignature;
    map['document_official_name'] = _documentOfficialName;
    map['document_country'] = _documentCountry;
    return map;
  }
}

// Update VerificationData to include questionnaire
class VerificationData {
  VerificationData({
    DocumentData? document,
    List<Questionnaire>? questionnaire,
  }) {
    _document = document;
    _questionnaire = questionnaire;
  }

  VerificationData.fromJson(dynamic json) {
    _document = json['document'] != null
        ? DocumentData.fromJson(json['document'])
        : null;
    if (json['questionnaire'] != null) {
      _questionnaire = [];
      json['questionnaire'].forEach((v) {
        _questionnaire?.add(Questionnaire.fromJson(v));
      });
    }
  }

  DocumentData? _document;
  List<Questionnaire>? _questionnaire;

  VerificationData copyWith({
    DocumentData? document,
    List<Questionnaire>? questionnaire,
  }) =>
      VerificationData(
        document: document ?? _document,
        questionnaire: questionnaire ?? _questionnaire,
      );

  DocumentData? get document => _document;
  List<Questionnaire>? get questionnaire => _questionnaire;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (_document != null) {
      map['document'] = _document?.toJson();
    }
    if (_questionnaire != null) {
      map['questionnaire'] = _questionnaire?.map((v) => v.toJson()).toList();
    }
    return map;
  }
}

// Add the missing Questionnaire class
class Questionnaire {
  Questionnaire({
    String? title,
    String? page,
    List<Questions>? questions,
  }) {
    _title = title;
    _page = page;
    _questions = questions;
  }

  Questionnaire.fromJson(dynamic json) {
    _title = json['title'];
    _page = json['page'];
    if (json['questions'] != null) {
      _questions = [];
      json['questions'].forEach((v) {
        _questions?.add(Questions.fromJson(v));
      });
    }
  }

  String? _title;
  String? _page;
  List<Questions>? _questions;

  Questionnaire copyWith({
    String? title,
    String? page,
    List<Questions>? questions,
  }) =>
      Questionnaire(
        title: title ?? _title,
        page: page ?? _page,
        questions: questions ?? _questions,
      );

  String? get title => _title;
  String? get page => _page;
  List<Questions>? get questions => _questions;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['title'] = _title;
    map['page'] = _page;
    if (_questions != null) {
      map['questions'] = _questions?.map((v) => v.toJson()).toList();
    }
    return map;
  }
}

// Add the missing Questions class
class Questions {
  Questions({
    String? question,
    String? type,
    String? answer,
  }) {
    _question = question;
    _type = type;
    _answer = answer;
  }

  Questions.fromJson(dynamic json) {
    _question = json['question'];
    _type = json['type'];
    _answer = json['answer'];
  }

  String? _question;
  String? _type;
  String? _answer;

  Questions copyWith({
    String? question,
    String? type,
    String? answer,
  }) =>
      Questions(
        question: question ?? _question,
        type: type ?? _type,
        answer: answer ?? _answer,
      );

  String? get question => _question;
  String? get type => _type;
  String? get answer => _answer;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['question'] = _question;
    map['type'] = _type;
    map['answer'] = _answer;
    return map;
  }
}

// Update DocumentResult to include missing fields
class DocumentResult {
  DocumentResult({
    num? document,
    num? documentVisibility,
    num? documentMustNotBeExpired,
    num? documentProof,
    num? selectedType,
    num? documentCountry,
    num? faceOnDocumentMatched,
    num? documentNumber,
    num? gender,
    num? expiryDate,
    num? issueDate,
    num? dob,
    num? name,
  }) {
    _document = document;
    _documentVisibility = documentVisibility;
    _documentMustNotBeExpired = documentMustNotBeExpired;
    _documentProof = documentProof;
    _selectedType = selectedType;
    _documentCountry = documentCountry;
    _faceOnDocumentMatched = faceOnDocumentMatched;
    _documentNumber = documentNumber;
    _issueDate = issueDate;
    _gender = gender;
    _dob = dob;
    _expiryDate = expiryDate;
    _name = name;
  }

  DocumentResult.fromJson(dynamic json) {
    _document = json['document'];
    _documentVisibility = json['document_visibility'];
    _documentMustNotBeExpired = json['document_must_not_be_expired'];
    _documentProof = json['document_proof'];
    _selectedType = json['selected_type'];
    _documentCountry = json['document_country'];
    _faceOnDocumentMatched = json['face_on_document_matched'];
    _documentNumber = json['document_number'];
    _issueDate = json['issue_date'];
    _gender = json['gender'];
    _dob = json['dob'];
    _expiryDate = json['expiry_date'];
    _name = json['name'];
  }

  num? _document;
  num? _documentVisibility;
  num? _documentMustNotBeExpired;
  num? _documentProof;
  num? _selectedType;
  num? _documentCountry;
  num? _faceOnDocumentMatched;
  num? _documentNumber;
  num? _issueDate;
  num? _gender;
  num? _dob;
  num? _expiryDate;
  num? _name;

  DocumentResult copyWith({
    num? document,
    num? documentVisibility,
    num? documentMustNotBeExpired,
    num? documentProof,
    num? selectedType,
    num? documentCountry,
    num? faceOnDocumentMatched,
    num? documentNumber,
    num? issueDate,
    num? gender,
    num? dob,
    num? expiryDate,
    num? name,
  }) =>
      DocumentResult(
        document: document ?? _document,
        documentVisibility: documentVisibility ?? _documentVisibility,
        documentMustNotBeExpired:
            documentMustNotBeExpired ?? _documentMustNotBeExpired,
        documentProof: documentProof ?? _documentProof,
        selectedType: selectedType ?? _selectedType,
        documentCountry: documentCountry ?? _documentCountry,
        faceOnDocumentMatched: faceOnDocumentMatched ?? _faceOnDocumentMatched,
        documentNumber: documentNumber ?? _documentNumber,
        issueDate: issueDate ?? _issueDate,
        gender: gender ?? _gender,
        dob: dob ?? _dob,
        expiryDate: expiryDate ?? _expiryDate,
        name: name ?? _name,
      );

  num? get document => _document;
  num? get documentVisibility => _documentVisibility;
  num? get documentMustNotBeExpired => _documentMustNotBeExpired;
  num? get documentProof => _documentProof;
  num? get selectedType => _selectedType;
  num? get documentCountry => _documentCountry;
  num? get faceOnDocumentMatched => _faceOnDocumentMatched;
  num? get documentNumber => _documentNumber;
  num? get issueDate => _issueDate;
  num? get gender => _gender;
  num? get dob => _dob;
  num? get expiryDate => _expiryDate;
  num? get name => _name;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['document'] = _document;
    map['document_visibility'] = _documentVisibility;
    map['document_must_not_be_expired'] = _documentMustNotBeExpired;
    map['document_proof'] = _documentProof;
    map['selected_type'] = _selectedType;
    map['document_country'] = _documentCountry;
    map['face_on_document_matched'] = _faceOnDocumentMatched;
    map['document_number'] = _documentNumber;
    map['issue_date'] = _issueDate;
    map['gender'] = _gender;
    map['dob'] = _dob;
    map['expiry_date'] = _expiryDate;
    map['name'] = _name;
    return map;
  }
}

// Update VerificationResult to include questionnaire
class VerificationResult {
  VerificationResult({
    num? face,
    DocumentResult? document,
    num? questionnaire,
  }) {
    _face = face;
    _document = document;
    _questionnaire = questionnaire;
  }

  VerificationResult.fromJson(dynamic json) {
    _face = json['face'];
    _document = json['document'] != null
        ? DocumentResult.fromJson(json['document'])
        : null;
    _questionnaire = json['questionnaire'];
  }

  num? _face;
  DocumentResult? _document;
  num? _questionnaire;

  VerificationResult copyWith({
    num? face,
    DocumentResult? document,
    num? questionnaire,
  }) =>
      VerificationResult(
        face: face ?? _face,
        document: document ?? _document,
        questionnaire: questionnaire ?? _questionnaire,
      );

  num? get face => _face;
  DocumentResult? get document => _document;
  num? get questionnaire => _questionnaire;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['face'] = _face;
    if (_document != null) {
      map['document'] = _document?.toJson();
    }
    map['questionnaire'] = _questionnaire;
    return map;
  }
}

// The rest of your existing classes remain the same...
class Info {
  Info({
    Agent? agent,
    Geolocation? geolocation,
  }) {
    _agent = agent;
    _geolocation = geolocation;
  }

  Info.fromJson(dynamic json) {
    _agent = json['agent'] != null ? Agent.fromJson(json['agent']) : null;
    _geolocation = json['geolocation'] != null
        ? Geolocation.fromJson(json['geolocation'])
        : null;
  }

  Agent? _agent;
  Geolocation? _geolocation;

  Info copyWith({
    Agent? agent,
    Geolocation? geolocation,
  }) =>
      Info(
        agent: agent ?? _agent,
        geolocation: geolocation ?? _geolocation,
      );

  Agent? get agent => _agent;
  Geolocation? get geolocation => _geolocation;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (_agent != null) {
      map['agent'] = _agent?.toJson();
    }
    if (_geolocation != null) {
      map['geolocation'] = _geolocation?.toJson();
    }
    return map;
  }
}

class Geolocation {
  Geolocation({
    String? host,
    String? ip,
    String? rdns,
    String? asn,
    String? isp,
    String? countryName,
    String? countryCode,
    String? regionName,
    String? regionCode,
    String? city,
    String? postalCode,
    String? continentName,
    String? continentCode,
    String? latitude,
    String? longitude,
    String? metroCode,
    String? timezone,
    String? ipType,
    String? capital,
    String? currency,
  }) {
    _host = host;
    _ip = ip;
    _rdns = rdns;
    _asn = asn;
    _isp = isp;
    _countryName = countryName;
    _countryCode = countryCode;
    _regionName = regionName;
    _regionCode = regionCode;
    _city = city;
    _postalCode = postalCode;
    _continentName = continentName;
    _continentCode = continentCode;
    _latitude = latitude;
    _longitude = longitude;
    _metroCode = metroCode;
    _timezone = timezone;
    _ipType = ipType;
    _capital = capital;
    _currency = currency;
  }

  Geolocation.fromJson(dynamic json) {
    _host = json['host'];
    _ip = json['ip'];
    _rdns = json['rdns'];
    _asn = json['asn'];
    _isp = json['isp'];
    _countryName = json['country_name'];
    _countryCode = json['country_code'];
    _regionName = json['region_name'];
    _regionCode = json['region_code'];
    _city = json['city'];
    _postalCode = json['postal_code'];
    _continentName = json['continent_name'];
    _continentCode = json['continent_code'];
    _latitude = json['latitude'];
    _longitude = json['longitude'];
    _metroCode = json['metro_code'];
    _timezone = json['timezone'];
    _ipType = json['ip_type'];
    _capital = json['capital'];
    _currency = json['currency'];
  }

  String? _host;
  String? _ip;
  String? _rdns;
  String? _asn;
  String? _isp;
  String? _countryName;
  String? _countryCode;
  String? _regionName;
  String? _regionCode;
  String? _city;
  String? _postalCode;
  String? _continentName;
  String? _continentCode;
  String? _latitude;
  String? _longitude;
  String? _metroCode;
  String? _timezone;
  String? _ipType;
  String? _capital;
  String? _currency;

  Geolocation copyWith({
    String? host,
    String? ip,
    String? rdns,
    String? asn,
    String? isp,
    String? countryName,
    String? countryCode,
    String? regionName,
    String? regionCode,
    String? city,
    String? postalCode,
    String? continentName,
    String? continentCode,
    String? latitude,
    String? longitude,
    String? metroCode,
    String? timezone,
    String? ipType,
    String? capital,
    String? currency,
  }) =>
      Geolocation(
        host: host ?? _host,
        ip: ip ?? _ip,
        rdns: rdns ?? _rdns,
        asn: asn ?? _asn,
        isp: isp ?? _isp,
        countryName: countryName ?? _countryName,
        countryCode: countryCode ?? _countryCode,
        regionName: regionName ?? _regionName,
        regionCode: regionCode ?? _regionCode,
        city: city ?? _city,
        postalCode: postalCode ?? _postalCode,
        continentName: continentName ?? _continentName,
        continentCode: continentCode ?? _continentCode,
        latitude: latitude ?? _latitude,
        longitude: longitude ?? _longitude,
        metroCode: metroCode ?? _metroCode,
        timezone: timezone ?? _timezone,
        ipType: ipType ?? _ipType,
        capital: capital ?? _capital,
        currency: currency ?? _currency,
      );

  String? get host => _host;
  String? get ip => _ip;
  String? get rdns => _rdns;
  String? get asn => _asn;
  String? get isp => _isp;
  String? get countryName => _countryName;
  String? get countryCode => _countryCode;
  String? get regionName => _regionName;
  String? get regionCode => _regionCode;
  String? get city => _city;
  String? get postalCode => _postalCode;
  String? get continentName => _continentName;
  String? get continentCode => _continentCode;
  String? get latitude => _latitude;
  String? get longitude => _longitude;
  String? get metroCode => _metroCode;
  String? get timezone => _timezone;
  String? get ipType => _ipType;
  String? get capital => _capital;
  String? get currency => _currency;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['host'] = _host;
    map['ip'] = _ip;
    map['rdns'] = _rdns;
    map['asn'] = _asn;
    map['isp'] = _isp;
    map['country_name'] = _countryName;
    map['country_code'] = _countryCode;
    map['region_name'] = _regionName;
    map['region_code'] = _regionCode;
    map['city'] = _city;
    map['postal_code'] = _postalCode;
    map['continent_name'] = _continentName;
    map['continent_code'] = _continentCode;
    map['latitude'] = _latitude;
    map['longitude'] = _longitude;
    map['metro_code'] = _metroCode;
    map['timezone'] = _timezone;
    map['ip_type'] = _ipType;
    map['capital'] = _capital;
    map['currency'] = _currency;
    return map;
  }
}

class Agent {
  Agent({
    bool? isDesktop,
    bool? isPhone,
    String? useragent,
    String? deviceName,
    String? browserName,
    String? platformName,
  }) {
    _isDesktop = isDesktop;
    _isPhone = isPhone;
    _useragent = useragent;
    _deviceName = deviceName;
    _browserName = browserName;
    _platformName = platformName;
  }

  Agent.fromJson(dynamic json) {
    _isDesktop = json['is_desktop'];
    _isPhone = json['is_phone'];
    _useragent = json['useragent'];
    _deviceName = json['device_name'];
    _browserName = json['browser_name'];
    _platformName = json['platform_name'];
  }

  bool? _isDesktop;
  bool? _isPhone;
  String? _useragent;
  String? _deviceName;
  String? _browserName;
  String? _platformName;

  Agent copyWith({
    bool? isDesktop,
    bool? isPhone,
    String? useragent,
    String? deviceName,
    String? browserName,
    String? platformName,
  }) =>
      Agent(
        isDesktop: isDesktop ?? _isDesktop,
        isPhone: isPhone ?? _isPhone,
        useragent: useragent ?? _useragent,
        deviceName: deviceName ?? _deviceName,
        browserName: browserName ?? _browserName,
        platformName: platformName ?? _platformName,
      );

  bool? get isDesktop => _isDesktop;
  bool? get isPhone => _isPhone;
  String? get useragent => _useragent;
  String? get deviceName => _deviceName;
  String? get browserName => _browserName;
  String? get platformName => _platformName;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['is_desktop'] = _isDesktop;
    map['is_phone'] = _isPhone;
    map['useragent'] = _useragent;
    map['device_name'] = _deviceName;
    map['browser_name'] = _browserName;
    map['platform_name'] = _platformName;
    return map;
  }
}

class Proofs {
  Proofs({
    DocumentProof? document,
    String? accessToken,
    Face? face,
    String? verificationReport,
  }) {
    _document = document;
    _accessToken = accessToken;
    _face = face;
    _verificationReport = verificationReport;
  }

  Proofs.fromJson(dynamic json) {
    _document = json['document'] != null
        ? DocumentProof.fromJson(json['document'])
        : null;
    _accessToken = json['access_token'];
    _face = json['face'] != null ? Face.fromJson(json['face']) : null;
    _verificationReport = json['verification_report'];
  }

  DocumentProof? _document;
  String? _accessToken;
  Face? _face;
  String? _verificationReport;

  Proofs copyWith({
    DocumentProof? document,
    String? accessToken,
    Face? face,
    String? verificationReport,
  }) =>
      Proofs(
        document: document ?? _document,
        accessToken: accessToken ?? _accessToken,
        face: face ?? _face,
        verificationReport: verificationReport ?? _verificationReport,
      );

  DocumentProof? get document => _document;
  String? get accessToken => _accessToken;
  Face? get face => _face;
  String? get verificationReport => _verificationReport;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (_document != null) {
      map['document'] = _document?.toJson();
    }
    map['access_token'] = _accessToken;
    if (_face != null) {
      map['face'] = _face?.toJson();
    }
    map['verification_report'] = _verificationReport;
    return map;
  }
}

class Face {
  Face({
    String? proof,
  }) {
    _proof = proof;
  }

  Face.fromJson(dynamic json) {
    _proof = json['proof'];
  }

  String? _proof;

  Face copyWith({
    String? proof,
  }) =>
      Face(
        proof: proof ?? _proof,
      );

  String? get proof => _proof;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['proof'] = _proof;
    return map;
  }
}

class DocumentProof {
  DocumentProof({
    String? proof,
    String? additionalProof,
  }) {
    _proof = proof;
    _additionalProof = additionalProof;
  }

  DocumentProof.fromJson(dynamic json) {
    _proof = json['proof'];
    _additionalProof = json['additional_proof'];
  }

  String? _proof;
  String? _additionalProof;

  DocumentProof copyWith({
    String? proof,
    String? additionalProof,
  }) =>
      DocumentProof(
        proof: proof ?? _proof,
        additionalProof: additionalProof ?? _additionalProof,
      );

  String? get proof => _proof;
  String? get additionalProof => _additionalProof;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['proof'] = _proof;
    map['additional_proof'] = _additionalProof;
    return map;
  }
}

class DocumentData {
  DocumentData({
    Name? name,
    String? dob,
    String? expiryDate,
    String? issueDate,
    String? documentNumber,
    String? gender,
    String? country,
    List<String>? selectedType,
    List<String>? supportedTypes,
    num? faceMatchConfidence,
  }) {
    _name = name;
    _dob = dob;
    _expiryDate = expiryDate;
    _issueDate = issueDate;
    _documentNumber = documentNumber;
    _gender = gender;
    _country = country;
    _selectedType = selectedType;
    _supportedTypes = supportedTypes;
    _faceMatchConfidence = faceMatchConfidence;
  }

  DocumentData.fromJson(dynamic json) {
    _name = json['name'] != null ? Name.fromJson(json['name']) : null;
    _dob = json['dob'];
    _expiryDate = json['expiry_date'];
    _issueDate = json['issue_date'];
    _documentNumber = json['document_number'];
    _gender = json['gender'];
    _country = json['country'];
    _selectedType = json['selected_type'] != null
        ? json['selected_type'].cast<String>()
        : [];
    _supportedTypes = json['supported_types'] != null
        ? json['supported_types'].cast<String>()
        : [];
    _faceMatchConfidence = json['face_match_confidence'];
  }

  Name? _name;
  String? _dob;
  String? _expiryDate;
  String? _issueDate;
  String? _documentNumber;
  String? _gender;
  String? _country;
  List<String>? _selectedType;
  List<String>? _supportedTypes;
  num? _faceMatchConfidence;

  DocumentData copyWith({
    Name? name,
    String? dob,
    String? expiryDate,
    String? issueDate,
    String? documentNumber,
    String? gender,
    String? country,
    List<String>? selectedType,
    List<String>? supportedTypes,
    num? faceMatchConfidence,
  }) =>
      DocumentData(
        name: name ?? _name,
        dob: dob ?? _dob,
        expiryDate: expiryDate ?? _expiryDate,
        issueDate: issueDate ?? _issueDate,
        documentNumber: documentNumber ?? _documentNumber,
        gender: gender ?? _gender,
        country: country ?? _country,
        selectedType: selectedType ?? _selectedType,
        supportedTypes: supportedTypes ?? _supportedTypes,
        faceMatchConfidence: faceMatchConfidence ?? _faceMatchConfidence,
      );

  Name? get name => _name;
  String? get dob => _dob;
  String? get expiryDate => _expiryDate;
  String? get issueDate => _issueDate;
  String? get documentNumber => _documentNumber;
  String? get gender => _gender;
  String? get country => _country;
  List<String>? get selectedType => _selectedType;
  List<String>? get supportedTypes => _supportedTypes;
  num? get faceMatchConfidence => _faceMatchConfidence;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (_name != null) {
      map['name'] = _name?.toJson();
    }
    map['dob'] = _dob;
    map['expiry_date'] = _expiryDate;
    map['issue_date'] = _issueDate;
    map['document_number'] = _documentNumber;
    map['gender'] = _gender;
    map['country'] = _country;
    map['selected_type'] = _selectedType;
    map['supported_types'] = _supportedTypes;
    map['face_match_confidence'] = _faceMatchConfidence;
    return map;
  }
}

class Name {
  Name({
    String? fullName,
  }) {
    _fullName = fullName;
  }

  Name.fromJson(dynamic json) {
    _fullName = json['full_name'];
  }

  String? _fullName;

  Name copyWith({
    String? fullName,
  }) =>
      Name(
        fullName: fullName ?? _fullName,
      );

  String? get fullName => _fullName;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['full_name'] = _fullName;
    return map;
  }
}