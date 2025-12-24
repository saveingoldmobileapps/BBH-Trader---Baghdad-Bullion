import 'dart:convert';

/// status : "success"
/// code : 1
/// message : "OK: The request has succeeded."
/// payload : [{"_id":"68debc9af80342db3bf28f9d","userId":"68d4f6cb1725c465fb275c0e","script":"1 Gram Price","alertType":"Buy","condition":"Below","price":254.55,"createdAt":"2025-10-02T17:55:38.174Z","updatedAt":"2025-10-02T17:55:38.174Z","__v":0}]

AlertModelResponse alertModelResponseFromJson(String str) =>
    AlertModelResponse.fromJson(json.decode(str));
String alertModelResponseToJson(AlertModelResponse data) =>
    json.encode(data.toJson());

class AlertModelResponse {
  AlertModelResponse({
    String? status,
    num? code,
    String? message,
    List<AlertListData>? payload,
  }) {
    _status = status;
    _code = code;
    _message = message;
    _payload = payload;
  }

  AlertModelResponse.fromJson(dynamic json) {
    _status = json['status'];
    _code = json['code'];
    _message = json['message'];
    if (json['payload'] != null) {
      _payload = [];
      json['payload'].forEach((v) {
        _payload?.add(AlertListData.fromJson(v));
      });
    }
  }
  String? _status;
  num? _code;
  String? _message;
  List<AlertListData>? _payload;
  AlertModelResponse copyWith({
    String? status,
    num? code,
    String? message,
    List<AlertListData>? payload,
  }) =>
      AlertModelResponse(
        status: status ?? _status,
        code: code ?? _code,
        message: message ?? _message,
        payload: payload ?? _payload,
      );
  String? get status => _status;
  num? get code => _code;
  String? get message => _message;
  List<AlertListData>? get payload => _payload;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['status'] = _status;
    map['code'] = _code;
    map['message'] = _message;
    if (_payload != null) {
      map['payload'] = _payload?.map((v) => v.toJson()).toList();
    }
    return map;
  }
}

/// _id : "68debc9af80342db3bf28f9d"
/// userId : "68d4f6cb1725c465fb275c0e"
/// script : "1 Gram Price"
/// alertType : "Buy"
/// condition : "Below"
/// price : 254.55
/// createdAt : "2025-10-02T17:55:38.174Z"
/// updatedAt : "2025-10-02T17:55:38.174Z"
/// __v : 0

AlertListData payloadFromJson(String str) =>
    AlertListData.fromJson(json.decode(str));
String payloadToJson(AlertListData data) => json.encode(data.toJson());

class AlertListData {
  AlertListData({
    String? id,
    String? userId,
    String? script,
    String? alertType,
    String? condition,
    num? price,
    String? createdAt,
    String? updatedAt,
    num? v,
  }) {
    _id = id;
    _userId = userId;
    _script = script;
    _alertType = alertType;
    _condition = condition;
    _price = price;
    _createdAt = createdAt;
    _updatedAt = updatedAt;
    _v = v;
  }

  AlertListData.fromJson(dynamic json) {
    _id = json['_id'];
    _userId = json['userId'];
    _script = json['script'];
    _alertType = json['alertType'];
    _condition = json['condition'];
    _price = json['price'];
    _createdAt = json['createdAt'];
    _updatedAt = json['updatedAt'];
    _v = json['__v'];
  }
  String? _id;
  String? _userId;
  String? _script;
  String? _alertType;
  String? _condition;
  num? _price;
  String? _createdAt;
  String? _updatedAt;
  num? _v;
  AlertListData copyWith({
    String? id,
    String? userId,
    String? script,
    String? alertType,
    String? condition,
    num? price,
    String? createdAt,
    String? updatedAt,
    num? v,
  }) =>
      AlertListData(
        id: id ?? _id,
        userId: userId ?? _userId,
        script: script ?? _script,
        alertType: alertType ?? _alertType,
        condition: condition ?? _condition,
        price: price ?? _price,
        createdAt: createdAt ?? _createdAt,
        updatedAt: updatedAt ?? _updatedAt,
        v: v ?? _v,
      );
  String? get id => _id;
  String? get userId => _userId;
  String? get script => _script;
  String? get alertType => _alertType;
  String? get condition => _condition;
  num? get price => _price;
  String? get createdAt => _createdAt;
  String? get updatedAt => _updatedAt;
  num? get v => _v;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['_id'] = _id;
    map['userId'] = _userId;
    map['script'] = _script;
    map['alertType'] = _alertType;
    map['condition'] = _condition;
    map['price'] = _price;
    map['createdAt'] = _createdAt;
    map['updatedAt'] = _updatedAt;
    map['__v'] = _v;
    return map;
  }
}
