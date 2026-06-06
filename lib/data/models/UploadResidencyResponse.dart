import 'dart:convert';
/// status : "success"
/// code : 1
/// message : "OK: The request has succeeded."
/// payload : {"residencyProofURL":"https://sigprodbucket.s3.me-central-1.amazonaws.com/default/image-4852905f-60ab-4b32-8873-243449eed962.pdf"}

UploadResidencyResponse uploadResidencyResponseFromJson(String str) => UploadResidencyResponse.fromJson(json.decode(str));
String uploadResidencyResponseToJson(UploadResidencyResponse data) => json.encode(data.toJson());
class UploadResidencyResponse {
  UploadResidencyResponse({
      String? status, 
      num? code, 
      String? message, 
      Payload? payload,}){
    _status = status;
    _code = code;
    _message = message;
    _payload = payload;
}

  UploadResidencyResponse.fromJson(dynamic json) {
    _status = json['status'];
    _code = json['code'];
    _message = json['message'];
    _payload = json['payload'] != null ? Payload.fromJson(json['payload']) : null;
  }
  String? _status;
  num? _code;
  String? _message;
  Payload? _payload;
UploadResidencyResponse copyWith({  String? status,
  num? code,
  String? message,
  Payload? payload,
}) => UploadResidencyResponse(  status: status ?? _status,
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

/// residencyProofURL : "https://sigprodbucket.s3.me-central-1.amazonaws.com/default/image-4852905f-60ab-4b32-8873-243449eed962.pdf"

Payload payloadFromJson(String str) => Payload.fromJson(json.decode(str));
String payloadToJson(Payload data) => json.encode(data.toJson());
class Payload {
  Payload({
      String? residencyProofURL,}){
    _residencyProofURL = residencyProofURL;
}

  Payload.fromJson(dynamic json) {
    _residencyProofURL = json['residencyProofURL'];
  }
  String? _residencyProofURL;
Payload copyWith({  String? residencyProofURL,
}) => Payload(  residencyProofURL: residencyProofURL ?? _residencyProofURL,
);
  String? get residencyProofURL => _residencyProofURL;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['residencyProofURL'] = _residencyProofURL;
    return map;
  }

}