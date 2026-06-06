/// code : 1
/// message : "Images uploaded"
/// data : {"imageUrl":"https://faroopetsbucket.s3.me-central-1.amazonaws.com/image-04a9189f-26a0-427a-909c-48e3d6016795.png"}

class UploadImageResponse {
  UploadImageResponse({
      num? code, 
      String? message, 
      Data? data,}){
    _code = code;
    _message = message;
    _data = data;
}

  UploadImageResponse.fromJson(dynamic json) {
    _code = json['code'];
    _message = json['message'];
    _data = json['data'] != null ? Data.fromJson(json['data']) : null;
  }
  num? _code;
  String? _message;
  Data? _data;
UploadImageResponse copyWith({  num? code,
  String? message,
  Data? data,
}) => UploadImageResponse(  code: code ?? _code,
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

/// imageUrl : "https://faroopetsbucket.s3.me-central-1.amazonaws.com/image-04a9189f-26a0-427a-909c-48e3d6016795.png"

class Data {
  Data({
      String? imageUrl,}){
    _imageUrl = imageUrl;
}

  Data.fromJson(dynamic json) {
    _imageUrl = json['imageUrl'];
  }
  String? _imageUrl;
Data copyWith({  String? imageUrl,
}) => Data(  imageUrl: imageUrl ?? _imageUrl,
);
  String? get imageUrl => _imageUrl;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['imageUrl'] = _imageUrl;
    return map;
  }

}