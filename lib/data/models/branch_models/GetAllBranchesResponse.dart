class GetAllBranchesResponse {
  String? _status;
  num? _code;
  String? _message;
  Payload? _payload;

  GetAllBranchesResponse(
      {String? status, num? code, String? message, Payload? payload}) {
    if (status != null) {
      _status = status;
    }
    if (code != null) {
      _code = code;
    }
    if (message != null) {
      _message = message;
    }
    if (payload != null) {
      _payload = payload;
    }
  }

  String? get status => _status;

  set status(String? status) => _status = status;

  num? get code => _code;

  set code(num? code) => _code = code;

  String? get message => _message;

  set message(String? message) => _message = message;

  Payload? get payload => _payload;

  set payload(Payload? payload) => _payload = payload;

  GetAllBranchesResponse.fromJson(Map<String, dynamic> json) {
    _status = json['status'];
    _code = json['code'];
    _message = json['message'];
    _payload =
        json['payload'] != null ? new Payload.fromJson(json['payload']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = _status;
    data['code'] = _code;
    data['message'] = _message;
    if (_payload != null) {
      data['payload'] = _payload!.toJson();
    }
    return data;
  }
}

class Payload {
  List<AllBranches>? _allBranches;

  Payload({List<AllBranches>? allBranches}) {
    if (allBranches != null) {
      _allBranches = allBranches;
    }
  }

  List<AllBranches>? get allBranches => _allBranches;

  set allBranches(List<AllBranches>? allBranches) => _allBranches = allBranches;

  Payload.fromJson(Map<String, dynamic> json) {
    if (json['allBranches'] != null) {
      _allBranches = <AllBranches>[];
      json['allBranches'].forEach((v) {
        _allBranches!.add(new AllBranches.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (_allBranches != null) {
      data['allBranches'] = _allBranches!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class AllBranches {
  String? _sId;
  String? _branchName;
  String? _branchLocation;
  String? _branchPhoneNumber;
  String? _branchEmail;

  AllBranches(
      {String? sId,
      String? branchName,
      String? branchLocation,
      String? branchPhoneNumber,
      String? branchEmail}) {
    if (sId != null) {
      _sId = sId;
    }
    if (branchName != null) {
      _branchName = branchName;
    }
    if (branchLocation != null) {
      _branchLocation = branchLocation;
    }
    if (branchPhoneNumber != null) {
      _branchPhoneNumber = branchPhoneNumber;
    }
    if (branchEmail != null) {
      _branchEmail = branchEmail;
    }
  }

  String? get sId => _sId;

  set sId(String? sId) => _sId = sId;

  String? get branchName => _branchName;

  set branchName(String? branchName) => _branchName = branchName;

  String? get branchLocation => _branchLocation;

  set branchLocation(String? branchLocation) =>
      _branchLocation = branchLocation;

  String? get branchPhoneNumber => _branchPhoneNumber;

  set branchPhoneNumber(String? branchPhoneNumber) =>
      _branchPhoneNumber = branchPhoneNumber;

  String? get branchEmail => _branchEmail;

  set branchEmail(String? branchEmail) => _branchEmail = branchEmail;

  AllBranches.fromJson(Map<String, dynamic> json) {
    _sId = json['_id'];
    _branchName = json['branchName'];
    _branchLocation = json['branchLocation'];
    _branchPhoneNumber = json['branchPhoneNumber'];
    _branchEmail = json['branchEmail'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = _sId;
    data['branchName'] = _branchName;
    data['branchLocation'] = _branchLocation;
    data['branchPhoneNumber'] = _branchPhoneNumber;
    data['branchEmail'] = _branchEmail;
    return data;
  }
}
