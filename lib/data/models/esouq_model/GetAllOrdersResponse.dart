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
    if (status != null) {
      _status = status;
    }
    if (code != null) {
      _code = code;
    }
    if (message != null) {
      _message = message;
    }
    if (payload != null) {
      _payload = payload;
    }
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
    _payload = json['payload'] != null
        ? Payload.fromJson(json['payload'])
        : null;
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
    if (page != null) {
      _page = page;
    }
    if (limit != null) {
      _limit = limit;
    }
    if (totalPages != null) {
      _totalPages = totalPages;
    }
    if (hasNextPage != null) {
      _hasNextPage = hasNextPage;
    }
    if (hasPreviousPage != null) {
      _hasPreviousPage = hasPreviousPage;
    }
    if (kAllOrders != null) {
      _kAllOrders = kAllOrders;
    }
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

  set hasPreviousPage(bool? hasPreviousPage) =>
      _hasPreviousPage = hasPreviousPage;

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

  // Setters
  set sId(String? sId) => _sId = sId;
  set userId(UserId? userId) => _userId = userId;
  set productId(ProductId? productId) => _productId = productId;
  set quantity(num? quantity) => _quantity = quantity;
  set goldPrice(num? goldPrice) => _goldPrice = goldPrice;
  set makingCharges(num? makingCharges) => _makingCharges = makingCharges;
  set vat(num? vat) => _vat = vat;
  set premiumDiscount(num? premiumDiscount) =>
      _premiumDiscount = premiumDiscount;
  set deliveryCharges(num? deliveryCharges) =>
      _deliveryCharges = deliveryCharges;
  set paymentMethod(String? paymentMethod) => _paymentMethod = paymentMethod;
  set address(String? address) => _address = address;
  set isNominate(bool? isNominate) => _isNominate = isNominate;
  set nomineeName(String? nomineeName) => _nomineeName = nomineeName;
  set branchId(BranchId? branchId) => _branchId = branchId;
  set deliveryMethod(String? deliveryMethod) =>
      _deliveryMethod = deliveryMethod;
  set totalCharges(num? totalCharges) => _totalCharges = totalCharges;
  set grandTotal(num? grandTotal) => _grandTotal = grandTotal;
  set status(String? status) => _status = status;
  set balanceInMoneyWallet(num? balanceInMoneyWallet) =>
      _balanceInMoneyWallet = balanceInMoneyWallet;
  set balanceInMetalWallet(num? balanceInMetalWallet) =>
      _balanceInMetalWallet = balanceInMetalWallet;
  set transactionId(String? transactionId) => _transactionId = transactionId;
  set orderId(num? orderId) => _orderId = orderId;
  set createdAt(String? createdAt) => _createdAt = createdAt;
  set updatedAt(String? updatedAt) => _updatedAt = updatedAt;

  KAllOrders.fromJson(Map<String, dynamic> json) {
    _sId = json['_id'];
    _userId = json['userId'] != null ? UserId.fromJson(json['userId']) : null;
    _productId = json['productId'] != null
        ? ProductId.fromJson(json['productId'])
        : null;
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
    _branchId = json['branchId'] != null
        ? BranchId.fromJson(json['branchId'])
        : null;
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
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = _sId;
    if (_userId != null) {
      data['userId'] = _userId!.toJson();
    }
    if (_productId != null) {
      data['productId'] = _productId!.toJson();
    }
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
    if (_branchId != null) {
      data['branchId'] = _branchId!.toJson();
    }
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
    if (sId != null) {
      _sId = sId;
    }
    if (accountId != null) {
      _accountId = accountId;
    }
    if (userType != null) {
      _userType = userType;
    }
    if (firstName != null) {
      _firstName = firstName;
    }
    if (surname != null) {
      _surname = surname;
    }
    if (email != null) {
      _email = email;
    }
    if (phoneNumber != null) {
      _phoneNumber = phoneNumber;
    }
    if (imageUrl != null) {
      _imageUrl = imageUrl;
    }
    if (createdAt != null) {
      _createdAt = createdAt;
    }
    if (updatedAt != null) {
      _updatedAt = updatedAt;
    }
  }

  String? get sId => _sId;

  set sId(String? sId) => _sId = sId;

  String? get accountId => _accountId;

  set accountId(String? accountId) => _accountId = accountId;

  String? get userType => _userType;

  set userType(String? userType) => _userType = userType;

  String? get firstName => _firstName;

  set firstName(String? firstName) => _firstName = firstName;

  String? get surname => _surname;

  set surname(String? surname) => _surname = surname;

  String? get email => _email;

  set email(String? email) => _email = email;

  String? get phoneNumber => _phoneNumber;

  set phoneNumber(String? phoneNumber) => _phoneNumber = phoneNumber;

  String? get imageUrl => _imageUrl;

  set imageUrl(String? imageUrl) => _imageUrl = imageUrl;

  String? get createdAt => _createdAt;

  set createdAt(String? createdAt) => _createdAt = createdAt;

  String? get updatedAt => _updatedAt;

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
  String? _productName;
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
  List<String>? _imageUrl;
  bool? _isAvailable;
  bool? _inStoreCollection;
  String? _weightCategory;
  String? _weight;
  String? _createdAt;
  String? _updatedAt;
  num? _iV;

  ProductId({
    String? sId,
    String? adminId,
    String? productName,
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
    List<String>? imageUrl,
    bool? isAvailable,
    bool? inStoreCollection,
    String? weightCategory,
    String? weight,
    String? createdAt,
    String? updatedAt,
    num? iV,
  }) {
    if (sId != null) {
      _sId = sId;
    }
    if (adminId != null) {
      _adminId = adminId;
    }
    if (productName != null) {
      _productName = productName;
    }
    if (productCode != null) {
      _productCode = productCode;
    }
    if (weightFactor != null) {
      _weightFactor = weightFactor;
    }
    if (vat != null) {
      _vat = vat;
    }
    if (premiumDiscount != null) {
      _premiumDiscount = premiumDiscount;
    }
    if (deliveryCharges != null) {
      _deliveryCharges = deliveryCharges;
    }
    if (makingCharges != null) {
      _makingCharges = makingCharges;
    }
    if (availableBranches != null) {
      _availableBranches = availableBranches;
    }
    if (description != null) {
      _description = description;
    }
    if (purity != null) {
      _purity = purity;
    }
    if (dimensions != null) {
      _dimensions = dimensions;
    }
    if (origin != null) {
      _origin = origin;
    }
    if (brand != null) {
      _brand = brand;
    }
    if (condition != null) {
      _condition = condition;
    }
    if (imageUrl != null) {
      
      _imageUrl = imageUrl;
    }
    if (isAvailable != null) {
      _isAvailable = isAvailable;
    }
    if (inStoreCollection != null) {
      _inStoreCollection = inStoreCollection;
    }
    if (weightCategory != null) {
      _weightCategory = weightCategory;
    }
    if (weight != null) {
      _weight = weight;
    }
    if (createdAt != null) {
      _createdAt = createdAt;
    }
    if (updatedAt != null) {
      _updatedAt = updatedAt;
    }
    if (iV != null) {
      _iV = iV;
    }
  }

  String? get sId => _sId;

  set sId(String? sId) => _sId = sId;

  String? get adminId => _adminId;

  set adminId(String? adminId) => _adminId = adminId;

  String? get productName => _productName;

  set productName(String? productName) => _productName = productName;

  String? get productCode => _productCode;

  set productCode(String? productCode) => _productCode = productCode;

  String? get weightFactor => _weightFactor;

  set weightFactor(String? weightFactor) => _weightFactor = weightFactor;

  String? get vat => _vat;

  set vat(String? vat) => _vat = vat;

  String? get premiumDiscount => _premiumDiscount;

  set premiumDiscount(String? premiumDiscount) =>
      _premiumDiscount = premiumDiscount;

  String? get deliveryCharges => _deliveryCharges;

  set deliveryCharges(String? deliveryCharges) =>
      _deliveryCharges = deliveryCharges;

  String? get makingCharges => _makingCharges;

  set makingCharges(String? makingCharges) => _makingCharges = makingCharges;

  List<String>? get availableBranches => _availableBranches;

  set availableBranches(List<String>? availableBranches) =>
      _availableBranches = availableBranches;

  String? get description => _description;

  set description(String? description) => _description = description;

  String? get purity => _purity;

  set purity(String? purity) => _purity = purity;

  String? get dimensions => _dimensions;

  set dimensions(String? dimensions) => _dimensions = dimensions;

  String? get origin => _origin;

  set origin(String? origin) => _origin = origin;

  String? get brand => _brand;

  set brand(String? brand) => _brand = brand;

  String? get condition => _condition;

  set condition(String? condition) => _condition = condition;

  bool? get isAvailable => _isAvailable;

  set isAvailable(bool? isAvailable) => _isAvailable = isAvailable;

  bool? get inStoreCollection => _inStoreCollection;

  set inStoreCollection(bool? inStoreCollection) =>
      _inStoreCollection = inStoreCollection;

  String? get weightCategory => _weightCategory;

  set weightCategory(String? weightCategory) =>
      _weightCategory = weightCategory;

  String? get weight => _weight;

  set weight(String? weight) => _weight = weight;

  String? get createdAt => _createdAt;

  set createdAt(String? createdAt) => _createdAt = createdAt;

  String? get updatedAt => _updatedAt;

  set updatedAt(String? updatedAt) => _updatedAt = updatedAt;

  num? get iV => _iV;

  set iV(num? iV) => _iV = iV;

  List<String>? get imageUrl => _imageUrl;
  set imageUrl(List<String>? imageUrl) => _imageUrl = imageUrl;

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
    _availableBranches = json['availableBranches'].cast<String>();
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
    return data;
  }
}

class BranchId {
  String? _sId;
  String? _adminId;
  String? _branchName;
  String? _branchLocation;
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
    String? branchLocation,
    String? branchPhoneNumber,
    String? branchEmail,
    String? branchManager,
    List<num>? branchCoordinates,
    bool? isAvailable,
    String? createdAt,
    String? updatedAt,
    num? iV,
  }) {
    if (sId != null) {
      _sId = sId;
    }
    if (adminId != null) {
      _adminId = adminId;
    }
    if (branchName != null) {
      _branchName = branchName;
    }
    if (branchLocation != null) {
      _branchLocation = branchLocation;
    }
    if (branchPhoneNumber != null) {
      _branchPhoneNumber = branchPhoneNumber;
    }
    if (branchEmail != null) {
      _branchEmail = branchEmail;
    }
    if (branchManager != null) {
      _branchManager = branchManager;
    }
    if (branchCoordinates != null) {
      _branchCoordinates = branchCoordinates;
    }
    if (isAvailable != null) {
      _isAvailable = isAvailable;
    }
    if (createdAt != null) {
      _createdAt = createdAt;
    }
    if (updatedAt != null) {
      _updatedAt = updatedAt;
    }
    if (iV != null) {
      _iV = iV;
    }
  }

  String? get sId => _sId;

  set sId(String? sId) => _sId = sId;

  String? get adminId => _adminId;

  set adminId(String? adminId) => _adminId = adminId;

  String? get branchName => _branchName;

  set branchName(String? branchName) => _branchName = branchName;

  String? get branchLocation => _branchLocation;

  set branchLocation(String? branchLocation) =>
      _branchLocation = branchLocation;

  String? get branchPhoneNumber => _branchPhoneNumber;

  set branchPhoneNumber(String? branchPhoneNumber) =>
      _branchPhoneNumber = branchPhoneNumber;

  String? get branchEmail => _branchEmail;

  set branchEmail(String? branchEmail) => _branchEmail = branchEmail;

  String? get branchManager => _branchManager;

  set branchManager(String? branchManager) => _branchManager = branchManager;

  List<num>? get branchCoordinates => _branchCoordinates;

  set branchCoordinates(List<num>? branchCoordinates) =>
      _branchCoordinates = branchCoordinates;

  bool? get isAvailable => _isAvailable;

  set isAvailable(bool? isAvailable) => _isAvailable = isAvailable;

  String? get createdAt => _createdAt;

  set createdAt(String? createdAt) => _createdAt = createdAt;

  String? get updatedAt => _updatedAt;

  set updatedAt(String? updatedAt) => _updatedAt = updatedAt;

  num? get iV => _iV;

  set iV(num? iV) => _iV = iV;

  BranchId.fromJson(Map<String, dynamic> json) {
    _sId = json['_id'];
    _adminId = json['adminId'];
    _branchName = json['branchName'];
    _branchLocation = json['branchLocation'];
    _branchPhoneNumber = json['branchPhoneNumber'];
    _branchEmail = json['branchEmail'];
    _branchManager = json['branchManager'];
    _branchCoordinates = json['branchCoordinates'].cast<num>();
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
    data['branchLocation'] = _branchLocation;
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
