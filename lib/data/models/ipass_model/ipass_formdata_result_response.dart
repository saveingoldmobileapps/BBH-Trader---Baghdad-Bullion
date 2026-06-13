import 'dart:convert';

IpassFormDataResultResponse ipassFormDataResultResponseFromJson(String str) =>
    IpassFormDataResultResponse.fromJson(
      json.decode(str) as Map<String, dynamic>,
    );

String ipassFormDataResultResponseToJson(IpassFormDataResultResponse data) =>
    json.encode(data.toJson());

/// OCR poll response from iPass `web/get/all/formdata` (Azure prebuilt-layout).
class IpassFormDataResultResponse {
  IpassFormDataResultResponse({
    this.result,
    this.rawJson,
    this.scanSide,
    this.imageBase64,
  });

  IpassFormDataResult? result;
  Map<String, dynamic>? rawJson;
  String? scanSide;
  String? imageBase64;

  factory IpassFormDataResultResponse.fromApiJson(
    Map<dynamic, dynamic> json, {
    String? scanSide,
    String? imageBase64,
  }) {
    final response = IpassFormDataResultResponse(
      rawJson: Map<String, dynamic>.from(json),
      scanSide: scanSide,
      imageBase64: imageBase64,
    );
    response._parsePayload(json);
    return response;
  }

  IpassFormDataResultResponse.fromJson(Map<dynamic, dynamic> json) {
    rawJson = Map<String, dynamic>.from(json);
    scanSide = json['scanSide']?.toString();
    imageBase64 = json['imageBase64']?.toString();
    _parsePayload(json);
  }

  void _parsePayload(Map<dynamic, dynamic> json) {
    final resultJson = json['result'];
    if (resultJson is Map) {
      result = IpassFormDataResult.fromJson(resultJson);
      return;
    }
    if (json['analyzeResult'] is Map) {
      result = IpassFormDataResult.fromJson(json);
      result!.status ??= 'succeeded';
    }
  }

  bool get isSucceeded {
    final status = result?.status?.toLowerCase();
    if (status == 'succeeded') return true;
    if (status == 'failed' || status == 'canceled' || status == 'cancelled') {
      return false;
    }
    final content = ocrContent;
    return content != null && content.trim().isNotEmpty;
  }

  String? get ocrContent => result?.analyzeResult?.content;

  String? get documentName =>
      result?.name ?? rawJson?['name']?.toString();

  /// Full API body for backend — preserves `analyzeResult.pages`, `lines`, etc.
  Map<String, dynamic> toJson() {
    final out = <String, dynamic>{};
    if (rawJson != null && rawJson!.isNotEmpty) {
      out.addAll(rawJson!);
    } else if (result != null) {
      out.addAll(result!.toJson());
    }
    if (scanSide != null && scanSide!.isNotEmpty) {
      out['scanSide'] = scanSide;
    }
    if (imageBase64 != null && imageBase64!.isNotEmpty) {
      out['imageBase64'] = imageBase64;
    }
    return out;
  }
}

class IpassFormDataResult {
  IpassFormDataResult({
    this.status,
    this.createdDateTime,
    this.lastUpdatedDateTime,
    this.analyzeResult,
    this.sessionId,
    this.name,
    this.createdAt,
    this.type,
    this.sid,
    this.aiAgents,
  });

  IpassFormDataResult.fromJson(Map<dynamic, dynamic> json) {
    status = json['status']?.toString();
    createdDateTime = json['createdDateTime']?.toString();
    lastUpdatedDateTime = json['lastUpdatedDateTime']?.toString();
    sessionId = json['sessionId']?.toString();
    name = json['name']?.toString();
    createdAt = json['created_at']?.toString();
    type = json['type']?.toString();
    sid = json['sid']?.toString();
    aiAgents = json['aiAgents'];
    final analyze = json['analyzeResult'];
    analyzeResult =
        analyze is Map ? IpassAnalyzeResult.fromJson(analyze) : null;
  }

  String? status;
  String? createdDateTime;
  String? lastUpdatedDateTime;
  IpassAnalyzeResult? analyzeResult;
  String? sessionId;
  String? name;
  String? createdAt;
  String? type;
  String? sid;
  dynamic aiAgents;

  Map<String, dynamic> toJson() => {
        if (status != null) 'status': status,
        if (createdDateTime != null) 'createdDateTime': createdDateTime,
        if (lastUpdatedDateTime != null)
          'lastUpdatedDateTime': lastUpdatedDateTime,
        if (sessionId != null) 'sessionId': sessionId,
        if (name != null) 'name': name,
        if (createdAt != null) 'created_at': createdAt,
        if (type != null) 'type': type,
        if (sid != null) 'sid': sid,
        if (aiAgents != null) 'aiAgents': aiAgents,
        if (analyzeResult != null) 'analyzeResult': analyzeResult!.toJson(),
      };
}

class IpassAnalyzeResult {
  IpassAnalyzeResult({
    this.apiVersion,
    this.modelId,
    this.content,
    this.contentFormat,
    this.rawAnalyzeJson,
  });

  IpassAnalyzeResult.fromJson(Map<dynamic, dynamic> json) {
    rawAnalyzeJson = Map<String, dynamic>.from(json);
    apiVersion = json['apiVersion']?.toString();
    modelId = json['modelId']?.toString();
    content = json['content']?.toString();
    contentFormat = json['contentFormat']?.toString();
  }

  String? apiVersion;
  String? modelId;
  String? content;
  String? contentFormat;
  Map<String, dynamic>? rawAnalyzeJson;

  Map<String, dynamic> toJson() {
    if (rawAnalyzeJson != null && rawAnalyzeJson!.isNotEmpty) {
      return Map<String, dynamic>.from(rawAnalyzeJson!);
    }
    return {
      'apiVersion': apiVersion,
      'modelId': modelId,
      'content': content,
      'contentFormat': contentFormat,
    };
  }
}
