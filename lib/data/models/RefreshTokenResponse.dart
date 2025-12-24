import 'dart:convert';
/// status : "success"
/// code : 1
/// message : "OK: The request has succeeded."
/// payload : {"updatedTokens":{"serverToken":"eyJhbGciOiJIUzUxMiIsInR5cCI6IkpXVCJ9.eyJlbmNyeXB0ZWRFbWFpbCI6IjQ3ZDAyYTFjMTU3ZGNkMjNkZjI0NGM5YmJjYTI2NThiY2JlM2E4NTM5NzA2YjM2NjUwMWZhMjI0YWJjZDViOTUiLCJ0b2tlbklkIjoiZGMyZDE1NzUtNjZmMC00M2I1LWExZDktMjcwNjZhYjRjNDQ2IiwiaWF0IjoxNzM4OTMyNzEwLCJleHAiOjE3Mzk1Mzc1MTAsImF1ZCI6IjxtQG1vYmlsQGVfQGFwcF9AdWRpZW5AY2U-IiwiaXNzIjoiPHNAdmUkaW5nQG9sZF9pQEBzc3VyQGU-Iiwic3ViIjoiYWxpLnB5ZGV2ZWxvcGVyN0BnbWFpbC5jb20iLCJqdGkiOiJkYzJkMTU3NS02NmYwLTQzYjUtYTFkOS0yNzA2NmFiNGM0NDYifQ.NoPNp7qU40lDy8r1qmldF5xznJz6-SPl8YSRE5U76BaQnwmAWTA7MEjEjWod8-MhCRtCCLLRyWXncmHDwHnrGA","refreshToken":"eyJhbGciOiJIUzUxMiIsInR5cCI6IkpXVCJ9.eyJlbmNyeXB0ZWRFbWFpbCI6IjQ3ZDAyYTFjMTU3ZGNkMjNkZjI0NGM5YmJjYTI2NThiY2JlM2E4NTM5NzA2YjM2NjUwMWZhMjI0YWJjZDViOTUiLCJ0b2tlbklkIjoiZGMyZDE1NzUtNjZmMC00M2I1LWExZDktMjcwNjZhYjRjNDQ2IiwiaWF0IjoxNzM4OTMyNzEwLCJleHAiOjE3Mzk1Mzc1MTAsImF1ZCI6IjxtQG1vYmlsQGVfQGFwcF9AdWRpZW5AY2U-IiwiaXNzIjoiPHNAdmUkaW5nQG9sZF9pQEBzc3VyQGU-Iiwic3ViIjoiYWxpLnB5ZGV2ZWxvcGVyN0BnbWFpbC5jb20iLCJqdGkiOiJkYzJkMTU3NS02NmYwLTQzYjUtYTFkOS0yNzA2NmFiNGM0NDYifQ.IES_UZphb46clYbu8c8STiUTENGTn_PSBHUTjhsVPjwJcdXij-uhVPrXJj_eyTqjfuk61Ditpc5GzEBieSnFrQ"}}

RefreshTokenResponse refreshTokenResponseFromJson(String str) => RefreshTokenResponse.fromJson(json.decode(str));
String refreshTokenResponseToJson(RefreshTokenResponse data) => json.encode(data.toJson());
class RefreshTokenResponse {
  RefreshTokenResponse({
      String? status, 
      num? code, 
      String? message, 
      Payload? payload,}){
    _status = status;
    _code = code;
    _message = message;
    _payload = payload;
}

  RefreshTokenResponse.fromJson(dynamic json) {
    _status = json['status'];
    _code = json['code'];
    _message = json['message'];
    _payload = json['payload'] != null ? Payload.fromJson(json['payload']) : null;
  }
  String? _status;
  num? _code;
  String? _message;
  Payload? _payload;
RefreshTokenResponse copyWith({  String? status,
  num? code,
  String? message,
  Payload? payload,
}) => RefreshTokenResponse(  status: status ?? _status,
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

/// updatedTokens : {"serverToken":"eyJhbGciOiJIUzUxMiIsInR5cCI6IkpXVCJ9.eyJlbmNyeXB0ZWRFbWFpbCI6IjQ3ZDAyYTFjMTU3ZGNkMjNkZjI0NGM5YmJjYTI2NThiY2JlM2E4NTM5NzA2YjM2NjUwMWZhMjI0YWJjZDViOTUiLCJ0b2tlbklkIjoiZGMyZDE1NzUtNjZmMC00M2I1LWExZDktMjcwNjZhYjRjNDQ2IiwiaWF0IjoxNzM4OTMyNzEwLCJleHAiOjE3Mzk1Mzc1MTAsImF1ZCI6IjxtQG1vYmlsQGVfQGFwcF9AdWRpZW5AY2U-IiwiaXNzIjoiPHNAdmUkaW5nQG9sZF9pQEBzc3VyQGU-Iiwic3ViIjoiYWxpLnB5ZGV2ZWxvcGVyN0BnbWFpbC5jb20iLCJqdGkiOiJkYzJkMTU3NS02NmYwLTQzYjUtYTFkOS0yNzA2NmFiNGM0NDYifQ.NoPNp7qU40lDy8r1qmldF5xznJz6-SPl8YSRE5U76BaQnwmAWTA7MEjEjWod8-MhCRtCCLLRyWXncmHDwHnrGA","refreshToken":"eyJhbGciOiJIUzUxMiIsInR5cCI6IkpXVCJ9.eyJlbmNyeXB0ZWRFbWFpbCI6IjQ3ZDAyYTFjMTU3ZGNkMjNkZjI0NGM5YmJjYTI2NThiY2JlM2E4NTM5NzA2YjM2NjUwMWZhMjI0YWJjZDViOTUiLCJ0b2tlbklkIjoiZGMyZDE1NzUtNjZmMC00M2I1LWExZDktMjcwNjZhYjRjNDQ2IiwiaWF0IjoxNzM4OTMyNzEwLCJleHAiOjE3Mzk1Mzc1MTAsImF1ZCI6IjxtQG1vYmlsQGVfQGFwcF9AdWRpZW5AY2U-IiwiaXNzIjoiPHNAdmUkaW5nQG9sZF9pQEBzc3VyQGU-Iiwic3ViIjoiYWxpLnB5ZGV2ZWxvcGVyN0BnbWFpbC5jb20iLCJqdGkiOiJkYzJkMTU3NS02NmYwLTQzYjUtYTFkOS0yNzA2NmFiNGM0NDYifQ.IES_UZphb46clYbu8c8STiUTENGTn_PSBHUTjhsVPjwJcdXij-uhVPrXJj_eyTqjfuk61Ditpc5GzEBieSnFrQ"}

Payload payloadFromJson(String str) => Payload.fromJson(json.decode(str));
String payloadToJson(Payload data) => json.encode(data.toJson());
class Payload {
  Payload({
      UpdatedTokens? updatedTokens,}){
    _updatedTokens = updatedTokens;
}

  Payload.fromJson(dynamic json) {
    _updatedTokens = json['updatedTokens'] != null ? UpdatedTokens.fromJson(json['updatedTokens']) : null;
  }
  UpdatedTokens? _updatedTokens;
Payload copyWith({  UpdatedTokens? updatedTokens,
}) => Payload(  updatedTokens: updatedTokens ?? _updatedTokens,
);
  UpdatedTokens? get updatedTokens => _updatedTokens;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (_updatedTokens != null) {
      map['updatedTokens'] = _updatedTokens?.toJson();
    }
    return map;
  }

}

/// serverToken : "eyJhbGciOiJIUzUxMiIsInR5cCI6IkpXVCJ9.eyJlbmNyeXB0ZWRFbWFpbCI6IjQ3ZDAyYTFjMTU3ZGNkMjNkZjI0NGM5YmJjYTI2NThiY2JlM2E4NTM5NzA2YjM2NjUwMWZhMjI0YWJjZDViOTUiLCJ0b2tlbklkIjoiZGMyZDE1NzUtNjZmMC00M2I1LWExZDktMjcwNjZhYjRjNDQ2IiwiaWF0IjoxNzM4OTMyNzEwLCJleHAiOjE3Mzk1Mzc1MTAsImF1ZCI6IjxtQG1vYmlsQGVfQGFwcF9AdWRpZW5AY2U-IiwiaXNzIjoiPHNAdmUkaW5nQG9sZF9pQEBzc3VyQGU-Iiwic3ViIjoiYWxpLnB5ZGV2ZWxvcGVyN0BnbWFpbC5jb20iLCJqdGkiOiJkYzJkMTU3NS02NmYwLTQzYjUtYTFkOS0yNzA2NmFiNGM0NDYifQ.NoPNp7qU40lDy8r1qmldF5xznJz6-SPl8YSRE5U76BaQnwmAWTA7MEjEjWod8-MhCRtCCLLRyWXncmHDwHnrGA"
/// refreshToken : "eyJhbGciOiJIUzUxMiIsInR5cCI6IkpXVCJ9.eyJlbmNyeXB0ZWRFbWFpbCI6IjQ3ZDAyYTFjMTU3ZGNkMjNkZjI0NGM5YmJjYTI2NThiY2JlM2E4NTM5NzA2YjM2NjUwMWZhMjI0YWJjZDViOTUiLCJ0b2tlbklkIjoiZGMyZDE1NzUtNjZmMC00M2I1LWExZDktMjcwNjZhYjRjNDQ2IiwiaWF0IjoxNzM4OTMyNzEwLCJleHAiOjE3Mzk1Mzc1MTAsImF1ZCI6IjxtQG1vYmlsQGVfQGFwcF9AdWRpZW5AY2U-IiwiaXNzIjoiPHNAdmUkaW5nQG9sZF9pQEBzc3VyQGU-Iiwic3ViIjoiYWxpLnB5ZGV2ZWxvcGVyN0BnbWFpbC5jb20iLCJqdGkiOiJkYzJkMTU3NS02NmYwLTQzYjUtYTFkOS0yNzA2NmFiNGM0NDYifQ.IES_UZphb46clYbu8c8STiUTENGTn_PSBHUTjhsVPjwJcdXij-uhVPrXJj_eyTqjfuk61Ditpc5GzEBieSnFrQ"

UpdatedTokens updatedTokensFromJson(String str) => UpdatedTokens.fromJson(json.decode(str));
String updatedTokensToJson(UpdatedTokens data) => json.encode(data.toJson());
class UpdatedTokens {
  UpdatedTokens({
      String? serverToken, 
      String? refreshToken,}){
    _serverToken = serverToken;
    _refreshToken = refreshToken;
}

  UpdatedTokens.fromJson(dynamic json) {
    _serverToken = json['serverToken'];
    _refreshToken = json['refreshToken'];
  }
  String? _serverToken;
  String? _refreshToken;
UpdatedTokens copyWith({  String? serverToken,
  String? refreshToken,
}) => UpdatedTokens(  serverToken: serverToken ?? _serverToken,
  refreshToken: refreshToken ?? _refreshToken,
);
  String? get serverToken => _serverToken;
  String? get refreshToken => _refreshToken;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['serverToken'] = _serverToken;
    map['refreshToken'] = _refreshToken;
    return map;
  }

}