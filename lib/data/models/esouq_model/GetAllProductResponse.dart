import 'dart:convert';

/// status : "success"
/// code : 1
/// message : "OK: The request has succeeded."
/// payload : {"page":1,"limit":10,"totalPages":1,"hasNextPage":false,"hasPreviousPage":false,"allProducts":[{"_id":"67c6b706f80da73228ecb624","adminId":"67c2c70559e139298c5984da","productName":"50 gram","productPricing":"6999.99","productCode":"412451","weightFactor":"18.0 - 20.0","vat":"10%","premiumDiscount":"12.1","deliveryCharges":"23.50","makingCharges":"0","availableBranches":["Save In Gold (Jummeriah)","Save In Gold (Abu Dhabi)"],"description":"populating data..........","purity":"A1","dimensions":"20.2","origin":"6.25","brand":"Save in Gold","condition":"A1","imageUrl":"https://saveingoldbucket.s3.me-central-1.amazonaws.com/default/image-8145789f-77fb-4fdf-b131-1019cbc75558.jpg","isAvailable":true,"inStoreCollection":true,"shippingFees":"10","timingDate":"9:00 am to 7:00 pm","weightCategory":"Gram","weight":"10","createdAt":"2025-03-04T08:17:10.508Z","updatedAt":"2025-03-04T08:17:10.508Z","__v":0},{"_id":"67c2ce7d59e139298c598605","adminId":"67c2c70559e139298c5984da","productName":"150 gram","productPricing":"320","productCode":"8121","weightFactor":"18.0 - 20.0","vat":"10%","premiumDiscount":"15","deliveryCharges":"10.12","makingCharges":"20.00","availableBranches":["Save In Gold (Abu Dhabi)"],"description":"populating","purity":"10","dimensions":"20.2","origin":"625","brand":"A1","condition":"A1","imageUrl":"https://saveingoldbucket.s3.me-central-1.amazonaws.com/default/image-fe6eebcd-c6bd-4e61-9bc8-6f6094f5a21b.jpg","isAvailable":true,"inStoreCollection":true,"shippingFees":"20.75","timingDate":"9:00 am to 7:00 pm","weightCategory":"Ounce","weight":"10","createdAt":"2025-03-01T09:08:13.552Z","updatedAt":"2025-03-01T09:08:13.552Z","__v":0},{"_id":"67c2cdc959e139298c5985f1","adminId":"67c2c70559e139298c5984da","productName":"440 gram","productPricing":"500","productCode":"7812","weightFactor":"18.0 - 20.0","vat":"20%","premiumDiscount":"15","deliveryCharges":"10","makingCharges":"20.00","availableBranches":["Save In Gold (Al Yarmook, Sharjah)"],"description":"populating data","purity":"10","dimensions":"20.2","origin":"625","brand":"A1","condition":"A1","imageUrl":"https://saveingoldbucket.s3.me-central-1.amazonaws.com/default/image-d4c15092-5a87-4619-900b-2ad896a721af.jpg","isAvailable":true,"inStoreCollection":true,"shippingFees":"20.75","timingDate":"9:00 am to 7:00 pm","weightCategory":"Gram","weight":"20","createdAt":"2025-03-01T09:05:13.743Z","updatedAt":"2025-03-01T09:05:13.743Z","__v":0},{"_id":"67c2cd6359e139298c5985dd","adminId":"67c2c70559e139298c5984da","productName":"700 gram","productPricing":"1000","productCode":"23651","weightFactor":"18.0 - 20.0","vat":"5%","premiumDiscount":"15","deliveryCharges":"10.12","makingCharges":"20.00","availableBranches":["Save In Gold (Al Yarmook, Sharjah)","Save In Gold (Abu Dhabi)"],"description":"populating some data","purity":"10","dimensions":"20.2","origin":"625","brand":"A1","condition":"A1","imageUrl":"https://saveingoldbucket.s3.me-central-1.amazonaws.com/default/image-62bc6bbd-f28f-40cb-bec6-480743bc3a10.jpg","isAvailable":true,"inStoreCollection":true,"shippingFees":"20.75","timingDate":"9:00 am to 7:00 pm","weightCategory":"Gram","weight":"20","createdAt":"2025-03-01T09:03:31.126Z","updatedAt":"2025-03-01T09:03:31.126Z","__v":0}]}

GetAllProductResponse getAllProductResponseFromJson(String str) =>
    GetAllProductResponse.fromJson(json.decode(str));

String getAllProductResponseToJson(GetAllProductResponse data) =>
    json.encode(data.toJson());

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
    _code = json['code'];
    _message = json['message'];
    _payload =
        json['payload'] != null ? Payload.fromJson(json['payload']) : null;
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
  }) =>
      GetAllProductResponse(
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

/// page : 1
/// limit : 10
/// totalPages : 1
/// hasNextPage : false
/// hasPreviousPage : false
/// allProducts : [{"_id":"67c6b706f80da73228ecb624","adminId":"67c2c70559e139298c5984da","productName":"50 gram","productPricing":"6999.99","productCode":"412451","weightFactor":"18.0 - 20.0","vat":"10%","premiumDiscount":"12.1","deliveryCharges":"23.50","makingCharges":"0","availableBranches":["Save In Gold (Jummeriah)","Save In Gold (Abu Dhabi)"],"description":"populating data..........","purity":"A1","dimensions":"20.2","origin":"6.25","brand":"Save in Gold","condition":"A1","imageUrl":"https://saveingoldbucket.s3.me-central-1.amazonaws.com/default/image-8145789f-77fb-4fdf-b131-1019cbc75558.jpg","isAvailable":true,"inStoreCollection":true,"shippingFees":"10","timingDate":"9:00 am to 7:00 pm","weightCategory":"Gram","weight":"10","createdAt":"2025-03-04T08:17:10.508Z","updatedAt":"2025-03-04T08:17:10.508Z","__v":0},{"_id":"67c2ce7d59e139298c598605","adminId":"67c2c70559e139298c5984da","productName":"150 gram","productPricing":"320","productCode":"8121","weightFactor":"18.0 - 20.0","vat":"10%","premiumDiscount":"15","deliveryCharges":"10.12","makingCharges":"20.00","availableBranches":["Save In Gold (Abu Dhabi)"],"description":"populating","purity":"10","dimensions":"20.2","origin":"625","brand":"A1","condition":"A1","imageUrl":"https://saveingoldbucket.s3.me-central-1.amazonaws.com/default/image-fe6eebcd-c6bd-4e61-9bc8-6f6094f5a21b.jpg","isAvailable":true,"inStoreCollection":true,"shippingFees":"20.75","timingDate":"9:00 am to 7:00 pm","weightCategory":"Ounce","weight":"10","createdAt":"2025-03-01T09:08:13.552Z","updatedAt":"2025-03-01T09:08:13.552Z","__v":0},{"_id":"67c2cdc959e139298c5985f1","adminId":"67c2c70559e139298c5984da","productName":"440 gram","productPricing":"500","productCode":"7812","weightFactor":"18.0 - 20.0","vat":"20%","premiumDiscount":"15","deliveryCharges":"10","makingCharges":"20.00","availableBranches":["Save In Gold (Al Yarmook, Sharjah)"],"description":"populating data","purity":"10","dimensions":"20.2","origin":"625","brand":"A1","condition":"A1","imageUrl":"https://saveingoldbucket.s3.me-central-1.amazonaws.com/default/image-d4c15092-5a87-4619-900b-2ad896a721af.jpg","isAvailable":true,"inStoreCollection":true,"shippingFees":"20.75","timingDate":"9:00 am to 7:00 pm","weightCategory":"Gram","weight":"20","createdAt":"2025-03-01T09:05:13.743Z","updatedAt":"2025-03-01T09:05:13.743Z","__v":0},{"_id":"67c2cd6359e139298c5985dd","adminId":"67c2c70559e139298c5984da","productName":"700 gram","productPricing":"1000","productCode":"23651","weightFactor":"18.0 - 20.0","vat":"5%","premiumDiscount":"15","deliveryCharges":"10.12","makingCharges":"20.00","availableBranches":["Save In Gold (Al Yarmook, Sharjah)","Save In Gold (Abu Dhabi)"],"description":"populating some data","purity":"10","dimensions":"20.2","origin":"625","brand":"A1","condition":"A1","imageUrl":"https://saveingoldbucket.s3.me-central-1.amazonaws.com/default/image-62bc6bbd-f28f-40cb-bec6-480743bc3a10.jpg","isAvailable":true,"inStoreCollection":true,"shippingFees":"20.75","timingDate":"9:00 am to 7:00 pm","weightCategory":"Gram","weight":"20","createdAt":"2025-03-01T09:03:31.126Z","updatedAt":"2025-03-01T09:03:31.126Z","__v":0}]

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
    _page = json['page'];
    _limit = json['limit'];
    _totalPages = json['totalPages'];
    _hasNextPage = json['hasNextPage'];
    _hasPreviousPage = json['hasPreviousPage'];
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
  }) =>
      Payload(
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

/// _id : "67c6b706f80da73228ecb624"
/// adminId : "67c2c70559e139298c5984da"
/// productName : "50 gram"
/// productPricing : "6999.99"
/// productCode : "412451"
/// weightFactor : "18.0 - 20.0"
/// vat : "10%"
/// premiumDiscount : "12.1"
/// deliveryCharges : "23.50"
/// makingCharges : "0"
/// availableBranches : ["Save In Gold (Jummeriah)","Save In Gold (Abu Dhabi)"]
/// description : "populating data.........."
/// purity : "A1"
/// dimensions : "20.2"
/// origin : "6.25"
/// brand : "Save in Gold"
/// condition : "A1"
/// imageUrl : "https://saveingoldbucket.s3.me-central-1.amazonaws.com/default/image-8145789f-77fb-4fdf-b131-1019cbc75558.jpg"
/// isAvailable : true
/// inStoreCollection : true
/// shippingFees : "10"
/// timingDate : "9:00 am to 7:00 pm"
/// weightCategory : "Gram"
/// weight : "10"
/// createdAt : "2025-03-04T08:17:10.508Z"
/// updatedAt : "2025-03-04T08:17:10.508Z"
/// __v : 0

AllProducts allProductsFromJson(String str) =>
    AllProducts.fromJson(json.decode(str));

String allProductsToJson(AllProducts data) => json.encode(data.toJson());

class AllProducts {
  AllProducts({
    String? id,
    String? adminId,
    String? productName,
    String? productPricing,
    String? productCode,
    String? weightFactor,
    String? vat,
    String? premiumDiscount,
    String? deliveryCharges,
    String? makingCharges,
    List<String>? availableBranches,
    String? description,
    String? purity,
    String? dimensions,
    String? origin,
    String? brand,
    String? condition,
    List<String>? imageUrl, // Changed from String? to List<String>?
    bool? isAvailable,
    bool? inStoreCollection,
    String? shippingFees,
    String? timingDate,
    String? weightCategory,
    String? weight,
    String? createdAt,
    String? updatedAt,
    num? v,
  }) {
    _id = id;
    _adminId = adminId;
    _productName = productName;
    _productPricing = productPricing;
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
    _shippingFees = shippingFees;
    _timingDate = timingDate;
    _weightCategory = weightCategory;
    _weight = weight;
    _createdAt = createdAt;
    _updatedAt = updatedAt;
    _v = v;
  }

  AllProducts.fromJson(dynamic json) {
    _id = json['_id'];
    _adminId = json['adminId'];
    _productName = json['productName'];
    _productPricing = json['productPricing'];
    _productCode = json['productCode'];
    _weightFactor = json['weightFactor'];
    _vat = json['vat'];
    _premiumDiscount = json['premiumDiscount'];
    _deliveryCharges = json['deliveryCharges'];
    _makingCharges = json['makingCharges'];
    _availableBranches = json['availableBranches'] != null
        ? json['availableBranches'].cast<String>()
        : [];
    _description = json['description'];
    _purity = json['purity'];
    _dimensions = json['dimensions'];
    _origin = json['origin'];
    _brand = json['brand'];
    _condition = json['condition'];
    _imageUrl = json['imageUrl'] != null 
        ? (json['imageUrl'] is String 
            ? [json['imageUrl']] 
            : json['imageUrl'].cast<String>())
        : [];
    _isAvailable = json['isAvailable'];
    _inStoreCollection = json['inStoreCollection'];
    _shippingFees = json['shippingFees'];
    _timingDate = json['timingDate'];
    _weightCategory = json['weightCategory'];
    _weight = json['weight'];
    _createdAt = json['createdAt'];
    _updatedAt = json['updatedAt'];
    _v = json['__v'];
  }

  String? _id;
  String? _adminId;
  String? _productName;
  String? _productPricing;
  String? _productCode;
  String? _weightFactor;
  String? _vat;
  String? _premiumDiscount;
  String? _deliveryCharges;
  String? _makingCharges;
  List<String>? _availableBranches;
  String? _description;
  String? _purity;
  String? _dimensions;
  String? _origin;
  String? _brand;
  String? _condition;
  List<String>? _imageUrl; // Changed from String? to List<String>?
  bool? _isAvailable;
  bool? _inStoreCollection;
  String? _shippingFees;
  String? _timingDate;
  String? _weightCategory;
  String? _weight;
  String? _createdAt;
  String? _updatedAt;
  num? _v;

  AllProducts copyWith({
    String? id,
    String? adminId,
    String? productName,
    String? productPricing,
    String? productCode,
    String? weightFactor,
    String? vat,
    String? premiumDiscount,
    String? deliveryCharges,
    String? makingCharges,
    List<String>? availableBranches,
    String? description,
    String? purity,
    String? dimensions,
    String? origin,
    String? brand,
    String? condition,
    List<String>? imageUrl, // Changed from String? to List<String>?
    bool? isAvailable,
    bool? inStoreCollection,
    String? shippingFees,
    String? timingDate,
    String? weightCategory,
    String? weight,
    String? createdAt,
    String? updatedAt,
    num? v,
  }) =>
      AllProducts(
        id: id ?? _id,
        adminId: adminId ?? _adminId,
        productName: productName ?? _productName,
        productPricing: productPricing ?? _productPricing,
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
        shippingFees: shippingFees ?? _shippingFees,
        timingDate: timingDate ?? _timingDate,
        weightCategory: weightCategory ?? _weightCategory,
        weight: weight ?? _weight,
        createdAt: createdAt ?? _createdAt,
        updatedAt: updatedAt ?? _updatedAt,
        v: v ?? _v,
      );

  String? get id => _id;

  String? get adminId => _adminId;

  String? get productName => _productName;

  String? get productPricing => _productPricing;

  String? get productCode => _productCode;

  String? get weightFactor => _weightFactor;

  String? get vat => _vat;

  String? get premiumDiscount => _premiumDiscount;

  String? get deliveryCharges => _deliveryCharges;

  String? get makingCharges => _makingCharges;

  List<String>? get availableBranches => _availableBranches;

  String? get description => _description;

  String? get purity => _purity;

  String? get dimensions => _dimensions;

  String? get origin => _origin;

  String? get brand => _brand;

  String? get condition => _condition;

  List<String>? get imageUrl => _imageUrl; // Changed from String? to List<String>?
  bool? get isAvailable => _isAvailable;

  bool? get inStoreCollection => _inStoreCollection;

  String? get shippingFees => _shippingFees;

  String? get timingDate => _timingDate;

  String? get weightCategory => _weightCategory;

  String? get weight => _weight;

  String? get createdAt => _createdAt;

  String? get updatedAt => _updatedAt;

  num? get v => _v;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['_id'] = _id;
    map['adminId'] = _adminId;
    map['productName'] = _productName;
    map['productPricing'] = _productPricing;
    map['productCode'] = _productCode;
    map['weightFactor'] = _weightFactor;
    map['vat'] = _vat;
    map['premiumDiscount'] = _premiumDiscount;
    map['deliveryCharges'] = _deliveryCharges;
    map['makingCharges'] = _makingCharges;
    map['availableBranches'] = _availableBranches;
    map['description'] = _description;
    map['purity'] = _purity;
    map['dimensions'] = _dimensions;
    map['origin'] = _origin;
    map['brand'] = _brand;
    map['condition'] = _condition;
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
    return map;
  }
}
