import 'dart:convert';
/// status : "success"
/// code : 1
/// message : "OK: The request has succeeded."
/// payload : {"page":1,"limit":10,"totalPages":1,"hasNextPage":false,"hasPreviousPage":false,"allLoanRequests":[{"_id":"6853d797f0c7f8e0507a88fc","userId":{"_id":"683824cc6a451c8f2d3d9b26","accountId":"822272416","userType":"Real","firstName":"Mr","surname":"Waxir","email":"asmatwazir906@gmail.com","phoneNumber":"00971524378778","imageUrl":"","createdAt":"2025-05-29T09:11:40.205Z","updatedAt":"2025-06-19T09:36:02.927Z"},"branchId":"6815be3f09cf95538a3b446b","loanAmount":1000,"loanComment":"Accept","loanStatus":"Approved","balanceInMoneyWallet":750749.03,"balanceInMetalWallet":350.9452999999999,"metalFroze":5.0259,"transactionId":"TrxId-112232680338","createdAt":"2025-06-19T09:25:43.928Z","updatedAt":"2025-06-19T09:39:35.097Z"}]}

GetAllLoanResponse getAllLoanResponseFromJson(String str) => GetAllLoanResponse.fromJson(json.decode(str));
String getAllLoanResponseToJson(GetAllLoanResponse data) => json.encode(data.toJson());
class GetAllLoanResponse {
  GetAllLoanResponse({
      String? status, 
      num? code, 
      String? message, 
      Payload? payload,}){
    _status = status;
    _code = code;
    _message = message;
    _payload = payload;
}

  GetAllLoanResponse.fromJson(dynamic json) {
    _status = json['status'];
    _code = json['code'];
    _message = json['message'];
    _payload = json['payload'] != null ? Payload.fromJson(json['payload']) : null;
  }
  String? _status;
  num? _code;
  String? _message;
  Payload? _payload;
GetAllLoanResponse copyWith({  String? status,
  num? code,
  String? message,
  Payload? payload,
}) => GetAllLoanResponse(  status: status ?? _status,
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

/// page : 1
/// limit : 10
/// totalPages : 1
/// hasNextPage : false
/// hasPreviousPage : false
/// allLoanRequests : [{"_id":"6853d797f0c7f8e0507a88fc","userId":{"_id":"683824cc6a451c8f2d3d9b26","accountId":"822272416","userType":"Real","firstName":"Mr","surname":"Waxir","email":"asmatwazir906@gmail.com","phoneNumber":"00971524378778","imageUrl":"","createdAt":"2025-05-29T09:11:40.205Z","updatedAt":"2025-06-19T09:36:02.927Z"},"branchId":"6815be3f09cf95538a3b446b","loanAmount":1000,"loanComment":"Accept","loanStatus":"Approved","balanceInMoneyWallet":750749.03,"balanceInMetalWallet":350.9452999999999,"metalFroze":5.0259,"transactionId":"TrxId-112232680338","createdAt":"2025-06-19T09:25:43.928Z","updatedAt":"2025-06-19T09:39:35.097Z"}]

Payload payloadFromJson(String str) => Payload.fromJson(json.decode(str));
String payloadToJson(Payload data) => json.encode(data.toJson());
class Payload {
  Payload({
      num? page, 
      num? limit, 
      num? totalPages, 
      bool? hasNextPage, 
      bool? hasPreviousPage, 
      List<UserAllLoanRequests>? allLoanRequests,}){
    _page = page;
    _limit = limit;
    _totalPages = totalPages;
    _hasNextPage = hasNextPage;
    _hasPreviousPage = hasPreviousPage;
    _allLoanRequests = allLoanRequests;
}

  Payload.fromJson(dynamic json) {
    _page = json['page'];
    _limit = json['limit'];
    _totalPages = json['totalPages'];
    _hasNextPage = json['hasNextPage'];
    _hasPreviousPage = json['hasPreviousPage'];
    if (json['allLoanRequests'] != null) {
      _allLoanRequests = [];
      json['allLoanRequests'].forEach((v) {
        _allLoanRequests?.add(UserAllLoanRequests.fromJson(v));
      });
    }
  }
  num? _page;
  num? _limit;
  num? _totalPages;
  bool? _hasNextPage;
  bool? _hasPreviousPage;
  List<UserAllLoanRequests>? _allLoanRequests;
Payload copyWith({  num? page,
  num? limit,
  num? totalPages,
  bool? hasNextPage,
  bool? hasPreviousPage,
  List<UserAllLoanRequests>? allLoanRequests,
}) => Payload(  page: page ?? _page,
  limit: limit ?? _limit,
  totalPages: totalPages ?? _totalPages,
  hasNextPage: hasNextPage ?? _hasNextPage,
  hasPreviousPage: hasPreviousPage ?? _hasPreviousPage,
  allLoanRequests: allLoanRequests ?? _allLoanRequests,
);
  num? get page => _page;
  num? get limit => _limit;
  num? get totalPages => _totalPages;
  bool? get hasNextPage => _hasNextPage;
  bool? get hasPreviousPage => _hasPreviousPage;
  List<UserAllLoanRequests>? get allLoanRequests => _allLoanRequests;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['page'] = _page;
    map['limit'] = _limit;
    map['totalPages'] = _totalPages;
    map['hasNextPage'] = _hasNextPage;
    map['hasPreviousPage'] = _hasPreviousPage;
    if (_allLoanRequests != null) {
      map['allLoanRequests'] = _allLoanRequests?.map((v) => v.toJson()).toList();
    }
    return map;
  }

}

/// _id : "6853d797f0c7f8e0507a88fc"
/// userId : {"_id":"683824cc6a451c8f2d3d9b26","accountId":"822272416","userType":"Real","firstName":"Mr","surname":"Waxir","email":"asmatwazir906@gmail.com","phoneNumber":"00971524378778","imageUrl":"","createdAt":"2025-05-29T09:11:40.205Z","updatedAt":"2025-06-19T09:36:02.927Z"}
/// branchId : "6815be3f09cf95538a3b446b"
/// loanAmount : 1000
/// loanComment : "Accept"
/// loanStatus : "Approved"
/// balanceInMoneyWallet : 750749.03
/// balanceInMetalWallet : 350.9452999999999
/// metalFroze : 5.0259
/// transactionId : "TrxId-112232680338"
/// createdAt : "2025-06-19T09:25:43.928Z"
/// updatedAt : "2025-06-19T09:39:35.097Z"

UserAllLoanRequests allLoanRequestsFromJson(String str) => UserAllLoanRequests.fromJson(json.decode(str));
String allLoanRequestsToJson(UserAllLoanRequests data) => json.encode(data.toJson());
class UserAllLoanRequests {
  AllLoanRequests({
      String? id, 
      UserId? userId, 
      String? branchId, 
      num? loanAmount, 
      String? loanComment, 
      String? loanStatus, 
      num? balanceInMoneyWallet, 
      num? balanceInMetalWallet, 
      num? metalFroze, 
      String? transactionId, 
      String? createdAt, 
      String? updatedAt,}){
    _id = id;
    _userId = userId;
    _branchId = branchId;
    _loanAmount = loanAmount;
    _loanComment = loanComment;
    _loanStatus = loanStatus;
    _balanceInMoneyWallet = balanceInMoneyWallet;
    _balanceInMetalWallet = balanceInMetalWallet;
    _metalFroze = metalFroze;
    _transactionId = transactionId;
    _createdAt = createdAt;
    _updatedAt = updatedAt;
}

  UserAllLoanRequests.fromJson(dynamic json) {
    _id = json['_id'];
    _userId = json['userId'] != null ? UserId.fromJson(json['userId']) : null;
    _branchId = json['branchId'];
    _loanAmount = json['loanAmount'];
    _loanComment = json['loanComment'];
    _loanStatus = json['loanStatus'];
    _balanceInMoneyWallet = json['balanceInMoneyWallet'];
    _balanceInMetalWallet = json['balanceInMetalWallet'];
    _metalFroze = json['metalFroze'];
    _transactionId = json['transactionId'];
    _createdAt = json['createdAt'];
    _updatedAt = json['updatedAt'];
  }
  String? _id;
  UserId? _userId;
  String? _branchId;
  num? _loanAmount;
  String? _loanComment;
  String? _loanStatus;
  num? _balanceInMoneyWallet;
  num? _balanceInMetalWallet;
  num? _metalFroze;
  String? _transactionId;
  String? _createdAt;
  String? _updatedAt;
UserAllLoanRequests copyWith({  String? id,
  UserId? userId,
  String? branchId,
  num? loanAmount,
  String? loanComment,
  String? loanStatus,
  num? balanceInMoneyWallet,
  num? balanceInMetalWallet,
  num? metalFroze,
  String? transactionId,
  String? createdAt,
  String? updatedAt,
}) => AllLoanRequests(  id: id ?? _id,
  userId: userId ?? _userId,
  branchId: branchId ?? _branchId,
  loanAmount: loanAmount ?? _loanAmount,
  loanComment: loanComment ?? _loanComment,
  loanStatus: loanStatus ?? _loanStatus,
  balanceInMoneyWallet: balanceInMoneyWallet ?? _balanceInMoneyWallet,
  balanceInMetalWallet: balanceInMetalWallet ?? _balanceInMetalWallet,
  metalFroze: metalFroze ?? _metalFroze,
  transactionId: transactionId ?? _transactionId,
  createdAt: createdAt ?? _createdAt,
  updatedAt: updatedAt ?? _updatedAt,
);
  String? get id => _id;
  UserId? get userId => _userId;
  String? get branchId => _branchId;
  num? get loanAmount => _loanAmount;
  String? get loanComment => _loanComment;
  String? get loanStatus => _loanStatus;
  num? get balanceInMoneyWallet => _balanceInMoneyWallet;
  num? get balanceInMetalWallet => _balanceInMetalWallet;
  num? get metalFroze => _metalFroze;
  String? get transactionId => _transactionId;
  String? get createdAt => _createdAt;
  String? get updatedAt => _updatedAt;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['_id'] = _id;
    if (_userId != null) {
      map['userId'] = _userId?.toJson();
    }
    map['branchId'] = _branchId;
    map['loanAmount'] = _loanAmount;
    map['loanComment'] = _loanComment;
    map['loanStatus'] = _loanStatus;
    map['balanceInMoneyWallet'] = _balanceInMoneyWallet;
    map['balanceInMetalWallet'] = _balanceInMetalWallet;
    map['metalFroze'] = _metalFroze;
    map['transactionId'] = _transactionId;
    map['createdAt'] = _createdAt;
    map['updatedAt'] = _updatedAt;
    return map;
  }

}

/// _id : "683824cc6a451c8f2d3d9b26"
/// accountId : "822272416"
/// userType : "Real"
/// firstName : "Mr"
/// surname : "Waxir"
/// email : "asmatwazir906@gmail.com"
/// phoneNumber : "00971524378778"
/// imageUrl : ""
/// createdAt : "2025-05-29T09:11:40.205Z"
/// updatedAt : "2025-06-19T09:36:02.927Z"

UserId userIdFromJson(String str) => UserId.fromJson(json.decode(str));
String userIdToJson(UserId data) => json.encode(data.toJson());
class UserId {
  UserId({
      String? id, 
      String? accountId, 
      String? userType, 
      String? firstName, 
      String? surname, 
      String? email, 
      String? phoneNumber, 
      String? imageUrl, 
      String? createdAt, 
      String? updatedAt,}){
    _id = id;
    _accountId = accountId;
    _userType = userType;
    _firstName = firstName;
    _surname = surname;
    _email = email;
    _phoneNumber = phoneNumber;
    _imageUrl = imageUrl;
    _createdAt = createdAt;
    _updatedAt = updatedAt;
}

  UserId.fromJson(dynamic json) {
    _id = json['_id'];
    _accountId = json['accountId'];
    _userType = json['userType'];
    _firstName = json['firstName'];
    _surname = json['surname'];
    _email = json['email'];
    _phoneNumber = json['phoneNumber'];
    _imageUrl = json['imageUrl'];
    _createdAt = json['createdAt'];
    _updatedAt = json['updatedAt'];
  }
  String? _id;
  String? _accountId;
  String? _userType;
  String? _firstName;
  String? _surname;
  String? _email;
  String? _phoneNumber;
  String? _imageUrl;
  String? _createdAt;
  String? _updatedAt;
UserId copyWith({  String? id,
  String? accountId,
  String? userType,
  String? firstName,
  String? surname,
  String? email,
  String? phoneNumber,
  String? imageUrl,
  String? createdAt,
  String? updatedAt,
}) => UserId(  id: id ?? _id,
  accountId: accountId ?? _accountId,
  userType: userType ?? _userType,
  firstName: firstName ?? _firstName,
  surname: surname ?? _surname,
  email: email ?? _email,
  phoneNumber: phoneNumber ?? _phoneNumber,
  imageUrl: imageUrl ?? _imageUrl,
  createdAt: createdAt ?? _createdAt,
  updatedAt: updatedAt ?? _updatedAt,
);
  String? get id => _id;
  String? get accountId => _accountId;
  String? get userType => _userType;
  String? get firstName => _firstName;
  String? get surname => _surname;
  String? get email => _email;
  String? get phoneNumber => _phoneNumber;
  String? get imageUrl => _imageUrl;
  String? get createdAt => _createdAt;
  String? get updatedAt => _updatedAt;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['_id'] = _id;
    map['accountId'] = _accountId;
    map['userType'] = _userType;
    map['firstName'] = _firstName;
    map['surname'] = _surname;
    map['email'] = _email;
    map['phoneNumber'] = _phoneNumber;
    map['imageUrl'] = _imageUrl;
    map['createdAt'] = _createdAt;
    map['updatedAt'] = _updatedAt;
    return map;
  }

}