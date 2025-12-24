import 'dart:convert';

/// status : "success"
/// code : 1
/// message : "OK: The request has succeeded."
/// payload : [{"_id":"67d47ba0396231c0c8f92bc3","accountId":"559699547","firstName":"Mr","surname":"Asmat","email":"asmatwazir906@gmail.com"},{"_id":"67d7dc48396231c0c8fa1bd3","accountId":"186079121","firstName":"Muhammad","surname":"Bilal","email":"saveingoldbilal@gmail.com"},{"_id":"67d7df6a396231c0c8fa1f2c","accountId":"785312531","firstName":"Jhoana","surname":"Castilio","email":"info@saveingold.ae"},{"_id":"67d9556a396231c0c8fb5d35","accountId":"704086066","firstName":"Ali","surname":"Ali","email":"aliali@gmail.com"},{"_id":"67da8845c0bcb70ee85fe0a0","accountId":"368773800","firstName":"Flutter","surname":"Dev","email":"flutterdev@gmail.com"}]

AllFriendsApiResponseModel allFriendsApiResponseModelFromJson(String str) =>
    AllFriendsApiResponseModel.fromJson(json.decode(str));
String allFriendsApiResponseModelToJson(AllFriendsApiResponseModel data) =>
    json.encode(data.toJson());

class AllFriendsApiResponseModel {
  AllFriendsApiResponseModel({
    String? status,
    num? code,
    String? message,
    List<AllUsers>? payload,
  }) {
    _status = status;
    _code = code;
    _message = message;
    _payload = payload;
  }

  AllFriendsApiResponseModel.fromJson(dynamic json) {
    _status = json['status'];
    _code = json['code'];
    _message = json['message'];
    if (json['payload'] != null) {
      _payload = [];
      json['payload'].forEach((v) {
        _payload?.add(AllUsers.fromJson(v));
      });
    }
  }
  String? _status;
  num? _code;
  String? _message;
  List<AllUsers>? _payload;
  AllFriendsApiResponseModel copyWith({
    String? status,
    num? code,
    String? message,
    List<AllUsers>? payload,
  }) => AllFriendsApiResponseModel(
    status: status ?? _status,
    code: code ?? _code,
    message: message ?? _message,
    payload: payload ?? _payload,
  );
  String? get status => _status;
  num? get code => _code;
  String? get message => _message;
  List<AllUsers>? get payload => _payload;

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

/// _id : "67d47ba0396231c0c8f92bc3"
/// accountId : "559699547"
/// firstName : "Mr"
/// surname : "Asmat"
/// email : "asmatwazir906@gmail.com"

AllUsers payloadFromJson(String str) => AllUsers.fromJson(json.decode(str));
String payloadToJson(AllUsers data) => json.encode(data.toJson());

class AllUsers {
  Payload({
    String? id,
    String? accountId,
    String? firstName,
    String? surname,
    String? email,
    String? phoneNumber,
  }) {
    _id = id;
    _accountId = accountId;
    _firstName = firstName;
    _surname = surname;
    _email = email;
    _phoneNumber = phoneNumber;
  }

  AllUsers.fromJson(dynamic json) {
    _id = json['_id'];
    _accountId = json['accountId'];
    _firstName = json['firstName'];
    _surname = json['surname'];
    _email = json['email'];
    _phoneNumber = json['phoneNumber'];
  }
  String? _id;
  String? _accountId;
  String? _firstName;
  String? _surname;
  String? _email;
  String? _phoneNumber;
  AllUsers copyWith({
    String? id,
    String? accountId,
    String? firstName,
    String? phoneNumber,
    String? surname,
    String? email,
  }) => Payload(
    id: id ?? _id,
    accountId: accountId ?? _accountId,
    phoneNumber: phoneNumber ?? _phoneNumber,
    firstName: firstName ?? _firstName,
    surname: surname ?? _surname,
    email: email ?? _email,
  );
  String? get id => _id;
  String? get accountId => _accountId;
  String? get firstName => _firstName;
  String? get surname => _surname;
  String? get email => _email;
  String? get phoneNumber => _phoneNumber;
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['_id'] = _id;
    map['accountId'] = _accountId;
    map['firstName'] = _firstName;
    map['surname'] = _surname;
    map['email'] = _email;
    return map;
  }
}
