import 'dart:convert';

SubmitKycError submitKycErrorFromJson(String str) => SubmitKycError.fromJson(json.decode(str));
String submitKycErrorToJson(SubmitKycError data) => json.encode(data.toJson());

class SubmitKycError {
  SubmitKycError({
    String? status,
    num? code,
    String? message,
    Payload? payload,
  }) {
    _status = status;
    _code = code;
    _message = message;
    _payload = payload;
  }

  SubmitKycError.fromJson(dynamic json) {
    _status = json['status'];
    _code = json['code'];
    _message = json['message'];
    _payload = json['payload'] != null ? Payload.fromJson(json['payload']) : null;
  }

  String? _status;
  num? _code;
  String? _message;
  Payload? _payload;

  SubmitKycError copyWith({
    String? status,
    num? code,
    String? message,
    Payload? payload,
  }) =>
      SubmitKycError(
        status: status ?? _status,
        code: code ?? _code,
        message: message ?? _message,
        payload: payload ?? _payload,
      );

  String? get status => _status;
  num? get code => _code;
  String? get message => _message;
  Payload? get payload => _payload;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['status'] = _status;
    map['code'] = _code;
    map['message'] = _message;
    if (_payload != null) {
      map['payload'] = _payload?.toJson();
    }
    return map;
  }
}

Payload payloadFromJson(String str) => Payload.fromJson(json.decode(str));
String payloadToJson(Payload data) => json.encode(data.toJson());

class Payload {
  Payload({
    String? nameFromKYC,
    String? nativeNameFromKYC, // new field
    String? nameFromDB,
    String? dobFromKYC,
    String? dobFromDB,
    String? countryFromKYC,
    String? residencyFromKYC,       // NEW
    String? residencyFromDB,
    String? nationalityFromKYC,    // NEW
    String? nationalityFromDB,     // NEW
    String? countryFromDB,
    String? validStatus,
  }) {
    _nameFromKYC = nameFromKYC;
    _nativeNameFromKYC = nativeNameFromKYC;
    _nameFromDB = nameFromDB;
    _dobFromKYC = dobFromKYC;
    _dobFromDB = dobFromDB;
    _countryFromKYC = countryFromKYC;
    _residencyFromKYC = residencyFromKYC;     // NEW
    _residencyFromDB = residencyFromDB;
    _nationalityFromKYC = nationalityFromKYC; // NEW
    _nationalityFromDB = nationalityFromDB;   // NEW
    _countryFromDB = countryFromDB;
    _validStatus = validStatus;
  }

  Payload.fromJson(dynamic json) {
    _nameFromKYC = json['nameFromKYC'];
    _nativeNameFromKYC = json['nativeNameFromKYC'];
    _nameFromDB = json['nameFromDB'];
    _dobFromKYC = json['dobFromKYC'];
    _dobFromDB = json['dobFromDB'];
    _countryFromKYC = json['countryFromKYC'];

    _residencyFromKYC = json['residencyFromKYC'];       // NEW
    _residencyFromDB = json['residencyFromDB'];

    _nationalityFromKYC = json['nationalityFromKYC'];   // NEW
    _nationalityFromDB = json['nationalityFromDB'];     // NEW

    _countryFromDB = json['countryFromDB'];
    _validStatus = json['status'];
  }

  String? _nameFromKYC;
  String? _nativeNameFromKYC;
  String? _nameFromDB;
  String? _dobFromKYC;
  String? _dobFromDB;
  String? _countryFromKYC;

  String? _residencyFromKYC;       // NEW
  String? _residencyFromDB;

  String? _nationalityFromKYC;     // NEW
  String? _nationalityFromDB;      // NEW

  String? _countryFromDB;
  String? _validStatus;

  Payload copyWith({
    String? nameFromKYC,
    String? nativeNameFromKYC, // new field
    String? nameFromDB,
    String? dobFromKYC,
    String? dobFromDB,
    String? countryFromKYC,
    String? residencyFromKYC,
    String? residencyFromDB,
    String? nationalityFromKYC,
    String? nationalityFromDB,
    String? countryFromDB,
    String? validStatus,
  }) =>
      Payload(
        nameFromKYC: nameFromKYC ?? _nameFromKYC,
        nativeNameFromKYC: nativeNameFromKYC ?? _nativeNameFromKYC,
        nameFromDB: nameFromDB ?? _nameFromDB,
        dobFromKYC: dobFromKYC ?? _dobFromKYC,
        dobFromDB: dobFromDB ?? _dobFromDB,
        countryFromKYC: countryFromKYC ?? _countryFromKYC,

        residencyFromKYC: residencyFromKYC ?? _residencyFromKYC,
        residencyFromDB: residencyFromDB ?? _residencyFromDB,

        nationalityFromKYC: nationalityFromKYC ?? _nationalityFromKYC,
        nationalityFromDB: nationalityFromDB ?? _nationalityFromDB,

        countryFromDB: countryFromDB ?? _countryFromDB,
        validStatus: validStatus ?? _validStatus,
      );

  String? get nameFromKYC => _nameFromKYC;
  String? get nativeNameFromKYC => _nativeNameFromKYC;
  String? get nameFromDB => _nameFromDB;
  String? get dobFromKYC => _dobFromKYC;
  String? get dobFromDB => _dobFromDB;
  String? get countryFromKYC => _countryFromKYC;

  String? get residencyFromKYC => _residencyFromKYC;       // NEW
  String? get residencyFromDB => _residencyFromDB;

  String? get nationalityFromKYC => _nationalityFromKYC;   // NEW
  String? get nationalityFromDB => _nationalityFromDB;     // NEW

  String? get countryFromDB => _countryFromDB;
  String? get validStatus => _validStatus;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};

    map['nameFromKYC'] = _nameFromKYC;
    map['nativeNameFromKYC'] = _nativeNameFromKYC;
    map['nameFromDB'] = _nameFromDB;
    map['dobFromKYC'] = _dobFromKYC;
    map['dobFromDB'] = _dobFromDB;
    map['countryFromKYC'] = _countryFromKYC;

    map['residencyFromKYC'] = _residencyFromKYC;       // NEW
    map['residencyFromDB'] = _residencyFromDB;

    map['nationalityFromKYC'] = _nationalityFromKYC;   // NEW
    map['nationalityFromDB'] = _nationalityFromDB;     // NEW

    map['countryFromDB'] = _countryFromDB;
    map['status'] = _validStatus;

    return map;
  }
}
