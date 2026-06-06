import 'dart:convert';
/// status : "success"
/// code : 1
/// message : "OK: The request has succeeded."
/// payload : [{"_id":"67de79012d327c65899fd3d9","userId":{"_id":"67dbe6b179f0d7cbfe5aaa96","accountId":"893187879","userType":"Real","firstName":"Mr","surname":"Zain","email":"zain9@gmail.com","phoneNumber":"0524378778","imageUrl":"","createdAt":"2025-03-20T09:58:09.095Z","updatedAt":"2025-03-22T08:50:23.243Z"},"notificationData":{"type":"Gift","id":"67de78ff2d327c65899fd3cb"},"topic":"zaingmailcom","title":"Gift sent!","message":"You received a gift from Mr Zain","isRead":false,"createdAt":"2025-03-22T08:46:57.337Z","updatedAt":"2025-03-22T08:46:57.337Z","__v":0},{"_id":"67de79002d327c65899fd3d7","userId":{"_id":"67dbe6b179f0d7cbfe5aaa96","accountId":"893187879","userType":"Real","firstName":"Mr","surname":"Zain","email":"zain9@gmail.com","phoneNumber":"0524378778","imageUrl":"","createdAt":"2025-03-20T09:58:09.095Z","updatedAt":"2025-03-22T08:50:23.243Z"},"notificationData":{"type":"Gift","id":"67de78ff2d327c65899fd3cb"},"topic":"naqshotameergmailcom","title":"Gift received!","message":"Mr Zain sent you a gift","isRead":false,"createdAt":"2025-03-22T08:46:56.967Z","updatedAt":"2025-03-22T08:46:56.967Z","__v":0},{"_id":"67de781e2d327c65899fd3b9","userId":{"_id":"67dbe6b179f0d7cbfe5aaa96","accountId":"893187879","userType":"Real","firstName":"Mr","surname":"Zain","email":"zain9@gmail.com","phoneNumber":"0524378778","imageUrl":"","createdAt":"2025-03-20T09:58:09.095Z","updatedAt":"2025-03-22T08:50:23.243Z"},"notificationData":{"type":"Loan","id":"67de781c2d327c65899fd3af"},"topic":"zaingmailcom","title":"Loan created","message":"Congratulations for your new loan, we are looking forward to process your loan.","isRead":false,"createdAt":"2025-03-22T08:43:10.381Z","updatedAt":"2025-03-22T08:43:10.381Z","__v":0},{"_id":"67de77952d327c65899fd38a","userId":{"_id":"67dbe6b179f0d7cbfe5aaa96","accountId":"893187879","userType":"Real","firstName":"Mr","surname":"Zain","email":"zain9@gmail.com","phoneNumber":"0524378778","imageUrl":"","createdAt":"2025-03-20T09:58:09.095Z","updatedAt":"2025-03-22T08:50:23.243Z"},"notificationData":{"type":"Order","id":"67de77942d327c65899fd37c"},"topic":"zaingmailcom","title":"Order created","message":"Congratulations for your new order, we are looking forward to process your order.","isRead":false,"createdAt":"2025-03-22T08:40:53.760Z","updatedAt":"2025-03-22T08:40:53.760Z","__v":0},{"_id":"67de76142d327c65899fd31c","userId":{"_id":"67dbe6b179f0d7cbfe5aaa96","accountId":"893187879","userType":"Real","firstName":"Mr","surname":"Zain","email":"zain9@gmail.com","phoneNumber":"0524378778","imageUrl":"","createdAt":"2025-03-20T09:58:09.095Z","updatedAt":"2025-03-22T08:50:23.243Z"},"notificationData":{"type":"Loan","id":"67de76122d327c65899fd312"},"topic":"zaingmailcom","title":"Loan created","message":"Congratulations for your new loan, we are looking forward to process your loan.","isRead":false,"createdAt":"2025-03-22T08:34:28.013Z","updatedAt":"2025-03-22T08:34:28.013Z","__v":0}]

NotificationApiResponseModel notificationApiResponseModelFromJson(String str) => NotificationApiResponseModel.fromJson(json.decode(str));
String notificationApiResponseModelToJson(NotificationApiResponseModel data) => json.encode(data.toJson());
class NotificationApiResponseModel {
  NotificationApiResponseModel({
    String? status,
    num? code,
    String? message,
    List<NotificationList>? payload,}){
    _status = status;
    _code = code;
    _message = message;
    _payload = payload;
  }

  NotificationApiResponseModel.fromJson(dynamic json) {
    _status = json['status'];
    _code = json['code'];
    _message = json['message'];
    if (json['payload'] != null) {
      _payload = [];
      json['payload'].forEach((v) {
        _payload?.add(NotificationList.fromJson(v));
      });
    }
  }
  String? _status;
  num? _code;
  String? _message;
  List<NotificationList>? _payload;
  NotificationApiResponseModel copyWith({  String? status,
    num? code,
    String? message,
    List<NotificationList>? payload,
  }) => NotificationApiResponseModel(  status: status ?? _status,
    code: code ?? _code,
    message: message ?? _message,
    payload: payload ?? _payload,
  );
  String? get status => _status;
  num? get code => _code;
  String? get message => _message;
  List<NotificationList>? get payload => _payload;

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

/// _id : "67de79012d327c65899fd3d9"
/// userId : {"_id":"67dbe6b179f0d7cbfe5aaa96","accountId":"893187879","userType":"Real","firstName":"Mr","surname":"Zain","email":"zain9@gmail.com","phoneNumber":"0524378778","imageUrl":"","createdAt":"2025-03-20T09:58:09.095Z","updatedAt":"2025-03-22T08:50:23.243Z"}
/// notificationData : {"type":"Gift","id":"67de78ff2d327c65899fd3cb"}
/// topic : "zaingmailcom"
/// title : "Gift sent!"
/// message : "You received a gift from Mr Zain"
/// isRead : false
/// createdAt : "2025-03-22T08:46:57.337Z"
/// updatedAt : "2025-03-22T08:46:57.337Z"
/// __v : 0

NotificationList payloadFromJson(String str) => NotificationList.fromJson(json.decode(str));
String payloadToJson(NotificationList data) => json.encode(data.toJson());
class NotificationList {
  NotificationList({
    String? id,
    UserId? userId,
    NotificationData? notificationData,
    String? topic,
    String? title,
    String? titleInArabic,
    String? message,
    String? messageInArabic,
    bool? isRead,
    String? createdAt,
    String? updatedAt,
    num? v,
  }) {
    _id = id;
    _userId = userId;
    _notificationData = notificationData;
    _topic = topic;
    _title = title;
    _titleInArabic = titleInArabic;
    _message = message;
    _messageInArabic = messageInArabic;
    _isRead = isRead;
    _createdAt = createdAt;
    _updatedAt = updatedAt;
    _v = v;
  }

  NotificationList.fromJson(dynamic json) {
    _id = json['_id'];
    _userId =
        json['userId'] != null ? UserId.fromJson(json['userId']) : null;
    _notificationData = json['notificationData'] != null
        ? NotificationData.fromJson(json['notificationData'])
        : null;
    _topic = json['topic'];
    _title = json['title'];
    _titleInArabic = json['titleInArabic']; // 
    _message = json['message'];
    _messageInArabic = json['messageInArabic']; // 
    _isRead = json['isRead'];
    _createdAt = json['createdAt'];
    _updatedAt = json['updatedAt'];
    _v = json['__v'];
  }

  String? _id;
  UserId? _userId;
  NotificationData? _notificationData;
  String? _topic;
  String? _title;
  String? _titleInArabic; // 
  String? _message;
  String? _messageInArabic; // 
  bool? _isRead;
  String? _createdAt;
  String? _updatedAt;
  num? _v;

  NotificationList copyWith({
    String? id,
    UserId? userId,
    NotificationData? notificationData,
    String? topic,
    String? title,
    String? titleInArabic,
    String? message,
    String? messageInArabic,
    bool? isRead,
    String? createdAt,
    String? updatedAt,
    num? v,
  }) => NotificationList(  id: id ?? _id,
        userId: userId ?? _userId,
        notificationData: notificationData ?? _notificationData,
        topic: topic ?? _topic,
        title: title ?? _title,
        titleInArabic: titleInArabic ?? _titleInArabic,
        message: message ?? _message,
        messageInArabic: messageInArabic ?? _messageInArabic,
        isRead: isRead ?? _isRead,
        createdAt: createdAt ?? _createdAt,
        updatedAt: updatedAt ?? _updatedAt,
        v: v ?? _v,
      );

  String? get id => _id;
  UserId? get userId => _userId;
  NotificationData? get notificationData => _notificationData;
  String? get topic => _topic;
  String? get title => _title;
  String? get titleInArabic => _titleInArabic;
  String? get message => _message;
  String? get messageInArabic => _messageInArabic;
  bool? get isRead => _isRead;
  String? get createdAt => _createdAt;
  String? get updatedAt => _updatedAt;
  num? get v => _v;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['_id'] = _id;
    if (_userId != null) map['userId'] = _userId?.toJson();
    if (_notificationData != null) {
      map['notificationData'] = _notificationData?.toJson();
    }
    map['topic'] = _topic;
    map['title'] = _title;
    map['titleInArabic'] = _titleInArabic; 
    map['message'] = _message;
    map['messageInArabic'] = _messageInArabic; 
    map['isRead'] = _isRead;
    map['createdAt'] = _createdAt;
    map['updatedAt'] = _updatedAt;
    map['__v'] = _v;
    return map;
  }
}

/// type : "Gift"
/// id : "67de78ff2d327c65899fd3cb"

NotificationData notificationDataFromJson(String str) => NotificationData.fromJson(json.decode(str));
String notificationDataToJson(NotificationData data) => json.encode(data.toJson());
class NotificationData {
  NotificationData({
    String? type,
    String? id,}){
    _type = type;
    _id = id;
  }

  NotificationData.fromJson(dynamic json) {
    _type = json['type'];
    _id = json['id'];
  }
  String? _type;
  String? _id;
  NotificationData copyWith({  String? type,
    String? id,
  }) => NotificationData(  type: type ?? _type,
    id: id ?? _id,
  );
  String? get type => _type;
  String? get id => _id;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['type'] = _type;
    map['id'] = _id;
    return map;
  }

}

/// _id : "67dbe6b179f0d7cbfe5aaa96"
/// accountId : "893187879"
/// userType : "Real"
/// firstName : "Mr"
/// surname : "Zain"
/// email : "zain9@gmail.com"
/// phoneNumber : "0524378778"
/// imageUrl : ""
/// createdAt : "2025-03-20T09:58:09.095Z"
/// updatedAt : "2025-03-22T08:50:23.243Z"

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