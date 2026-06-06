import 'dart:convert';

/// status : "success"
/// code : 1
/// message : "OK: The request has succeeded."
/// payload : {"allUsers":[{"_id":"6851239331bbbe4e502757b9","accountId":"794301598","firstName":"Uroosa","surname":"Fatima","email":"uroosafatimaibrahim@gmail.com","phoneNumber":"00971505297595","imageUrl":""},{"_id":"684d4d3353a8ce4dd2e3c57c","accountId":"794301597","firstName":"Asmat","surname":"Ullah","email":"asmatwazir909@gmail.com","phoneNumber":"00971524378788","imageUrl":""},{"_id":"684bdd9d53a8ce4dd2474144","accountId":"794301596","firstName":"Muhammad","surname":"Tayyab","email":"mobileapp@saveingold.ae","phoneNumber":"00971552025311","imageUrl":""},{"_id":"684bd3d953a8ce4dd2436138","accountId":"794301594","firstName":"Mr","surname":"Asmat","email":"asmatwazir90@gmail.com","phoneNumber":"00971524378774","imageUrl":""},{"_id":"684add0e53a8ce4dd2337a05","accountId":"794301590","firstName":"a","surname":"a","email":"g@gmail.com","phoneNumber":"00971524378770","imageUrl":""},{"_id":"684a9b0cfd3c2530003603ce","accountId":"794301588","firstName":"ahmed","surname":"alabid","email":"odasim2033@gmail.com","phoneNumber":"00971551062774","imageUrl":""},{"_id":"68493495ce4e52ac48384b77","accountId":"794301586","firstName":"Asmat","surname":"Ullah","email":"asmatwazir901@gmail.com","phoneNumber":"00971524378779","imageUrl":""},{"_id":"68403bdddff5c7bf8220b536","accountId":"794301584","firstName":"Haider","surname":"Ali","email":"malisherm111@gmail.com","phoneNumber":"00971516887210","imageUrl":""},{"_id":"683e95207d77d4124183254c","accountId":"794301582","firstName":"Haider","surname":"Ali","email":"nodeno.jts.dev@gmail.com","phoneNumber":"00971553831575","imageUrl":""},{"_id":"683da0767d77d412416eec73","accountId":"794301581","firstName":"Muhammad","surname":"Bilal","email":"saveingoldbilal@gmail.com","phoneNumber":"00971522292346","imageUrl":""},{"_id":"683d50237d77d4124164597f","accountId":"794301578","firstName":"aya","surname":"alissa","email":"myh@yahoo.com","phoneNumber":"00971586918655","imageUrl":""},{"_id":"683d4e667d77d4124162639f","accountId":"794301577","firstName":"مؤمن","surname":"عبدالهادي أبوضيف مدين","email":"momenzizo50@gmail.com","phoneNumber":"00971545358380","imageUrl":""},{"_id":"683d4db47d77d4124160413c","accountId":"794301576","firstName":"Haider","surname":"Ali","email":"naqsh.o.tameer@gmail.com","phoneNumber":"00971553831523","imageUrl":""},{"_id":"6839ba778bef1a54c14164c9","accountId":"794301572","firstName":"Mohammed","surname":"HASHIM","email":"mohammed@dijllahgold.com","phoneNumber":"00971504636400","imageUrl":""},{"_id":"683996cf74f5331eb2ccd501","accountId":"794301571","firstName":"Lisha","surname":"Abraham","email":"lisha@dijllahgold.com","phoneNumber":"00971562757782","imageUrl":""},{"_id":"683824cc6a451c8f2d3d9b26","accountId":"822272416","firstName":"Asmat","surname":"ullah","email":"asmatwazir906@gmail.com","phoneNumber":"00971524378778","imageUrl":""},{"_id":"6838089e6a451c8f2d37d14d","accountId":"631282716","firstName":"Haider","surname":"Sher","email":"ali.pydeveloper6@gmail.com","phoneNumber":"00971506687218","imageUrl":""},{"_id":"68346f3950f31704f01bf659","accountId":"106958992","firstName":"Bilal","surname":"Shabbir","email":"bilalsaveingold@gmail.com","phoneNumber":"00971522292343","imageUrl":""},{"_id":"682f13c85592fd7a25c0dc67","accountId":"428591056","firstName":"Amro","surname":"Jaber","email":"info@saveingold.ae","phoneNumber":"00971561681738","imageUrl":""}]}

AllUserResponse allUserResponseFromJson(String str) =>
    AllUserResponse.fromJson(json.decode(str));
String allUserResponseToJson(AllUserResponse data) =>
    json.encode(data.toJson());

class AllUserResponse {
  AllUserResponse({
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

  AllUserResponse.fromJson(dynamic json) {
    _status = json['status'];
    _code = json['code'];
    _message = json['message'];
    _payload = json['payload'] != null
        ? Payload.fromJson(json['payload'])
        : null;
  }
  String? _status;
  num? _code;
  String? _message;
  Payload? _payload;
  AllUserResponse copyWith({
    String? status,
    num? code,
    String? message,
    Payload? payload,
  }) => AllUserResponse(
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

/// allUsers : [{"_id":"6851239331bbbe4e502757b9","accountId":"794301598","firstName":"Uroosa","surname":"Fatima","email":"uroosafatimaibrahim@gmail.com","phoneNumber":"00971505297595","imageUrl":""},{"_id":"684d4d3353a8ce4dd2e3c57c","accountId":"794301597","firstName":"Asmat","surname":"Ullah","email":"asmatwazir909@gmail.com","phoneNumber":"00971524378788","imageUrl":""},{"_id":"684bdd9d53a8ce4dd2474144","accountId":"794301596","firstName":"Muhammad","surname":"Tayyab","email":"mobileapp@saveingold.ae","phoneNumber":"00971552025311","imageUrl":""},{"_id":"684bd3d953a8ce4dd2436138","accountId":"794301594","firstName":"Mr","surname":"Asmat","email":"asmatwazir90@gmail.com","phoneNumber":"00971524378774","imageUrl":""},{"_id":"684add0e53a8ce4dd2337a05","accountId":"794301590","firstName":"a","surname":"a","email":"g@gmail.com","phoneNumber":"00971524378770","imageUrl":""},{"_id":"684a9b0cfd3c2530003603ce","accountId":"794301588","firstName":"ahmed","surname":"alabid","email":"odasim2033@gmail.com","phoneNumber":"00971551062774","imageUrl":""},{"_id":"68493495ce4e52ac48384b77","accountId":"794301586","firstName":"Asmat","surname":"Ullah","email":"asmatwazir901@gmail.com","phoneNumber":"00971524378779","imageUrl":""},{"_id":"68403bdddff5c7bf8220b536","accountId":"794301584","firstName":"Haider","surname":"Ali","email":"malisherm111@gmail.com","phoneNumber":"00971516887210","imageUrl":""},{"_id":"683e95207d77d4124183254c","accountId":"794301582","firstName":"Haider","surname":"Ali","email":"nodeno.jts.dev@gmail.com","phoneNumber":"00971553831575","imageUrl":""},{"_id":"683da0767d77d412416eec73","accountId":"794301581","firstName":"Muhammad","surname":"Bilal","email":"saveingoldbilal@gmail.com","phoneNumber":"00971522292346","imageUrl":""},{"_id":"683d50237d77d4124164597f","accountId":"794301578","firstName":"aya","surname":"alissa","email":"myh@yahoo.com","phoneNumber":"00971586918655","imageUrl":""},{"_id":"683d4e667d77d4124162639f","accountId":"794301577","firstName":"مؤمن","surname":"عبدالهادي أبوضيف مدين","email":"momenzizo50@gmail.com","phoneNumber":"00971545358380","imageUrl":""},{"_id":"683d4db47d77d4124160413c","accountId":"794301576","firstName":"Haider","surname":"Ali","email":"naqsh.o.tameer@gmail.com","phoneNumber":"00971553831523","imageUrl":""},{"_id":"6839ba778bef1a54c14164c9","accountId":"794301572","firstName":"Mohammed","surname":"HASHIM","email":"mohammed@dijllahgold.com","phoneNumber":"00971504636400","imageUrl":""},{"_id":"683996cf74f5331eb2ccd501","accountId":"794301571","firstName":"Lisha","surname":"Abraham","email":"lisha@dijllahgold.com","phoneNumber":"00971562757782","imageUrl":""},{"_id":"683824cc6a451c8f2d3d9b26","accountId":"822272416","firstName":"Asmat","surname":"ullah","email":"asmatwazir906@gmail.com","phoneNumber":"00971524378778","imageUrl":""},{"_id":"6838089e6a451c8f2d37d14d","accountId":"631282716","firstName":"Haider","surname":"Sher","email":"ali.pydeveloper6@gmail.com","phoneNumber":"00971506687218","imageUrl":""},{"_id":"68346f3950f31704f01bf659","accountId":"106958992","firstName":"Bilal","surname":"Shabbir","email":"bilalsaveingold@gmail.com","phoneNumber":"00971522292343","imageUrl":""},{"_id":"682f13c85592fd7a25c0dc67","accountId":"428591056","firstName":"Amro","surname":"Jaber","email":"info@saveingold.ae","phoneNumber":"00971561681738","imageUrl":""}]

Payload payloadFromJson(String str) => Payload.fromJson(json.decode(str));
String payloadToJson(Payload data) => json.encode(data.toJson());

class Payload {
  Payload({
    List<AllAppUsers>? allUsers,
  }) {
    _allUsers = allUsers;
  }

  Payload.fromJson(dynamic json) {
    if (json['allUsers'] != null) {
      _allUsers = [];
      json['allUsers'].forEach((v) {
        _allUsers?.add(AllAppUsers.fromJson(v));
      });
    }
  }
  List<AllAppUsers>? _allUsers;
  Payload copyWith({
    List<AllAppUsers>? allUsers,
  }) => Payload(
    allUsers: allUsers ?? _allUsers,
  );
  List<AllAppUsers>? get allUsers => _allUsers;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (_allUsers != null) {
      map['allUsers'] = _allUsers?.map((v) => v.toJson()).toList();
    }
    return map;
  }
}

/// _id : "6851239331bbbe4e502757b9"
/// accountId : "794301598"
/// firstName : "Uroosa"
/// surname : "Fatima"
/// email : "uroosafatimaibrahim@gmail.com"
/// phoneNumber : "00971505297595"
/// imageUrl : ""

AllAppUsers allUsersFromJson(String str) =>
    AllAppUsers.fromJson(json.decode(str));
String allUsersToJson(AllAppUsers data) => json.encode(data.toJson());

class AllAppUsers {
  AllUsers({
    String? id,
    String? accountId,
    String? firstName,
    String? surname,
    String? email,
    String? phoneNumber,
    String? imageUrl,
  }) {
    _id = id;
    _accountId = accountId;
    _firstName = firstName;
    _surname = surname;
    _email = email;
    _phoneNumber = phoneNumber;
    _imageUrl = imageUrl;
  }

  AllAppUsers.fromJson(dynamic json) {
    _id = json['_id'];
    _accountId = json['accountId'];
    _firstName = json['firstName'];
    _surname = json['surname'];
    _email = json['email'];
    _phoneNumber = json['phoneNumber'];
    _imageUrl = json['imageUrl'];
  }
  String? _id;
  String? _accountId;
  String? _firstName;
  String? _surname;
  String? _email;
  String? _phoneNumber;
  String? _imageUrl;
  AllAppUsers copyWith({
    String? id,
    String? accountId,
    String? firstName,
    String? surname,
    String? email,
    String? phoneNumber,
    String? imageUrl,
  }) => AllUsers(
    id: id ?? _id,
    accountId: accountId ?? _accountId,
    firstName: firstName ?? _firstName,
    surname: surname ?? _surname,
    email: email ?? _email,
    phoneNumber: phoneNumber ?? _phoneNumber,
    imageUrl: imageUrl ?? _imageUrl,
  );
  String? get id => _id;
  String? get accountId => _accountId;
  String? get firstName => _firstName;
  String? get surname => _surname;
  String? get email => _email;
  String? get phoneNumber => _phoneNumber;
  String? get imageUrl => _imageUrl;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['_id'] = _id;
    map['accountId'] = _accountId;
    map['firstName'] = _firstName;
    map['surname'] = _surname;
    map['email'] = _email;
    map['phoneNumber'] = _phoneNumber;
    map['imageUrl'] = _imageUrl;
    return map;
  }
}
