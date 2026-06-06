import 'dart:convert';

/// status : "success"
/// code : 1
/// message : "OK: The request has succeeded."
/// payload : [{"_id":"67fe597e225b234eae2aeac9","userId":"67fe1963410205d229ed07f8","transactionId":"TrxId-376602359008","metalBalance":59,"transactionType":"Credit in","paymentModel":"Trade","debit":10,"date":"2025-04-15T13:05:02.142Z"},{"_id":"67fe5980225b234eae2aeae6","userId":"67fe1963410205d229ed07f8","transactionId":"TrxId-966507391373","metalBalance":49,"transactionType":"Credit out","paymentModel":"Trade","credit":10,"date":"2025-04-15T13:05:05.072Z"}]

MetalApiResponseModel metalApiResponseModelFromJson(String str) =>
    MetalApiResponseModel.fromJson(json.decode(str));
String metalApiResponseModelToJson(MetalApiResponseModel data) =>
    json.encode(data.toJson());

class MetalApiResponseModel {
  MetalApiResponseModel({
    String? status,
    num? code,
    String? message,
    List<MetalHistoryList>? payload,
  }) {
    _status = status;
    _code = code;
    _message = message;
    _payload = payload;
  }

  MetalApiResponseModel.fromJson(dynamic json) {
    _status = json['status'];
    _code = json['code'];
    _message = json['message'];
    if (json['payload'] != null) {
      _payload = [];
      json['payload'].forEach((v) {
        _payload?.add(MetalHistoryList.fromJson(v));
      });
    }
  }
  String? _status;
  num? _code;
  String? _message;
  List<MetalHistoryList>? _payload;
  MetalApiResponseModel copyWith({
    String? status,
    num? code,
    String? message,
    List<MetalHistoryList>? payload,
  }) =>
      MetalApiResponseModel(
        status: status ?? _status,
        code: code ?? _code,
        message: message ?? _message,
        payload: payload ?? _payload,
      );
  String? get status => _status;
  num? get code => _code;
  String? get message => _message;
  List<MetalHistoryList>? get payload => _payload;

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

/// _id : "67fe597e225b234eae2aeac9"
/// userId : "67fe1963410205d229ed07f8"
/// transactionId : "TrxId-376602359008"
/// metalBalance : 59
/// transactionType : "Credit in"
/// paymentModel : "Trade"
/// debit : 10
/// date : "2025-04-15T13:05:02.142Z"

MetalHistoryList payloadFromJson(String str) =>
    MetalHistoryList.fromJson(json.decode(str));
String payloadToJson(MetalHistoryList data) => json.encode(data.toJson());

class MetalHistoryList {
  MetalHistoryList({
    String? id,
    String? userId,
    String? tradeType,
    String? transactionId,
    num? metalBalance,
    String? transactionType,
    String? paymentModel,
    String? paymentModelInArabic,
    num? debit,
    num? credit,
    String? date,
  }) {
    _id = id;
    _userId = userId;
    _transactionId = transactionId;
    _tradeType = tradeType;
    _metalBalance = metalBalance;
    _transactionType = transactionType;
    _paymentModel = paymentModel;
    _paymentModelInArabic = paymentModelInArabic;
    _debit = debit;
    _credit = credit;
    _date = date;
  }

  MetalHistoryList.fromJson(dynamic json) {
    _id = json['_id'];
    _userId = json['userId'];
    _tradeType = json['tradeType'];
    _transactionId = json['transactionId'];
    _metalBalance = json['metalBalance'];
    _transactionType = json['transactionType'];
    _paymentModel = json['paymentModel'];
    _paymentModelInArabic = json['paymentModelInArabic'];
    _debit = json['debit'];
    _credit = json['credit'];
    _date = json['date'];
  }

  String? _id;
  String? _userId;
  String? _tradeType;
  String? _transactionId;
  num? _metalBalance;
  String? _transactionType;
  String? _paymentModel;
  String? _paymentModelInArabic;
  num? _debit;
  num? _credit;
  String? _date;

  MetalHistoryList copyWith({
    String? id,
    String? userId,
    
    String? tradeType,
    String? transactionId,
    num? metalBalance,
    String? transactionType,
    String? paymentModel,
    String? paymentModelInArabic,
    num? debit,
    num? credit,
    String? date,
  }) =>
      MetalHistoryList(
        id: id ?? _id,
        userId: userId ?? _userId,
        
        tradeType:  _tradeType,
        transactionId: transactionId ?? _transactionId,
        metalBalance: metalBalance ?? _metalBalance,
        transactionType: transactionType ?? _transactionType,
        paymentModel: paymentModel ?? _paymentModel,
        paymentModelInArabic: paymentModelInArabic??_paymentModelInArabic,
        debit: debit ?? _debit,
        credit: credit ?? _credit,
        date: date ?? _date,
      );

  String? get id => _id;
  String? get userId => _userId;
  String? get tradeType => _tradeType;
  String? get transactionId => _transactionId;
  num? get metalBalance => _metalBalance;
  String? get transactionType => _transactionType;
  String? get paymentModel => _paymentModel;
  String? get paymentModelInArabic => _paymentModelInArabic;
  num? get debit => _debit;
  num? get credit => _credit;
  String? get date => _date;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['_id'] = _id;
    map['userId'] = _userId;
    map['tradeType'] = _tradeType;
    map['transactionId'] = _transactionId;
    map['metalBalance'] = _metalBalance;
    map['transactionType'] = _transactionType;
    map['paymentModel'] = _paymentModel;
    map['paymentModelInArabic'] = _paymentModelInArabic;
    map['debit'] = _debit;
    map['credit'] = _credit;
    map['date'] = _date;
    return map;
  }
}
