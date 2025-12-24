import 'dart:convert';
/// status : "success"
/// code : 1
/// message : "OK: The request has succeeded."
/// payload : {"iosVersion":"1.0.1","androidVersion":"1.1.1","updateType":"Normal"}

AppUpdateResponseModel appUpdateResponseModelFromJson(String str) => AppUpdateResponseModel.fromJson(json.decode(str));
String appUpdateResponseModelToJson(AppUpdateResponseModel data) => json.encode(data.toJson());
class AppUpdateResponseModel {
  AppUpdateResponseModel({
      String? status, 
      num? code, 
      String? message, 
      Payload? payload,}){
    _status = status;
    _code = code;
    _message = message;
    _payload = payload;
}

  AppUpdateResponseModel.fromJson(dynamic json) {
    _status = json['status'];
    _code = json['code'];
    _message = json['message'];
    _payload = json['payload'] != null ? Payload.fromJson(json['payload']) : null;
  }
  String? _status;
  num? _code;
  String? _message;
  Payload? _payload;
AppUpdateResponseModel copyWith({  String? status,
  num? code,
  String? message,
  Payload? payload,
}) => AppUpdateResponseModel(  status: status ?? _status,
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

/// iosVersion : "1.0.1"
/// androidVersion : "1.1.1"
/// updateType : "Normal"

Payload payloadFromJson(String str) => Payload.fromJson(json.decode(str));
String payloadToJson(Payload data) => json.encode(data.toJson());
class Payload {
  Payload({
      String? iosVersion, 
      String? androidVersion, 
      String? updateType,
      bool? isMaintenanceMode, }){
    _iosVersion = iosVersion;
    _androidVersion = androidVersion;
    _updateType = updateType;
}

  Payload.fromJson(dynamic json) {
    _iosVersion = json['iosVersion'];
    _androidVersion = json['androidVersion'];
    _updateType = json['updateType'];
    _isMaintenanceMode = json['isMaintenanceMode'];
  }
  String? _iosVersion;
  String? _androidVersion;
  String? _updateType;
  bool ? _isMaintenanceMode;
Payload copyWith({  String? iosVersion,
  String? androidVersion,
  String? updateType,
  bool? isMaintenanceMode
}) => Payload(  iosVersion: iosVersion ?? _iosVersion,
  androidVersion: androidVersion ?? _androidVersion,
  updateType: updateType ?? _updateType,
  isMaintenanceMode: isMaintenanceMode ?? _isMaintenanceMode,
);
  String? get iosVersion => _iosVersion;
  String? get androidVersion => _androidVersion;
  String? get updateType => _updateType;
  bool? get isMaintenanceMode=> _isMaintenanceMode;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['iosVersion'] = _iosVersion;
    map['androidVersion'] = _androidVersion;
    map['updateType'] = _updateType;
    map['isMaintenanceMode']= _isMaintenanceMode;
    return map;
  }

}