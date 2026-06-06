import 'dart:convert';


EsouqFilterModel esouqFilterModelFromJson(String str) =>
    EsouqFilterModel.fromJson(json.decode(str));
String esouqFilterModelToJson(EsouqFilterModel data) =>
    json.encode(data.toJson());

class EsouqFilterModel {
  EsouqFilterModel({
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

  EsouqFilterModel.fromJson(dynamic json) {
    _status = json['status'];
    _code = json['code'];
    _message = json['message'];
    _payload = json['payload'] != null
        ? Payload.fromJson(json['payload'])
        : null;
  }
  String? _status;
  num? _code;
  String? _message;
  Payload? _payload;
  EsouqFilterModel copyWith({
    String? status,
    num? code,
    String? message,
    Payload? payload,
  }) => EsouqFilterModel(
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
    List<AllProducts>? allProducts,
  }) {
    _allProducts = allProducts;
  }

  Payload.fromJson(dynamic json) {
    if (json['allProducts'] != null) {
      _allProducts = [];
      json['allProducts'].forEach((v) {
        _allProducts?.add(AllProducts.fromJson(v));
      });
    }
  }
  List<AllProducts>? _allProducts;
  Payload copyWith({
    List<AllProducts>? allProducts,
  }) => Payload(
    allProducts: allProducts ?? _allProducts,
  );
  List<AllProducts>? get allProducts => _allProducts;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
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
    String? productCode,
    String? weightFactor,
    String? vat,
    String? premiumDiscount,
    String? deliveryCharges,
    String? makingCharges,
    List<String>? availableBranches,
    Description? description,
    String? purity,
    String? dimensions,
    Origin? origin,
    Brand? brand,
    Condition? condition,
    List<String>? imageUrl,
    bool? isAvailable,
    bool? inStoreCollection,
    String? weightCategory,
    String? weight,
    String? createdAt,
    String? updatedAt,
    num? v,
    List<String>? branchIds,
    ProductName? productName,
    String? shapeType,      // ADD THIS
    String? shapeSubType,   // ADD THIS
  }) {
    _id = id;
    _adminId = adminId;
    _productCode = productCode;
    _weightFactor = weightFactor;
    _vat = vat;
    _premiumDiscount = premiumDiscount;
    _deliveryCharges = deliveryCharges;
    _makingCharges = makingCharges;
    _availableBranches = availableBranches;
    _description = description;
    _purity = purity;
    _dimensions = dimensions;
    _origin = origin;
    _brand = brand;
    _condition = condition;
    _imageUrl = imageUrl;
    _isAvailable = isAvailable;
    _inStoreCollection = inStoreCollection;
    _weightCategory = weightCategory;
    _weight = weight;
    _createdAt = createdAt;
    _updatedAt = updatedAt;
    _v = v;
    _branchIds = branchIds;
    _productName = productName;
    _shapeType = shapeType;        // ADD THIS
    _shapeSubType = shapeSubType;  // ADD THIS
  }

  AllProducts.fromJson(dynamic json) {
    _id = json['_id'];
    _adminId = json['adminId'];
    _productCode = json['productCode'];
    _weightFactor = json['weightFactor'];
    _vat = json['vat'];
    _premiumDiscount = json['premiumDiscount'];
    _deliveryCharges = json['deliveryCharges'];
    _makingCharges = json['makingCharges'];
    _availableBranches = json['availableBranches'] != null
        ? json['availableBranches'].cast<String>()
        : [];
    _description = json['description'] != null
        ? Description.fromJson(json['description'])
        : null;
    _purity = json['purity'];
    _dimensions = json['dimensions'];
    _origin = json['origin'] != null ? Origin.fromJson(json['origin']) : null;
    _brand = json['brand'] != null ? Brand.fromJson(json['brand']) : null;
    _condition = json['condition'] != null
        ? Condition.fromJson(json['condition'])
        : null;
    _imageUrl = json['imageUrl'] != null ? json['imageUrl'].cast<String>() : [];
    _isAvailable = json['isAvailable'];
    _inStoreCollection = json['inStoreCollection'];
    _weightCategory = json['weightCategory'];
    _weight = json['weight'];
    _createdAt = json['createdAt'];
    _updatedAt = json['updatedAt'];
    _v = json['__v'];
    _branchIds = json['branchIds'] != null
        ? json['branchIds'].cast<String>()
        : [];
    _productName = json['productName'] != null
        ? ProductName.fromJson(json['productName'])
        : null;
    _shapeType = json['shapeType'];           // ADD THIS
    _shapeSubType = json['shapeSubType'];     // ADD THIS
  }
  
  String? _id;
  String? _adminId;
  String? _productCode;
  String? _weightFactor;
  String? _vat;
  String? _premiumDiscount;
  String? _deliveryCharges;
  String? _makingCharges;
  List<String>? _availableBranches;
  Description? _description;
  String? _purity;
  String? _dimensions;
  Origin? _origin;
  Brand? _brand;
  Condition? _condition;
  List<String>? _imageUrl;
  bool? _isAvailable;
  bool? _inStoreCollection;
  String? _weightCategory;
  String? _weight;
  String? _createdAt;
  String? _updatedAt;
  num? _v;
  List<String>? _branchIds;
  ProductName? _productName;
  String? _shapeType;        // ADD THIS
  String? _shapeSubType;     // ADD THIS

  // Getters
  String? get id => _id;
  String? get adminId => _adminId;
  String? get productCode => _productCode;
  String? get weightFactor => _weightFactor;
  String? get vat => _vat;
  String? get premiumDiscount => _premiumDiscount;
  String? get deliveryCharges => _deliveryCharges;
  String? get makingCharges => _makingCharges;
  List<String>? get availableBranches => _availableBranches;
  Description? get description => _description;
  String? get purity => _purity;
  String? get dimensions => _dimensions;
  Origin? get origin => _origin;
  Brand? get brand => _brand;
  Condition? get condition => _condition;
  List<String>? get imageUrl => _imageUrl;
  bool? get isAvailable => _isAvailable;
  bool? get inStoreCollection => _inStoreCollection;
  String? get weightCategory => _weightCategory;
  String? get weight => _weight;
  String? get createdAt => _createdAt;
  String? get updatedAt => _updatedAt;
  num? get v => _v;
  List<String>? get branchIds => _branchIds;
  ProductName? get productName => _productName;
  String? get shapeType => _shapeType;           // ADD THIS
  String? get shapeSubType => _shapeSubType;     // ADD THIS

  AllProducts copyWith({
    String? id,
    String? adminId,
    String? productCode,
    String? weightFactor,
    String? vat,
    String? premiumDiscount,
    String? deliveryCharges,
    String? makingCharges,
    List<String>? availableBranches,
    Description? description,
    String? purity,
    String? dimensions,
    Origin? origin,
    Brand? brand,
    Condition? condition,
    List<String>? imageUrl,
    bool? isAvailable,
    bool? inStoreCollection,
    String? weightCategory,
    String? weight,
    String? createdAt,
    String? updatedAt,
    num? v,
    List<String>? branchIds,
    ProductName? productName,
    String? shapeType,           // ADD THIS
    String? shapeSubType,        // ADD THIS
  }) => AllProducts(
    id: id ?? _id,
    adminId: adminId ?? _adminId,
    productCode: productCode ?? _productCode,
    weightFactor: weightFactor ?? _weightFactor,
    vat: vat ?? _vat,
    premiumDiscount: premiumDiscount ?? _premiumDiscount,
    deliveryCharges: deliveryCharges ?? _deliveryCharges,
    makingCharges: makingCharges ?? _makingCharges,
    availableBranches: availableBranches ?? _availableBranches,
    description: description ?? _description,
    purity: purity ?? _purity,
    dimensions: dimensions ?? _dimensions,
    origin: origin ?? _origin,
    brand: brand ?? _brand,
    condition: condition ?? _condition,
    imageUrl: imageUrl ?? _imageUrl,
    isAvailable: isAvailable ?? _isAvailable,
    inStoreCollection: inStoreCollection ?? _inStoreCollection,
    weightCategory: weightCategory ?? _weightCategory,
    weight: weight ?? _weight,
    createdAt: createdAt ?? _createdAt,
    updatedAt: updatedAt ?? _updatedAt,
    v: v ?? _v,
    branchIds: branchIds ?? _branchIds,
    productName: productName ?? _productName,
    shapeType: shapeType ?? _shapeType,              // ADD THIS
    shapeSubType: shapeSubType ?? _shapeSubType,    // ADD THIS
  );

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['_id'] = _id;
    map['adminId'] = _adminId;
    map['productCode'] = _productCode;
    map['weightFactor'] = _weightFactor;
    map['vat'] = _vat;
    map['premiumDiscount'] = _premiumDiscount;
    map['deliveryCharges'] = _deliveryCharges;
    map['makingCharges'] = _makingCharges;
    map['availableBranches'] = _availableBranches;
    if (_description != null) {
      map['description'] = _description?.toJson();
    }
    map['purity'] = _purity;
    map['dimensions'] = _dimensions;
    if (_origin != null) {
      map['origin'] = _origin?.toJson();
    }
    if (_brand != null) {
      map['brand'] = _brand?.toJson();
    }
    if (_condition != null) {
      map['condition'] = _condition?.toJson();
    }
    map['imageUrl'] = _imageUrl;
    map['isAvailable'] = _isAvailable;
    map['inStoreCollection'] = _inStoreCollection;
    map['weightCategory'] = _weightCategory;
    map['weight'] = _weight;
    map['createdAt'] = _createdAt;
    map['updatedAt'] = _updatedAt;
    map['__v'] = _v;
    map['branchIds'] = _branchIds;
    if (_productName != null) {
      map['productName'] = _productName?.toJson();
    }
    map['shapeType'] = _shapeType;           // ADD THIS
    map['shapeSubType'] = _shapeSubType;     // ADD THIS
    return map;
  }
}
/// en : "2.5 Gram"
/// ar : "2.5 جرام"

ProductName productNameFromJson(String str) =>
    ProductName.fromJson(json.decode(str));
String productNameToJson(ProductName data) => json.encode(data.toJson());

class ProductName {
  ProductName({
    String? en,
    String? ar,
  }) {
    _en = en;
    _ar = ar;
  }

  ProductName.fromJson(dynamic json) {
    _en = json['en'];
    _ar = json['ar'];
  }
  String? _en;
  String? _ar;
  ProductName copyWith({
    String? en,
    String? ar,
  }) => ProductName(
    en: en ?? _en,
    ar: ar ?? _ar,
  );
  String? get en => _en;
  String? get ar => _ar;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['en'] = _en;
    map['ar'] = _ar;
    return map;
  }
}

/// en : "New"
/// ar : "جديد"

Condition conditionFromJson(String str) => Condition.fromJson(json.decode(str));
String conditionToJson(Condition data) => json.encode(data.toJson());

class Condition {
  Condition({
    String? en,
    String? ar,
  }) {
    _en = en;
    _ar = ar;
  }

  Condition.fromJson(dynamic json) {
    _en = json['en'];
    _ar = json['ar'];
  }
  String? _en;
  String? _ar;
  Condition copyWith({
    String? en,
    String? ar,
  }) => Condition(
    en: en ?? _en,
    ar: ar ?? _ar,
  );
  String? get en => _en;
  String? get ar => _ar;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['en'] = _en;
    map['ar'] = _ar;
    return map;
  }
}

/// en : "Baghdad Bullion House"
/// ar : "بيت السبائك بغداد"

Brand brandFromJson(String str) => Brand.fromJson(json.decode(str));
String brandToJson(Brand data) => json.encode(data.toJson());

class Brand {
  Brand({
    String? en,
    String? ar,
  }) {
    _en = en;
    _ar = ar;
  }

  Brand.fromJson(dynamic json) {
    _en = json['en'];
    _ar = json['ar'];
  }
  String? _en;
  String? _ar;
  Brand copyWith({
    String? en,
    String? ar,
  }) => Brand(
    en: en ?? _en,
    ar: ar ?? _ar,
  );
  String? get en => _en;
  String? get ar => _ar;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['en'] = _en;
    map['ar'] = _ar;
    return map;
  }
}

/// en : "Iraq"
/// ar : "العراق"

Origin originFromJson(String str) => Origin.fromJson(json.decode(str));
String originToJson(Origin data) => json.encode(data.toJson());

class Origin {
  Origin({
    String? en,
    String? ar,
  }) {
    _en = en;
    _ar = ar;
  }

  Origin.fromJson(dynamic json) {
    _en = json['en'];
    _ar = json['ar'];
  }
  String? _en;
  String? _ar;
  Origin copyWith({
    String? en,
    String? ar,
  }) => Origin(
    en: en ?? _en,
    ar: ar ?? _ar,
  );
  String? get en => _en;
  String? get ar => _ar;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['en'] = _en;
    map['ar'] = _ar;
    return map;
  }
}

/// en : "2.5 Gram"
/// ar : "2.5 جرام"

Description descriptionFromJson(String str) =>
    Description.fromJson(json.decode(str));
String descriptionToJson(Description data) => json.encode(data.toJson());

class Description {
  Description({
    String? en,
    String? ar,
  }) {
    _en = en;
    _ar = ar;
  }

  Description.fromJson(dynamic json) {
    _en = json['en'];
    _ar = json['ar'];
  }
  String? _en;
  String? _ar;
  Description copyWith({
    String? en,
    String? ar,
  }) => Description(
    en: en ?? _en,
    ar: ar ?? _ar,
  );
  String? get en => _en;
  String? get ar => _ar;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['en'] = _en;
    map['ar'] = _ar;
    return map;
  }
}
