import 'package:baghdad_bullion_house/core/common_service.dart';

class GetAllOrdersResponse {
  String? _status;
  num? _code;
  String? _message;
  Payload? _payload;

  GetAllOrdersResponse({
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

  String? get status => _status;
  set status(String? status) => _status = status;

  num? get code => _code;
  set code(num? code) => _code = code;

  String? get message => _message;
  set message(String? message) => _message = message;

  Payload? get payload => _payload;
  set payload(Payload? payload) => _payload = payload;

  GetAllOrdersResponse.fromJson(Map<String, dynamic> json) {
    _status = json['status'];
    _code = json['code'];
    _message = json['message'];
    _payload = json['payload'] != null ? Payload.fromJson(json['payload']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = _status;
    data['code'] = _code;
    data['message'] = _message;
    if (_payload != null) {
      data['payload'] = _payload!.toJson();
    }
    return data;
  }
}

class Payload {
  num? _page;
  num? _limit;
  num? _totalPages;
  bool? _hasNextPage;
  bool? _hasPreviousPage;
  List<KAllOrders>? _kAllOrders;

  Payload({
    num? page,
    num? limit,
    num? totalPages,
    bool? hasNextPage,
    bool? hasPreviousPage,
    List<KAllOrders>? kAllOrders,
  }) {
    _page = page;
    _limit = limit;
    _totalPages = totalPages;
    _hasNextPage = hasNextPage;
    _hasPreviousPage = hasPreviousPage;
    _kAllOrders = kAllOrders;
  }

  num? get page => _page;
  set page(num? page) => _page = page;

  num? get limit => _limit;
  set limit(num? limit) => _limit = limit;

  num? get totalPages => _totalPages;
  set totalPages(num? totalPages) => _totalPages = totalPages;

  bool? get hasNextPage => _hasNextPage;
  set hasNextPage(bool? hasNextPage) => _hasNextPage = hasNextPage;

  bool? get hasPreviousPage => _hasPreviousPage;
  set hasPreviousPage(bool? hasPreviousPage) => _hasPreviousPage = hasPreviousPage;

  List<KAllOrders>? get kAllOrders => _kAllOrders;
  set kAllOrders(List<KAllOrders>? kAllOrders) => _kAllOrders = kAllOrders;

  Payload.fromJson(Map<String, dynamic> json) {
    _page = json['page'];
    _limit = json['limit'];
    _totalPages = json['totalPages'];
    _hasNextPage = json['hasNextPage'];
    _hasPreviousPage = json['hasPreviousPage'];
    if (json['kAllOrders'] != null) {
      _kAllOrders = <KAllOrders>[];
      json['kAllOrders'].forEach((v) {
        _kAllOrders!.add(KAllOrders.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['page'] = _page;
    data['limit'] = _limit;
    data['totalPages'] = _totalPages;
    data['hasNextPage'] = _hasNextPage;
    data['hasPreviousPage'] = _hasPreviousPage;
    if (_kAllOrders != null) {
      data['kAllOrders'] = _kAllOrders!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class KAllOrders {
  String? _sId;
  UserId? _userId;
  ProductId? _productId;
  num? _quantity;
  num? _goldPrice;
  num? _makingCharges;
  num? _vat;
  num? _premiumDiscount;
  num? _deliveryCharges;
  String? _paymentMethod;
  String? _address;
  bool? _isNominate;
  String? _nomineeName;
  String? _nomineeDocument;
  BranchId? _branchId;
  String? _deliveryMethod;
  num? _totalCharges;
  num? _grandTotal;
  String? _status;
  num? _balanceInMoneyWallet;
  num? _balanceInMetalWallet;
  String? _transactionId;
  num? _orderId;
  String? _createdAt;
  String? _updatedAt;
  num? _iV;
  String? _goldQuantityInGrams;
  List<DealsData>? _dealsData;

  KAllOrders({
    String? sId,
    UserId? userId,
    ProductId? productId,
    num? quantity,
    num? goldPrice,
    num? makingCharges,
    num? vat,
    num? premiumDiscount,
    num? deliveryCharges,
    String? paymentMethod,
    String? address,
    bool? isNominate,
    String? nomineeName,
    String? nomineeDocument,
    BranchId? branchId,
    String? deliveryMethod,
    num? totalCharges,
    num? grandTotal,
    String? status,
    num? balanceInMoneyWallet,
    num? balanceInMetalWallet,
    String? transactionId,
    num? orderId,
    String? createdAt,
    String? updatedAt,
    num? iV,
    String? goldQuantityInGrams,
    List<DealsData>? dealsData,
  }) {
    _sId = sId;
    _userId = userId;
    _productId = productId;
    _quantity = quantity;
    _goldPrice = goldPrice;
    _makingCharges = makingCharges;
    _vat = vat;
    _premiumDiscount = premiumDiscount;
    _deliveryCharges = deliveryCharges;
    _paymentMethod = paymentMethod;
    _address = address;
    _isNominate = isNominate;
    _nomineeName = nomineeName;
    _nomineeDocument = nomineeDocument;
    _branchId = branchId;
    _deliveryMethod = deliveryMethod;
    _totalCharges = totalCharges;
    _grandTotal = grandTotal;
    _status = status;
    _balanceInMoneyWallet = balanceInMoneyWallet;
    _balanceInMetalWallet = balanceInMetalWallet;
    _transactionId = transactionId;
    _orderId = orderId;
    _createdAt = createdAt;
    _updatedAt = updatedAt;
    _iV = iV;
    _goldQuantityInGrams = goldQuantityInGrams;
    _dealsData = dealsData;
  }

  // Getters
  String? get sId => _sId;
  UserId? get userId => _userId;
  ProductId? get productId => _productId;
  num? get quantity => _quantity;
  num? get goldPrice => _goldPrice;
  num? get makingCharges => _makingCharges;
  num? get vat => _vat;
  num? get premiumDiscount => _premiumDiscount;
  num? get deliveryCharges => _deliveryCharges;
  String? get paymentMethod => _paymentMethod;
  String? get address => _address;
  bool? get isNominate => _isNominate;
  String? get nomineeName => _nomineeName;
  String? get nomineeDocument => _nomineeDocument;
  BranchId? get branchId => _branchId;
  String? get deliveryMethod => _deliveryMethod;
  num? get totalCharges => _totalCharges;
  num? get grandTotal => _grandTotal;
  String? get status => _status;
  num? get balanceInMoneyWallet => _balanceInMoneyWallet;
  num? get balanceInMetalWallet => _balanceInMetalWallet;
  String? get transactionId => _transactionId;
  num? get orderId => _orderId;
  String? get createdAt => _createdAt;
  String? get updatedAt => _updatedAt;
  num? get iV => _iV;
  String? get goldQuantityInGrams => _goldQuantityInGrams;
  List<DealsData>? get dealsData => _dealsData;

  // Setters
  set sId(String? sId) => _sId = sId;
  set userId(UserId? userId) => _userId = userId;
  set productId(ProductId? productId) => _productId = productId;
  set quantity(num? quantity) => _quantity = quantity;
  set goldPrice(num? goldPrice) => _goldPrice = goldPrice;
  set makingCharges(num? makingCharges) => _makingCharges = makingCharges;
  set vat(num? vat) => _vat = vat;
  set premiumDiscount(num? premiumDiscount) => _premiumDiscount = premiumDiscount;
  set deliveryCharges(num? deliveryCharges) => _deliveryCharges = deliveryCharges;
  set paymentMethod(String? paymentMethod) => _paymentMethod = paymentMethod;
  set address(String? address) => _address = address;
  set isNominate(bool? isNominate) => _isNominate = isNominate;
  set nomineeName(String? nomineeName) => _nomineeName = nomineeName;
  set nomineeDocument(String? nomineeDocument) => _nomineeDocument = nomineeDocument;
  set branchId(BranchId? branchId) => _branchId = branchId;
  set deliveryMethod(String? deliveryMethod) => _deliveryMethod = deliveryMethod;
  set totalCharges(num? totalCharges) => _totalCharges = totalCharges;
  set grandTotal(num? grandTotal) => _grandTotal = grandTotal;
  set status(String? status) => _status = status;
  set balanceInMoneyWallet(num? balanceInMoneyWallet) => _balanceInMoneyWallet = balanceInMoneyWallet;
  set balanceInMetalWallet(num? balanceInMetalWallet) => _balanceInMetalWallet = balanceInMetalWallet;
  set transactionId(String? transactionId) => _transactionId = transactionId;
  set orderId(num? orderId) => _orderId = orderId;
  set createdAt(String? createdAt) => _createdAt = createdAt;
  set updatedAt(String? updatedAt) => _updatedAt = updatedAt;
  set iV(num? iV) => _iV = iV;
  set goldQuantityInGrams(String? goldQuantityInGrams) => _goldQuantityInGrams = goldQuantityInGrams;
  set dealsData(List<DealsData>? dealsData) => _dealsData = dealsData;

  KAllOrders.fromJson(Map<String, dynamic> json) {
    _sId = json['_id'];
    _userId = json['userId'] != null ? UserId.fromJson(json['userId']) : null;
    _productId = json['productId'] != null ? ProductId.fromJson(json['productId']) : null;
    _quantity = json['quantity'];
    _goldPrice = json['goldPrice'];
    _makingCharges = json['makingCharges'];
    _vat = json['vat'];
    _premiumDiscount = json['premiumDiscount'];
    _deliveryCharges = json['deliveryCharges'];
    _paymentMethod = json['paymentMethod'];
    _address = json['address'];
    _isNominate = json['isNominate'];
    _nomineeName = json['nomineeName'];
    _nomineeDocument = json['nomineeDocument'];
    _branchId = json['branchId'] != null ? BranchId.fromJson(json['branchId']) : null;
    _deliveryMethod = json['deliveryMethod'];
    _totalCharges = json['totalCharges'];
    _grandTotal = json['grandTotal'];
    _status = json['status'];
    _balanceInMoneyWallet = json['balanceInMoneyWallet'];
    _balanceInMetalWallet = json['balanceInMetalWallet'];
    _transactionId = json['transactionId'];
    _orderId = json['orderId'];
    _createdAt = json['createdAt'];
    _updatedAt = json['updatedAt'];
    _iV = json['__v'];
    _goldQuantityInGrams = json['goldQuantityInGrams']?.toString();
    if (json['dealsData'] != null) {
      _dealsData = <DealsData>[];
      json['dealsData'].forEach((v) {
        _dealsData!.add(DealsData.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = _sId;
    if (_userId != null) data['userId'] = _userId!.toJson();
    if (_productId != null) data['productId'] = _productId!.toJson();
    data['quantity'] = _quantity;
    data['goldPrice'] = _goldPrice;
    data['makingCharges'] = _makingCharges;
    data['vat'] = _vat;
    data['premiumDiscount'] = _premiumDiscount;
    data['deliveryCharges'] = _deliveryCharges;
    data['paymentMethod'] = _paymentMethod;
    data['address'] = _address;
    data['isNominate'] = _isNominate;
    data['nomineeName'] = _nomineeName;
    data['nomineeDocument'] = _nomineeDocument;
    if (_branchId != null) data['branchId'] = _branchId!.toJson();
    data['deliveryMethod'] = _deliveryMethod;
    data['totalCharges'] = _totalCharges;
    data['grandTotal'] = _grandTotal;
    data['status'] = _status;
    data['balanceInMoneyWallet'] = _balanceInMoneyWallet;
    data['balanceInMetalWallet'] = _balanceInMetalWallet;
    data['transactionId'] = _transactionId;
    data['orderId'] = _orderId;
    data['createdAt'] = _createdAt;
    data['updatedAt'] = _updatedAt;
    data['__v'] = _iV;
    data['goldQuantityInGrams'] = _goldQuantityInGrams;
    if (_dealsData != null) {
      data['dealsData'] = _dealsData!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class DealsData {
  String? _tradeId;
  int? _dealId;
  num? _amount;
  String? _id;

  DealsData({String? tradeId, int? dealId, num? amount, String? id}) {
    _tradeId = tradeId;
    _dealId = dealId;
    _amount = amount;
    _id = id;
  }

  String? get tradeId => _tradeId;
  int? get dealId => _dealId;
  num? get amount => _amount;
  String? get id => _id;

  set tradeId(String? value) => _tradeId = value;
  set dealId(int? value) => _dealId = value;
  set amount(num? value) => _amount = value;
  set id(String? value) => _id = value;

  DealsData.fromJson(Map<String, dynamic> json) {
    _tradeId = json['tradeId'];
    _dealId = json['dealId'];
    _amount = json['amount'];
    _id = json['_id'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['tradeId'] = _tradeId;
    data['dealId'] = _dealId;
    data['amount'] = _amount;
    data['_id'] = _id;
    return data;
  }
}

class UserId {
  String? _sId;
  String? _accountId;
  String? _userType;
  String? _firstName;
  String? _surname;
  String? _email;
  String? _phoneNumber;
  String? _imageUrl;
  String? _createdAt;
  String? _updatedAt;

  UserId({
    String? sId,
    String? accountId,
    String? userType,
    String? firstName,
    String? surname,
    String? email,
    String? phoneNumber,
    String? imageUrl,
    String? createdAt,
    String? updatedAt,
  }) {
    _sId = sId;
    _accountId = accountId;
    _userType = userType;
    _firstName = firstName;
    _surname = surname;
    _email = email;
    _phoneNumber = phoneNumber;
    _imageUrl = imageUrl;
    _createdAt = createdAt;
    _updatedAt = updatedAt;
  }

  String? get sId => _sId;
  String? get accountId => _accountId;
  String? get userType => _userType;
  String? get firstName => _firstName;
  String? get surname => _surname;
  String? get email => _email;
  String? get phoneNumber => _phoneNumber;
  String? get imageUrl => _imageUrl;
  String? get createdAt => _createdAt;
  String? get updatedAt => _updatedAt;

  set sId(String? sId) => _sId = sId;
  set accountId(String? accountId) => _accountId = accountId;
  set userType(String? userType) => _userType = userType;
  set firstName(String? firstName) => _firstName = firstName;
  set surname(String? surname) => _surname = surname;
  set email(String? email) => _email = email;
  set phoneNumber(String? phoneNumber) => _phoneNumber = phoneNumber;
  set imageUrl(String? imageUrl) => _imageUrl = imageUrl;
  set createdAt(String? createdAt) => _createdAt = createdAt;
  set updatedAt(String? updatedAt) => _updatedAt = updatedAt;

  UserId.fromJson(Map<String, dynamic> json) {
    _sId = json['_id'];
    _accountId = json['accountId'];
    _userType = json['userType'];
    _firstName = json['firstName'];
    _surname = json['surname'];
    _email = json['email'];
    _phoneNumber = json['phoneNumber'];
    _imageUrl = json['imageUrl'];
    _createdAt = json['createdAt'];
    _updatedAt = json['updatedAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = _sId;
    data['accountId'] = _accountId;
    data['userType'] = _userType;
    data['firstName'] = _firstName;
    data['surname'] = _surname;
    data['email'] = _email;
    data['phoneNumber'] = _phoneNumber;
    data['imageUrl'] = _imageUrl;
    data['createdAt'] = _createdAt;
    data['updatedAt'] = _updatedAt;
    return data;
  }
}

class ProductId {
  String? _sId;
  String? _adminId;
  dynamic _productName;
  String? _productCode;
  String? _weightFactor;
  String? _vat;
  String? _premiumDiscount;
  String? _deliveryCharges;
  String? _makingCharges;
  List<String>? _availableBranches;
  dynamic _description;
  String? _purity;
  String? _dimensions;
  dynamic _origin;
  dynamic _brand;
  dynamic _condition;
  List<String>? _imageUrl;
  bool? _isAvailable;
  bool? _inStoreCollection;
  String? _weightCategory;
  String? _weight;
  String? _createdAt;
  String? _updatedAt;
  num? _iV;
  List<String>? _branchIds;

  ProductId({
    String? sId,
    String? adminId,
    dynamic productName,
    String? productCode,
    String? weightFactor,
    String? vat,
    String? premiumDiscount,
    String? deliveryCharges,
    String? makingCharges,
    List<String>? availableBranches,
    dynamic description,
    String? purity,
    String? dimensions,
    dynamic origin,
    dynamic brand,
    dynamic condition,
    List<String>? imageUrl,
    bool? isAvailable,
    bool? inStoreCollection,
    String? weightCategory,
    String? weight,
    String? createdAt,
    String? updatedAt,
    num? iV,
    List<String>? branchIds,
  }) {
    _sId = sId;
    _adminId = adminId;
    _productName = productName;
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
    _iV = iV;
    _branchIds = branchIds;
  }

  // Getters with localization support
  String? get sId => _sId;
  String? get adminId => _adminId;
  
  String? get productName => _getLocalizedText(_productName);
  dynamic get rawProductName => _productName;
  
  String? get productCode => _productCode;
  String? get weightFactor => _weightFactor;
  String? get vat => _vat;
  String? get premiumDiscount => _premiumDiscount;
  String? get deliveryCharges => _deliveryCharges;
  String? get makingCharges => _makingCharges;
  List<String>? get availableBranches => _availableBranches;
  
  String? get description => _getLocalizedText(_description);
  dynamic get rawDescription => _description;
  
  String? get purity => _purity;
  String? get dimensions => _dimensions;
  
  String? get origin => _getLocalizedText(_origin);
  dynamic get rawOrigin => _origin;
  
  String? get brand => _getLocalizedText(_brand);
  dynamic get rawBrand => _brand;
  
  String? get condition => _getLocalizedText(_condition);
  dynamic get rawCondition => _condition;
  
  List<String>? get imageUrl => _imageUrl;
  bool? get isAvailable => _isAvailable;
  bool? get inStoreCollection => _inStoreCollection;
  String? get weightCategory => _weightCategory;
  String? get weight => _weight;
  String? get createdAt => _createdAt;
  String? get updatedAt => _updatedAt;
  num? get iV => _iV;
  List<String>? get branchIds => _branchIds;

  // Setters
  set sId(String? sId) => _sId = sId;
  set adminId(String? adminId) => _adminId = adminId;
  set productName(dynamic productName) => _productName = productName;
  set productCode(String? productCode) => _productCode = productCode;
  set weightFactor(String? weightFactor) => _weightFactor = weightFactor;
  set vat(String? vat) => _vat = vat;
  set premiumDiscount(String? premiumDiscount) => _premiumDiscount = premiumDiscount;
  set deliveryCharges(String? deliveryCharges) => _deliveryCharges = deliveryCharges;
  set makingCharges(String? makingCharges) => _makingCharges = makingCharges;
  set availableBranches(List<String>? availableBranches) => _availableBranches = availableBranches;
  set description(dynamic description) => _description = description;
  set purity(String? purity) => _purity = purity;
  set dimensions(String? dimensions) => _dimensions = dimensions;
  set origin(dynamic origin) => _origin = origin;
  set brand(dynamic brand) => _brand = brand;
  set condition(dynamic condition) => _condition = condition;
  set imageUrl(List<String>? imageUrl) => _imageUrl = imageUrl;
  set isAvailable(bool? isAvailable) => _isAvailable = isAvailable;
  set inStoreCollection(bool? inStoreCollection) => _inStoreCollection = inStoreCollection;
  set weightCategory(String? weightCategory) => _weightCategory = weightCategory;
  set weight(String? weight) => _weight = weight;
  set createdAt(String? createdAt) => _createdAt = createdAt;
  set updatedAt(String? updatedAt) => _updatedAt = updatedAt;
  set iV(num? iV) => _iV = iV;
  set branchIds(List<String>? branchIds) => _branchIds = branchIds;

  /// Helper method to extract localized text based on current app language
  String? _getLocalizedText(dynamic value) {
    if (value == null) return null;
    if (value is String) return value;
    if (value is Map<String, dynamic>) {
      final currentLanguage = CommonService.lang ?? 'en';
      return value[currentLanguage] ?? value['en'] ?? value.values.firstOrNull?.toString();
    }
    return value.toString();
  }

  ProductId.fromJson(Map<String, dynamic> json) {
    _sId = json['_id'];
    _adminId = json['adminId'];
    _productName = json['productName'];
    _productCode = json['productCode'];
    _weightFactor = json['weightFactor'];
    _vat = json['vat'];
    _premiumDiscount = json['premiumDiscount'];
    _deliveryCharges = json['deliveryCharges'];
    _makingCharges = json['makingCharges'];
    _availableBranches = json['availableBranches']?.cast<String>();
    _description = json['description'];
    _purity = json['purity'];
    _dimensions = json['dimensions'];
    _origin = json['origin'];
    _brand = json['brand'];
    _condition = json['condition'];
    _imageUrl = json['imageUrl']?.cast<String>();
    _isAvailable = json['isAvailable'];
    _inStoreCollection = json['inStoreCollection'];
    _weightCategory = json['weightCategory'];
    _weight = json['weight'];
    _createdAt = json['createdAt'];
    _updatedAt = json['updatedAt'];
    _iV = json['__v'];
    _branchIds = json['branchIds']?.cast<String>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = _sId;
    data['adminId'] = _adminId;
    data['productName'] = _productName;
    data['productCode'] = _productCode;
    data['weightFactor'] = _weightFactor;
    data['vat'] = _vat;
    data['premiumDiscount'] = _premiumDiscount;
    data['deliveryCharges'] = _deliveryCharges;
    data['makingCharges'] = _makingCharges;
    data['availableBranches'] = _availableBranches;
    data['description'] = _description;
    data['purity'] = _purity;
    data['dimensions'] = _dimensions;
    data['origin'] = _origin;
    data['brand'] = _brand;
    data['condition'] = _condition;
    data['imageUrl'] = _imageUrl;
    data['isAvailable'] = _isAvailable;
    data['inStoreCollection'] = _inStoreCollection;
    data['weightCategory'] = _weightCategory;
    data['weight'] = _weight;
    data['createdAt'] = _createdAt;
    data['updatedAt'] = _updatedAt;
    data['__v'] = _iV;
    data['branchIds'] = _branchIds;
    return data;
  }
}

class BranchId {
  String? _sId;
  String? _adminId;
  String? _branchName;
  String? _branchNameInArabic;
  String? _branchLocation;
  String? _branchLocationInArabic;
  String? _branchPhoneNumber;
  String? _branchEmail;
  String? _branchManager;
  List<num>? _branchCoordinates;
  bool? _isAvailable;
  String? _createdAt;
  String? _updatedAt;
  num? _iV;

  BranchId({
    String? sId,
    String? adminId,
    String? branchName,
    String? branchNameInArabic,
    String? branchLocation,
    String? branchLocationInArabic,
    String? branchPhoneNumber,
    String? branchEmail,
    String? branchManager,
    List<num>? branchCoordinates,
    bool? isAvailable,
    String? createdAt,
    String? updatedAt,
    num? iV,
  }) {
    _sId = sId;
    _adminId = adminId;
    _branchName = branchName;
    _branchNameInArabic = branchNameInArabic;
    _branchLocation = branchLocation;
    _branchLocationInArabic = branchLocationInArabic;
    _branchPhoneNumber = branchPhoneNumber;
    _branchEmail = branchEmail;
    _branchManager = branchManager;
    _branchCoordinates = branchCoordinates;
    _isAvailable = isAvailable;
    _createdAt = createdAt;
    _updatedAt = updatedAt;
    _iV = iV;
  }

  String? get sId => _sId;
  String? get adminId => _adminId;
  
  String? get branchName {
    final currentLanguage = CommonService.lang ?? 'en';
    if (currentLanguage == 'ar' && _branchNameInArabic != null && _branchNameInArabic!.isNotEmpty) {
      return _branchNameInArabic;
    }
    return _branchName;
  }
  
  String? get branchNameEn => _branchName;
  String? get branchNameAr => _branchNameInArabic;
  
  String? get branchLocation {
    final currentLanguage = CommonService.lang ?? 'en';
    if (currentLanguage == 'ar' && _branchLocationInArabic != null && _branchLocationInArabic!.isNotEmpty) {
      return _branchLocationInArabic;
    }
    return _branchLocation;
  }
  
  String? get branchLocationEn => _branchLocation;
  String? get branchLocationAr => _branchLocationInArabic;
  
  String? get branchPhoneNumber => _branchPhoneNumber;
  String? get branchEmail => _branchEmail;
  String? get branchManager => _branchManager;
  List<num>? get branchCoordinates => _branchCoordinates;
  bool? get isAvailable => _isAvailable;
  String? get createdAt => _createdAt;
  String? get updatedAt => _updatedAt;
  num? get iV => _iV;

  set sId(String? sId) => _sId = sId;
  set adminId(String? adminId) => _adminId = adminId;
  set branchName(String? branchName) => _branchName = branchName;
  set branchNameInArabic(String? branchNameInArabic) => _branchNameInArabic = branchNameInArabic;
  set branchLocation(String? branchLocation) => _branchLocation = branchLocation;
  set branchLocationInArabic(String? branchLocationInArabic) => _branchLocationInArabic = branchLocationInArabic;
  set branchPhoneNumber(String? branchPhoneNumber) => _branchPhoneNumber = branchPhoneNumber;
  set branchEmail(String? branchEmail) => _branchEmail = branchEmail;
  set branchManager(String? branchManager) => _branchManager = branchManager;
  set branchCoordinates(List<num>? branchCoordinates) => _branchCoordinates = branchCoordinates;
  set isAvailable(bool? isAvailable) => _isAvailable = isAvailable;
  set createdAt(String? createdAt) => _createdAt = createdAt;
  set updatedAt(String? updatedAt) => _updatedAt = updatedAt;
  set iV(num? iV) => _iV = iV;

  BranchId.fromJson(Map<String, dynamic> json) {
    _sId = json['_id'];
    _adminId = json['adminId'];
    _branchName = json['branchName'];
    _branchNameInArabic = json['branchNameInArabic'];
    _branchLocation = json['branchLocation'];
    _branchLocationInArabic = json['branchLocationInArabic'];
    _branchPhoneNumber = json['branchPhoneNumber'];
    _branchEmail = json['branchEmail'];
    _branchManager = json['branchManager'];
    _branchCoordinates = json['branchCoordinates']?.cast<num>();
    _isAvailable = json['isAvailable'];
    _createdAt = json['createdAt'];
    _updatedAt = json['updatedAt'];
    _iV = json['__v'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = _sId;
    data['adminId'] = _adminId;
    data['branchName'] = _branchName;
    data['branchNameInArabic'] = _branchNameInArabic;
    data['branchLocation'] = _branchLocation;
    data['branchLocationInArabic'] = _branchLocationInArabic;
    data['branchPhoneNumber'] = _branchPhoneNumber;
    data['branchEmail'] = _branchEmail;
    data['branchManager'] = _branchManager;
    data['branchCoordinates'] = _branchCoordinates;
    data['isAvailable'] = _isAvailable;
    data['createdAt'] = _createdAt;
    data['updatedAt'] = _updatedAt;
    data['__v'] = _iV;
    return data;
  }
}

// Extension for firstOrNull
extension FirstOrNullExt on Iterable {
  dynamic get firstOrNull => isEmpty ? null : first;
}