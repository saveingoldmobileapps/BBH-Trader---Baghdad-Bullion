import 'dart:convert';

IpassFormDataResultResponse ipassFormDataResultResponseFromJson(String str) =>
    IpassFormDataResultResponse.fromJson(
      json.decode(str) as Map<String, dynamic>,
    );

String ipassFormDataResultResponseToJson(IpassFormDataResultResponse data) =>
    json.encode(data.toJson());

class IpassFormDataResultResponse {
  IpassFormDataResultResponse({this.result});

  IpassFormDataResultResponse.fromJson(Map<dynamic, dynamic> json) {
    final resultJson = json['result'];
    result =
        resultJson is Map ? IpassFormDataResult.fromJson(resultJson) : null;
  }

  IpassFormDataResult? result;

  bool get isSucceeded => result?.status?.toLowerCase() == 'succeeded';

  String? get ocrContent => result?.analyzeResult?.content;

  Map<String, dynamic> toJson() => {
        if (result != null) 'result': result!.toJson(),
      };
}

class IpassFormDataResult {
  IpassFormDataResult({
    this.status,
    this.createdDateTime,
    this.lastUpdatedDateTime,
    this.analyzeResult,
    this.sessionId,
  });

  IpassFormDataResult.fromJson(Map<dynamic, dynamic> json) {
    status = json['status']?.toString();
    createdDateTime = json['createdDateTime']?.toString();
    lastUpdatedDateTime = json['lastUpdatedDateTime']?.toString();
    sessionId = json['sessionId']?.toString();
    final analyze = json['analyzeResult'];
    analyzeResult =
        analyze is Map ? IpassAnalyzeResult.fromJson(analyze) : null;
  }

  String? status;
  String? createdDateTime;
  String? lastUpdatedDateTime;
  IpassAnalyzeResult? analyzeResult;
  String? sessionId;

  Map<String, dynamic> toJson() => {
        'status': status,
        'createdDateTime': createdDateTime,
        'lastUpdatedDateTime': lastUpdatedDateTime,
        'sessionId': sessionId,
        if (analyzeResult != null) 'analyzeResult': analyzeResult!.toJson(),
      };
}

class IpassAnalyzeResult {
  IpassAnalyzeResult({
    this.apiVersion,
    this.modelId,
    this.content,
    this.contentFormat,
  });

  IpassAnalyzeResult.fromJson(Map<dynamic, dynamic> json) {
    apiVersion = json['apiVersion']?.toString();
    modelId = json['modelId']?.toString();
    content = json['content']?.toString();
    contentFormat = json['contentFormat']?.toString();
  }

  String? apiVersion;
  String? modelId;
  String? content;
  String? contentFormat;

  Map<String, dynamic> toJson() => {
        'apiVersion': apiVersion,
        'modelId': modelId,
        'content': content,
        'contentFormat': contentFormat,
      };
}
