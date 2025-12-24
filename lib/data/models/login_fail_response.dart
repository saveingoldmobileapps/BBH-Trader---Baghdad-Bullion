class LoginfailResponse {
  String? status;
  int? code;
  String? message;
  Payload? payload;

  LoginfailResponse({this.status, this.code, this.message, this.payload});

  LoginfailResponse.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    code = json['code'];
    message = json['message'];
    payload =
        json['payload'] != null ? Payload.fromJson(json['payload']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    data['code'] = code;
    data['message'] = message;
    if (payload != null) {
      data['payload'] = payload!.toJson();
    }
    return data;
  }
}

class Payload {
  String? updatedPhoneNumber;
  String? message;
  Payload({this.updatedPhoneNumber, this.message});

  Payload.fromJson(Map<String, dynamic> json) {
    updatedPhoneNumber = json['updatedPhoneNumber'];
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['updatedPhoneNumber'] = updatedPhoneNumber;
    return data;
  }
}
