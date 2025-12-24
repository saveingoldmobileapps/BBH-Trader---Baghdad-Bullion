import 'dart:convert';
/// status : "success"
/// code : 1
/// message : "OK: The request has succeeded."
/// payload : {"cardsList":[{"_id":"68fa64aeae0e6e0e298a40a4","isActive":true,"userId":"68d25248744c2246a1b2e33d","bankName":"Mezaan Bank","beneficiaryName":"Ali Sher","ibanNumber":"PK02MEZN1234567890123458","createdAt":"2025-10-23T17:23:58.998Z","updatedAt":"2025-10-23T17:23:58.998Z"}]}

BankCardReponse bankCardReponseFromJson(String str) => BankCardReponse.fromJson(json.decode(str));
String bankCardReponseToJson(BankCardReponse data) => json.encode(data.toJson());
class BankCardReponse {
  BankCardReponse({
      String? status, 
      num? code, 
      String? message, 
      Payload? payload,}){
    _status = status;
    _code = code;
    _message = message;
    _payload = payload;
}

  BankCardReponse.fromJson(dynamic json) {
    _status = json['status'];
    _code = json['code'];
    _message = json['message'];
    _payload = json['payload'] != null ? Payload.fromJson(json['payload']) : null;
  }
  String? _status;
  num? _code;
  String? _message;
  Payload? _payload;
BankCardReponse copyWith({  String? status,
  num? code,
  String? message,
  Payload? payload,
}) => BankCardReponse(  status: status ?? _status,
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

/// cardsList : [{"_id":"68fa64aeae0e6e0e298a40a4","isActive":true,"userId":"68d25248744c2246a1b2e33d","bankName":"Mezaan Bank","beneficiaryName":"Ali Sher","ibanNumber":"PK02MEZN1234567890123458","createdAt":"2025-10-23T17:23:58.998Z","updatedAt":"2025-10-23T17:23:58.998Z"}]

Payload payloadFromJson(String str) => Payload.fromJson(json.decode(str));
String payloadToJson(Payload data) => json.encode(data.toJson());
class Payload {
  Payload({
      List<CardsList>? cardsList,}){
    _cardsList = cardsList;
}

  Payload.fromJson(dynamic json) {
    if (json['cardsList'] != null) {
      _cardsList = [];
      json['cardsList'].forEach((v) {
        _cardsList?.add(CardsList.fromJson(v));
      });
    }
  }
  List<CardsList>? _cardsList;
Payload copyWith({  List<CardsList>? cardsList,
}) => Payload(  cardsList: cardsList ?? _cardsList,
);
  List<CardsList>? get cardsList => _cardsList;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (_cardsList != null) {
      map['cardsList'] = _cardsList?.map((v) => v.toJson()).toList();
    }
    return map;
  }

}

/// _id : "68fa64aeae0e6e0e298a40a4"
/// isActive : true
/// userId : "68d25248744c2246a1b2e33d"
/// bankName : "Mezaan Bank"
/// beneficiaryName : "Ali Sher"
/// ibanNumber : "PK02MEZN1234567890123458"
/// createdAt : "2025-10-23T17:23:58.998Z"
/// updatedAt : "2025-10-23T17:23:58.998Z"

CardsList cardsListFromJson(String str) => CardsList.fromJson(json.decode(str));
String cardsListToJson(CardsList data) => json.encode(data.toJson());
class CardsList {
  CardsList({
      String? id, 
      bool? isActive, 
      String? userId, 
      String? bankName, 
      String? beneficiaryName, 
      String? ibanNumber, 
      String? createdAt, 
      String? updatedAt,}){
    _id = id;
    _isActive = isActive;
    _userId = userId;
    _bankName = bankName;
    _beneficiaryName = beneficiaryName;
    _ibanNumber = ibanNumber;
    _createdAt = createdAt;
    _updatedAt = updatedAt;
}

  CardsList.fromJson(dynamic json) {
    _id = json['_id'];
    _isActive = json['isActive'];
    _userId = json['userId'];
    _bankName = json['bankName'];
    _beneficiaryName = json['beneficiaryName'];
    _ibanNumber = json['ibanNumber'];
    _createdAt = json['createdAt'];
    _updatedAt = json['updatedAt'];
  }
  String? _id;
  bool? _isActive;
  String? _userId;
  String? _bankName;
  String? _beneficiaryName;
  String? _ibanNumber;
  String? _createdAt;
  String? _updatedAt;
CardsList copyWith({  String? id,
  bool? isActive,
  String? userId,
  String? bankName,
  String? beneficiaryName,
  String? ibanNumber,
  String? createdAt,
  String? updatedAt,
}) => CardsList(  id: id ?? _id,
  isActive: isActive ?? _isActive,
  userId: userId ?? _userId,
  bankName: bankName ?? _bankName,
  beneficiaryName: beneficiaryName ?? _beneficiaryName,
  ibanNumber: ibanNumber ?? _ibanNumber,
  createdAt: createdAt ?? _createdAt,
  updatedAt: updatedAt ?? _updatedAt,
);
  String? get id => _id;
  bool? get isActive => _isActive;
  String? get userId => _userId;
  String? get bankName => _bankName;
  String? get beneficiaryName => _beneficiaryName;
  String? get ibanNumber => _ibanNumber;
  String? get createdAt => _createdAt;
  String? get updatedAt => _updatedAt;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['_id'] = _id;
    map['isActive'] = _isActive;
    map['userId'] = _userId;
    map['bankName'] = _bankName;
    map['beneficiaryName'] = _beneficiaryName;
    map['ibanNumber'] = _ibanNumber;
    map['createdAt'] = _createdAt;
    map['updatedAt'] = _updatedAt;
    return map;
  }

}