/// code : 1
/// message : "User created."
/// data : {"createdUser":{"id":"6724740857631cea1ba8c42b","userType":"Individual","email":"dubai13@gmail.com","firstName":"Thor","surname":"Thunder","phoneNumber":"+971552025313","imageUrl":"https://tamayazbucket.s3.me-central-1.amazonaws.com/user-avatar.png","location":"16, 85th Street, Financial Centre Metro Dubai, United Arab Emirates 6721","houseNumber":"111","streetAddress":"Street 2","area":"Bur Dubai","emirate":"Dubai","isVerified":false,"accessToken":"eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJlbWFpbCI6ImR1YmFpMTNAZ21haWwuY29tIiwidG9rZW5JZCI6ImRmNjVjMDQyLWNkNGItNDAwOC05MmQ4LTA4Y2M2ODQ5OThjNCIsImlhdCI6MTczMDQ0MjI0OCwiZXhwIjoxNzMxMDQ3MDQ4fQ.rfbPEeYIKGakGJQjxsO5I1vYQl_kZLY6-IV0Z880IPM","refreshToken":"eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJlbWFpbCI6ImR1YmFpMTNAZ21haWwuY29tIiwidG9rZW5JZCI6ImRmNjVjMDQyLWNkNGItNDAwOC05MmQ4LTA4Y2M2ODQ5OThjNCIsImlhdCI6MTczMDQ0MjI0OCwiZXhwIjoxNzMxMDQ3MDQ4fQ.o9o58QCzZm3JpM1OYdGDbMOf8goAu5phXbPeaye24Ls","createdAt":"2024-11-01T06:24:08.827Z","updatedAt":"2024-11-01T06:24:08.827Z"}}
library;

class RegisterDetailResponse {
  RegisterDetailResponse({
    num? code,
    String? message,
    Data? data,
  }) {
    _code = code;
    _message = message;
    _data = data;
  }

  RegisterDetailResponse.fromJson(dynamic json) {
    _code = json['code'];
    _message = json['message'];
    _data = json['data'] != null ? Data.fromJson(json['data']) : null;
  }
  num? _code;
  String? _message;
  Data? _data;
  RegisterDetailResponse copyWith({
    num? code,
    String? message,
    Data? data,
  }) =>
      RegisterDetailResponse(
        code: code ?? _code,
        message: message ?? _message,
        data: data ?? _data,
      );
  num? get code => _code;
  String? get message => _message;
  Data? get data => _data;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['code'] = _code;
    map['message'] = _message;
    if (_data != null) {
      map['data'] = _data?.toJson();
    }
    return map;
  }
}

/// createdUser : {"id":"6724740857631cea1ba8c42b","userType":"Individual","email":"dubai13@gmail.com","firstName":"Thor","surname":"Thunder","phoneNumber":"+971552025313","imageUrl":"https://tamayazbucket.s3.me-central-1.amazonaws.com/user-avatar.png","location":"16, 85th Street, Financial Centre Metro Dubai, United Arab Emirates 6721","houseNumber":"111","streetAddress":"Street 2","area":"Bur Dubai","emirate":"Dubai","isVerified":false,"accessToken":"eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJlbWFpbCI6ImR1YmFpMTNAZ21haWwuY29tIiwidG9rZW5JZCI6ImRmNjVjMDQyLWNkNGItNDAwOC05MmQ4LTA4Y2M2ODQ5OThjNCIsImlhdCI6MTczMDQ0MjI0OCwiZXhwIjoxNzMxMDQ3MDQ4fQ.rfbPEeYIKGakGJQjxsO5I1vYQl_kZLY6-IV0Z880IPM","refreshToken":"eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJlbWFpbCI6ImR1YmFpMTNAZ21haWwuY29tIiwidG9rZW5JZCI6ImRmNjVjMDQyLWNkNGItNDAwOC05MmQ4LTA4Y2M2ODQ5OThjNCIsImlhdCI6MTczMDQ0MjI0OCwiZXhwIjoxNzMxMDQ3MDQ4fQ.o9o58QCzZm3JpM1OYdGDbMOf8goAu5phXbPeaye24Ls","createdAt":"2024-11-01T06:24:08.827Z","updatedAt":"2024-11-01T06:24:08.827Z"}

class Data {
  Data({
    CreatedUser? createdUser,
  }) {
    _createdUser = createdUser;
  }

  Data.fromJson(dynamic json) {
    _createdUser = json['createdUser'] != null
        ? CreatedUser.fromJson(json['createdUser'])
        : null;
  }
  CreatedUser? _createdUser;
  Data copyWith({
    CreatedUser? createdUser,
  }) =>
      Data(
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

/// id : "6724740857631cea1ba8c42b"
/// userType : "Individual"
/// email : "dubai13@gmail.com"
/// firstName : "Thor"
/// surname : "Thunder"
/// phoneNumber : "+971552025313"
/// imageUrl : "https://tamayazbucket.s3.me-central-1.amazonaws.com/user-avatar.png"
/// location : "16, 85th Street, Financial Centre Metro Dubai, United Arab Emirates 6721"
/// houseNumber : "111"
/// streetAddress : "Street 2"
/// area : "Bur Dubai"
/// emirate : "Dubai"
/// isVerified : false
/// accessToken : "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJlbWFpbCI6ImR1YmFpMTNAZ21haWwuY29tIiwidG9rZW5JZCI6ImRmNjVjMDQyLWNkNGItNDAwOC05MmQ4LTA4Y2M2ODQ5OThjNCIsImlhdCI6MTczMDQ0MjI0OCwiZXhwIjoxNzMxMDQ3MDQ4fQ.rfbPEeYIKGakGJQjxsO5I1vYQl_kZLY6-IV0Z880IPM"
/// refreshToken : "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJlbWFpbCI6ImR1YmFpMTNAZ21haWwuY29tIiwidG9rZW5JZCI6ImRmNjVjMDQyLWNkNGItNDAwOC05MmQ4LTA4Y2M2ODQ5OThjNCIsImlhdCI6MTczMDQ0MjI0OCwiZXhwIjoxNzMxMDQ3MDQ4fQ.o9o58QCzZm3JpM1OYdGDbMOf8goAu5phXbPeaye24Ls"
/// createdAt : "2024-11-01T06:24:08.827Z"
/// updatedAt : "2024-11-01T06:24:08.827Z"

class CreatedUser {
  CreatedUser({
    String? id,
    String? userType,
    String? email,
    String? firstName,
    String? surname,
    String? phoneNumber,
    String? imageUrl,
    String? location,
    String? houseNumber,
    String? streetAddress,
    String? area,
    String? emirate,
    bool? isVerified,
    String? accessToken,
    String? refreshToken,
    String? createdAt,
    String? leanCustomerId,
    String? updatedAt,
  }) {
    _id = id;
    _userType = userType;
    _email = email;
    _firstName = firstName;
    _surname = surname;
    _phoneNumber = phoneNumber;
    _imageUrl = imageUrl;
    _location = location;
    _houseNumber = houseNumber;
    _streetAddress = streetAddress;
    _area = area;
    _emirate = emirate;
    _isVerified = isVerified;
    _accessToken = accessToken;
    _refreshToken = refreshToken;
    _createdAt = createdAt;
    _leanCustomerId = leanCustomerId;
    _updatedAt = updatedAt;
  }

  CreatedUser.fromJson(dynamic json) {
    _id = json['id'];
    _userType = json['userType'];
    _email = json['email'];
    _firstName = json['firstName'];
    _surname = json['surname'];
    _phoneNumber = json['phoneNumber'];
    _imageUrl = json['imageUrl'];
    _location = json['location'];
    _houseNumber = json['houseNumber'];
    _streetAddress = json['streetAddress'];
    _area = json['area'];
    _emirate = json['emirate'];
    _isVerified = json['isVerified'];
    _accessToken = json['accessToken'];
    _refreshToken = json['refreshToken'];
    _createdAt = json['createdAt'];
    _updatedAt = json['updatedAt'];
    _leanCustomerId = json['leanCustomerId'];
  }
  String? _id;
  String? _userType;
  String? _email;
  String? _firstName;
  String? _surname;
  String? _phoneNumber;
  String? _imageUrl;
  String? _location;
  String? _houseNumber;
  String? _streetAddress;
  String? _area;
  String? _emirate;
  bool? _isVerified;
  String? _accessToken;
  String? _refreshToken;
  String? _leanCustomerId;
  String? _createdAt;
  String? _updatedAt;
  CreatedUser copyWith({
    String? id,
    String? userType,
    String? email,
    String? firstName,
    String? surname,
    String? phoneNumber,
    String? imageUrl,
    String? location,
    String? houseNumber,
    String? streetAddress,
    String? area,
    String? emirate,
    bool? isVerified,
    String? accessToken,
    String? refreshToken,
    String? createdAt,
    String? updatedAt,
    String? leanCustomerId,
  }) =>
      CreatedUser(
          id: id ?? _id,
          userType: userType ?? _userType,
          email: email ?? _email,
          firstName: firstName ?? _firstName,
          surname: surname ?? _surname,
          phoneNumber: phoneNumber ?? _phoneNumber,
          imageUrl: imageUrl ?? _imageUrl,
          location: location ?? _location,
          houseNumber: houseNumber ?? _houseNumber,
          streetAddress: streetAddress ?? _streetAddress,
          area: area ?? _area,
          emirate: emirate ?? _emirate,
          isVerified: isVerified ?? _isVerified,
          accessToken: accessToken ?? _accessToken,
          refreshToken: refreshToken ?? _refreshToken,
          createdAt: createdAt ?? _createdAt,
          updatedAt: updatedAt ?? _updatedAt,
          leanCustomerId: leanCustomerId ?? _leanCustomerId);
  String? get id => _id;
  String? get userType => _userType;
  String? get email => _email;
  String? get firstName => _firstName;
  String? get surname => _surname;
  String? get phoneNumber => _phoneNumber;
  String? get imageUrl => _imageUrl;
  String? get location => _location;
  String? get houseNumber => _houseNumber;
  String? get streetAddress => _streetAddress;
  String? get area => _area;
  String? get emirate => _emirate;
  bool? get isVerified => _isVerified;
  String? get accessToken => _accessToken;
  String? get refreshToken => _refreshToken;
  String? get createdAt => _createdAt;
  String? get updatedAt => _updatedAt;
  String? get leanCustomerId => _leanCustomerId;
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = _id;
    map['userType'] = _userType;
    map['email'] = _email;
    map['firstName'] = _firstName;
    map['surname'] = _surname;
    map['phoneNumber'] = _phoneNumber;
    map['imageUrl'] = _imageUrl;
    map['location'] = _location;
    map['houseNumber'] = _houseNumber;
    map['streetAddress'] = _streetAddress;
    map['area'] = _area;
    map['emirate'] = _emirate;
    map['isVerified'] = _isVerified;
    map['accessToken'] = _accessToken;
    map['refreshToken'] = _refreshToken;
    map['createdAt'] = _createdAt;
    map['updatedAt'] = _updatedAt;
    map['leanCustomerId'] = _leanCustomerId;
    return map;
  }
}
