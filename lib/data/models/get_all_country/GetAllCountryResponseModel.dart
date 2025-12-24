import 'dart:convert';
/// status : "success"
/// code : 1
/// message : "OK: The request has succeeded."
/// payload : {"kAllCountries":[{"_id":"681dd829baa7158e123a9755","name":"Botswana","region":"Africa","countryCode":"BW","isCountryEnabled":true,"__v":0,"createdAt":"2025-05-09T10:25:45.248Z","updatedAt":"2025-05-09T10:25:45.248Z"},{"_id":"681dd829baa7158e123a9756","name":"Tonga","region":"Oceania","countryCode":"TO","isCountryEnabled":true,"__v":0,"createdAt":"2025-05-09T10:25:45.248Z","updatedAt":"2025-05-09T10:25:45.248Z"},null]}

GetAllCountryResponseModel getAllCountryResponseModelFromJson(String str) => GetAllCountryResponseModel.fromJson(json.decode(str));
String getAllCountryResponseModelToJson(GetAllCountryResponseModel data) => json.encode(data.toJson());
class GetAllCountryResponseModel {
  GetAllCountryResponseModel({
      String? status, 
      num? code, 
      String? message, 
      Payload? payload,}){
    _status = status;
    _code = code;
    _message = message;
    _payload = payload;
}

  GetAllCountryResponseModel.fromJson(dynamic json) {
    _status = json['status'];
    _code = json['code'];
    _message = json['message'];
    _payload = json['payload'] != null ? Payload.fromJson(json['payload']) : null;
  }
  String? _status;
  num? _code;
  String? _message;
  Payload? _payload;
GetAllCountryResponseModel copyWith({  String? status,
  num? code,
  String? message,
  Payload? payload,
}) => GetAllCountryResponseModel(  status: status ?? _status,
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

/// kAllCountries : [{"_id":"681dd829baa7158e123a9755","name":"Botswana","region":"Africa","countryCode":"BW","isCountryEnabled":true,"__v":0,"createdAt":"2025-05-09T10:25:45.248Z","updatedAt":"2025-05-09T10:25:45.248Z"},{"_id":"681dd829baa7158e123a9756","name":"Tonga","region":"Oceania","countryCode":"TO","isCountryEnabled":true,"__v":0,"createdAt":"2025-05-09T10:25:45.248Z","updatedAt":"2025-05-09T10:25:45.248Z"},null]

Payload payloadFromJson(String str) => Payload.fromJson(json.decode(str));
String payloadToJson(Payload data) => json.encode(data.toJson());
class Payload {
  Payload({
      List<KAllCountries>? kAllCountries,}){
    _kAllCountries = kAllCountries;
}

  // Payload.fromJson(dynamic json) {
  //   if (json['kAllCountries'] != null) {
  //     _kAllCountries = [];
  //     json['kAllCountries'].forEach((v) {
  //       _kAllCountries?.add(KAllCountries.fromJson(v));
  //     });
  //   }
  Payload.fromJson(dynamic json) {
  if (json['kAllCountries'] != null) {
    _kAllCountries = [];
    json['kAllCountries'].forEach((v) {
      if (v != null && v is Map<String, dynamic>) {
        _kAllCountries?.add(KAllCountries.fromJson(v));
      }
    });
  }
}

  List<KAllCountries>? _kAllCountries;
Payload copyWith({  List<KAllCountries>? kAllCountries,
}) => Payload(  kAllCountries: kAllCountries ?? _kAllCountries,
);
  List<KAllCountries>? get kAllCountries => _kAllCountries;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (_kAllCountries != null) {
      map['kAllCountries'] = _kAllCountries?.map((v) => v.toJson()).toList();
    }
    return map;
  }

}

/// _id : "681dd829baa7158e123a9755"
/// name : "Botswana"
/// region : "Africa"
/// countryCode : "BW"
/// isCountryEnabled : true
/// __v : 0
/// createdAt : "2025-05-09T10:25:45.248Z"
/// updatedAt : "2025-05-09T10:25:45.248Z"

KAllCountries kAllCountriesFromJson(String str) => KAllCountries.fromJson(json.decode(str));
String kAllCountriesToJson(KAllCountries data) => json.encode(data.toJson());
class KAllCountries {
  KAllCountries({
      String? id, 
      String? name, 
      String? region, 
      String? countryCode, 
      bool? isCountryEnabled, 
      num? v, 
      String? createdAt, 
      String? updatedAt,}){
    _id = id;
    _name = name;
    _region = region;
    _countryCode = countryCode;
    _isCountryEnabled = isCountryEnabled;
    _v = v;
    _createdAt = createdAt;
    _updatedAt = updatedAt;
}

  KAllCountries.fromJson(dynamic json) {
    _id = json['_id'];
    _name = json['name'];
    _region = json['region'];
    _countryCode = json['countryCode'];
    _isCountryEnabled = json['isCountryEnabled'];
    _v = json['__v'];
    _createdAt = json['createdAt'];
    _updatedAt = json['updatedAt'];
  }
  String? _id;
  String? _name;
  String? _region;
  String? _countryCode;
  bool? _isCountryEnabled;
  num? _v;
  String? _createdAt;
  String? _updatedAt;
KAllCountries copyWith({  String? id,
  String? name,
  String? region,
  String? countryCode,
  bool? isCountryEnabled,
  num? v,
  String? createdAt,
  String? updatedAt,
}) => KAllCountries(  id: id ?? _id,
  name: name ?? _name,
  region: region ?? _region,
  countryCode: countryCode ?? _countryCode,
  isCountryEnabled: isCountryEnabled ?? _isCountryEnabled,
  v: v ?? _v,
  createdAt: createdAt ?? _createdAt,
  updatedAt: updatedAt ?? _updatedAt,
);
  String? get id => _id;
  String? get name => _name;
  String? get region => _region;
  String? get countryCode => _countryCode;
  bool? get isCountryEnabled => _isCountryEnabled;
  num? get v => _v;
  String? get createdAt => _createdAt;
  String? get updatedAt => _updatedAt;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['_id'] = _id;
    map['name'] = _name;
    map['region'] = _region;
    map['countryCode'] = _countryCode;
    map['isCountryEnabled'] = _isCountryEnabled;
    map['__v'] = _v;
    map['createdAt'] = _createdAt;
    map['updatedAt'] = _updatedAt;
    return map;
  }

}