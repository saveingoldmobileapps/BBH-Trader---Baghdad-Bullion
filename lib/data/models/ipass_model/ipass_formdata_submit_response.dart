import 'dart:convert';

IpassFormDataSubmitResponse ipassFormDataSubmitResponseFromJson(String str) =>
    IpassFormDataSubmitResponse.fromJson(
      json.decode(str) as Map<String, dynamic>,
    );

class IpassFormDataSubmitResponse {
  IpassFormDataSubmitResponse({
    this.status = false,
    this.message,
    this.data,
  });

  IpassFormDataSubmitResponse.fromJson(Map<String, dynamic> json) {
    status = json['status'] == true;
    message = json['message']?.toString();
    final dataJson = json['data'];
    data = dataJson is Map
        ? IpassFormDataSubmitData.fromJson(Map<String, dynamic>.from(dataJson))
        : null;
  }

  bool status = false;
  String? message;
  IpassFormDataSubmitData? data;

  String? get apiRequestId => data?.headerUrl?.apiRequestId;
}

class IpassFormDataSubmitData {
  IpassFormDataSubmitData({this.headerUrl});

  IpassFormDataSubmitData.fromJson(Map<String, dynamic> json) {
    final header = json['headerUrl'];
    headerUrl = header is Map
        ? IpassFormDataHeaderUrl.fromJson(Map<String, dynamic>.from(header))
        : null;
  }

  IpassFormDataHeaderUrl? headerUrl;
}

class IpassFormDataHeaderUrl {
  IpassFormDataHeaderUrl({this.apiRequestId});

  IpassFormDataHeaderUrl.fromJson(Map<String, dynamic> json) {
    apiRequestId = json['apim-request-id']?.toString();
  }

  String? apiRequestId;
}
