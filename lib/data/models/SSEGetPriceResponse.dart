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
  Prices({
    String? symbol,
    String? mDEntryType,
    num? mDBuyingPx,
    num? lastHighBuyingPrice,
    num? mDSellingPx,
    num? lastLowSellingPrice,
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

  Prices.fromJson(Map<String, dynamic> json) {
    _symbol = json['Symbol'];
    _mDEntryType = json['MDEntryType'];
    _mDBuyingPx = json['MDBuyingPx'];
    _mDSellingPx = json['MDSellingPx'];
    _lastLowSellingPrice = json['lastLowSellingPrice'];
    _lastHighBuyingPrice = json['lastHighBuyingPrice'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['Symbol'] = _symbol;
    data['MDEntryType'] = _mDEntryType;
    data['MDBuyingPx'] = _mDBuyingPx;
    data['MDSellingPx'] = _mDSellingPx;
    data['lastLowSellingPrice'] = _lastLowSellingPrice;
    data['lastHighBuyingPrice'] = _lastHighBuyingPrice;
    return data;
  }
}
