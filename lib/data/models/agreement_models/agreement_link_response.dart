class AgreementLinkResponse {
  AgreementLinkResponse({
    this.status,
    this.code,
    this.message,
    this.payload,
  });

  AgreementLinkResponse.fromJson(dynamic json) {
    status = json['status'];
    code = json['code'];
    message = json['message'];
    payload = json['payload'] != null
        ? AgreementLinkPayload.fromJson(json['payload'])
        : null;
  }

  String? status;
  num? code;
  String? message;
  AgreementLinkPayload? payload;
}

class AgreementLinkPayload {
  AgreementLinkPayload({this.agreementLink});

  AgreementLinkPayload.fromJson(dynamic json) {
    agreementLink = json['agreementLink']?.toString();
  }

  String? agreementLink;
}
