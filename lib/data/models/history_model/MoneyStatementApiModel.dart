import 'dart:convert';

/// status : "success"
/// code : 1
/// message : "OK: The request has succeeded."
/// payload : [{"_id":"67ee7488c4da73eddf59ec8b","userId":"67e26220bce3cf50d1535b2e","transactionId":"67ee7488c4da73eddf59ec8b","paymentMethod":"Money","orderType":"Loan","transactionType":"Loan","quantity":"","debit":1000,"credit":"","totalBalance":"","openPosition":"","closedPosition":"","date":"2025-04-03T11:44:08.044Z","triggerAt":"","triggerType":"","moneyBalance":50000,"metalBalance":50},{"_id":"67ee7b0ac4da73eddf59f504","userId":"67e26220bce3cf50d1535b2e","paymentMethod":"Money","transactionId":"67ee7b0ac4da73eddf59f504","orderType":"Gift","transactionType":"Gift","quantity":"","debit":"","credit":10,"totalBalance":"","openPosition":"","closedPosition":"","date":"2025-04-03T12:11:54.913Z","triggerAt":"","triggerType":"","moneyBalance":49990,"metalBalance":40},{"_id":"67ee7d03c4da73eddf59f6be","userId":"67e26220bce3cf50d1535b2e","orderId":"","triggerAt":0,"triggerType":"Buy","transactionId":"67ee7d03c4da73eddf59f6be","paymentMethod":"Money","orderType":"Trade","transactionType":"Bought","quantity":10,"debit":"","credit":10,"date":"2025-04-03T12:20:19.551Z"},{"_id":"67eea612e7336789e063c6a5","userId":"67e26220bce3cf50d1535b2e","orderId":"","triggerAt":0,"triggerType":"Sell","transactionId":"67eea612e7336789e063c6a5","paymentMethod":"Money","orderType":"Trade","transactionType":"Sold","quantity":11,"debit":11,"credit":"","date":"2025-04-03T15:15:30.592Z"},{"_id":"67eeed20e7336789e064537d","userId":"67e26220bce3cf50d1535b2e","orderId":"","triggerAt":0,"triggerType":"Buy","transactionId":"67eeed20e7336789e064537d","paymentMethod":"Money","orderType":"Trade","transactionType":"Bought","quantity":0.0006,"debit":"","credit":0.0006,"date":"2025-04-03T20:18:40.111Z"},{"_id":"67f01e3c34cb6b6eafc46a96","userId":"67e26220bce3cf50d1535b2e","orderId":"ORD987654321","transactionId":"67f01e3c34cb6b6eafc46a96","paymentMethod":"Money","orderType":"Open","transactionType":"","quantity":"","debit":50000,"openPosition":"","closedPosition":"","date":"2025-04-04T18:00:28.736Z","profitAmount":"","lossAmount":"","triggerAt":"","triggerType":"","moneyBalance":49956.99945,"metalBalance":""}]

MoneyStatementApiModel moneyStatementApiModelFromJson(String str) =>
    MoneyStatementApiModel.fromJson(json.decode(str));
String moneyStatementApiModelToJson(MoneyStatementApiModel data) =>
    json.encode(data.toJson());

class MoneyStatementApiModel {
  MoneyStatementApiModel({
    String? status,
    String? code,
    String? message,
    List<MoneyHistory>? payload,
  }) {
    _status = status;
    _code = code;
    _message = message;
    _payload = payload;
  }

  MoneyStatementApiModel.fromJson(dynamic json) {
    _status = json['status'];
    _code = json['code'].toString();
    _message = json['message'];
    if (json['payload'] != null) {
      _payload = [];
      json['payload'].forEach((v) {
        _payload?.add(MoneyHistory.fromJson(v));
      });
    }
  }
  String? _status;
  String? _code;
  String? _message;
  List<MoneyHistory>? _payload;
  MoneyStatementApiModel copyWith({
    String? status,
    String? code,
    String? message,
    List<MoneyHistory>? payload,
  }) =>
      MoneyStatementApiModel(
        status: status ?? _status,
        code: code ?? _code,
        message: message ?? _message,
        payload: payload ?? _payload,
      );
  String? get status => _status;
  String? get code => _code;
  String? get message => _message;
  List<MoneyHistory>? get payload => _payload;

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

/// _id : "67ee7488c4da73eddf59ec8b"
/// userId : "67e26220bce3cf50d1535b2e"
/// transactionId : "67ee7488c4da73eddf59ec8b"
/// paymentMethod : "Money"
/// orderType : "Loan"
/// transactionType : "Loan"
/// quantity : ""
/// debit : 1000
/// credit : ""
/// totalBalance : ""
/// openPosition : ""
/// closedPosition : ""
/// date : "2025-04-03T11:44:08.044Z"
/// triggerAt : ""
/// triggerType : ""
/// moneyBalance : 50000
/// metalBalance : 50

MoneyHistory payloadFromJson(String str) =>
    MoneyHistory.fromJson(json.decode(str));
String payloadToJson(MoneyHistory data) => json.encode(data.toJson());

class MoneyHistory {
  MoneyHistory({
    String? id,
    String? userId,
    String? transactionId,
    String? paymentMethod,
    String? orderType,
    String? transactionType,
    String? quantity,
    String? debit,
    String? credit,
    String? totalBalance,
    String? openPosition,
    String? closedPosition,
    String? date,
    String? triggerAt,
    String? triggerType,
    String? moneyBalance,
    String? metalBalance,
  }) {
    _id = id;
    _userId = userId;
    _transactionId = transactionId;
    _paymentMethod = paymentMethod;
    _orderType = orderType;
    _transactionType = transactionType;
    _quantity = quantity;
    _debit = debit;
    _credit = credit;
    _totalBalance = totalBalance;
    _openPosition = openPosition;
    _closedPosition = closedPosition;
    _date = date;
    _triggerAt = triggerAt;
    _triggerType = triggerType;
    _moneyBalance = moneyBalance;
    _metalBalance = metalBalance;
  }

  MoneyHistory.fromJson(dynamic json) {
    _id = json['_id'];
    _userId = json['userId'];
    _transactionId = json['transactionId'];
    _paymentMethod = json['paymentMethod'];
    _orderType = json['orderType'];
    _transactionType = json['transactionType'];
    _quantity = json['quantity'].toString();
    _debit = json['debit'].toString();
    _credit = json['credit'].toString();
    _totalBalance = json['totalBalance'].toString();
    _openPosition = json['openPosition'].toString();
    _closedPosition = json['closedPosition'].toString();
    _date = json['date'];
    _triggerAt = json['triggerAt'].toString();
    _triggerType = json['triggerType'];
    _moneyBalance = json['moneyBalance'].toString();
    _metalBalance = json['metalBalance'].toString();
  }
  String? _id;
  String? _userId;
  String? _transactionId;
  String? _paymentMethod;
  String? _orderType;
  String? _transactionType;
  String? _quantity;
  String? _debit;
  String? _credit;
  String? _totalBalance;
  String? _openPosition;
  String? _closedPosition;
  String? _date;
  String? _triggerAt;
  String? _triggerType;
  String? _moneyBalance;
  String? _metalBalance;
  MoneyHistory copyWith({
    String? id,
    String? userId,
    String? transactionId,
    String? paymentMethod,
    String? orderType,
    String? transactionType,
    String? quantity,
    String? debit,
    String? credit,
    String? totalBalance,
    String? openPosition,
    String? closedPosition,
    String? date,
    String? triggerAt,
    String? triggerType,
    String? moneyBalance,
    String? metalBalance,
  }) =>
      MoneyHistory(
        id: id ?? _id,
        userId: userId ?? _userId,
        transactionId: transactionId ?? _transactionId,
        paymentMethod: paymentMethod ?? _paymentMethod,
        orderType: orderType ?? _orderType,
        transactionType: transactionType ?? _transactionType,
        quantity: quantity ?? _quantity,
        debit: debit ?? _debit,
        credit: credit ?? _credit,
        totalBalance: totalBalance ?? _totalBalance,
        openPosition: openPosition ?? _openPosition,
        closedPosition: closedPosition ?? _closedPosition,
        date: date ?? _date,
        triggerAt: triggerAt ?? _triggerAt,
        triggerType: triggerType ?? _triggerType,
        moneyBalance: moneyBalance ?? _moneyBalance,
        metalBalance: metalBalance ?? _metalBalance,
      );
  String? get id => _id;
  String? get userId => _userId;
  String? get transactionId => _transactionId;
  String? get paymentMethod => _paymentMethod;
  String? get orderType => _orderType;
  String? get transactionType => _transactionType;
  String? get quantity => _quantity;
  String? get debit => _debit;
  String? get credit => _credit;
  String? get totalBalance => _totalBalance;
  String? get openPosition => _openPosition;
  String? get closedPosition => _closedPosition;
  String? get date => _date;
  String? get triggerAt => _triggerAt;
  String? get triggerType => _triggerType;
  String? get moneyBalance => _moneyBalance;
  String? get metalBalance => _metalBalance;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['_id'] = _id;
    map['userId'] = _userId;
    map['transactionId'] = _transactionId;
    map['paymentMethod'] = _paymentMethod;
    map['orderType'] = _orderType;
    map['transactionType'] = _transactionType;
    map['quantity'] = _quantity;
    map['debit'] = _debit;
    map['credit'] = _credit;
    map['totalBalance'] = _totalBalance;
    map['openPosition'] = _openPosition;
    map['closedPosition'] = _closedPosition;
    map['date'] = _date;
    map['triggerAt'] = _triggerAt;
    map['triggerType'] = _triggerType;
    map['moneyBalance'] = _moneyBalance;
    map['metalBalance'] = _metalBalance;
    return map;
  }
}
