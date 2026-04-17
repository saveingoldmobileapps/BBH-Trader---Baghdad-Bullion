import 'dart:convert';

/// status : "success"
/// code : 1
/// message : "OK: The request has succeeded."
/// payload : { page, limit, totalPages, hasNextPage, hasPreviousPage, allProducts: [...] }
/// Product fields may be localized objects: { "en": "...", "ar": "..." } or legacy plain strings.

GetAllProductResponse getAllProductResponseFromJson(String str) =>
    GetAllProductResponse.fromJson(json.decode(str));

String getAllProductResponseToJson(GetAllProductResponse data) =>
    json.encode(data.toJson());

/// API returns either `{en, ar}` or a single string (legacy).
class EsouqLocalizedText {
  EsouqLocalizedText({this.en, this.ar});

  factory EsouqLocalizedText.fromJson(dynamic json) {
    if (json == null) return EsouqLocalizedText();
    if (json is String) {
      final s = json.trim();
      return EsouqLocalizedText(en: s, ar: s);
    }
    if (json is Map) {
      return EsouqLocalizedText(
        en: json['en']?.toString(),
        ar: json['ar']?.toString(),
      );
    }
    return EsouqLocalizedText();
  }

  final String? en;
  final String? ar;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (en != null) map['en'] = en;
    if (ar != null) map['ar'] = ar;
    return map;
  }

  /// Pick text for [languageCode] (e.g. `en`, `ar`). Falls back to the other locale if empty.
  String textFor(String languageCode) {
    final lc = languageCode.toLowerCase();
    final primary = lc.startsWith('ar') ? ar : en;
    final fallback = lc.startsWith('ar') ? en : ar;
    final p = primary?.trim();
    if (p != null && p.isNotEmpty) return p;
    final f = fallback?.trim();
    if (f != null && f.isNotEmpty) return f;
    return '';
  }
}

class GetAllProductResponse {
  GetAllProductResponse({
    String? status,
    int? code,
    String? message,
    Payload? payload,
  }) {
    _status = status;
    _code = code;
    _message = message;
    _payload = payload;
  }

  GetAllProductResponse.fromJson(dynamic json) {
    _status = json['status'];
    _code = _jsonToInt(json['code']);
    _message = json['message'];
    _payload = json['payload'] != null
        ? Payload.fromJson(json['payload'])
        : null;
  }

  String? _status;
  int? _code;
  String? _message;
  Payload? _payload;

  GetAllProductResponse copyWith({
    String? status,
    int? code,
    String? message,
    Payload? payload,
  }) => GetAllProductResponse(
    status: status ?? _status,
    code: code ?? _code,
    message: message ?? _message,
    payload: payload ?? _payload,
  );

  String? get status => _status;

  int? get code => _code;

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

int? _jsonToInt(dynamic v) {
  if (v == null) return null;
  if (v is int) return v;
  if (v is num) return v.toInt();
  return int.tryParse(v.toString());
}

Payload payloadFromJson(String str) => Payload.fromJson(json.decode(str));

String payloadToJson(Payload data) => json.encode(data.toJson());

class Payload {
  Payload({
    int? page,
    int? limit,
    int? totalPages,
    bool? hasNextPage,
    bool? hasPreviousPage,
    List<AllProducts>? allProducts,
  }) {
    _page = page;
    _limit = limit;
    _totalPages = totalPages;
    _hasNextPage = hasNextPage;
    _hasPreviousPage = hasPreviousPage;
    _allProducts = allProducts;
  }

  Payload.fromJson(dynamic json) {
    // Legacy: payload was a bare array of products
    if (json is List) {
      _allProducts = json.map((v) => AllProducts.fromJson(v)).toList();
      _page = 1;
      _limit = _allProducts?.length ?? 0;
      _totalPages = 1;
      _hasNextPage = false;
      _hasPreviousPage = false;
      return;
    }

    _page = _jsonToInt(json['page']);
    _limit = _jsonToInt(json['limit']);
    _totalPages = _jsonToInt(json['totalPages']);
    _hasNextPage = json['hasNextPage'] as bool?;
    _hasPreviousPage = json['hasPreviousPage'] as bool?;
    if (json['allProducts'] != null) {
      _allProducts = [];
      json['allProducts'].forEach((v) {
        _allProducts?.add(AllProducts.fromJson(v));
      });
    }
  }

  int? _page;
  int? _limit;
  int? _totalPages;
  bool? _hasNextPage;
  bool? _hasPreviousPage;
  List<AllProducts>? _allProducts;

  Payload copyWith({
    int? page,
    int? limit,
    int? totalPages,
    bool? hasNextPage,
    bool? hasPreviousPage,
    List<AllProducts>? allProducts,
  }) => Payload(
    page: page ?? _page,
    limit: limit ?? _limit,
    totalPages: totalPages ?? _totalPages,
    hasNextPage: hasNextPage ?? _hasNextPage,
    hasPreviousPage: hasPreviousPage ?? _hasPreviousPage,
    allProducts: allProducts ?? _allProducts,
  );

  int? get page => _page;

  int? get limit => _limit;

  int? get totalPages => _totalPages;

  bool? get hasNextPage => _hasNextPage;

  bool? get hasPreviousPage => _hasPreviousPage;

  List<AllProducts>? get allProducts => _allProducts;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['page'] = _page;
    map['limit'] = _limit;
    map['totalPages'] = _totalPages;
    map['hasNextPage'] = _hasNextPage;
    map['hasPreviousPage'] = _hasPreviousPage;
    if (_allProducts != null) {
      map['allProducts'] = _allProducts?.map((v) => v.toJson()).toList();
    }
    return map;
  }
}

AllProducts allProductsFromJson(String str) =>
    AllProducts.fromJson(json.decode(str));

String allProductsToJson(AllProducts data) => json.encode(data.toJson());

class AllProducts {
  AllProducts({
    String? id,
    String? adminId,
    EsouqLocalizedText? productNameI18n,
    String? productPricing,
    String? productCode,
    String? weightFactor,
    String? vat,
    String? premiumDiscount,
    String? deliveryCharges,
    String? makingCharges,
    List<String>? availableBranches,
    EsouqLocalizedText? descriptionI18n,
    String? purity,
    String? dimensions,
    EsouqLocalizedText? originI18n,
    EsouqLocalizedText? brandI18n,
    EsouqLocalizedText? conditionI18n,
    List<String>? imageUrl,
    bool? isAvailable,
    bool? inStoreCollection,
    String? shippingFees,
    String? timingDate,
    String? weightCategory,
    String? weight,
    String? createdAt,
    String? updatedAt,
    num? v,
    List<String>? branchIds,
  }) {
    _id = id;
    _adminId = adminId;
    _productNameI18n = productNameI18n;
    _productPricing = productPricing;
    _productCode = productCode;
    _weightFactor = weightFactor;
    _vat = vat;
    _premiumDiscount = premiumDiscount;
    _deliveryCharges = deliveryCharges;
    _makingCharges = makingCharges;
    _availableBranches = availableBranches;
    _descriptionI18n = descriptionI18n;
    _purity = purity;
    _dimensions = dimensions;
    _originI18n = originI18n;
    _brandI18n = brandI18n;
    _conditionI18n = conditionI18n;
    _imageUrl = imageUrl;
    _isAvailable = isAvailable;
    _inStoreCollection = inStoreCollection;
    _shippingFees = shippingFees;
    _timingDate = timingDate;
    _weightCategory = weightCategory;
    _weight = weight;
    _createdAt = createdAt;
    _updatedAt = updatedAt;
    _v = v;
    _branchIds = branchIds;
  }

  AllProducts.fromJson(dynamic json) {
    _id = json['_id'];
    _adminId = json['adminId'];
    _productNameI18n = EsouqLocalizedText.fromJson(json['productName']);
    _productPricing = json['productPricing']?.toString();
    _productCode = json['productCode']?.toString();
    _weightFactor = json['weightFactor']?.toString();
    _vat = json['vat']?.toString();
    _premiumDiscount = json['premiumDiscount']?.toString();
    _deliveryCharges = json['deliveryCharges']?.toString();
    _makingCharges = json['makingCharges']?.toString();
    _availableBranches = json['availableBranches'] != null
        ? json['availableBranches'].cast<String>()
        : [];
    _descriptionI18n = EsouqLocalizedText.fromJson(json['description']);
    _purity = json['purity']?.toString();
    _dimensions = json['dimensions']?.toString();
    _originI18n = EsouqLocalizedText.fromJson(json['origin']);
    _brandI18n = EsouqLocalizedText.fromJson(json['brand']);
    _conditionI18n = EsouqLocalizedText.fromJson(json['condition']);
    _imageUrl = json['imageUrl'] != null
        ? (json['imageUrl'] is String
              ? [json['imageUrl'] as String]
              : List<String>.from(
                  (json['imageUrl'] as List).map((e) => e.toString()),
                ))
        : [];
    _isAvailable = json['isAvailable'] as bool?;
    _inStoreCollection = json['inStoreCollection'] as bool?;
    _shippingFees = json['shippingFees']?.toString();
    _timingDate = json['timingDate']?.toString();
    _weightCategory = json['weightCategory']?.toString();
    _weight = json['weight']?.toString();
    _createdAt = json['createdAt']?.toString();
    _updatedAt = json['updatedAt']?.toString();
    _v = json['__v'] as num?;
    _branchIds = json['branchIds'] != null
        ? List<String>.from(
            (json['branchIds'] as List).map((e) => e.toString()),
          )
        : [];
  }

  String? _id;
  String? _adminId;
  EsouqLocalizedText? _productNameI18n;
  String? _productPricing;
  String? _productCode;
  String? _weightFactor;
  String? _vat;
  String? _premiumDiscount;
  String? _deliveryCharges;
  String? _makingCharges;
  List<String>? _availableBranches;
  EsouqLocalizedText? _descriptionI18n;
  String? _purity;
  String? _dimensions;
  EsouqLocalizedText? _originI18n;
  EsouqLocalizedText? _brandI18n;
  EsouqLocalizedText? _conditionI18n;
  List<String>? _imageUrl;
  bool? _isAvailable;
  bool? _inStoreCollection;
  String? _shippingFees;
  String? _timingDate;
  String? _weightCategory;
  String? _weight;
  String? _createdAt;
  String? _updatedAt;
  num? _v;
  List<String>? _branchIds;

  /// Use [languageCode] from `Localizations.localeOf(context).languageCode` in UI
  /// so labels update on locale change without refetching the API.
  String localizedProductName(String languageCode) =>
      _productNameI18n?.textFor(languageCode) ?? '';

  String localizedDescription(String languageCode) =>
      _descriptionI18n?.textFor(languageCode) ?? '';

  String localizedOrigin(String languageCode) =>
      _originI18n?.textFor(languageCode) ?? '';

  String localizedBrand(String languageCode) =>
      _brandI18n?.textFor(languageCode) ?? '';

  String localizedCondition(String languageCode) =>
      _conditionI18n?.textFor(languageCode) ?? '';

  EsouqLocalizedText? get productNameI18n => _productNameI18n;

  EsouqLocalizedText? get descriptionI18n => _descriptionI18n;

  EsouqLocalizedText? get originI18n => _originI18n;

  EsouqLocalizedText? get brandI18n => _brandI18n;

  EsouqLocalizedText? get conditionI18n => _conditionI18n;

  AllProducts copyWith({
    String? id,
    String? adminId,
    EsouqLocalizedText? productNameI18n,
    String? productPricing,
    String? productCode,
    String? weightFactor,
    String? vat,
    String? premiumDiscount,
    String? deliveryCharges,
    String? makingCharges,
    List<String>? availableBranches,
    EsouqLocalizedText? descriptionI18n,
    String? purity,
    String? dimensions,
    EsouqLocalizedText? originI18n,
    EsouqLocalizedText? brandI18n,
    EsouqLocalizedText? conditionI18n,
    List<String>? imageUrl,
    bool? isAvailable,
    bool? inStoreCollection,
    String? shippingFees,
    String? timingDate,
    String? weightCategory,
    String? weight,
    String? createdAt,
    String? updatedAt,
    num? v,
    List<String>? branchIds,
  }) => AllProducts(
    id: id ?? _id,
    adminId: adminId ?? _adminId,
    productNameI18n: productNameI18n ?? _productNameI18n,
    productPricing: productPricing ?? _productPricing,
    productCode: productCode ?? _productCode,
    weightFactor: weightFactor ?? _weightFactor,
    vat: vat ?? _vat,
    premiumDiscount: premiumDiscount ?? _premiumDiscount,
    deliveryCharges: deliveryCharges ?? _deliveryCharges,
    makingCharges: makingCharges ?? _makingCharges,
    availableBranches: availableBranches ?? _availableBranches,
    descriptionI18n: descriptionI18n ?? _descriptionI18n,
    purity: purity ?? _purity,
    dimensions: dimensions ?? _dimensions,
    originI18n: originI18n ?? _originI18n,
    brandI18n: brandI18n ?? _brandI18n,
    conditionI18n: conditionI18n ?? _conditionI18n,
    imageUrl: imageUrl ?? _imageUrl,
    isAvailable: isAvailable ?? _isAvailable,
    inStoreCollection: inStoreCollection ?? _inStoreCollection,
    shippingFees: shippingFees ?? _shippingFees,
    timingDate: timingDate ?? _timingDate,
    weightCategory: weightCategory ?? _weightCategory,
    weight: weight ?? _weight,
    createdAt: createdAt ?? _createdAt,
    updatedAt: updatedAt ?? _updatedAt,
    v: v ?? _v,
    branchIds: branchIds ?? _branchIds,
  );

  String? get id => _id;

  String? get adminId => _adminId;

  String? get productPricing => _productPricing;

  String? get productCode => _productCode;

  String? get weightFactor => _weightFactor;

  String? get vat => _vat;

  String? get premiumDiscount => _premiumDiscount;

  String? get deliveryCharges => _deliveryCharges;

  String? get makingCharges => _makingCharges;

  List<String>? get availableBranches => _availableBranches;

  String? get purity => _purity;

  String? get dimensions => _dimensions;

  List<String>? get imageUrl => _imageUrl;

  bool? get isAvailable => _isAvailable;

  bool? get inStoreCollection => _inStoreCollection;

  String? get shippingFees => _shippingFees;

  String? get timingDate => _timingDate;

  String? get weightCategory => _weightCategory;

  String? get weight => _weight;

  String? get createdAt => _createdAt;

  String? get updatedAt => _updatedAt;

  num? get v => _v;

  List<String>? get branchIds => _branchIds;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['_id'] = _id;
    map['adminId'] = _adminId;
    if (_productNameI18n != null) {
      map['productName'] = _productNameI18n!.toJson();
    }
    map['productPricing'] = _productPricing;
    map['productCode'] = _productCode;
    map['weightFactor'] = _weightFactor;
    map['vat'] = _vat;
    map['premiumDiscount'] = _premiumDiscount;
    map['deliveryCharges'] = _deliveryCharges;
    map['makingCharges'] = _makingCharges;
    map['availableBranches'] = _availableBranches;
    if (_descriptionI18n != null) {
      map['description'] = _descriptionI18n!.toJson();
    }
    map['purity'] = _purity;
    map['dimensions'] = _dimensions;
    if (_originI18n != null) map['origin'] = _originI18n!.toJson();
    if (_brandI18n != null) map['brand'] = _brandI18n!.toJson();
    if (_conditionI18n != null) {
      map['condition'] = _conditionI18n!.toJson();
    }
    map['imageUrl'] = _imageUrl;
    map['isAvailable'] = _isAvailable;
    map['inStoreCollection'] = _inStoreCollection;
    map['shippingFees'] = _shippingFees;
    map['timingDate'] = _timingDate;
    map['weightCategory'] = _weightCategory;
    map['weight'] = _weight;
    map['createdAt'] = _createdAt;
    map['updatedAt'] = _updatedAt;
    map['__v'] = _v;
    map['branchIds'] = _branchIds;
    return map;
  }
}
