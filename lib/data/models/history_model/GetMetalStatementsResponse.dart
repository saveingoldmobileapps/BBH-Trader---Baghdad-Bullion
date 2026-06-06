import 'dart:convert';

/// status : "success"
/// code : 1
/// message : "OK: The request has succeeded."
/// payload : [{"_id":"680386e5ef08d201a359b5fb","userId":"67fcd04a8b81de3f4d6adccc","tradeType":"Buy","buyingPrice":390.48,"transactionId":"TrxId-991815931827","metalBalance":75,"pnl":19.519999999999982,"transactionType":"Credit in","paymentModel":"Trade","credit":3,"debit":1171.44,"date":"2025-04-19T11:20:05.765Z","status":"Opened"},{"_id":"680386e1ef08d201a359b5d6","userId":"67fcd04a8b81de3f4d6adccc","tradeType":"Sell","sellingPrice":390,"transactionId":"TrxId-451861478223","metalBalance":99,"pnl":-15,"transactionType":"Credit out","paymentModel":"Trade","debit":10,"credit":3900,"date":"2025-04-19T11:20:01.136Z","status":"Closed"},{"_id":"6803866bef08d201a359b58c","userId":"67fcd04a8b81de3f4d6adccc","tradeType":"Buy","buyingPrice":390.48,"transactionId":"TrxId-783882678122","metalBalance":99,"pnl":60,"transactionType":"Credit in","paymentModel":"Trade","credit":3,"debit":1171.44,"date":"2025-04-19T11:18:03.649Z","status":"Opened"}]

GetMetalStatementsResponse getMetalStatementsResponseFromJson(String str) =>
    GetMetalStatementsResponse.fromJson(json.decode(str));

String getMetalStatementsResponseToJson(GetMetalStatementsResponse data) =>
    json.encode(data.toJson());

class GetMetalStatementsResponse {
  GetMetalStatementsResponse({
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

  GetMetalStatementsResponse.fromJson(dynamic json) {
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

  GetMetalStatementsResponse copyWith({
    String? status,
    num? code,
    String? message,
    List<MetalHistoryList>? payload,
  }) =>
      GetMetalStatementsResponse(
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

/// _id : "680386e5ef08d201a359b5fb"
/// userId : "67fcd04a8b81de3f4d6adccc"
/// tradeType : "Buy"
/// buyingPrice : 390.48
/// transactionId : "TrxId-991815931827"
/// metalBalance : 75
/// pnl : 19.519999999999982
/// transactionType : "Credit in"
/// paymentModel : "Trade"
/// credit : 3
/// debit : 1171.44
/// date : "2025-04-19T11:20:05.765Z"
/// status : "Opened"

MetalHistoryList payloadFromJson(String str) => MetalHistoryList.fromJson(json.decode(str));

String payloadToJson(MetalHistoryList data) => json.encode(data.toJson());

class MetalHistoryList {
  MetalHistoryList({
    String? id,
    String? userId,
    String? tradeType,
    num? buyingPrice,
    num? sellingPrice,
    String? transactionId,
    num? metalBalance,
    num? pnl,
    String? transactionType,
    String? paymentModel,
    String? paymentModelInArabic,
    num? credit,
    num? debit,
    String? date,
    String? status,
  }) {
    _id = id;
    _userId = userId;
    _tradeType = tradeType;
    _buyingPrice = buyingPrice;
    _sellingPrice = sellingPrice;
    _transactionId = transactionId;
    _metalBalance = metalBalance;
    _pnl = pnl;
    _transactionType = transactionType;
    _paymentModel = paymentModel;
    _paymentModelInArabic = paymentModelInArabic;
    _credit = credit;
    _debit = debit;
    _date = date;
    _status = status;
  }

  MetalHistoryList.fromJson(dynamic json) {
    _id = json['_id'];
    _userId = json['userId'];
    _tradeType = json['tradeType'];
    _buyingPrice = json['buyingPrice'];
    _sellingPrice = json['sellingPrice'];
    _transactionId = json['transactionId'];
    _metalBalance = json['metalBalance'];
    _pnl = json['pnl'];
    _transactionType = json['transactionType'];
    _paymentModel = json['paymentModel'];
    _paymentModelInArabic = json['paymentModelInArabic'];
    _credit = json['credit'];
    _debit = json['debit'];
    _date = json['date'];
    _status = json['status'];
  }

  String? _id;
  String? _userId;
  String? _tradeType;
  num? _buyingPrice;
  num? _sellingPrice;
  String? _transactionId;
  num? _metalBalance;
  num? _pnl;
  String? _transactionType;
  String? _paymentModel;
  String? _paymentModelInArabic;
  num? _credit;
  num? _debit;
  String? _date;
  String? _status;

  MetalHistoryList copyWith({
    String? id,
    String? userId,
    String? tradeType,
    num? buyingPrice,
    num? sellingPrice,
    String? transactionId,
    num? metalBalance,
    num? pnl,
    String? transactionType,
    String? paymentModel,
    String? paymentModelInArabic,
    num? credit,
    num? debit,
    String? date,
    String? status,
  }) =>
      MetalHistoryList(
        id: id ?? _id,
        userId: userId ?? _userId,
        tradeType: tradeType ?? _tradeType,
        buyingPrice: buyingPrice ?? _buyingPrice,
        sellingPrice: sellingPrice ?? _sellingPrice,
        transactionId: transactionId ?? _transactionId,
        metalBalance: metalBalance ?? _metalBalance,
        pnl: pnl ?? _pnl,
        transactionType: transactionType ?? _transactionType,
        paymentModel: paymentModel ?? _paymentModel,
        paymentModelInArabic: paymentModelInArabic??_paymentModelInArabic,
        credit: credit ?? _credit,
        debit: debit ?? _debit,
        date: date ?? _date,
        status: status ?? _status,
      );

  String? get id => _id;

  String? get userId => _userId;

  String? get tradeType => _tradeType;

  num? get buyingPrice => _buyingPrice;

  num? get sellingPrice => _sellingPrice;

  String? get transactionId => _transactionId;

  num? get metalBalance => _metalBalance;

  num? get pnl => _pnl;

  String? get transactionType => _transactionType;

  String? get paymentModel => _paymentModel;//paymentModelInArabic
  String? get paymentModelInArabic => _paymentModelInArabic;

  num? get credit => _credit;

  num? get debit => _debit;

  String? get date => _date;

  String? get status => _status;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['_id'] = _id;
    map['userId'] = _userId;
    map['tradeType'] = _tradeType;
    map['buyingPrice'] = _buyingPrice;
    map['sellingPrice'] = _sellingPrice;
    map['transactionId'] = _transactionId;
    map['metalBalance'] = _metalBalance;
    map['pnl'] = _pnl;
    map['transactionType'] = _transactionType;
    map['paymentModel'] = _paymentModel;
    map['paymentModelInArabic'] = _paymentModelInArabic;

    map['credit'] = _credit;
    map['debit'] = _debit;
    map['date'] = _date;
    map['status'] = _status;
    return map;
  }
}
