import 'dart:convert';
/// status : "success"
/// code : 1
/// message : "OK: The request has succeeded."
/// payload : {"_id":"67e7b33e195258223bca8833","userId":{"_id":"67e26220bce3cf50d1535b2e","accountId":"633801669","userType":"Real","firstName":"Mr","surname":"Asmat","email":"asmatwazir906@gmail.com","phoneNumber":"0524378778","imageUrl":"","createdAt":"2025-03-25T07:58:24.450Z","updatedAt":"2025-03-29T11:01:08.357Z"},"productId":"67d567bd396231c0c8f961ec","quantity":1,"goldPrice":90981.273,"makingCharges":0,"vat":0,"premiumDiscount":300,"deliveryCharges":40,"paymentMethod":"Metal","address":"","isNominate":false,"nomineeName":"","branchId":"67d29af1f934a886c60d3244","deliveryMethod":"Pickup","totalCharges":340,"grandTotal":250,"status":"Pending","balanceInMoneyWallet":1274.75,"balanceInMetalWallet":93082.257,"orderId":84312991,"createdAt":"2025-03-29T08:45:50.914Z","updatedAt":"2025-03-29T08:45:51.977Z"}

GetOrderDetailResponse GetOrderDetailResponseFromJson(String str) => GetOrderDetailResponse.fromJson(json.decode(str));
String GetOrderDetailResponseToJson(GetOrderDetailResponse data) => json.encode(data.toJson());
class GetOrderDetailResponse {
  GetOrderDetailResponse({
      String? status, 
      num? code, 
      String? message, 
      Payload? payload,}){
    _status = status;
    _code = code;
    _message = message;
    _payload = payload;
}

  GetOrderDetailResponse.fromJson(dynamic json) {
    _status = json['status'];
    _code = json['code'];
    _message = json['message'];
    _payload = json['payload'] != null ? Payload.fromJson(json['payload']) : null;
  }
  String? _status;
  num? _code;
  String? _message;
  Payload? _payload;
GetOrderDetailResponse copyWith({  String? status,
  num? code,
  String? message,
  Payload? payload,
}) => GetOrderDetailResponse(  status: status ?? _status,
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

/// _id : "67e7b33e195258223bca8833"
/// userId : {"_id":"67e26220bce3cf50d1535b2e","accountId":"633801669","userType":"Real","firstName":"Mr","surname":"Asmat","email":"asmatwazir906@gmail.com","phoneNumber":"0524378778","imageUrl":"","createdAt":"2025-03-25T07:58:24.450Z","updatedAt":"2025-03-29T11:01:08.357Z"}
/// productId : "67d567bd396231c0c8f961ec"
/// quantity : 1
/// goldPrice : 90981.273
/// makingCharges : 0
/// vat : 0
/// premiumDiscount : 300
/// deliveryCharges : 40
/// paymentMethod : "Metal"
/// address : ""
/// isNominate : false
/// nomineeName : ""
/// branchId : "67d29af1f934a886c60d3244"
/// deliveryMethod : "Pickup"
/// totalCharges : 340
/// grandTotal : 250
/// status : "Pending"
/// balanceInMoneyWallet : 1274.75
/// balanceInMetalWallet : 93082.257
/// orderId : 84312991
/// createdAt : "2025-03-29T08:45:50.914Z"
/// updatedAt : "2025-03-29T08:45:51.977Z"

Payload payloadFromJson(String str) => Payload.fromJson(json.decode(str));
String payloadToJson(Payload data) => json.encode(data.toJson());
class Payload {
  Payload({
      String? id, 
      UserId? userId, 
      String? productId, 
      num? quantity, 
      num? goldPrice, 
      num? makingCharges, 
      num? vat, 
      num? premiumDiscount, 
      num? deliveryCharges, 
      String? paymentMethod, 
      String? address, 
      bool? isNominate, 
      String? nomineeName, 
      String? branchId, 
      String? deliveryMethod, 
      num? totalCharges, 
      num? grandTotal, 
      String? status, 
      num? balanceInMoneyWallet, 
      num? balanceInMetalWallet, 
      num? orderId, 
      String? createdAt, 
      String? updatedAt,}){
    _id = id;
    _userId = userId;
    _productId = productId;
    _quantity = quantity;
    _goldPrice = goldPrice;
    _makingCharges = makingCharges;
    _vat = vat;
    _premiumDiscount = premiumDiscount;
    _deliveryCharges = deliveryCharges;
    _paymentMethod = paymentMethod;
    _address = address;
    _isNominate = isNominate;
    _nomineeName = nomineeName;
    _branchId = branchId;
    _deliveryMethod = deliveryMethod;
    _totalCharges = totalCharges;
    _grandTotal = grandTotal;
    _status = status;
    _balanceInMoneyWallet = balanceInMoneyWallet;
    _balanceInMetalWallet = balanceInMetalWallet;
    _orderId = orderId;
    _createdAt = createdAt;
    _updatedAt = updatedAt;
}

  Payload.fromJson(dynamic json) {
    _id = json['_id'];
    _userId = json['userId'] != null ? UserId.fromJson(json['userId']) : null;
    _productId = json['productId'];
    _quantity = json['quantity'];
    _goldPrice = json['goldPrice'];
    _makingCharges = json['makingCharges'];
    _vat = json['vat'];
    _premiumDiscount = json['premiumDiscount'];
    _deliveryCharges = json['deliveryCharges'];
    _paymentMethod = json['paymentMethod'];
    _address = json['address'];
    _isNominate = json['isNominate'];
    _nomineeName = json['nomineeName'];
    _branchId = json['branchId'];
    _deliveryMethod = json['deliveryMethod'];
    _totalCharges = json['totalCharges'];
    _grandTotal = json['grandTotal'];
    _status = json['status'];
    _balanceInMoneyWallet = json['balanceInMoneyWallet'];
    _balanceInMetalWallet = json['balanceInMetalWallet'];
    _orderId = json['orderId'];
    _createdAt = json['createdAt'];
    _updatedAt = json['updatedAt'];
  }
  String? _id;
  UserId? _userId;
  String? _productId;
  num? _quantity;
  num? _goldPrice;
  num? _makingCharges;
  num? _vat;
  num? _premiumDiscount;
  num? _deliveryCharges;
  String? _paymentMethod;
  String? _address;
  bool? _isNominate;
  String? _nomineeName;
  String? _branchId;
  String? _deliveryMethod;
  num? _totalCharges;
  num? _grandTotal;
  String? _status;
  num? _balanceInMoneyWallet;
  num? _balanceInMetalWallet;
  num? _orderId;
  String? _createdAt;
  String? _updatedAt;
Payload copyWith({  String? id,
  UserId? userId,
  String? productId,
  num? quantity,
  num? goldPrice,
  num? makingCharges,
  num? vat,
  num? premiumDiscount,
  num? deliveryCharges,
  String? paymentMethod,
  String? address,
  bool? isNominate,
  String? nomineeName,
  String? branchId,
  String? deliveryMethod,
  num? totalCharges,
  num? grandTotal,
  String? status,
  num? balanceInMoneyWallet,
  num? balanceInMetalWallet,
  num? orderId,
  String? createdAt,
  String? updatedAt,
}) => Payload(  id: id ?? _id,
  userId: userId ?? _userId,
  productId: productId ?? _productId,
  quantity: quantity ?? _quantity,
  goldPrice: goldPrice ?? _goldPrice,
  makingCharges: makingCharges ?? _makingCharges,
  vat: vat ?? _vat,
  premiumDiscount: premiumDiscount ?? _premiumDiscount,
  deliveryCharges: deliveryCharges ?? _deliveryCharges,
  paymentMethod: paymentMethod ?? _paymentMethod,
  address: address ?? _address,
  isNominate: isNominate ?? _isNominate,
  nomineeName: nomineeName ?? _nomineeName,
  branchId: branchId ?? _branchId,
  deliveryMethod: deliveryMethod ?? _deliveryMethod,
  totalCharges: totalCharges ?? _totalCharges,
  grandTotal: grandTotal ?? _grandTotal,
  status: status ?? _status,
  balanceInMoneyWallet: balanceInMoneyWallet ?? _balanceInMoneyWallet,
  balanceInMetalWallet: balanceInMetalWallet ?? _balanceInMetalWallet,
  orderId: orderId ?? _orderId,
  createdAt: createdAt ?? _createdAt,
  updatedAt: updatedAt ?? _updatedAt,
);
  String? get id => _id;
  UserId? get userId => _userId;
  String? get productId => _productId;
  num? get quantity => _quantity;
  num? get goldPrice => _goldPrice;
  num? get makingCharges => _makingCharges;
  num? get vat => _vat;
  num? get premiumDiscount => _premiumDiscount;
  num? get deliveryCharges => _deliveryCharges;
  String? get paymentMethod => _paymentMethod;
  String? get address => _address;
  bool? get isNominate => _isNominate;
  String? get nomineeName => _nomineeName;
  String? get branchId => _branchId;
  String? get deliveryMethod => _deliveryMethod;
  num? get totalCharges => _totalCharges;
  num? get grandTotal => _grandTotal;
  String? get status => _status;
  num? get balanceInMoneyWallet => _balanceInMoneyWallet;
  num? get balanceInMetalWallet => _balanceInMetalWallet;
  num? get orderId => _orderId;
  String? get createdAt => _createdAt;
  String? get updatedAt => _updatedAt;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['_id'] = _id;
    if (_userId != null) {
      map['userId'] = _userId?.toJson();
    }
    map['productId'] = _productId;
    map['quantity'] = _quantity;
    map['goldPrice'] = _goldPrice;
    map['makingCharges'] = _makingCharges;
    map['vat'] = _vat;
    map['premiumDiscount'] = _premiumDiscount;
    map['deliveryCharges'] = _deliveryCharges;
    map['paymentMethod'] = _paymentMethod;
    map['address'] = _address;
    map['isNominate'] = _isNominate;
    map['nomineeName'] = _nomineeName;
    map['branchId'] = _branchId;
    map['deliveryMethod'] = _deliveryMethod;
    map['totalCharges'] = _totalCharges;
    map['grandTotal'] = _grandTotal;
    map['status'] = _status;
    map['balanceInMoneyWallet'] = _balanceInMoneyWallet;
    map['balanceInMetalWallet'] = _balanceInMetalWallet;
    map['orderId'] = _orderId;
    map['createdAt'] = _createdAt;
    map['updatedAt'] = _updatedAt;
    return map;
  }

}

/// _id : "67e26220bce3cf50d1535b2e"
/// accountId : "633801669"
/// userType : "Real"
/// firstName : "Mr"
/// surname : "Asmat"
/// email : "asmatwazir906@gmail.com"
/// phoneNumber : "0524378778"
/// imageUrl : ""
/// createdAt : "2025-03-25T07:58:24.450Z"
/// updatedAt : "2025-03-29T11:01:08.357Z"

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