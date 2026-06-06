import 'dart:convert';

NewMoneyApiResponseModel newMoneyApiResponseModelFromJson(String str) =>
    NewMoneyApiResponseModel.fromJson(json.decode(str));
String newMoneyApiResponseModelToJson(NewMoneyApiResponseModel data) =>
    json.encode(data.toJson());

class NewMoneyApiResponseModel {
  NewMoneyApiResponseModel({
    String? status,
    num? code,
    String? message,
    List<MoneyHistoryList>? payload,
  }) {
    _status = status;
    _code = code;
    _message = message;
    _payload = payload;
  }

  NewMoneyApiResponseModel.fromJson(dynamic json) {
    _status = json['status'];
    _code = json['code'];
    _message = json['message'];
    if (json['payload'] != null) {
      _payload = [];
      json['payload'].forEach((v) {
        _payload?.add(MoneyHistoryList.fromJson(v));
      });
    }
  }
  String? _status;
  num? _code;
  String? _message;
  List<MoneyHistoryList>? _payload;
  NewMoneyApiResponseModel copyWith({
    String? status,
    num? code,
    String? message,
    List<MoneyHistoryList>? payload,
  }) => NewMoneyApiResponseModel(
    status: status ?? _status,
    code: code ?? _code,
    message: message ?? _message,
    payload: payload ?? _payload,
  );
  String? get status => _status;
  num? get code => _code;
  String? get message => _message;
  List<MoneyHistoryList>? get payload => _payload;

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

/// _id : "67fe58d6924c7a8d933ece9a"
/// userId : "67fe1963410205d229ed07f8"
/// transactionId : "TrxId-969078159180"
/// transactionType : "Gift Sent"
/// paymentModel : "Credit out"
/// credit : 400
/// date : "2025-04-15T13:02:14.976Z"
/// moneyBalance : 4750

MoneyHistoryList payloadFromJson(String str) =>
    MoneyHistoryList.fromJson(json.decode(str));
String payloadToJson(MoneyHistoryList data) => json.encode(data.toJson());

class MoneyHistoryList {
  MoneyHistoryList({
    String? id,
    String? userId,
    String? transactionId,
    String? transactionType,
    String? transactionTypeInAr,
    String? paymentModel,
    String? paymentModelInArabic,
    num? credit,
    num? debit,
    String? date,
    num? grams,
    num? moneyBalance,
    String? statusst,
  }) {
    _id = id;
    _userId = userId;
    _transactionId = transactionId;
    _transactionType = transactionType;
    _transactionTypeInAr = transactionTypeInAr;
    _paymentModel = paymentModel;
    _paymentModelInArabic = paymentModelInArabic;
    _credit = credit;
    _debit = debit;
    _date = date;
    _grams = grams;
    _moneyBalance = moneyBalance;
    _statusst = statusst;
  }

  MoneyHistoryList.fromJson(dynamic json) {
    _id = json['_id'];
    _userId = json['userId'];
    _transactionId = json['transactionId'];
    _transactionType = json['transactionType'];
    _transactionTypeInAr = json['transactionTypeInAr'];
    _paymentModel = json['paymentModel'];
    _paymentModelInArabic = json['paymentModelInArabic'];
    _credit = json['credit'];
    _debit = json['debit'];
    _date = json['date'];
    _grams = json['grams'];
    _moneyBalance = json['moneyBalance'];
    _statusst = json['status'];
  }

  String? _id;
  String? _userId;
  String? _transactionId;
  String? _transactionType;
  String? _transactionTypeInAr;
  String? _paymentModel;
  String? _paymentModelInArabic;
  num? _credit;
  num? _debit;
  String? _date;
  num? _grams;
  num? _moneyBalance;
  String? _statusst; //= json['status'];

  MoneyHistoryList copyWith({
    String? id,
    String? userId,
    String? transactionId,
    String? transactionType,
    String? transactionTypeInAr,
    String? paymentModel,
    String? paymentModelInArabic,
    num? credit,
    num? debit,
    String? date,
    num? grams,
    num? moneyBalance,
    String? statusst,
  }) => MoneyHistoryList(
    id: id ?? _id,
    userId: userId ?? _userId,
    transactionId: transactionId ?? _transactionId,
    transactionType: transactionType ?? _transactionType,
    transactionTypeInAr: transactionTypeInAr ?? _transactionTypeInAr,
    paymentModel: paymentModel ?? _paymentModel,
    paymentModelInArabic: paymentModelInArabic ?? _paymentModelInArabic,
    credit: credit ?? _credit,
    debit: debit ?? _debit,
    date: date ?? _date,
    grams: grams ?? _grams,
    moneyBalance: moneyBalance ?? _moneyBalance,
    statusst: _statusst ?? _statusst,
  );

  String? get id => _id;
  String? get userId => _userId;
  String? get transactionId => _transactionId;
  String? get transactionType => _transactionType;
  String? get transactionTypeInAr => _transactionTypeInAr;
  String? get paymentModel => _paymentModel;
  String? get paymentModelInArabic => _paymentModelInArabic;
  num? get credit => _credit;
  num? get debit => _debit;
  String? get date => _date;
  num? get grams => _grams;
  num? get moneyBalance => _moneyBalance;
  String? get status => _statusst;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['_id'] = _id;
    map['userId'] = _userId;
    map['transactionId'] = _transactionId;
    map['transactionType'] = _transactionType;
    map['transactionTypeInAr'] = _transactionTypeInAr;
    map['paymentModel'] = _paymentModel;
    map['paymentModelInArabic'] = _paymentModelInArabic;
    map['credit'] = _credit;
    map['debit'] = _debit;
    map['date'] = _date;
    map['grams'] = _grams;
    map['moneyBalance'] = _moneyBalance;
    map['status'] = _statusst;
    return map;
  }
}
