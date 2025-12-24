class GetLivePricingResponse {
  String? _symbol;
  String? _mDEntryType;
  double? _mDBuyingPx;
  double? _mDSellingPx;

  GetLivePricingResponse({
    String? symbol,
    String? mDEntryType,
    double? mDBuyingPx,
    double? mDSellingPx,
  }) {
    if (symbol != null) {
      _symbol = symbol;
    }
    if (mDEntryType != null) {
      _mDEntryType = mDEntryType;
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

  double? get mDBuyingPx => _mDBuyingPx;

  set mDBuyingPx(double? mDBuyingPx) => _mDBuyingPx = mDBuyingPx;

  double? get mDSellingPx => _mDSellingPx;

  set mDSellingPx(double? mDSellingPx) => _mDSellingPx = mDSellingPx;

  GetLivePricingResponse.fromJson(Map<String, dynamic> json) {
    _symbol = json['Symbol'];
    _mDEntryType = json['MDEntryType'];
    _mDBuyingPx = json['MDBuyingPx'];
    _mDSellingPx = json['MDSellingPx'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['Symbol'] = _symbol;
    data['MDEntryType'] = _mDEntryType;
    data['MDBuyingPx'] = _mDBuyingPx;
    data['MDSellingPx'] = _mDSellingPx;
    return data;
  }
}
