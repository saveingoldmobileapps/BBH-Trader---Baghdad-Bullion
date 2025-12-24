import 'dart:convert';

/// status : "success"
/// code : 1
/// message : "OK: The request has succeeded."
/// payload : {"page":1,"limit":10,"totalPages":1,"hasNextPage":false,"hasPreviousPage":false,"kAllWithdraws":[{"_id":"682d953a8976f672ca695c72","userId":{"_id":"682c34254509d8b5373f3ce0","accountId":"254271564","userType":"Real","firstName":"Muhammad","surname":"Tayyab","email":"mobileapp@saveingold.ae","phoneNumber":"00971552025311","imageUrl":"","createdAt":"2025-05-20T07:49:57.205Z","updatedAt":"2025-05-21T08:56:25.974Z"},"beneficiaryName":"Amro Al Jaber","bankName":"Mashreq Bank","iban":"ABCD12345678901234567890","amount":100,"status":"Pending","moneyBalanceInWallet":8002,"transactionId":"TrxId-376875376479","createdAt":"2025-05-21T08:56:26.145Z","updatedAt":"2025-05-21T08:56:26.145Z","__v":0}]}

GetAllWithdrawalFundsResponse getAllWithdrawalFundsResponseFromJson(
        String str) =>
    GetAllWithdrawalFundsResponse.fromJson(json.decode(str));

String getAllWithdrawalFundsResponseToJson(
        GetAllWithdrawalFundsResponse data) =>
    json.encode(data.toJson());

class GetAllWithdrawalFundsResponse {
  GetAllWithdrawalFundsResponse({
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

  GetAllWithdrawalFundsResponse.fromJson(dynamic json) {
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

  GetAllWithdrawalFundsResponse copyWith({
    String? status,
    num? code,
    String? message,
    Payload? payload,
  }) =>
      GetAllWithdrawalFundsResponse(
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

/// page : 1
/// limit : 10
/// totalPages : 1
/// hasNextPage : false
/// hasPreviousPage : false
/// kAllWithdraws : [{"_id":"682d953a8976f672ca695c72","userId":{"_id":"682c34254509d8b5373f3ce0","accountId":"254271564","userType":"Real","firstName":"Muhammad","surname":"Tayyab","email":"mobileapp@saveingold.ae","phoneNumber":"00971552025311","imageUrl":"","createdAt":"2025-05-20T07:49:57.205Z","updatedAt":"2025-05-21T08:56:25.974Z"},"beneficiaryName":"Amro Al Jaber","bankName":"Mashreq Bank","iban":"ABCD12345678901234567890","amount":100,"status":"Pending","moneyBalanceInWallet":8002,"transactionId":"TrxId-376875376479","createdAt":"2025-05-21T08:56:26.145Z","updatedAt":"2025-05-21T08:56:26.145Z","__v":0}]

Payload payloadFromJson(String str) => Payload.fromJson(json.decode(str));

String payloadToJson(Payload data) => json.encode(data.toJson());

class Payload {
  Payload({
    num? page,
    num? limit,
    num? totalPages,
    bool? hasNextPage,
    bool? hasPreviousPage,
    List<KAllWithdraws>? kAllWithdraws,
  }) {
    _page = page;
    _limit = limit;
    _totalPages = totalPages;
    _hasNextPage = hasNextPage;
    _hasPreviousPage = hasPreviousPage;
    _kAllWithdraws = kAllWithdraws;
  }

  Payload.fromJson(dynamic json) {
    _page = json['page'];
    _limit = json['limit'];
    _totalPages = json['totalPages'];
    _hasNextPage = json['hasNextPage'];
    _hasPreviousPage = json['hasPreviousPage'];
    if (json['kAllWithdraws'] != null) {
      _kAllWithdraws = [];
      json['kAllWithdraws'].forEach((v) {
        _kAllWithdraws?.add(KAllWithdraws.fromJson(v));
      });
    }
  }

  num? _page;
  num? _limit;
  num? _totalPages;
  bool? _hasNextPage;
  bool? _hasPreviousPage;
  List<KAllWithdraws>? _kAllWithdraws;

  Payload copyWith({
    num? page,
    num? limit,
    num? totalPages,
    bool? hasNextPage,
    bool? hasPreviousPage,
    List<KAllWithdraws>? kAllWithdraws,
  }) =>
      Payload(
        page: page ?? _page,
        limit: limit ?? _limit,
        totalPages: totalPages ?? _totalPages,
        hasNextPage: hasNextPage ?? _hasNextPage,
        hasPreviousPage: hasPreviousPage ?? _hasPreviousPage,
        kAllWithdraws: kAllWithdraws ?? _kAllWithdraws,
      );

  num? get page => _page;

  num? get limit => _limit;

  num? get totalPages => _totalPages;

  bool? get hasNextPage => _hasNextPage;

  bool? get hasPreviousPage => _hasPreviousPage;

  List<KAllWithdraws>? get kAllWithdraws => _kAllWithdraws;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['page'] = _page;
    map['limit'] = _limit;
    map['totalPages'] = _totalPages;
    map['hasNextPage'] = _hasNextPage;
    map['hasPreviousPage'] = _hasPreviousPage;
    if (_kAllWithdraws != null) {
      map['kAllWithdraws'] = _kAllWithdraws?.map((v) => v.toJson()).toList();
    }
    return map;
  }
}

/// _id : "682d953a8976f672ca695c72"
/// userId : {"_id":"682c34254509d8b5373f3ce0","accountId":"254271564","userType":"Real","firstName":"Muhammad","surname":"Tayyab","email":"mobileapp@saveingold.ae","phoneNumber":"00971552025311","imageUrl":"","createdAt":"2025-05-20T07:49:57.205Z","updatedAt":"2025-05-21T08:56:25.974Z"}
/// beneficiaryName : "Amro Al Jaber"
/// bankName : "Mashreq Bank"
/// iban : "ABCD12345678901234567890"
/// amount : 100
/// status : "Pending"
/// moneyBalanceInWallet : 8002
/// transactionId : "TrxId-376875376479"
/// createdAt : "2025-05-21T08:56:26.145Z"
/// updatedAt : "2025-05-21T08:56:26.145Z"
/// __v : 0

KAllWithdraws kAllWithdrawsFromJson(String str) =>
    KAllWithdraws.fromJson(json.decode(str));

String kAllWithdrawsToJson(KAllWithdraws data) => json.encode(data.toJson());

class KAllWithdraws {
  KAllWithdraws({
    String? id,
    UserId? userId,
    String? beneficiaryName,
    String? bankName,
    String? iban,
    num? amount,
    String? status,
    num? moneyBalanceInWallet,
    String? transactionId,
    String? createdAt,
    String? updatedAt,
    num? v,
  }) {
    _id = id;
    _userId = userId;
    _beneficiaryName = beneficiaryName;
    _bankName = bankName;
    _iban = iban;
    _amount = amount;
    _status = status;
    _moneyBalanceInWallet = moneyBalanceInWallet;
    _transactionId = transactionId;
    _createdAt = createdAt;
    _updatedAt = updatedAt;
    _v = v;
  }

  KAllWithdraws.fromJson(dynamic json) {
    _id = json['_id'];
    _userId = json['userId'] != null ? UserId.fromJson(json['userId']) : null;
    _beneficiaryName = json['beneficiaryName'];
    _bankName = json['bankName'];
    _iban = json['iban'];
    _amount = json['amount'];
    _status = json['status'];
    _moneyBalanceInWallet = json['moneyBalanceInWallet'];
    _transactionId = json['transactionId'];
    _createdAt = json['createdAt'];
    _updatedAt = json['updatedAt'];
    _v = json['__v'];
  }

  String? _id;
  UserId? _userId;
  String? _beneficiaryName;
  String? _bankName;
  String? _iban;
  num? _amount;
  String? _status;
  num? _moneyBalanceInWallet;
  String? _transactionId;
  String? _createdAt;
  String? _updatedAt;
  num? _v;

  KAllWithdraws copyWith({
    String? id,
    UserId? userId,
    String? beneficiaryName,
    String? bankName,
    String? iban,
    num? amount,
    String? status,
    num? moneyBalanceInWallet,
    String? transactionId,
    String? createdAt,
    String? updatedAt,
    num? v,
  }) =>
      KAllWithdraws(
        id: id ?? _id,
        userId: userId ?? _userId,
        beneficiaryName: beneficiaryName ?? _beneficiaryName,
        bankName: bankName ?? _bankName,
        iban: iban ?? _iban,
        amount: amount ?? _amount,
        status: status ?? _status,
        moneyBalanceInWallet: moneyBalanceInWallet ?? _moneyBalanceInWallet,
        transactionId: transactionId ?? _transactionId,
        createdAt: createdAt ?? _createdAt,
        updatedAt: updatedAt ?? _updatedAt,
        v: v ?? _v,
      );

  String? get id => _id;

  UserId? get userId => _userId;

  String? get beneficiaryName => _beneficiaryName;

  String? get bankName => _bankName;

  String? get iban => _iban;

  num? get amount => _amount;

  String? get status => _status;

  num? get moneyBalanceInWallet => _moneyBalanceInWallet;

  String? get transactionId => _transactionId;

  String? get createdAt => _createdAt;

  String? get updatedAt => _updatedAt;

  num? get v => _v;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['_id'] = _id;
    if (_userId != null) {
      map['userId'] = _userId?.toJson();
    }
    map['beneficiaryName'] = _beneficiaryName;
    map['bankName'] = _bankName;
    map['iban'] = _iban;
    map['amount'] = _amount;
    map['status'] = _status;
    map['moneyBalanceInWallet'] = _moneyBalanceInWallet;
    map['transactionId'] = _transactionId;
    map['createdAt'] = _createdAt;
    map['updatedAt'] = _updatedAt;
    map['__v'] = _v;
    return map;
  }
}

/// _id : "682c34254509d8b5373f3ce0"
/// accountId : "254271564"
/// userType : "Real"
/// firstName : "Muhammad"
/// surname : "Tayyab"
/// email : "mobileapp@saveingold.ae"
/// phoneNumber : "00971552025311"
/// imageUrl : ""
/// createdAt : "2025-05-20T07:49:57.205Z"
/// updatedAt : "2025-05-21T08:56:25.974Z"

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
    String? updatedAt,
  }) {
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

  UserId copyWith({
    String? id,
    String? accountId,
    String? userType,
    String? firstName,
    String? surname,
    String? email,
    String? phoneNumber,
    String? imageUrl,
    String? createdAt,
    String? updatedAt,
  }) =>
      UserId(
        id: id ?? _id,
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
