import 'dart:convert';
/// status : "success"
/// code : 1
/// message : "OK: The request has succeeded."
/// payload : {"allBanks":[{"_id":"67fe66238de63c5bf3fe7a39","bankName":"Mashreq","accountName":"Save in Gold FZCO","accountNumber":"1234567890","iban":"AE070331234567890123456","swiftCode":"SCBLAEAD","createdAt":"2025-04-15T13:58:59.618Z","updatedAt":"2025-04-16T06:38:06.419Z","__v":0},{"_id":"67ff50ac50c51f0fe404673a","bankName":"Dubai Islami Bank","accountName":"Save in Gold FZCO","accountNumber":"4514567890","iban":"AE070331234567890123987","swiftCode":"DBALAEAD","createdAt":"2025-04-16T06:39:40.919Z","updatedAt":"2025-04-16T06:39:40.919Z","__v":0},{"_id":"67ffa9e4a17a3ae426878344","bankName":"Sharjah Islami Bank","accountName":"Save in Gold FZCO","accountNumber":"4514567110","iban":"AE070331234567890123110","swiftCode":"SHALAEAD","createdAt":"2025-04-16T13:00:20.195Z","updatedAt":"2025-04-16T13:00:20.195Z","__v":0},{"_id":"67ffac3fa17a3ae42687ae4c","bankName":"Commercial Bank of Dubai","accountName":"Save in Gold FZCO","accountNumber":"826545461454454545","iban":"AE5416415489784512251277","swiftCode":"ALEHAEADDFS","createdAt":"2025-04-16T13:10:23.772Z","updatedAt":"2025-04-17T06:31:01.549Z","__v":0},{"_id":"67ffaeedb62e7880f306da60","bankName":"Emirates Nbd Bank","accountName":"Save In Gold","accountNumber":"1234567890123456","iban":"AE712741274812455557414541","swiftCode":"ALFEAEA1123","createdAt":"2025-04-16T13:21:49.341Z","updatedAt":"2025-04-16T13:21:49.341Z","__v":0}]}

DirectTransferbankResponse directTransferbankResponseFromJson(String str) => DirectTransferbankResponse.fromJson(json.decode(str));
String directTransferbankResponseToJson(DirectTransferbankResponse data) => json.encode(data.toJson());
class DirectTransferbankResponse {
  DirectTransferbankResponse({
      String? status, 
      num? code, 
      String? message, 
      Payload? payload,}){
    _status = status;
    _code = code;
    _message = message;
    _payload = payload;
}

  DirectTransferbankResponse.fromJson(dynamic json) {
    _status = json['status'];
    _code = json['code'];
    _message = json['message'];
    _payload = json['payload'] != null ? Payload.fromJson(json['payload']) : null;
  }
  String? _status;
  num? _code;
  String? _message;
  Payload? _payload;
DirectTransferbankResponse copyWith({  String? status,
  num? code,
  String? message,
  Payload? payload,
}) => DirectTransferbankResponse(  status: status ?? _status,
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

/// allBanks : [{"_id":"67fe66238de63c5bf3fe7a39","bankName":"Mashreq","accountName":"Save in Gold FZCO","accountNumber":"1234567890","iban":"AE070331234567890123456","swiftCode":"SCBLAEAD","createdAt":"2025-04-15T13:58:59.618Z","updatedAt":"2025-04-16T06:38:06.419Z","__v":0},{"_id":"67ff50ac50c51f0fe404673a","bankName":"Dubai Islami Bank","accountName":"Save in Gold FZCO","accountNumber":"4514567890","iban":"AE070331234567890123987","swiftCode":"DBALAEAD","createdAt":"2025-04-16T06:39:40.919Z","updatedAt":"2025-04-16T06:39:40.919Z","__v":0},{"_id":"67ffa9e4a17a3ae426878344","bankName":"Sharjah Islami Bank","accountName":"Save in Gold FZCO","accountNumber":"4514567110","iban":"AE070331234567890123110","swiftCode":"SHALAEAD","createdAt":"2025-04-16T13:00:20.195Z","updatedAt":"2025-04-16T13:00:20.195Z","__v":0},{"_id":"67ffac3fa17a3ae42687ae4c","bankName":"Commercial Bank of Dubai","accountName":"Save in Gold FZCO","accountNumber":"826545461454454545","iban":"AE5416415489784512251277","swiftCode":"ALEHAEADDFS","createdAt":"2025-04-16T13:10:23.772Z","updatedAt":"2025-04-17T06:31:01.549Z","__v":0},{"_id":"67ffaeedb62e7880f306da60","bankName":"Emirates Nbd Bank","accountName":"Save In Gold","accountNumber":"1234567890123456","iban":"AE712741274812455557414541","swiftCode":"ALFEAEA1123","createdAt":"2025-04-16T13:21:49.341Z","updatedAt":"2025-04-16T13:21:49.341Z","__v":0}]

Payload payloadFromJson(String str) => Payload.fromJson(json.decode(str));
String payloadToJson(Payload data) => json.encode(data.toJson());
class Payload {
  Payload({
      List<AllBanks>? allBanks,}){
    _allBanks = allBanks;
}

  Payload.fromJson(dynamic json) {
    if (json['allBanks'] != null) {
      _allBanks = [];
      json['allBanks'].forEach((v) {
        _allBanks?.add(AllBanks.fromJson(v));
      });
    }
  }
  List<AllBanks>? _allBanks;
Payload copyWith({  List<AllBanks>? allBanks,
}) => Payload(  allBanks: allBanks ?? _allBanks,
);
  List<AllBanks>? get allBanks => _allBanks;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (_allBanks != null) {
      map['allBanks'] = _allBanks?.map((v) => v.toJson()).toList();
    }
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

AllBanks allBanksFromJson(String str) => AllBanks.fromJson(json.decode(str));
String allBanksToJson(AllBanks data) => json.encode(data.toJson());
class AllBanks {
  AllBanks({
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

  AllBanks.fromJson(dynamic json) {
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
AllBanks copyWith({  String? id,
  String? bankName,
  String? accountName,
  String? accountNumber,
  String? iban,
  String? swiftCode,
  String? createdAt,
  String? updatedAt,
  num? v,
}) => AllBanks(  id: id ?? _id,
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