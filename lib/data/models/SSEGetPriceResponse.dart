class SSEGetGoldPriceResponse {
  List<Prices>? prices;

  SSEGetGoldPriceResponse({this.prices});

  factory SSEGetGoldPriceResponse.fromJson(List<dynamic> json) {
    return SSEGetGoldPriceResponse(
      prices: json.map((e) => Prices.fromJson(e)).toList(),
    );
  }
}

class Prices {
  String? _symbol;
  String? _mDEntryType;
  num? _mDBuyingPx;
  num? _mDSellingPx;
  num? _lastLowSellingPrice;
  num? _lastHighBuyingPrice;
  ExchangeRate? _exchangeRate;
  Prices({
    String? symbol,
    String? mDEntryType,
    num? mDBuyingPx,
    num? lastHighBuyingPrice,
    num? mDSellingPx,
    num? lastLowSellingPrice,
    ExchangeRate? exchangeRate,
  }) {
    if (symbol != null) {
      _symbol = symbol;
    }
    if (mDEntryType != null) {
      _mDEntryType = mDEntryType;
    }
    if (lastLowSellingPrice != null) {
      _lastLowSellingPrice = lastLowSellingPrice;
    }
    if (lastHighBuyingPrice != null) {
      _lastHighBuyingPrice = lastHighBuyingPrice;
    }
    if (mDBuyingPx != null) {
      _mDBuyingPx = mDBuyingPx;
    }
    if (mDSellingPx != null) {
      _mDSellingPx = mDSellingPx;
    }
    if (exchangeRate != null) {
      _exchangeRate = exchangeRate;
    }
  }

  String? get symbol => _symbol;
  set symbol(String? symbol) => _symbol = symbol;
  String? get mDEntryType => _mDEntryType;
  set mDEntryType(String? mDEntryType) => _mDEntryType = mDEntryType;
  num? get mDBuyingPx => _mDBuyingPx;
  set mDBuyingPx(num? mDBuyingPx) => _mDBuyingPx = mDBuyingPx;
  num? get lastLowSellingPrice => _lastLowSellingPrice;
  set lastLowSellingPrice(num? lastLowSellingPrice) =>
      _lastLowSellingPrice = lastLowSellingPrice;
  num? get lastHighBuyingPrice => _lastHighBuyingPrice;
  set lastHighBuyingPrice(num? lastHighBuyingPrice) =>
      _lastHighBuyingPrice = lastHighBuyingPrice;
  num? get mDSellingPx => _mDSellingPx;
  set mDSellingPx(num? mDSellingPx) => _mDSellingPx = mDSellingPx;
  ExchangeRate? get exchangeRate => _exchangeRate;
  set exchangeRate(ExchangeRate? exchangeRate) => _exchangeRate = exchangeRate;

  Prices.fromJson(Map<String, dynamic> json) {
    _symbol = json['Symbol'];
    _mDEntryType = json['MDEntryType'];
    _mDBuyingPx = json['MDBuyingPx'];
    _mDSellingPx = json['MDSellingPx'];
    _lastLowSellingPrice = json['lastLowSellingPrice'];
    _lastHighBuyingPrice = json['lastHighBuyingPrice'];
    _exchangeRate =
        json['exchangeRate'] != null
            ? ExchangeRate.fromJson(json['exchangeRate'])
            : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['Symbol'] = _symbol;
    data['MDEntryType'] = _mDEntryType;
    data['MDBuyingPx'] = _mDBuyingPx;
    data['MDSellingPx'] = _mDSellingPx;
    data['lastLowSellingPrice'] = _lastLowSellingPrice;
    data['lastHighBuyingPrice'] = _lastHighBuyingPrice;
    if (_exchangeRate != null) {
      data['exchangeRate'] = _exchangeRate!.toJson();
    }
    return data;
  }
}

class ExchangeRate {
  num? _buying;
  num? _selling;

  ExchangeRate({num? buying, num? selling}) {
    if (buying != null) _buying = buying;
    if (selling != null) _selling = selling;
  }

  num? get buying => _buying;
  set buying(num? buying) => _buying = buying;

  num? get selling => _selling;
  set selling(num? selling) => _selling = selling;

  ExchangeRate.fromJson(Map<String, dynamic> json) {
    _buying = json['buying'];
    _selling = json['selling'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['buying'] = _buying;
    data['selling'] = _selling;
    return data;
  }
}
