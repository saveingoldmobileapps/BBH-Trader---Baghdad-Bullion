import 'dart:convert';

/// status : "success"
/// code : 1
/// message : "OK: The request has succeeded."
/// payload : [{"_id":"6815bddf09cf95538a3b4263","branchName":"Save In Gold","branchLocation":"Gold Souk, Dubai, UAE","branchPhoneNumber":"+971562656180","branchEmail":"amro@saveingold.ae"},{"_id":"6815be3f09cf95538a3b446b","branchName":"Save In Gold","branchLocation":"Sharjah, UAE","branchPhoneNumber":"+971562654987","branchEmail":"ceo@saveingold.ae"},{"_id":"6815bf0709cf95538a3b48ae","branchName":"Save In Gold","branchLocation":"Abu Dhabi, UAE","branchPhoneNumber":"+971569879987","branchEmail":"info@saveingold.ae"},{"_id":"682ed61a5592fd7a25b97208","branchName":"Save In Gold","branchLocation":"Jordan","branchPhoneNumber":"+962791234567","branchEmail":"amro@saveingold.ae"}]

BankBranchesApiResponseModel bankBranchesApiResponseModelFromJson(String str) =>
    BankBranchesApiResponseModel.fromJson(json.decode(str));
String bankBranchesApiResponseModelToJson(BankBranchesApiResponseModel data) =>
    json.encode(data.toJson());

class BankBranchesApiResponseModel {
  BankBranchesApiResponseModel({
    String? status, 
    num? code, 
    String? message, 
    List<Payload>? payload,}){
    _status = status;
    _code = code;
    _message = message;
    _payload = payload;
  }

  BankBranchesApiResponseModel.fromJson(dynamic json) {
    _status = json['status'];
    _code = json['code'];
    _message = json['message'];
    if (json['payload'] != null) {
      _payload = [];
      json['payload'].forEach((v) {
        _payload?.add(Payload.fromJson(v));
      });
    }
  }
  String? _status;
  num? _code;
  String? _message;
  List<Payload>? _payload;
  BankBranchesApiResponseModel copyWith({
    String? status,
    num? code,
    String? message,
    List<Payload>? payload,
  }) => BankBranchesApiResponseModel(
    status: status ?? _status,
    code: code ?? _code,
    message: message ?? _message,
    payload: payload ?? _payload,
  );
  String? get status => _status;
  num? get code => _code;
  String? get message => _message;
  List<Payload>? get payload => _payload;

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

/// _id : "6815bddf09cf95538a3b4263"
/// branchName : "Save In Gold"
/// branchLocation : "Gold Souk, Dubai, UAE"
/// branchPhoneNumber : "+971562656180"
/// branchEmail : "amro@saveingold.ae"

Payload payloadFromJson(String str) => Payload.fromJson(json.decode(str));
String payloadToJson(Payload data) => json.encode(data.toJson());

class Payload {
  Payload({
    String? id,
    String? branchName,
    String? branchLocation,
    String? branchPhoneNumber,
    String? branchEmail,
  }) {
    _id = id;
    _branchName = branchName;
    _branchLocation = branchLocation;
    _branchPhoneNumber = branchPhoneNumber;
    _branchEmail = branchEmail;
  }

  Payload.fromJson(dynamic json) {
    _id = json['_id'];
    _branchName = json['branchName'];
    _branchLocation = json['branchLocation'];
    _branchPhoneNumber = json['branchPhoneNumber'];
    _branchEmail = json['branchEmail'];
  }
  String? _id;
  String? _branchName;
  String? _branchLocation;
  String? _branchPhoneNumber;
  String? _branchEmail;
  Payload copyWith({
    String? id,
    String? branchName,
    String? branchLocation,
    String? branchPhoneNumber,
    String? branchEmail,
  }) => Payload(
    id: id ?? _id,
    branchName: branchName ?? _branchName,
    branchLocation: branchLocation ?? _branchLocation,
    branchPhoneNumber: branchPhoneNumber ?? _branchPhoneNumber,
    branchEmail: branchEmail ?? _branchEmail,
  );
  String? get id => _id;
  String? get branchName => _branchName;
  String? get branchLocation => _branchLocation;
  String? get branchPhoneNumber => _branchPhoneNumber;
  String? get branchEmail => _branchEmail;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['_id'] = _id;
    map['branchName'] = _branchName;
    map['branchLocation'] = _branchLocation;
    map['branchPhoneNumber'] = _branchPhoneNumber;
    map['branchEmail'] = _branchEmail;
    return map;
  }
}
