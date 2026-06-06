import 'dart:convert';

/// status : "success"
/// code : 1
/// message : "Created: A new resource has been created."
/// payload : {"createdUser":{"id":"67a5fef6ed7f3d97efd9bf93","accountId":"214691672","userType":"Real","firstName":"Haider","surname":"Ali","dateOfBirthday":"","email":"ali.pydeveloper8@gmail.com","phoneNumber":"0552025312","imageUrl":"","moneyBalance":0,"metalBalance":0,"accessToken":"eyJhbGciOiJIUzUxMiIsInR5cCI6IkpXVCJ9.eyJlbmNyeXB0ZWRFbWFpbCI6ImRiMmJhYzY4NmFiNjEyNDdiNjZmZDQyMDZhOWEyODRlMGY5MzFlNzJmOWU0MmMyZDlmZjg4MjBkZDUxNmYyMjkiLCJ0b2tlbklkIjoiOTZiNWJhNDQtOWE4Mi00ZTI4LThmYjYtOWQ3MTY2NGRkZTI1IiwiaWF0IjoxNzM4OTMxOTU3LCJleHAiOjE3Mzg5MzI4NTcsImF1ZCI6IjxtQG1vYmlsQGVfQGFwcF9AdWRpZW5AY2U-IiwiaXNzIjoiPHNAdmUkaW5nQG9sZF9pQEBzc3VyQGU-Iiwic3ViIjoiYWxpLnB5ZGV2ZWxvcGVyOEBnbWFpbC5jb20iLCJqdGkiOiI5NmI1YmE0NC05YTgyLTRlMjgtOGZiNi05ZDcxNjY0ZGRlMjUifQ.HfpABZKYpt1n4tLz-A6lXiVgRhoTo6OEewcnZvnmToQELy2W5AIHs580gQe0OfUFrCjPHxrqH5BE2O7DqdqZQg","createdAt":"2025-02-07T12:39:18.213Z","updatedAt":"2025-02-07T12:39:18.213Z"}}

RegisterResponse registerResponseFromJson(String str) =>
    RegisterResponse.fromJson(json.decode(str));
String registerResponseToJson(RegisterResponse data) =>
    json.encode(data.toJson());

class RegisterResponse {
  RegisterResponse({
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

  RegisterResponse.fromJson(dynamic json) {
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
  RegisterResponse copyWith({
    String? status,
    num? code,
    String? message,
    Payload? payload,
  }) =>
      RegisterResponse(
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

/// createdUser : {"id":"67a5fef6ed7f3d97efd9bf93","accountId":"214691672","userType":"Real","firstName":"Haider","surname":"Ali","dateOfBirthday":"","email":"ali.pydeveloper8@gmail.com","phoneNumber":"0552025312","imageUrl":"","moneyBalance":0,"metalBalance":0,"accessToken":"eyJhbGciOiJIUzUxMiIsInR5cCI6IkpXVCJ9.eyJlbmNyeXB0ZWRFbWFpbCI6ImRiMmJhYzY4NmFiNjEyNDdiNjZmZDQyMDZhOWEyODRlMGY5MzFlNzJmOWU0MmMyZDlmZjg4MjBkZDUxNmYyMjkiLCJ0b2tlbklkIjoiOTZiNWJhNDQtOWE4Mi00ZTI4LThmYjYtOWQ3MTY2NGRkZTI1IiwiaWF0IjoxNzM4OTMxOTU3LCJleHAiOjE3Mzg5MzI4NTcsImF1ZCI6IjxtQG1vYmlsQGVfQGFwcF9AdWRpZW5AY2U-IiwiaXNzIjoiPHNAdmUkaW5nQG9sZF9pQEBzc3VyQGU-Iiwic3ViIjoiYWxpLnB5ZGV2ZWxvcGVyOEBnbWFpbC5jb20iLCJqdGkiOiI5NmI1YmE0NC05YTgyLTRlMjgtOGZiNi05ZDcxNjY0ZGRlMjUifQ.HfpABZKYpt1n4tLz-A6lXiVgRhoTo6OEewcnZvnmToQELy2W5AIHs580gQe0OfUFrCjPHxrqH5BE2O7DqdqZQg","createdAt":"2025-02-07T12:39:18.213Z","updatedAt":"2025-02-07T12:39:18.213Z"}

Payload payloadFromJson(String str) => Payload.fromJson(json.decode(str));
String payloadToJson(Payload data) => json.encode(data.toJson());

class Payload {
  Payload({
    CreatedUser? createdUser,
  }) {
    _createdUser = createdUser;
  }

  Payload.fromJson(dynamic json) {
    _createdUser = json['createdUser'] != null
        ? CreatedUser.fromJson(json['createdUser'])
        : null;
  }
  CreatedUser? _createdUser;
  Payload copyWith({
    CreatedUser? createdUser,
  }) =>
      Payload(
        createdUser: createdUser ?? _createdUser,
      );
  CreatedUser? get createdUser => _createdUser;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (_createdUser != null) {
      map['createdUser'] = _createdUser?.toJson();
    }
    return map;
  }
}

/// id : "67a5fef6ed7f3d97efd9bf93"
/// accountId : "214691672"
/// userType : "Real"
/// firstName : "Haider"
/// surname : "Ali"
/// dateOfBirthday : ""
/// email : "ali.pydeveloper8@gmail.com"
/// phoneNumber : "0552025312"
/// imageUrl : ""
/// moneyBalance : 0
/// metalBalance : 0
/// accessToken : "eyJhbGciOiJIUzUxMiIsInR5cCI6IkpXVCJ9.eyJlbmNyeXB0ZWRFbWFpbCI6ImRiMmJhYzY4NmFiNjEyNDdiNjZmZDQyMDZhOWEyODRlMGY5MzFlNzJmOWU0MmMyZDlmZjg4MjBkZDUxNmYyMjkiLCJ0b2tlbklkIjoiOTZiNWJhNDQtOWE4Mi00ZTI4LThmYjYtOWQ3MTY2NGRkZTI1IiwiaWF0IjoxNzM4OTMxOTU3LCJleHAiOjE3Mzg5MzI4NTcsImF1ZCI6IjxtQG1vYmlsQGVfQGFwcF9AdWRpZW5AY2U-IiwiaXNzIjoiPHNAdmUkaW5nQG9sZF9pQEBzc3VyQGU-Iiwic3ViIjoiYWxpLnB5ZGV2ZWxvcGVyOEBnbWFpbC5jb20iLCJqdGkiOiI5NmI1YmE0NC05YTgyLTRlMjgtOGZiNi05ZDcxNjY0ZGRlMjUifQ.HfpABZKYpt1n4tLz-A6lXiVgRhoTo6OEewcnZvnmToQELy2W5AIHs580gQe0OfUFrCjPHxrqH5BE2O7DqdqZQg"
/// createdAt : "2025-02-07T12:39:18.213Z"
/// updatedAt : "2025-02-07T12:39:18.213Z"

CreatedUser createdUserFromJson(String str) =>
    CreatedUser.fromJson(json.decode(str));
String createdUserToJson(CreatedUser data) => json.encode(data.toJson());
class CreatedUser {
  CreatedUser({
    this.id,
    this.accountId,
    this.userType,
    this.firstName,
    this.surname,
    this.dateOfBirthday,
    this.email,
    this.phoneNumber,
    this.imageUrl,
    this.moneyBalance,
    this.metalBalance,
    this.accessToken,
    this.leanCustomerId,
    this.createdAt,
    this.updatedAt,
  });

  String? id;
  String? accountId;
  String? userType;
  NameModel? firstName; // <-- change here
  NameModel? surname;   // <-- change here
  String? dateOfBirthday;
  String? email;
  String? phoneNumber;
  String? imageUrl;
  num? moneyBalance;
  num? metalBalance;
  String? accessToken;
  String? leanCustomerId;
  String? createdAt;
  String? updatedAt;

  CreatedUser.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    accountId = json['accountId'];
    userType = json['userType'];
    firstName =
        json['firstName'] != null ? NameModel.fromJson(json['firstName']) : null;
    surname =
        json['surname'] != null ? NameModel.fromJson(json['surname']) : null;
    leanCustomerId = json['leanCustomerId'];
    dateOfBirthday = json['dateOfBirthday'];
    email = json['email'];
    phoneNumber = json['phoneNumber'];
    imageUrl = json['imageUrl'];
    moneyBalance = json['moneyBalance'];
    metalBalance = json['metalBalance'];
    accessToken = json['accessToken'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'accountId': accountId,
        'userType': userType,
        'firstName': firstName?.toJson(),
        'surname': surname?.toJson(),
        'leanCustomerId': leanCustomerId,
        'dateOfBirthday': dateOfBirthday,
        'email': email,
        'phoneNumber': phoneNumber,
        'imageUrl': imageUrl,
        'moneyBalance': moneyBalance,
        'metalBalance': metalBalance,
        'accessToken': accessToken,
        'createdAt': createdAt,
        'updatedAt': updatedAt,
      };
}
class NameModel {
  NameModel({this.en, this.ar});

  NameModel.fromJson(Map<String, dynamic> json) {
    en = json['en'];
    ar = json['ar'];
  }

  String? en;
  String? ar;

  Map<String, dynamic> toJson() => {
        'en': en,
        'ar': ar,
      };
}
