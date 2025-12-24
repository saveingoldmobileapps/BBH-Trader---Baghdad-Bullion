import 'dart:convert';

TimeZoneApiModel timeZoneApiModelFromJson(String str) =>
    TimeZoneApiModel.fromJson(json.decode(str));
String timeZoneApiModelToJson(TimeZoneApiModel data) =>
    json.encode(data.toJson());

class TimeZoneApiModel {
  TimeZoneApiModel({
    String? status,
    num? code,
    String? message,
    TimeZoneList? payload,
  }) {
    _status = status;
    _code = code;
    _message = message;
    _payload = payload;
  }

  TimeZoneApiModel.fromJson(dynamic json) {
    _status = json['status'];
    _code = json['code'];
    _message = json['message'];
    _payload =
        json['payload'] != null ? TimeZoneList.fromJson(json['payload']) : null;
  }
  String? _status;
  num? _code;
  String? _message;
  TimeZoneList? _payload;
  TimeZoneApiModel copyWith({
    String? status,
    num? code,
    String? message,
    TimeZoneList? payload,
  }) =>
      TimeZoneApiModel(
        status: status ?? _status,
        code: code ?? _code,
        message: message ?? _message,
        payload: payload ?? _payload,
      );
  String? get status => _status;
  num? get code => _code;
  String? get message => _message;
  TimeZoneList? get payload => _payload;

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

TimeZoneList payloadFromJson(String str) => TimeZoneList.fromJson(json.decode(str));
String payloadToJson(TimeZoneList data) => json.encode(data.toJson());

class TimeZoneList {
  TimeZoneList({
    List<KAllTimezones>? kAllTimezones,
  }) {
    _kAllTimezones = kAllTimezones;
  }

  TimeZoneList.fromJson(dynamic json) {
    if (json['kAllTimezones'] != null) {
      _kAllTimezones = [];
      json['kAllTimezones'].forEach((v) {
        _kAllTimezones?.add(KAllTimezones.fromJson(v));
      });
    }
  }
  List<KAllTimezones>? _kAllTimezones;
  TimeZoneList copyWith({
    List<KAllTimezones>? kAllTimezones,
  }) =>
      TimeZoneList(
        kAllTimezones: kAllTimezones ?? _kAllTimezones,
      );
  List<KAllTimezones>? get kAllTimezones => _kAllTimezones;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (_kAllTimezones != null) {
      map['kAllTimezones'] = _kAllTimezones?.map((v) => v.toJson()).toList();
    }
    return map;
  }
}

KAllTimezones kAllTimezonesFromJson(String str) =>
    KAllTimezones.fromJson(json.decode(str));
String kAllTimezonesToJson(KAllTimezones data) => json.encode(data.toJson());

class KAllTimezones {
  KAllTimezones({
    String? id,
    String? name,
    String? timezone,
  }) {
    _id = id;
    _name = name;
    _timezone = timezone;
  }

  KAllTimezones.fromJson(dynamic json) {
    _id = json['_id'];
    _name = json['name'];
    _timezone = json['timezone'];
  }
  String? _id;
  String? _name;
  String? _timezone;
  KAllTimezones copyWith({
    String? id,
    String? name,
    String? timezone,
  }) =>
      KAllTimezones(
        id: id ?? _id,
        name: name ?? _name,
        timezone: timezone ?? _timezone,
      );
  String? get id => _id;
  String? get name => _name;
  String? get timezone => _timezone;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['_id'] = _id;
    map['name'] = _name;
    map['timezone'] = _timezone;
    return map;
  }
}
