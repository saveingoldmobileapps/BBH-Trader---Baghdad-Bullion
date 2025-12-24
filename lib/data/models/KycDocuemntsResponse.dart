import 'dart:convert';

/// status : "success"
/// code : 1
/// message : "OK: The request has succeeded."
/// payload : {"kycDocsUrl":"https://sigprodbucket.s3.me-central-1.amazonaws.com/default/image-4852905f-60ab-4b32-8873-243449eed962.pdf"}

KycUrlResponse kycUrlResponseFromJson(String str) =>
    KycUrlResponse.fromJson(json.decode(str));

String kycUrlResponseToJson(KycUrlResponse data) => json.encode(data.toJson());

class KycUrlResponse {
  KycUrlResponse({
    String? status,
    num? code,
    String? message,
    KycUrlPayload? payload,
  }) {
    _status = status;
    _code = code;
    _message = message;
    _payload = payload;
  }

  KycUrlResponse.fromJson(dynamic json) {
    _status = json['status'];
    _code = json['code'];
    _message = json['message'];
    _payload = json['payload'] != null
        ? KycUrlPayload.fromJson(json['payload'])
        : null;
  }

  String? _status;
  num? _code;
  String? _message;
  KycUrlPayload? _payload;

  KycUrlResponse copyWith({
    String? status,
    num? code,
    String? message,
    KycUrlPayload? payload,
  }) =>
      KycUrlResponse(
        status: status ?? _status,
        code: code ?? _code,
        message: message ?? _message,
        payload: payload ?? _payload,
      );

  String? get status => _status;
  num? get code => _code;
  String? get message => _message;
  KycUrlPayload? get payload => _payload;

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

/// payload model for KYC URL
class KycUrlPayload {
  KycUrlPayload({
    String? kycDocsUrl,
  }) {
    _kycDocsUrl = kycDocsUrl;
  }

  KycUrlPayload.fromJson(dynamic json) {
    _kycDocsUrl = json['kycDocsUrl'];
  }

  String? _kycDocsUrl;

  KycUrlPayload copyWith({
    String? kycDocsUrl,
  }) =>
      KycUrlPayload(
        kycDocsUrl: kycDocsUrl ?? _kycDocsUrl,
      );

  String? get kycDocsUrl => _kycDocsUrl;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['kycDocsUrl'] = _kycDocsUrl;
    return map;
  }
}
