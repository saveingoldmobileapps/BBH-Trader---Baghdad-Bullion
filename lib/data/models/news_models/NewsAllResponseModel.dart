import 'dart:convert';
/// status : "success"
/// code : 1
/// message : "OK: The request has succeeded."
/// payload : {"allnews":[{"_id":"67f8bb4e84045d171564903d","title":"Gold Mining Innovation Reduces Environmental Impact","description":"New technology in gold mining aims to cut down carbon emissions and water usage, making operations more sustainable.","url":"https://example.com/gold-mining-tech","createdAt":"2025-04-11T06:48:46.825Z","updatedAt":"2025-04-11T06:48:46.825Z","__v":0},{"_id":"67f8bb3a84045d1715649036","title":"Central Banks Continue Gold Buying Spree","description":"Several central banks increased their gold reserves last quarter, signaling continued confidence in the precious metal.","url":"https://example.com/central-banks-gold","createdAt":"2025-04-11T06:48:26.356Z","updatedAt":"2025-04-11T06:48:26.356Z","__v":0},{"_id":"67f8bb1984045d171564902f","title":"Gold Price Hits Record High","description":"Gold prices surged to an all-time high as global economic uncertainties drove investors to safe-haven assets.","url":"https://example.com/gold-price-record","createdAt":"2025-04-11T06:47:53.473Z","updatedAt":"2025-04-11T06:47:53.473Z","__v":0}]}

NewsAllResponseModel newsAllResponseModelFromJson(String str) => NewsAllResponseModel.fromJson(json.decode(str));
String newsAllResponseModelToJson(NewsAllResponseModel data) => json.encode(data.toJson());
class NewsAllResponseModel {
  NewsAllResponseModel({
      String? status, 
      num? code, 
      String? message, 
      NewsAllList? payload,}){
    _status = status;
    _code = code;
    _message = message;
    _payload = payload;
}

  NewsAllResponseModel.fromJson(dynamic json) {
    _status = json['status'];
    _code = json['code'];
    _message = json['message'];
    _payload = json['payload'] != null ? NewsAllList.fromJson(json['payload']) : null;
  }
  String? _status;
  num? _code;
  String? _message;
  
  NewsAllList? _payload;
NewsAllResponseModel copyWith({  String? status,
  num? code,
  String? message,
  NewsAllList? payload,
}) => NewsAllResponseModel(  status: status ?? _status,
  code: code ?? _code,
  message: message ?? _message,
  payload: payload ?? _payload,
);
  String? get status => _status;
  num? get code => _code;
  String? get message => _message;
  NewsAllList? get payload => _payload;

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

/// allnews : [{"_id":"67f8bb4e84045d171564903d","title":"Gold Mining Innovation Reduces Environmental Impact","description":"New technology in gold mining aims to cut down carbon emissions and water usage, making operations more sustainable.","url":"https://example.com/gold-mining-tech","createdAt":"2025-04-11T06:48:46.825Z","updatedAt":"2025-04-11T06:48:46.825Z","__v":0},{"_id":"67f8bb3a84045d1715649036","title":"Central Banks Continue Gold Buying Spree","description":"Several central banks increased their gold reserves last quarter, signaling continued confidence in the precious metal.","url":"https://example.com/central-banks-gold","createdAt":"2025-04-11T06:48:26.356Z","updatedAt":"2025-04-11T06:48:26.356Z","__v":0},{"_id":"67f8bb1984045d171564902f","title":"Gold Price Hits Record High","description":"Gold prices surged to an all-time high as global economic uncertainties drove investors to safe-haven assets.","url":"https://example.com/gold-price-record","createdAt":"2025-04-11T06:47:53.473Z","updatedAt":"2025-04-11T06:47:53.473Z","__v":0}]

NewsAllList payloadFromJson(String str) => NewsAllList.fromJson(json.decode(str));
String payloadToJson(NewsAllList data) => json.encode(data.toJson());
class NewsAllList {
  NewsAllList({
    List<Allnews>? allnews,
    }){
    _allnews = allnews;
}

  NewsAllList.fromJson(dynamic json) {
    if (json['allnews'] != null) {
      _allnews = [];
      json['allnews'].forEach((v) {
        _allnews?.add(Allnews.fromJson(v));
      });
    }
  }
  List<Allnews>? _allnews;
NewsAllList copyWith({  List<Allnews>? allnews,
}) => NewsAllList(  allnews: allnews ?? _allnews,
);
  List<Allnews>? get allnews => _allnews;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (_allnews != null) {
      map['allnews'] = _allnews?.map((v) => v.toJson()).toList();
    }
    return map;
  }

}

/// _id : "67f8bb4e84045d171564903d"
/// title : "Gold Mining Innovation Reduces Environmental Impact"
/// description : "New technology in gold mining aims to cut down carbon emissions and water usage, making operations more sustainable."
/// url : "https://example.com/gold-mining-tech"
/// createdAt : "2025-04-11T06:48:46.825Z"
/// updatedAt : "2025-04-11T06:48:46.825Z"
/// __v : 0

Allnews allnewsFromJson(String str) => Allnews.fromJson(json.decode(str));
String allnewsToJson(Allnews data) => json.encode(data.toJson());
class Allnews {
  Allnews({
      String? id, 
      String? title, 
      String? description, 
      String? url, 
      String? createdAt, 
      String? updatedAt, 
      num? v,}){
    _id = id;
    _title = title;
    _description = description;
    _url = url;
    _createdAt = createdAt;
    _updatedAt = updatedAt;
    _v = v;
}

  Allnews.fromJson(dynamic json) {
    _id = json['_id'];
    _title = json['title'];
    _description = json['body'];
    _url = json['url'];
    _createdAt = json['createdAt'];
    _updatedAt = json['updatedAt'];
    _v = json['__v'];
  }
  String? _id;
  String? _title;
  String? _description;
  String? _url;
  String? _createdAt;
  String? _updatedAt;
  num? _v;
Allnews copyWith({  String? id,
  String? title,
  String? description,
  String? url,
  String? createdAt,
  String? updatedAt,
  num? v,
}) => Allnews(  id: id ?? _id,
  title: title ?? _title,
  description: description ?? _description,
  url: url ?? _url,
  createdAt: createdAt ?? _createdAt,
  updatedAt: updatedAt ?? _updatedAt,
  v: v ?? _v,
);
  String? get id => _id;
  String? get title => _title;
  String? get description => _description;
  String? get url => _url;
  String? get createdAt => _createdAt;
  String? get updatedAt => _updatedAt;
  num? get v => _v;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['_id'] = _id;
    map['title'] = _title;
    map['body'] = _description;
    map['url'] = _url;
    map['createdAt'] = _createdAt;
    map['updatedAt'] = _updatedAt;
    map['__v'] = _v;
    return map;
  }

}