import 'dart:convert';

/// status : "success"
/// code : 1
/// message : "OK: The request has succeeded."
/// payload : {"message":"One Time Password (OTP) sent successfully.","otp":"908210"}

SuccessResponse successResponseFromJson(String str) =>
    SuccessResponse.fromJson(json.decode(str));

String successResponseToJson(SuccessResponse data) => json.encode(data.toJson());

class SuccessResponse {
  SuccessResponse({
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

  SuccessResponse.fromJson(dynamic json) {
    _status = json['status'];
    _code = json['code'];
    _message = json['message'];
    _payload =
        json['payload'] != null ? Payload.fromJson(json['payload']) : null;
  }

  String? _status;
  num? _code;
  String? _message;
  Payload? _payload;

  SuccessResponse copyWith({
    String? status,
    num? code,
    String? message,
    Payload? payload,
  }) =>
      SuccessResponse(
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

/// message : "One Time Password (OTP) sent successfully."
/// otp : "908210"

Payload payloadFromJson(String str) => Payload.fromJson(json.decode(str));

String payloadToJson(Payload data) => json.encode(data.toJson());

class Payload {
  Payload({
    String? message,
    String? otp,
  }) {
    _message = message;
    _otp = otp;
  }

  Payload.fromJson(dynamic json) {
    _message = json['message'];
    _otp = json['otp']; // <--- added OTP
  }

  String? _message;
  String? _otp;

  Payload copyWith({
    String? message,
    String? otp,
  }) =>
      Payload(
        message: message ?? _message,
        otp: otp ?? _otp,
      );

  String? get message => _message;
  String? get otp => _otp; // <--- getter for OTP

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['message'] = _message;
    map['otp'] = _otp; // <--- include OTP in JSON
    return map;
  }
}
