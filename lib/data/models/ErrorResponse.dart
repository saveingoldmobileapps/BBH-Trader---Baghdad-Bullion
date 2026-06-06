import 'dart:convert';
/// status : "failure"
/// code : 0
/// message : "Bad Request: The server could not handle invalid request."
/// payload : {"message":"User or email is undefined"}

ErrorResponse errorResponseFromJson(String str) => ErrorResponse.fromJson(json.decode(str));
String errorResponseToJson(ErrorResponse data) => json.encode(data.toJson());
class ErrorResponse {
  ErrorResponse({
    String? status,
    num? code,
    String? message,
    String? userData,
    Payload? payload,}){
    _status = status;
    _code = code;
    _message = message;
    _payload = payload;
  }

  ErrorResponse.fromJson(dynamic json) {
    _status = json['status'];
    _code = json['code'];
    _message = json['message'];
    _payload = json['payload'] != null ? Payload.fromJson(json['payload']) : null;
  }
  String? _status;
  num? _code;
  String? _message;
  Payload? _payload;
  ErrorResponse copyWith({  String? status,
    num? code,
    String? message,
    Payload? payload,
  }) => ErrorResponse(  status: status ?? _status,
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

/// message : "User or email is undefined"

Payload payloadFromJson(String str) => Payload.fromJson(json.decode(str));
String payloadToJson(Payload data) => json.encode(data.toJson());
class Payload {
  Payload({
    String? message,
    String? userData, }) {
    _message = message;
    _userData = userData;
  }

  Payload.fromJson(dynamic json) {
    _message = json['message'];
    _userData = json['userData'];
  }
  String? _message;
  String? _userData;
  Payload copyWith({  String? message,
    String? userData,
  }) => Payload(  message: message ?? _message,
        userData: userData ?? _userData,
      );
  String? get message => _message;
  
  String? get userData => _userData;
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['message'] = _message;
    map['userData'] = _userData;
    return map;
  }
}
