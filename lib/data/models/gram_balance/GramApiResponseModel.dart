import 'dart:convert';

/// status : "success"
/// code : 1
/// message : "OK: The request has succeeded."
/// payload : [{"_id":"680258a3bf265ffeae913eef","userId":"67fcd04a8b81de3f4d6adccc","tradeType":"Buy","tradeBy":"Money","tradeMoney":3906.87,"tradeMetal":10,"tradeStatus":"Opened","buyingPrice":390.68666332084484,"buyAtPriceStatus":true,"buyAtPrice":3900,"orderId":95575450,"createdAt":"2025-04-18T13:50:27.575Z","moneyBalance":16517.185999999994},{"_id":"680257ddbf265ffeae91374e","userId":"67fcd04a8b81de3f4d6adccc","tradeType":"Buy","tradeBy":"Money","tradeMoney":3906.67,"tradeMetal":10,"tradeStatus":"Opened","buyingPrice":390.66717321250644,"buyAtPriceStatus":true,"buyAtPrice":3900,"orderId":73288125,"createdAt":"2025-04-18T13:47:09.530Z","moneyBalance":16517.185999999994},{"_id":"6802451903f0525ddb28a8c8","userId":"67fcd04a8b81de3f4d6adccc","tradeType":"Sell","tradeBy":"Metal","tradeMoney":15229.63,"tradeMetal":39,"tradeStatus":"Closed","sellingPrice":390.5032200587265,"sellAtProfitStatus":false,"sellAtProfit":0,"orderId":57215598,"createdAt":"2025-04-18T12:27:05.716Z","moneyBalance":46018.79},{"_id":"6802441a03f0525ddb28a700","userId":"67fcd04a8b81de3f4d6adccc","tradeType":"Sell","tradeBy":"Metal","tradeMoney":3904.06,"tradeMetal":10,"tradeStatus":"Closed","sellingPrice":390.40624200450947,"sellAtProfitStatus":false,"sellAtProfit":0,"orderId":70422095,"createdAt":"2025-04-18T12:22:50.207Z","moneyBalance":30789.160000000003},{"_id":"680243ea03f0525ddb28a650","userId":"67fcd04a8b81de3f4d6adccc","tradeType":"Sell","tradeBy":"Metal","tradeMoney":351.49,"tradeMetal":0.9,"tradeStatus":"Closed","sellingPrice":390.54692515015205,"sellAtProfitStatus":false,"sellAtProfit":0,"orderId":48914791,"createdAt":"2025-04-18T12:22:02.876Z","moneyBalance":26885.100000000002},{"_id":"680243e303f0525ddb28a612","userId":"67fcd04a8b81de3f4d6adccc","tradeType":"Sell","tradeBy":"Metal","tradeMoney":390.58,"tradeMetal":1,"tradeStatus":"Closed","sellingPrice":390.58259795450476,"sellAtProfitStatus":false,"sellAtProfit":0,"orderId":88001086,"createdAt":"2025-04-18T12:21:55.520Z","moneyBalance":26533.61},{"_id":"680243ab03f0525ddb28a51f","userId":"67fcd04a8b81de3f4d6adccc","tradeType":"Sell","tradeBy":"Metal","tradeMoney":3513.72,"tradeMetal":9,"tradeStatus":"Closed","sellingPrice":390.4136836822387,"sellAtProfitStatus":false,"sellAtProfit":0,"orderId":99043182,"createdAt":"2025-04-18T12:20:59.531Z","moneyBalance":26143.03},{"_id":"68023f8003f0525ddb289851","userId":"67fcd04a8b81de3f4d6adccc","tradeType":"Buy","tradeBy":"Money","tradeMoney":3123.85,"tradeMetal":8,"tradeStatus":"Opened","buyingPrice":390.4808950255389,"buyAtPriceStatus":true,"buyAtPrice":3110,"orderId":67767058,"createdAt":"2025-04-18T12:03:12.859Z","moneyBalance":22629.309999999998},{"_id":"68023eb003f0525ddb28956d","userId":"67fcd04a8b81de3f4d6adccc","tradeType":"Buy","tradeBy":"Money","tradeMoney":4296.22,"tradeMetal":11,"tradeStatus":"Opened","buyingPrice":390.56582464914686,"buyAtPriceStatus":true,"buyAtPrice":4290,"orderId":17701823,"createdAt":"2025-04-18T11:59:44.401Z","moneyBalance":22629.309999999998},{"_id":"68023dfc03f0525ddb28932c","userId":"67fcd04a8b81de3f4d6adccc","tradeType":"Buy","tradeBy":"Money","tradeMoney":3905.95,"tradeMetal":10,"tradeStatus":"Opened","buyingPrice":390.59452826324525,"buyAtPriceStatus":true,"buyAtPrice":3900,"orderId":51577222,"createdAt":"2025-04-18T11:56:44.962Z","moneyBalance":22629.309999999998},{"_id":"6802399203f0525ddb288456","userId":"67fcd04a8b81de3f4d6adccc","tradeType":"Buy","tradeBy":"Money","tradeMoney":1171.44,"tradeMetal":3,"tradeStatus":"Opened","buyingPrice":390.48124939114507,"buyAtPriceStatus":true,"buyAtPrice":1165,"orderId":96434289,"createdAt":"2025-04-18T11:37:54.426Z","moneyBalance":30050.119999999995},{"_id":"6802385c86c2639ca105f00e","userId":"67fcd04a8b81de3f4d6adccc","tradeType":"Buy","tradeBy":"Money","tradeMoney":3900,"tradeMetal":10,"tradeStatus":"Opened","buyingPrice":392.4516402832224,"buyAtPriceStatus":true,"buyAtPrice":500,"orderId":16830732,"createdAt":"2025-04-18T11:32:44.684Z","moneyBalance":30050.119999999995},{"_id":"68020839a8601bed66c6d7c9","userId":"67fcd04a8b81de3f4d6adccc","tradeType":"Sell","tradeBy":"Metal","tradeMoney":6503.19,"tradeMetal":16.6,"tradeStatus":"Closed","sellingPrice":391.7582649138504,"sellAtProfitStatus":false,"sellAtProfit":null,"orderId":71927430,"createdAt":"2025-04-18T08:07:21.382Z","moneyBalance":32978.759999999995},{"_id":"680206bca8601bed66c6c3e2","userId":"67fcd04a8b81de3f4d6adccc","tradeType":"Sell","tradeBy":"Metal","tradeMoney":1958.79,"tradeMetal":5,"tradeStatus":"Closed","sellingPrice":391.7582649138504,"sellAtProfitStatus":false,"sellAtProfit":null,"orderId":84640119,"createdAt":"2025-04-18T08:01:00.460Z","moneyBalance":26475.569999999996},{"_id":"680205bfa8601bed66c6a7c8","userId":"67fcd04a8b81de3f4d6adccc","tradeType":"Buy","tradeBy":"Money","tradeMoney":3917.58,"tradeMetal":10,"tradeStatus":"Opened","buyingPrice":395.7582649138504,"buyAtPriceStatus":false,"buyAtPrice":null,"orderId":57885314,"createdAt":"2025-04-18T07:56:47.307Z","moneyBalance":25692.049999999996},{"_id":"68010888f20412eff658bc58","userId":"67fcd04a8b81de3f4d6adccc","tradeType":"Sell","tradeBy":"Metal","tradeMoney":3900,"tradeMetal":10,"tradeStatus":"Closed","sellingPrice":350,"sellAtProfitStatus":false,"sellAtProfit":null,"orderId":92726229,"createdAt":"2025-04-17T13:56:24.631Z","moneyBalance":29609.629999999997},{"_id":"68010867922251383dc2364d","userId":"67fcd04a8b81de3f4d6adccc","tradeType":"Sell","tradeBy":"Metal","tradeMoney":3900,"tradeMetal":10,"tradeStatus":"Closed","sellingPrice":350,"sellAtProfitStatus":false,"sellAtProfit":null,"orderId":54196390,"createdAt":"2025-04-17T13:55:51.841Z","moneyBalance":25709.629999999997},{"_id":"6801083c66374706343b418c","userId":"67fcd04a8b81de3f4d6adccc","tradeType":"Sell","tradeBy":"Metal","tradeMoney":3900,"tradeMetal":10,"tradeStatus":"Closed","sellingPrice":350,"sellAtProfitStatus":false,"sellAtProfit":null,"orderId":67383820,"createdAt":"2025-04-17T13:55:08.669Z","moneyBalance":21809.629999999997},{"_id":"6801027602352c81a156c227","userId":"67fcd04a8b81de3f4d6adccc","tradeType":"Sell","tradeBy":"Metal","tradeMoney":3900,"tradeMetal":10,"tradeStatus":"Closed","sellingPrice":350,"sellAtProfitStatus":false,"sellAtProfit":null,"orderId":82508598,"createdAt":"2025-04-17T13:30:30.705Z","moneyBalance":21809.629999999997},{"_id":"68010152264cc01eb78798ec","userId":"67fcd04a8b81de3f4d6adccc","tradeType":"Sell","tradeBy":"Metal","tradeMoney":3900,"tradeMetal":10,"tradeStatus":"Closed","sellingPrice":350,"sellAtProfitStatus":false,"sellAtProfit":null,"orderId":20566390,"createdAt":"2025-04-17T13:25:38.990Z","moneyBalance":17909.629999999997},{"_id":"6801010d3ba6c1f72f6f6298","userId":"67fcd04a8b81de3f4d6adccc","tradeType":"Sell","tradeBy":"Metal","tradeMoney":3900,"tradeMetal":10,"tradeStatus":"Closed","sellingPrice":350,"sellAtProfitStatus":false,"sellAtProfit":null,"orderId":75657019,"createdAt":"2025-04-17T13:24:29.291Z","moneyBalance":14009.629999999997},{"_id":"6801004d3ba6c1f72f6f4ebc","userId":"67fcd04a8b81de3f4d6adccc","tradeType":"Sell","tradeBy":"Metal","tradeMoney":3900,"tradeMetal":10,"tradeStatus":"Closed","sellingPrice":350,"sellAtProfitStatus":false,"sellAtProfit":null,"orderId":47595018,"createdAt":"2025-04-17T13:21:17.779Z","moneyBalance":14009.629999999997},{"_id":"680100313ba6c1f72f6f4b90","userId":"67fcd04a8b81de3f4d6adccc","tradeType":"Sell","tradeBy":"Metal","tradeMoney":3900,"tradeMetal":10,"tradeStatus":"Closed","sellingPrice":350,"sellAtProfitStatus":false,"sellAtProfit":null,"orderId":49699183,"createdAt":"2025-04-17T13:20:49.349Z","moneyBalance":14009.629999999997},{"_id":"6800f22940a142ffbb054198","userId":"67fcd04a8b81de3f4d6adccc","tradeType":"Sell","tradeBy":"Metal","tradeMoney":3900,"tradeMetal":10,"tradeStatus":"Closed","sellingPrice":350,"sellAtProfitStatus":false,"sellAtProfit":null,"orderId":18423158,"createdAt":"2025-04-17T12:20:57.627Z","moneyBalance":25709.629999999997},{"_id":"6800f21940a142ffbb054160","userId":"67fcd04a8b81de3f4d6adccc","tradeType":"Sell","tradeBy":"Metal","tradeMoney":3900,"tradeMetal":10,"tradeStatus":"Closed","sellingPrice":350,"sellAtProfitStatus":false,"sellAtProfit":null,"orderId":87500863,"createdAt":"2025-04-17T12:20:41.569Z","moneyBalance":21809.629999999997},{"_id":"6800ebaf81b2e44463205a47","userId":"67fcd04a8b81de3f4d6adccc","tradeType":"Sell","tradeBy":"Metal","tradeMoney":3900,"tradeMetal":10,"tradeStatus":"Closed","sellingPrice":350,"sellAtProfitStatus":false,"sellAtProfit":null,"orderId":96342669,"createdAt":"2025-04-17T11:53:19.448Z","moneyBalance":10109.629999999996}]

GramApiResponseModel gramApiResponseModelFromJson(String str) =>
    GramApiResponseModel.fromJson(json.decode(str));

String gramApiResponseModelToJson(GramApiResponseModel data) =>
    json.encode(data.toJson());

class GramApiResponseModel {
  GramApiResponseModel({
    String? status,
    num? code,
    String? message,
    List<Payload>? payload,
  }) {
    _status = status;
    _code = code;
    _message = message;
    _payload = payload;
  }

  GramApiResponseModel.fromJson(dynamic json) {
    _status = json['status'];
    _code = json['code'];
    _message = json['message'];
    if (json['payload'] != null) {
      _payload = [];
      json['payload'].forEach((v) {
        _payload?.add(Payload.fromJson(v));
      });
    }
  }

  String? _status;
  num? _code;
  String? _message;
  List<Payload>? _payload;

  GramApiResponseModel copyWith({
    String? status,
    num? code,
    String? message,
    List<Payload>? payload,
  }) =>
      GramApiResponseModel(
        status: status ?? _status,
        code: code ?? _code,
        message: message ?? _message,
        payload: payload ?? _payload,
      );

  String? get status => _status;

  num? get code => _code;

  String? get message => _message;

  List<Payload>? get payload => _payload;

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

/// _id : "680258a3bf265ffeae913eef"
/// userId : "67fcd04a8b81de3f4d6adccc"
/// tradeType : "Buy"
/// tradeBy : "Money"
/// tradeMoney : 3906.87
/// tradeMetal : 10
/// tradeStatus : "Opened"
/// buyingPrice : 390.68666332084484
/// buyAtPriceStatus : true
/// buyAtPrice : 3900
/// orderId : 95575450
/// createdAt : "2025-04-18T13:50:27.575Z"
/// moneyBalance : 16517.185999999994

Payload payloadFromJson(String str) => Payload.fromJson(json.decode(str));

String payloadToJson(Payload data) => json.encode(data.toJson());

class Payload {
  Payload({
    String? id,
    String? userId,
    String? tradeCategory,
    String? barNumber,
    String? tradeType,
    String? tradeBy,
    num? tradeMoney,
    num? tradeMetal,
    String? tradeStatus,
    num? buyingPrice,
    num? sellingPrice,
    bool? buyAtPriceStatus,
    num? buyAtPrice,
    num? sellAtProfit,
    num? orderId,
    num? dealId,
    String? createdAt,
    num? moneyBalance,
  }) {
    _id = id;
    _userId = userId;
    _tradeCategory = tradeCategory;
    _barNumber = barNumber;
    _tradeType = tradeType;
    _tradeBy = tradeBy;
    _tradeMoney = tradeMoney;
    _tradeMetal = tradeMetal;
    _tradeStatus = tradeStatus;
    _buyingPrice = buyingPrice;
    _sellingPrice = sellingPrice;
    _buyAtPriceStatus = buyAtPriceStatus;
    _buyAtPrice = buyAtPrice;
    _sellAtProfit = sellAtProfit;
    _orderId = orderId;
    _dealId = dealId;
    _createdAt = createdAt;
    _moneyBalance = moneyBalance;
  }

  Payload.fromJson(dynamic json) {
    _id = json['_id'];
    _userId = json['userId'];
    _tradeCategory = json['tradeCategory'];
    _barNumber= json['barNumber'];
    _tradeType = json['tradeType'];
    _tradeBy = json['tradeBy'];
    _tradeMoney = json['tradeMoney'];
    _tradeMetal = json['tradeMetal'];
    _tradeStatus = json['tradeStatus'];
    _sellingPrice = json['sellingPrice'];
    _buyingPrice = json['buyingPrice'];
    _buyAtPriceStatus = json['buyAtPriceStatus'];
    _buyAtPrice = json['buyAtPrice'];
    _sellAtProfit = json['sellAtProfit'];
    _orderId = json['orderId'];
    _dealId = json['dealId'];
    _createdAt = json['createdAt'];
    _moneyBalance = json['moneyBalance'];
  }

  String? _id;
  String? _userId;
  String? _tradeCategory;
  String? _barNumber;
  String? _tradeType;
  String? _tradeBy;
  num? _tradeMoney;
  num? _tradeMetal;
  String? _tradeStatus;
  num? _buyingPrice;
  num? _sellingPrice;
  bool? _buyAtPriceStatus;
  num? _buyAtPrice;
  num? _sellAtProfit;
  num? _orderId;
  num? _dealId;
  String? _createdAt;
  num? _moneyBalance;

  Payload copyWith({
    String? id,
    String? userId,
    String? tradeCategory,
    String? barNumber,
    String? tradeType,
    String? tradeBy,
    num? tradeMoney,
    num? tradeMetal,
    String? tradeStatus,
    num? buyingPrice,
    num? sellingPrice,
    bool? buyAtPriceStatus,
    num? buyAtPrice,
    num? sellAtProfit,
    num? orderId,
    num? dealId,
    String? createdAt,
    num? moneyBalance,
  }) =>
      Payload(
        id: id ?? _id,
        userId: userId ?? _userId,
        tradeCategory: tradeCategory?? _tradeCategory,
        barNumber: barNumber??_barNumber,
      
        tradeType: tradeType ?? _tradeType,
        tradeBy: tradeBy ?? _tradeBy,
        tradeMoney: tradeMoney ?? _tradeMoney,
        tradeMetal: tradeMetal ?? _tradeMetal,
        tradeStatus: tradeStatus ?? _tradeStatus,
        buyingPrice: buyingPrice ?? _buyingPrice,
        sellingPrice: sellingPrice ?? _sellingPrice,
        buyAtPriceStatus: buyAtPriceStatus ?? _buyAtPriceStatus,
        buyAtPrice: buyAtPrice ?? _buyAtPrice,
        sellAtProfit: sellAtProfit ?? _sellAtProfit,
        orderId: orderId ?? _orderId,
        dealId: dealId ?? _dealId,
        createdAt: createdAt ?? _createdAt,
        moneyBalance: moneyBalance ?? _moneyBalance,
      );

  String? get id => _id;

  String? get userId => _userId;

  String? get tradeCategory=> _tradeCategory;

  String? get barNumber=> _barNumber;

  String? get tradeType => _tradeType;

  String? get tradeBy => _tradeBy;

  num? get tradeMoney => _tradeMoney;

  num? get tradeMetal => _tradeMetal;

  String? get tradeStatus => _tradeStatus;

  num? get buyingPrice => _buyingPrice;

  num? get sellingPrice => _sellingPrice;

  bool? get buyAtPriceStatus => _buyAtPriceStatus;

  num? get buyAtPrice => _buyAtPrice;

  num? get sellAtProfit => _sellAtProfit;

  num? get orderId => _orderId;

  num? get dealId => _dealId;

  String? get createdAt => _createdAt;

  num? get moneyBalance => _moneyBalance;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['_id'] = _id;
    map['userId'] = _userId;
    map['tradeCategory'] = _tradeCategory;
    map['barNumber'] = _barNumber;
    map['tradeType'] = _tradeType;
    map['tradeBy'] = _tradeBy;
    map['tradeMoney'] = _tradeMoney;
    map['tradeMetal'] = _tradeMetal;
    map['tradeStatus'] = _tradeStatus;
    map['buyingPrice'] = _buyingPrice;
    map['sellingPrice'] = _sellingPrice;
    map['buyAtPriceStatus'] = _buyAtPriceStatus;
    map['buyAtPrice'] = _buyAtPrice;
    map['sellAtProfit'] = _sellAtProfit;
    map['orderId'] = _orderId;
    map['dealId'] = _dealId;
    map['createdAt'] = _createdAt;
    map['moneyBalance'] = _moneyBalance;
    return map;
  }
}
