import 'dart:convert';
/// status : "success"
/// code : 1
/// message : "OK: The request has succeeded."
/// payload : {"bank":{"_id":"67fe66238de63c5bf3fe7a39","bankName":"Mashreq","accountName":"Save in Gold FZCO","accountNumber":"1234567890","iban":"AE070331234567890123456","swiftCode":"SCBLAEAD","createdAt":"2025-04-15T13:58:59.618Z","updatedAt":"2025-04-16T06:38:06.419Z","__v":0},"supportDetails":[{"_id":"67ff7516b3132814ceb468fa","whatsApp":"+971561680743","supportEmail":"info@saveingold.ae","officeTiming":"Monday to Friday, 9:00 AM – 6:00 PM (Gulf Standard Time - GMT+4)","createdAt":"2025-04-16T09:15:02.114Z","updatedAt":"2025-04-16T09:15:02.114Z","__v":0}]}

BankDetailResponse bankDetailResponseFromJson(String str) => BankDetailResponse.fromJson(json.decode(str));
String bankDetailResponseToJson(BankDetailResponse data) => json.encode(data.toJson());
class BankDetailResponse {
  BankDetailResponse({
      String? status, 
      num? code, 
      String? message, 
      Payload? payload,}){
    _status = status;
    _code = code;
    _message = message;
    _payload = payload;
}

  BankDetailResponse.fromJson(dynamic json) {
    _status = json['status'];
    _code = json['code'];
    _message = json['message'];
    _payload = json['payload'] != null ? Payload.fromJson(json['payload']) : null;
  }
  String? _status;
  num? _code;
  String? _message;
  Payload? _payload;
BankDetailResponse copyWith({  String? status,
  num? code,
  String? message,
  Payload? payload,
}) => BankDetailResponse(  status: status ?? _status,
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

/// bank : {"_id":"67fe66238de63c5bf3fe7a39","bankName":"Mashreq","accountName":"Save in Gold FZCO","accountNumber":"1234567890","iban":"AE070331234567890123456","swiftCode":"SCBLAEAD","createdAt":"2025-04-15T13:58:59.618Z","updatedAt":"2025-04-16T06:38:06.419Z","__v":0}
/// supportDetails : [{"_id":"67ff7516b3132814ceb468fa","whatsApp":"+971561680743","supportEmail":"info@saveingold.ae","officeTiming":"Monday to Friday, 9:00 AM – 6:00 PM (Gulf Standard Time - GMT+4)","createdAt":"2025-04-16T09:15:02.114Z","updatedAt":"2025-04-16T09:15:02.114Z","__v":0}]

Payload payloadFromJson(String str) => Payload.fromJson(json.decode(str));
String payloadToJson(Payload data) => json.encode(data.toJson());
class Payload {
  Payload({
      Bank? bank, 
      List<SupportDetails>? supportDetails,}){
    _bank = bank;
    _supportDetails = supportDetails;
}

  Payload.fromJson(dynamic json) {
    _bank = json['bank'] != null ? Bank.fromJson(json['bank']) : null;
    if (json['supportDetails'] != null) {
      _supportDetails = [];
      json['supportDetails'].forEach((v) {
        _supportDetails?.add(SupportDetails.fromJson(v));
      });
    }
  }
  Bank? _bank;
  List<SupportDetails>? _supportDetails;
Payload copyWith({  Bank? bank,
  List<SupportDetails>? supportDetails,
}) => Payload(  bank: bank ?? _bank,
  supportDetails: supportDetails ?? _supportDetails,
);
  Bank? get bank => _bank;
  List<SupportDetails>? get supportDetails => _supportDetails;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (_bank != null) {
      map['bank'] = _bank?.toJson();
    }
    if (_supportDetails != null) {
      map['supportDetails'] = _supportDetails?.map((v) => v.toJson()).toList();
    }
    return map;
  }

}

/// _id : "67ff7516b3132814ceb468fa"
/// whatsApp : "+971561680743"
/// supportEmail : "info@saveingold.ae"
/// officeTiming : "Monday to Friday, 9:00 AM – 6:00 PM (Gulf Standard Time - GMT+4)"
/// createdAt : "2025-04-16T09:15:02.114Z"
/// updatedAt : "2025-04-16T09:15:02.114Z"
/// __v : 0

SupportDetails supportDetailsFromJson(String str) => SupportDetails.fromJson(json.decode(str));
String supportDetailsToJson(SupportDetails data) => json.encode(data.toJson());
class SupportDetails {
  SupportDetails({
      String? id, 
      String? whatsApp, 
      String? supportEmail, 
      String? officeTiming, 
      String? createdAt, 
      String? updatedAt, 
      num? v,}){
    _id = id;
    _whatsApp = whatsApp;
    _supportEmail = supportEmail;
    _officeTiming = officeTiming;
    _createdAt = createdAt;
    _updatedAt = updatedAt;
    _v = v;
}

  SupportDetails.fromJson(dynamic json) {
    _id = json['_id'];
    _whatsApp = json['whatsApp'];
    _supportEmail = json['supportEmail'];
    _officeTiming = json['officeTiming'];
    _createdAt = json['createdAt'];
    _updatedAt = json['updatedAt'];
    _v = json['__v'];
  }
  String? _id;
  String? _whatsApp;
  String? _supportEmail;
  String? _officeTiming;
  String? _createdAt;
  String? _updatedAt;
  num? _v;
SupportDetails copyWith({  String? id,
  String? whatsApp,
  String? supportEmail,
  String? officeTiming,
  String? createdAt,
  String? updatedAt,
  num? v,
}) => SupportDetails(  id: id ?? _id,
  whatsApp: whatsApp ?? _whatsApp,
  supportEmail: supportEmail ?? _supportEmail,
  officeTiming: officeTiming ?? _officeTiming,
  createdAt: createdAt ?? _createdAt,
  updatedAt: updatedAt ?? _updatedAt,
  v: v ?? _v,
);
  String? get id => _id;
  String? get whatsApp => _whatsApp;
  String? get supportEmail => _supportEmail;
  String? get officeTiming => _officeTiming;
  String? get createdAt => _createdAt;
  String? get updatedAt => _updatedAt;
  num? get v => _v;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['_id'] = _id;
    map['whatsApp'] = _whatsApp;
    map['supportEmail'] = _supportEmail;
    map['officeTiming'] = _officeTiming;
    map['createdAt'] = _createdAt;
    map['updatedAt'] = _updatedAt;
    map['__v'] = _v;
    return map;
  }

}

/// _id : "67fe66238de63c5bf3fe7a39"
/// bankName : "Mashreq"
/// accountName : "Save in Gold FZCO"
/// accountNumber : "1234567890"
/// iban : "AE070331234567890123456"
/// swiftCode : "SCBLAEAD"
/// createdAt : "2025-04-15T13:58:59.618Z"
/// updatedAt : "2025-04-16T06:38:06.419Z"
/// __v : 0

Bank bankFromJson(String str) => Bank.fromJson(json.decode(str));
String bankToJson(Bank data) => json.encode(data.toJson());
class Bank {
  Bank({
      String? id, 
      String? bankName, 
      String? accountName, 
      String? accountNumber, 
      String? iban, 
      String? swiftCode, 
      String? createdAt, 
      String? updatedAt, 
      num? v,}){
    _id = id;
    _bankName = bankName;
    _accountName = accountName;
    _accountNumber = accountNumber;
    _iban = iban;
    _swiftCode = swiftCode;
    _createdAt = createdAt;
    _updatedAt = updatedAt;
    _v = v;
}

  Bank.fromJson(dynamic json) {
    _id = json['_id'];
    _bankName = json['bankName'];
    _accountName = json['accountName'];
    _accountNumber = json['accountNumber'];
    _iban = json['iban'];
    _swiftCode = json['swiftCode'];
    _createdAt = json['createdAt'];
    _updatedAt = json['updatedAt'];
    _v = json['__v'];
  }
  String? _id;
  String? _bankName;
  String? _accountName;
  String? _accountNumber;
  String? _iban;
  String? _swiftCode;
  String? _createdAt;
  String? _updatedAt;
  num? _v;
Bank copyWith({  String? id,
  String? bankName,
  String? accountName,
  String? accountNumber,
  String? iban,
  String? swiftCode,
  String? createdAt,
  String? updatedAt,
  num? v,
}) => Bank(  id: id ?? _id,
  bankName: bankName ?? _bankName,
  accountName: accountName ?? _accountName,
  accountNumber: accountNumber ?? _accountNumber,
  iban: iban ?? _iban,
  swiftCode: swiftCode ?? _swiftCode,
  createdAt: createdAt ?? _createdAt,
  updatedAt: updatedAt ?? _updatedAt,
  v: v ?? _v,
);
  String? get id => _id;
  String? get bankName => _bankName;
  String? get accountName => _accountName;
  String? get accountNumber => _accountNumber;
  String? get iban => _iban;
  String? get swiftCode => _swiftCode;
  String? get createdAt => _createdAt;
  String? get updatedAt => _updatedAt;
  num? get v => _v;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['_id'] = _id;
    map['bankName'] = _bankName;
    map['accountName'] = _accountName;
    map['accountNumber'] = _accountNumber;
    map['iban'] = _iban;
    map['swiftCode'] = _swiftCode;
    map['createdAt'] = _createdAt;
    map['updatedAt'] = _updatedAt;
    map['__v'] = _v;
    return map;
  }

}