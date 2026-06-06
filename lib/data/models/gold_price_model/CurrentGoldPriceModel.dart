import 'dart:convert';

CurrentGoldPriceModel currentGoldPriceModelFromJson(String str) =>
    CurrentGoldPriceModel.fromJson(json.decode(str));

String currentGoldPriceModelToJson(CurrentGoldPriceModel data) =>
    json.encode(data.toJson());

class CurrentGoldPriceModel {
  CurrentGoldPriceModel({
    String? status,
    num? code,
    String? message,
    Payload? payload,
  }) {
    _status = status;
    _code = code;
    _message = message;
    _payload = payload;
  }

  CurrentGoldPriceModel.fromJson(dynamic json) {
    _status = json['status'];
    _code = json['code'];
    _message = json['message'];
    _payload =
        json['payload'] != null ? Payload.fromJson(json['payload']) : null;
  }

  String? _status;
  num? _code;
  String? _message;
  Payload? _payload;

  CurrentGoldPriceModel copyWith({
    String? status,
    num? code,
    String? message,
    Payload? payload,
  }) =>
      CurrentGoldPriceModel(
        status: status ?? _status,
        code: code ?? _code,
        message: message ?? _message,
        payload: payload ?? _payload,
      );

  String? get status => _status;

  num? get code => _code;

  String? get message => _message;

  Payload? get payload => _payload;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['status'] = _status;
    map['code'] = _code;
    map['message'] = _message;
    if (_payload != null) {
      map['payload'] = _payload?.toJson();
    }
    return map;
  }
}

Payload payloadFromJson(String str) => Payload.fromJson(json.decode(str));

String payloadToJson(Payload data) => json.encode(data.toJson());

class Payload {
  Payload({
    String? timeSpan,
    List<Prices>? prices,
  }) {
    _timeSpan = timeSpan;
    _prices = prices;
  }

  Payload.fromJson(dynamic json) {
    _timeSpan = json['timeSpan'];
    if (json['prices'] != null) {
      _prices = [];
      json['prices'].forEach((v) {
        _prices?.add(Prices.fromJson(v));
      });
    }
  }

  String? _timeSpan;
  List<Prices>? _prices;

  Payload copyWith({
    String? timeSpan,
    List<Prices>? prices,
  }) =>
      Payload(
        timeSpan: timeSpan ?? _timeSpan,
        prices: prices ?? _prices,
      );

  String? get timeSpan => _timeSpan;

  List<Prices>? get prices => _prices;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['timeSpan'] = _timeSpan;
    if (_prices != null) {
      map['prices'] = _prices?.map((v) => v.toJson()).toList();
    }
    return map;
  }
}

Prices pricesFromJson(String str) => Prices.fromJson(json.decode(str));

String pricesToJson(Prices data) => json.encode(data.toJson());

class Prices {
  Prices({
    String? id,
    String? timestamp,
    num? price,
  }) {
    _id = id;
    _timestamp = timestamp;
    _price = price;
  }

  Prices.fromJson(dynamic json) {
    _id = json['_id'];
    _timestamp = json['timestamp'];
    _price = json['price'];
  }

  String? _id;
  String? _timestamp;
  num? _price;

  Prices copyWith({
    String? id,
    String? timestamp,
    num? price,
  }) =>
      Prices(
        id: id ?? _id,
        timestamp: timestamp ?? _timestamp,
        price: price ?? _price,
      );

  String? get id => _id;

  String? get timestamp => _timestamp;

  num? get price => _price;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['_id'] = _id;
    map['timestamp'] = _timestamp;
    map['price'] = _price;
    return map;
  }
}
