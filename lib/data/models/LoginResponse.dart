import 'dart:convert';

LoginResponse loginResponseFromJson(String str) =>
    LoginResponse.fromJson(json.decode(str));

String loginResponseToJson(LoginResponse data) => json.encode(data.toJson());

class LoginResponse {
  LoginResponse({
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

  LoginResponse.fromJson(dynamic json) {
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

/// ---------------- Payload ----------------

class Payload {
  Payload({
    UserInfo? userInfo,
  }) {
    _userInfo = userInfo;
  }

  Payload.fromJson(dynamic json) {
    _userInfo =
        json['userInfo'] != null ? UserInfo.fromJson(json['userInfo']) : null;
  }

  UserInfo? _userInfo;

  UserInfo? get userInfo => _userInfo;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (_userInfo != null) {
      map['userInfo'] = _userInfo?.toJson();
    }
    return map;
  }
}

/// ---------------- UserInfo ----------------

class UserInfo {
  UserInfo({
    String? id,
    String? accountId,
    String? userType,
    String? email,
    NameField? firstName,
    NameField? surname,
    String? phoneNumber,
    String? imageUrl,
    bool? isPhoneVerified,
    bool? isEmailVerified,
    bool? isUserKYCVerified,
    String? accessToken,
    String? timezone,
    String? language,
    String? createdAt,
    String? updatedAt,
    String? leanCustomerId,
  }) {
    _id = id;
    _accountId = accountId;
    _userType = userType;
    _email = email;
    _firstName = firstName;
    _surname = surname;
    _phoneNumber = phoneNumber;
    _imageUrl = imageUrl;
    _isPhoneVerified = isPhoneVerified;
    _isEmailVerified = isEmailVerified;
    _isUserKYCVerified = isUserKYCVerified;
    _accessToken = accessToken;
    _timezone = timezone;
    _language = language;
    _createdAt = createdAt;
    _updatedAt = updatedAt;
    _leanCustomerId = leanCustomerId;
  }

  UserInfo.fromJson(dynamic json) {
    _id = json['id'];
    _accountId = json['accountId'];
    _userType = json['userType'];
    _email = json['email'];
    _firstName =
        json['firstName'] != null ? NameField.fromJson(json['firstName']) : null;
    _surname =
        json['surname'] != null ? NameField.fromJson(json['surname']) : null;
    _phoneNumber = json['phoneNumber'];
    _imageUrl = json['imageUrl'];
    _isPhoneVerified = json['isPhoneVerified'];
    _isEmailVerified = json['isEmailVerified'];
    _isUserKYCVerified = json['isUserKYCVerified'];
    _accessToken = json['accessToken'];
    _timezone = json['timezone'];
    _language = json['language'];
    _createdAt = json['createdAt'];
    _updatedAt = json['updatedAt'];
    _leanCustomerId = json['leanCustomerId'];
  }

  String? _id;
  String? _accountId;
  String? _userType;
  String? _email;
  NameField? _firstName;
  NameField? _surname;
  String? _phoneNumber;
  String? _imageUrl;
  bool? _isPhoneVerified;
  bool? _isEmailVerified;
  bool? _isUserKYCVerified;
  String? _accessToken;
  String? _timezone;
  String? _language;
  String? _createdAt;
  String? _updatedAt;
  String? _leanCustomerId;

  String? get id => _id;
  String? get accountId => _accountId;
  String? get userType => _userType;
  String? get email => _email;
  NameField? get firstName => _firstName;
  NameField? get surname => _surname;
  String? get phoneNumber => _phoneNumber;
  String? get imageUrl => _imageUrl;
  bool? get isPhoneVerified => _isPhoneVerified;
  bool? get isEmailVerified => _isEmailVerified;
  bool? get isUserKYCVerified => _isUserKYCVerified;
  String? get accessToken => _accessToken;
  String? get timezone => _timezone;
  String? get language => _language;
  String? get createdAt => _createdAt;
  String? get updatedAt => _updatedAt;
  String? get leanCustomerId => _leanCustomerId;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = _id;
    map['accountId'] = _accountId;
    map['userType'] = _userType;
    map['email'] = _email;
    if (_firstName != null) {
      map['firstName'] = _firstName?.toJson();
    }
    if (_surname != null) {
      map['surname'] = _surname?.toJson();
    }
    map['phoneNumber'] = _phoneNumber;
    map['imageUrl'] = _imageUrl;
    map['isPhoneVerified'] = _isPhoneVerified;
    map['isEmailVerified'] = _isEmailVerified;
    map['isUserKYCVerified'] = _isUserKYCVerified;
    map['accessToken'] = _accessToken;
    map['timezone'] = _timezone;
    map['language'] = _language;
    map['createdAt'] = _createdAt;
    map['updatedAt'] = _updatedAt;
    map['leanCustomerId'] = _leanCustomerId;
    return map;
  }
}

/// ---------------- NameField ----------------
/// For firstName and surname which now have {en, ar}
class NameField {
  NameField({
    String? en,
    String? ar,
  }) {
    _en = en;
    _ar = ar;
  }

  NameField.fromJson(dynamic json) {
    _en = json['en'];
    _ar = json['ar'];
  }

  String? _en;
  String? _ar;

  String? get en => _en;
  String? get ar => _ar;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['en'] = _en;
    map['ar'] = _ar;
    return map;
  }
}



// import 'dart:convert';

// /// status : "success"
// /// code : 1
// /// message : "OK: The request has succeeded."
// /// payload : {"userInfo":{"id":"67a5d44d76c057c14df952eb","userType":"Real","email":"ali.pydeveloper7@gmail.com","firstName":"Haider","surname":"Ali","phoneNumber":"0552025311","imageUrl":"","accessToken":"eyJhbGciOiJIUzUxMiIsInR5cCI6IkpXVCJ9.eyJlbmNyeXB0ZWRFbWFpbCI6IjQ3ZDAyYTFjMTU3ZGNkMjNkZjI0NGM5YmJjYTI2NThiY2JlM2E4NTM5NzA2YjM2NjUwMWZhMjI0YWJjZDViOTUiLCJ0b2tlbklkIjoiY2U1NjAxNjktMjVkYy00N2QzLWIyYWItYWZhMzA0NjIxMTExIiwiaWF0IjoxNzM4OTMxNDUzLCJleHAiOjE3Mzg5MzIzNTMsImF1ZCI6IjxtQG1vYmlsQGVfQGFwcF9AdWRpZW5AY2U-IiwiaXNzIjoiPHNAdmUkaW5nQG9sZF9pQEBzc3VyQGU-Iiwic3ViIjoiYWxpLnB5ZGV2ZWxvcGVyN0BnbWFpbC5jb20iLCJqdGkiOiJjZTU2MDE2OS0yNWRjLTQ3ZDMtYjJhYi1hZmEzMDQ2MjExMTEifQ.3vmqKFEK9err_dqmE4eCpWUJcadwIFolyKvGB2ljWowq8ebpK4HUpNTJUb8ej-uIljMEa7xxrCbexy2nlQiy_w","createdAt":"2025-02-07T09:37:17.280Z","updatedAt":"2025-02-07T12:30:53.428Z"}}

// LoginResponse loginResponseFromJson(String str) =>
//     LoginResponse.fromJson(json.decode(str));

// String loginResponseToJson(LoginResponse data) => json.encode(data.toJson());

// class LoginResponse {
//   LoginResponse({
//     String? status,
//     num? code,
//     String? message,
//     Payload? payload,
//   }) {
//     _status = status;
//     _code = code;
//     _message = message;
//     _payload = payload;
//   }

//   LoginResponse.fromJson(dynamic json) {
//     _status = json['status'];
//     _code = json['code'];
//     _message = json['message'];
//     _payload =
//         json['payload'] != null ? Payload.fromJson(json['payload']) : null;
//   }

//   String? _status;
//   num? _code;
//   String? _message;
//   Payload? _payload;

//   LoginResponse copyWith({
//     String? status,
//     num? code,
//     String? message,
//     Payload? payload,
//   }) =>
//       LoginResponse(
//         status: status ?? _status,
//         code: code ?? _code,
//         message: message ?? _message,
//         payload: payload ?? _payload,
//       );

//   String? get status => _status;

//   num? get code => _code;

//   String? get message => _message;

//   Payload? get payload => _payload;

//   Map<String, dynamic> toJson() {
//     final map = <String, dynamic>{};
//     map['status'] = _status;
//     map['code'] = _code;
//     map['message'] = _message;
//     if (_payload != null) {
//       map['payload'] = _payload?.toJson();
//     }
//     return map;
//   }
// }

// /// userInfo : {"id":"67a5d44d76c057c14df952eb","userType":"Real","email":"ali.pydeveloper7@gmail.com","firstName":"Haider","surname":"Ali","phoneNumber":"0552025311","imageUrl":"","accessToken":"eyJhbGciOiJIUzUxMiIsInR5cCI6IkpXVCJ9.eyJlbmNyeXB0ZWRFbWFpbCI6IjQ3ZDAyYTFjMTU3ZGNkMjNkZjI0NGM5YmJjYTI2NThiY2JlM2E4NTM5NzA2YjM2NjUwMWZhMjI0YWJjZDViOTUiLCJ0b2tlbklkIjoiY2U1NjAxNjktMjVkYy00N2QzLWIyYWItYWZhMzA0NjIxMTExIiwiaWF0IjoxNzM4OTMxNDUzLCJleHAiOjE3Mzg5MzIzNTMsImF1ZCI6IjxtQG1vYmlsQGVfQGFwcF9AdWRpZW5AY2U-IiwiaXNzIjoiPHNAdmUkaW5nQG9sZF9pQEBzc3VyQGU-Iiwic3ViIjoiYWxpLnB5ZGV2ZWxvcGVyN0BnbWFpbC5jb20iLCJqdGkiOiJjZTU2MDE2OS0yNWRjLTQ3ZDMtYjJhYi1hZmEzMDQ2MjExMTEifQ.3vmqKFEK9err_dqmE4eCpWUJcadwIFolyKvGB2ljWowq8ebpK4HUpNTJUb8ej-uIljMEa7xxrCbexy2nlQiy_w","createdAt":"2025-02-07T09:37:17.280Z","updatedAt":"2025-02-07T12:30:53.428Z"}

// Payload payloadFromJson(String str) => Payload.fromJson(json.decode(str));

// String payloadToJson(Payload data) => json.encode(data.toJson());

// class Payload {
//   Payload({
//     UserInfo? userInfo,
//   }) {
//     _userInfo = userInfo;
//   }

//   Payload.fromJson(dynamic json) {
//     _userInfo =
//         json['userInfo'] != null ? UserInfo.fromJson(json['userInfo']) : null;
//   }

//   UserInfo? _userInfo;

//   Payload copyWith({
//     UserInfo? userInfo,
//   }) =>
//       Payload(
//         userInfo: userInfo ?? _userInfo,
//       );

//   UserInfo? get userInfo => _userInfo;

//   Map<String, dynamic> toJson() {
//     final map = <String, dynamic>{};
//     if (_userInfo != null) {
//       map['userInfo'] = _userInfo?.toJson();
//     }
//     return map;
//   }
// }

// /// id : "67a5d44d76c057c14df952eb"
// /// userType : "Real"
// /// email : "ali.pydeveloper7@gmail.com"
// /// firstName : "Haider"
// /// surname : "Ali"
// /// phoneNumber : "0552025311"
// /// imageUrl : ""
// /// accessToken : "eyJhbGciOiJIUzUxMiIsInR5cCI6IkpXVCJ9.eyJlbmNyeXB0ZWRFbWFpbCI6IjQ3ZDAyYTFjMTU3ZGNkMjNkZjI0NGM5YmJjYTI2NThiY2JlM2E4NTM5NzA2YjM2NjUwMWZhMjI0YWJjZDViOTUiLCJ0b2tlbklkIjoiY2U1NjAxNjktMjVkYy00N2QzLWIyYWItYWZhMzA0NjIxMTExIiwiaWF0IjoxNzM4OTMxNDUzLCJleHAiOjE3Mzg5MzIzNTMsImF1ZCI6IjxtQG1vYmlsQGVfQGFwcF9AdWRpZW5AY2U-IiwiaXNzIjoiPHNAdmUkaW5nQG9sZF9pQEBzc3VyQGU-Iiwic3ViIjoiYWxpLnB5ZGV2ZWxvcGVyN0BnbWFpbC5jb20iLCJqdGkiOiJjZTU2MDE2OS0yNWRjLTQ3ZDMtYjJhYi1hZmEzMDQ2MjExMTEifQ.3vmqKFEK9err_dqmE4eCpWUJcadwIFolyKvGB2ljWowq8ebpK4HUpNTJUb8ej-uIljMEa7xxrCbexy2nlQiy_w"
// /// createdAt : "2025-02-07T09:37:17.280Z"
// /// updatedAt : "2025-02-07T12:30:53.428Z"

// UserInfo userInfoFromJson(String str) => UserInfo.fromJson(json.decode(str));

// String userInfoToJson(UserInfo data) => json.encode(data.toJson());

// class UserInfo {
//   UserInfo({
//     String? id,
//     String? accountId,
//     String? userType,
//     String? email,
//     String? firstName,
//     String? surname,
//     String? phoneNumber,
//     String? imageUrl,
//     String? accessToken,
//     String? createdAt,
//     String? updatedAt,
//     String? leanCustomerId,
//   }) {
//     _id = id;
//     _userType = userType;
//     _email = email;
//     _firstName = firstName;
//     _surname = surname;
//     _phoneNumber = phoneNumber;
//     _imageUrl = imageUrl;
//     _accountID = accountId;
//     _accessToken = accessToken;
//     _createdAt = createdAt;
//     _updatedAt = updatedAt;
//     _leanCustomerId = leanCustomerId;
//   }

//   UserInfo.fromJson(dynamic json) {
//     _id = json['id'];
//     _userType = json['userType'];
//     _email = json['email'];
//     _firstName = json['firstName'];
//     _surname = json['surname'];
//     _phoneNumber = json['phoneNumber'];
//     _imageUrl = json['imageUrl'];
//     _accessToken = json['accessToken'];
//     _createdAt = json['createdAt'];
//     _updatedAt = json['updatedAt'];
//     _accountID = json['accountId'];
//     _leanCustomerId = json['leanCustomerId'];
//   }

//   String? _id;
//   String? _accountID;
//   String? _userType;
//   String? _email;
//   String? _firstName;
//   String? _surname;
//   String? _phoneNumber;
//   String? _imageUrl;
//   String? _accessToken;
//   String? _createdAt;
//   String? _updatedAt;
//   String? _leanCustomerId;

//   UserInfo copyWith(
//           {String? id,
//           String? userType,
//           String? email,
//           String? accountId,
//           String? firstName,
//           String? surname,
//           String? phoneNumber,
//           String? imageUrl,
//           String? accessToken,
//           String? createdAt,
//           String? updatedAt,
//           String? leanCustomerId}) =>
//       UserInfo(
//           id: id ?? _id,
//           userType: userType ?? _userType,
//           email: email ?? _email,
//           firstName: firstName ?? _firstName,
//           surname: surname ?? _surname,
//           phoneNumber: phoneNumber ?? _phoneNumber,
//           imageUrl: imageUrl ?? _imageUrl,
//           accessToken: accessToken ?? _accessToken,
//           createdAt: createdAt ?? _createdAt,
//           updatedAt: updatedAt ?? _updatedAt,
//           leanCustomerId: leanCustomerId ?? _leanCustomerId,
//           accountId: accountId ?? _accountID);

//   String? get id => _id;
//   String? get accountId => _accountID;
//   String? get userType => _userType;

//   String? get email => _email;

//   String? get firstName => _firstName;

//   String? get surname => _surname;

//   String? get phoneNumber => _phoneNumber;
//   String? get createdAt => _createdAt;
//   String? get imageUrl => _imageUrl;

//   String? get accessToken => _accessToken;

//   String? get leanCustomerId => _leanCustomerId;

//   String? get updatedAt => _updatedAt;

//   Map<String, dynamic> toJson() {
//     final map = <String, dynamic>{};
//     map['id'] = _id;
//     map['userType'] = _userType;
//     map['email'] = _email;
//     map['firstName'] = _firstName;
//     map['surname'] = _surname;
//     map['phoneNumber'] = _phoneNumber;
//     map['leanCustomerId'] = _leanCustomerId;
//     map['imageUrl'] = _imageUrl;
//     map['accessToken'] = _accessToken;
//     map['createdAt'] = _createdAt;
//     map['updatedAt'] = _updatedAt;
//     return map;
//   }
// }
