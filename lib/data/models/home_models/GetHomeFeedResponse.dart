import 'dart:convert';
/// status : "success"
/// code : 1
/// message : "OK: The request has succeeded."
/// payload : {"isPhoneVerified":true,"isEmailVerified":true,"isUserKYCVerified":true,"isBasicUserVerified":true,"walletExists":{"_id":"6819af0bd80794b60a37e01f","userId":"6819af0bd80794b60a37e01e","moneyBalance":399700,"metalBalance":392,"createdAt":"2025-05-06T06:41:15.382Z","updatedAt":"2025-05-06T07:40:24.278Z","__v":0},"offers":[{"_id":"6819f27cadf8bf34773dd46f","title":"Save In Gold","offerImgUrl":"https://sigprodbucket.s3.me-central-1.amazonaws.com/default/image-c27b9cc1-72ed-431f-a44b-7d617c1a9a0b.png","isOfferEnabled":true,"createdAt":"2025-05-06T11:29:00.113Z","updatedAt":"2025-05-07T08:03:43.853Z","__v":0}],"newsUpdates":[{"_id":"681b63487d086ad402945d0a","title":"Gold prices fall to lowest levels in over 3 weeks as market sell-off hits bullion","description":"Gold prices fell on Monday to their lowest levels in more than three weeks, continuing their retreat amid a wider market sell-off, as investors dumped bullion to cover losses in other trades on fears of a global recession due to an escalating trade war.\nIn UAE, 24k opened at Dh365.75 per gram while 22K was selling at Dh338.50 per gram. Among the other variants, 21K and 18K opened at Dh324.75 and Dh278.25 per gram, respectively.","url":"https://www.khaleejtimes.com/business/markets/uae-gold-prices-drop-lowest-over-3-weeks","createdAt":"2025-05-07T13:42:32.040Z","updatedAt":"2025-05-07T13:42:32.040Z","__v":0},{"_id":"681b62ef7d086ad402945a0b","title":"UAE Gold Market Thrives Amid Rising Prices","description":"Gold prices in the UAE rise as geopolitical tensions and economic factors influence the market.\nThe United Arab Emirates (UAE) has solidified its position as a formidable player in the global gold market, with gold imports reaching a staggering $20 billion in 2019. This figure highlights the nation’s reliance on gold, which constitutes over a third of its total imports. The UAE’s primary markets for gold include India, Switzerland, and the USA, showcasing its strategic connections in the international trade landscape.","url":"https://evrimagaci.org/tpg/uae-gold-market-thrives-amid-rising-prices-343896","createdAt":"2025-05-07T13:41:03.098Z","updatedAt":"2025-05-07T13:41:03.098Z","__v":0},{"_id":"681b62bd7d086ad402945868","title":"Gold prices spike in Dubai: Why UAE shoppers should wait until Thursday","description":"Dubai: The Dubai Gold Rate has risen by Dh3.5 a gram to start the week, with a gram of 22K selling at Dh365 (and Dh394 for 24K), in what will be a huge disappointment for shoppers who were expecting prices to soften.\n\nToday’s rate is still lower than last Monday’s (April 28) Dh371, but all through last week the trend was for the local gold rate to drop. On May 1, it was at Dh359.\n\n“Shoppers would have been expecting gold to slip to around Dh350-Dh355 levels, so to see prices around Dh365 will be a huge blow to sales this week if this trend continues,” said a jeweller. “Even tourist demand will come in lower. The only hope is that some of the planning wedding purchases materialize.”","url":"https://gulfnews.com/business/retail/dubai-gold-rate-shoots-up-by-dh35-disappointing-shoppers-1.500115900","createdAt":"2025-05-07T13:40:13.902Z","updatedAt":"2025-05-07T13:40:13.902Z","__v":0},{"_id":"681b62987d086ad402945702","title":"Dubai Gold Rate back to touching distance of highest level - shoppers stay away","description":"Dubai: The Dubai Gold Rate is just Dh5 away from its highest point in the last 30 days – and also the highest ever as prices swelled ahead of the crucial meeting of the US Federal Reserve Wednesday. Currently, the Dubai rate is at Dh376.5 a gram for 22K – and Dh406.5 for 24K.\n\nThe highest single-day Dubai gold rate was the Dh381.5 on April 21.\n\nTo put matters more starkly, the difference between today’s Dubai Gold Rate and on April 7 is a whopping Dh45.50.  That’s the sort of price gap that will push shoppers to the sidelines. Most shoppers and jewellery retailers in the UAE certainly didn’t see this coming, after gold recorded a gradually softening in rates last week.","url":"https://gulfnews.com/business/retail/dubai-gold-rate-back-to-touching-distance-of-highest-level-shoppers-stay-away-1.500117145","createdAt":"2025-05-07T13:39:36.547Z","updatedAt":"2025-05-07T13:39:36.547Z","__v":0}]}

GetHomeFeedResponse getHomeFeedResponseFromJson(String str) =>
    GetHomeFeedResponse.fromJson(json.decode(str));
String getHomeFeedResponseToJson(GetHomeFeedResponse data) =>
    json.encode(data.toJson());

class GetHomeFeedResponse {
  GetHomeFeedResponse({
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

  GetHomeFeedResponse.fromJson(dynamic json) {
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
  GetHomeFeedResponse copyWith({
    String? status,
    num? code,
    String? message,
    Payload? payload,
  }) => GetHomeFeedResponse(
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

        // "temporaryCreditStatus": false,
        // "temporaryCreditAmount": 0,
        // "isFrozen": false
/// isPhoneVerified : true
/// isEmailVerified : true
/// isUserKYCVerified : true
/// isBasicUserVerified : true
/// walletExists : {"_id":"6819af0bd80794b60a37e01f","userId":"6819af0bd80794b60a37e01e","moneyBalance":399700,"metalBalance":392,"createdAt":"2025-05-06T06:41:15.382Z","updatedAt":"2025-05-06T07:40:24.278Z","__v":0}
/// offers : [{"_id":"6819f27cadf8bf34773dd46f","title":"Save In Gold","offerImgUrl":"https://sigprodbucket.s3.me-central-1.amazonaws.com/default/image-c27b9cc1-72ed-431f-a44b-7d617c1a9a0b.png","isOfferEnabled":true,"createdAt":"2025-05-06T11:29:00.113Z","updatedAt":"2025-05-07T08:03:43.853Z","__v":0}]
/// newsUpdates : [{"_id":"681b63487d086ad402945d0a","title":"Gold prices fall to lowest levels in over 3 weeks as market sell-off hits bullion","description":"Gold prices fell on Monday to their lowest levels in more than three weeks, continuing their retreat amid a wider market sell-off, as investors dumped bullion to cover losses in other trades on fears of a global recession due to an escalating trade war.\nIn UAE, 24k opened at Dh365.75 per gram while 22K was selling at Dh338.50 per gram. Among the other variants, 21K and 18K opened at Dh324.75 and Dh278.25 per gram, respectively.","url":"https://www.khaleejtimes.com/business/markets/uae-gold-prices-drop-lowest-over-3-weeks","createdAt":"2025-05-07T13:42:32.040Z","updatedAt":"2025-05-07T13:42:32.040Z","__v":0},{"_id":"681b62ef7d086ad402945a0b","title":"UAE Gold Market Thrives Amid Rising Prices","description":"Gold prices in the UAE rise as geopolitical tensions and economic factors influence the market.\nThe United Arab Emirates (UAE) has solidified its position as a formidable player in the global gold market, with gold imports reaching a staggering $20 billion in 2019. This figure highlights the nation’s reliance on gold, which constitutes over a third of its total imports. The UAE’s primary markets for gold include India, Switzerland, and the USA, showcasing its strategic connections in the international trade landscape.","url":"https://evrimagaci.org/tpg/uae-gold-market-thrives-amid-rising-prices-343896","createdAt":"2025-05-07T13:41:03.098Z","updatedAt":"2025-05-07T13:41:03.098Z","__v":0},{"_id":"681b62bd7d086ad402945868","title":"Gold prices spike in Dubai: Why UAE shoppers should wait until Thursday","description":"Dubai: The Dubai Gold Rate has risen by Dh3.5 a gram to start the week, with a gram of 22K selling at Dh365 (and Dh394 for 24K), in what will be a huge disappointment for shoppers who were expecting prices to soften.\n\nToday’s rate is still lower than last Monday’s (April 28) Dh371, but all through last week the trend was for the local gold rate to drop. On May 1, it was at Dh359.\n\n“Shoppers would have been expecting gold to slip to around Dh350-Dh355 levels, so to see prices around Dh365 will be a huge blow to sales this week if this trend continues,” said a jeweller. “Even tourist demand will come in lower. The only hope is that some of the planning wedding purchases materialize.”","url":"https://gulfnews.com/business/retail/dubai-gold-rate-shoots-up-by-dh35-disappointing-shoppers-1.500115900","createdAt":"2025-05-07T13:40:13.902Z","updatedAt":"2025-05-07T13:40:13.902Z","__v":0},{"_id":"681b62987d086ad402945702","title":"Dubai Gold Rate back to touching distance of highest level - shoppers stay away","description":"Dubai: The Dubai Gold Rate is just Dh5 away from its highest point in the last 30 days – and also the highest ever as prices swelled ahead of the crucial meeting of the US Federal Reserve Wednesday. Currently, the Dubai rate is at Dh376.5 a gram for 22K – and Dh406.5 for 24K.\n\nThe highest single-day Dubai gold rate was the Dh381.5 on April 21.\n\nTo put matters more starkly, the difference between today’s Dubai Gold Rate and on April 7 is a whopping Dh45.50.  That’s the sort of price gap that will push shoppers to the sidelines. Most shoppers and jewellery retailers in the UAE certainly didn’t see this coming, after gold recorded a gradually softening in rates last week.","url":"https://gulfnews.com/business/retail/dubai-gold-rate-back-to-touching-distance-of-highest-level-shoppers-stay-away-1.500117145","createdAt":"2025-05-07T13:39:36.547Z","updatedAt":"2025-05-07T13:39:36.547Z","__v":0}]

Payload payloadFromJson(String str) => Payload.fromJson(json.decode(str));
String payloadToJson(Payload data) => json.encode(data.toJson());

class Payload {
  Payload({
    bool? isPhoneVerified,

    bool? isEmailVerified,
    bool? isUserKYCVerified,
    bool? isBasicUserVerified,
    String? userType,
    bool? sellAtLoss,
    bool? googlePay,
    bool? applePay,
    bool? temporaryCreditStatus,
    bool? isFrozen,
    //double? temporaryCreditAmount,
    WalletExists? walletExists,
    List<Offers>? offers,
    List<NewsUpdates>? newsUpdates,
  }) {
    _isPhoneVerified = isPhoneVerified;
    _isEmailVerified = isEmailVerified;
    _userType = userType;
    _isUserKYCVerified = isUserKYCVerified;
    _isBasicUserVerified = isBasicUserVerified;
    _sellAtLoss = sellAtLoss;
    _googlePay= googlePay;
    _applePay = applePay;
    _temporaryCreditStatus = temporaryCreditStatus;
    _isFrozen = isFrozen;
   // _temporaryCreditAmount = temporaryCreditAmount;
    _walletExists = walletExists;
    _offers = offers;
    _newsUpdates = newsUpdates;
  }

  Payload.fromJson(dynamic json) {
    _isPhoneVerified = json['isPhoneVerified'];
    _userType = json['userType'];
    _isEmailVerified = json['isEmailVerified'];
    _isUserKYCVerified = json['isUserKYCVerified'];
    _isBasicUserVerified = json['isBasicUserVerified'];
    _sellAtLoss = json['sellAtLoss'];
    _googlePay = json['googlePay'];
    _applePay = json['applePay'];
    _temporaryCreditStatus = json['temporaryCreditStatus'];
    _isFrozen = json['isFrozen'];
    //_temporaryCreditAmount = json['temporaryCreditAmount'];
    _walletExists = json['walletExists'] != null
        ? WalletExists.fromJson(json['walletExists'])
        : null;
    if (json['offers'] != null) {
      _offers = [];
      json['offers'].forEach((v) {
        _offers?.add(Offers.fromJson(v));
      });
    }
    if (json['newsUpdates'] != null) {
      _newsUpdates = [];
      json['newsUpdates'].forEach((v) {
        _newsUpdates?.add(NewsUpdates.fromJson(v));
      });
    }
  }
  bool? _isPhoneVerified;
  bool? _isEmailVerified;
  bool? _isUserKYCVerified;
  bool? _isBasicUserVerified;
  bool? _sellAtLoss;
  bool? _googlePay;
  bool? _applePay;
  bool? _temporaryCreditStatus;
  bool?  _isFrozen;
  //double?  _temporaryCreditAmount;
  String? _userType;
  WalletExists? _walletExists;
  List<Offers>? _offers;
  List<NewsUpdates>? _newsUpdates;
  Payload copyWith({
    bool? isPhoneVerified,
    bool? isEmailVerified,
    bool? isUserKYCVerified,
    bool? isBasicUserVerified,
    bool? sellAtLoss,
    String? userType,
    WalletExists? walletExists,
    List<Offers>? offers,
    List<NewsUpdates>? newsUpdates,
  }) => Payload(
    isPhoneVerified: isPhoneVerified ?? _isPhoneVerified,
    isEmailVerified: isEmailVerified ?? _isEmailVerified,
    isUserKYCVerified: isUserKYCVerified ?? _isUserKYCVerified,
    isBasicUserVerified: isBasicUserVerified ?? _isBasicUserVerified,
    sellAtLoss: sellAtLoss ?? _sellAtLoss,
    googlePay: googlePay ?? _googlePay,
    applePay: applePay?? _applePay,
    temporaryCreditStatus: temporaryCreditStatus ?? _temporaryCreditStatus,
    isFrozen: isFrozen ?? _isFrozen,
    //temporaryCreditAmount: temporaryCreditAmount ?? _temporaryCreditAmount,
    userType: userType ?? _userType,
    walletExists: walletExists ?? _walletExists,
    offers: offers ?? _offers,
    newsUpdates: newsUpdates ?? _newsUpdates,
  );
  bool? get isPhoneVerified => _isPhoneVerified;
  bool? get isEmailVerified => _isEmailVerified;
  bool? get isUserKYCVerified => _isUserKYCVerified;
  bool? get isBasicUserVerified => _isBasicUserVerified;
  String? get userType => _userType;

  bool? get sellAtLoss => _sellAtLoss;
  bool? get googlePay => _googlePay;
  bool? get applePay => _applePay;

  bool? get temporaryCreditStatus => _temporaryCreditStatus;
  bool? get isFrozen => _isFrozen;
  //double? get temporaryCreditAmount => _temporaryCreditAmount;
  WalletExists? get walletExists => _walletExists;
  List<Offers>? get offers => _offers;
  List<NewsUpdates>? get newsUpdates => _newsUpdates;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['isPhoneVerified'] = _isPhoneVerified;
    map['isEmailVerified'] = _isEmailVerified;
    map['isUserKYCVerified'] = _isUserKYCVerified;
    map['isBasicUserVerified'] = _isBasicUserVerified;
    map['sellAtLoss'] = _sellAtLoss;
    map['googlePay'] = _googlePay;
    map['applePay']= _applePay;
    map['temporaryCreditStatus'] = _temporaryCreditStatus;
    map['isFrozen'] = _isFrozen;
    //map['temporaryCreditAmount'] = _temporaryCreditAmount;
    if (_walletExists != null) {
      map['walletExists'] = _walletExists?.toJson();
    }
    if (_offers != null) {
      map['offers'] = _offers?.map((v) => v.toJson()).toList();
    }
    if (_newsUpdates != null) {
      map['newsUpdates'] = _newsUpdates?.map((v) => v.toJson()).toList();
    }
    return map;
  }
}

/// _id : "681b63487d086ad402945d0a"
/// title : "Gold prices fall to lowest levels in over 3 weeks as market sell-off hits bullion"
/// description : "Gold prices fell on Monday to their lowest levels in more than three weeks, continuing their retreat amid a wider market sell-off, as investors dumped bullion to cover losses in other trades on fears of a global recession due to an escalating trade war.\nIn UAE, 24k opened at Dh365.75 per gram while 22K was selling at Dh338.50 per gram. Among the other variants, 21K and 18K opened at Dh324.75 and Dh278.25 per gram, respectively."
/// url : "https://www.khaleejtimes.com/business/markets/uae-gold-prices-drop-lowest-over-3-weeks"
/// createdAt : "2025-05-07T13:42:32.040Z"
/// updatedAt : "2025-05-07T13:42:32.040Z"
/// __v : 0

NewsUpdates newsUpdatesFromJson(String str) =>
    NewsUpdates.fromJson(json.decode(str));
String newsUpdatesToJson(NewsUpdates data) => json.encode(data.toJson());

class NewsUpdates {
  NewsUpdates({
    String? id,
    String? title,
    String? description,
    String? url,
    String? createdAt,
    String? updatedAt,
    num? v,
  }) {
    _id = id;
    _title = title;
    _description = description;
    _url = url;
    _createdAt = createdAt;
    _updatedAt = updatedAt;
    _v = v;
  }

  NewsUpdates.fromJson(dynamic json) {
    _id = json['_id'];
    _title = json['title'];
    _description = json['body'];
    _url = json['url'];
    _createdAt = json['createdAt'];
    _updatedAt = json['updatedAt'];
    _v = json['__v'];
  }
  String? _id;
  String? _title;
  String? _description;
  String? _url;
  String? _createdAt;
  String? _updatedAt;
  num? _v;
  NewsUpdates copyWith({
    String? id,
    String? title,
    String? description,
    String? url,
    String? createdAt,
    String? updatedAt,
    num? v,
  }) => NewsUpdates(
    id: id ?? _id,
    title: title ?? _title,
    description: description ?? _description,
    url: url ?? _url,
    createdAt: createdAt ?? _createdAt,
    updatedAt: updatedAt ?? _updatedAt,
    v: v ?? _v,
  );
  String? get id => _id;
  String? get title => _title;
  String? get description => _description;
  String? get url => _url;
  String? get createdAt => _createdAt;
  String? get updatedAt => _updatedAt;
  num? get v => _v;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['_id'] = _id;
    map['title'] = _title;
    map['body'] = _description;
    map['url'] = _url;
    map['createdAt'] = _createdAt;
    map['updatedAt'] = _updatedAt;
    map['__v'] = _v;
    return map;
  }
}

/// _id : "6819f27cadf8bf34773dd46f"
/// title : "Save In Gold"
/// offerImgUrl : "https://sigprodbucket.s3.me-central-1.amazonaws.com/default/image-c27b9cc1-72ed-431f-a44b-7d617c1a9a0b.png"
/// isOfferEnabled : true
/// createdAt : "2025-05-06T11:29:00.113Z"
/// updatedAt : "2025-05-07T08:03:43.853Z"
/// __v : 0

Offers offersFromJson(String str) => Offers.fromJson(json.decode(str));
String offersToJson(Offers data) => json.encode(data.toJson());

class Offers {
  Offers({
    String? id,
    String? title,
    String? offerImgUrl,
    String? offerLinkUrl,
    bool? isOfferEnabled,
    String? createdAt,
    String? updatedAt,
    num? v,
  }) {
    _id = id;
    _title = title;
    _offerImgUrl = offerImgUrl;
    _offerLinkUrl = offerLinkUrl;
    _isOfferEnabled = isOfferEnabled;
    _createdAt = createdAt;
    _updatedAt = updatedAt;
    _v = v;
  }

  Offers.fromJson(dynamic json) {
    _id = json['_id'];
    _title = json['title'];
    _offerImgUrl = json['offerImgUrl'];
    _offerLinkUrl = json['url'];
    _isOfferEnabled = json['isOfferEnabled'];
    _createdAt = json['createdAt'];
    _updatedAt = json['updatedAt'];
    _v = json['__v'];
  }
  String? _id;
  String? _title;
  String? _offerImgUrl;
  String? _offerLinkUrl;
  bool? _isOfferEnabled;
  String? _createdAt;
  String? _updatedAt;
  num? _v;
  Offers copyWith({
    String? id,
    String? title,
    String? offerImgUrl,
    String? offerLinkUrl,
    bool? isOfferEnabled,
    String? createdAt,
    String? updatedAt,
    num? v,
  }) => Offers(
    id: id ?? _id,
    title: title ?? _title,
    offerImgUrl: offerImgUrl ?? _offerImgUrl,
    offerLinkUrl: offerLinkUrl ?? _offerLinkUrl,
    isOfferEnabled: isOfferEnabled ?? _isOfferEnabled,
    createdAt: createdAt ?? _createdAt,
    updatedAt: updatedAt ?? _updatedAt,
    v: v ?? _v,
  );
  String? get id => _id;
  String? get title => _title;
  String? get offerImgUrl => _offerImgUrl;
  String? get offerLinkUrl => _offerLinkUrl;
  bool? get isOfferEnabled => _isOfferEnabled;
  String? get createdAt => _createdAt;
  String? get updatedAt => _updatedAt;
  num? get v => _v;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['_id'] = _id;
    map['title'] = _title;
    map['offerImgUrl'] = _offerImgUrl;
    map['url'] = _offerLinkUrl;
    map['isOfferEnabled'] = _isOfferEnabled;
    map['createdAt'] = _createdAt;
    map['updatedAt'] = _updatedAt;
    map['__v'] = _v;
    return map;
  }
}

/// _id : "6819af0bd80794b60a37e01f"
/// userId : "6819af0bd80794b60a37e01e"
/// moneyBalance : 399700
/// metalBalance : 392
/// createdAt : "2025-05-06T06:41:15.382Z"
/// updatedAt : "2025-05-06T07:40:24.278Z"
/// __v : 0

WalletExists walletExistsFromJson(String str) =>
    WalletExists.fromJson(json.decode(str));
String walletExistsToJson(WalletExists data) => json.encode(data.toJson());

class WalletExists {
  WalletExists({
    String? id,
    String? userId,
    num? moneyBalance,
    num? metalBalance,
    String? createdAt,
    String? updatedAt,
    num? frozenMetalBalance,
    num? loanAmountBalance,
    num? v,
  }) {
    _id = id;
    _userId = userId;
    _moneyBalance = moneyBalance;
    _metalBalance = metalBalance;
    _createdAt = createdAt;
    _updatedAt = updatedAt;
    _frozenMetalBalance = frozenMetalBalance;
    _loanAmountBalance = loanAmountBalance;
    _v = v;
  }

  WalletExists.fromJson(dynamic json) {
    _id = json['_id'];
    _userId = json['userId'];
    _moneyBalance = json['moneyBalance'];
    _metalBalance = json['metalBalance'];
    _createdAt = json['createdAt'];
    _updatedAt = json['updatedAt'];
    _frozenMetalBalance = json['frozenMetalBalance'];
    _loanAmountBalance = json['loanAmountBalance'];

    _v = json['__v'];
  }
  String? _id;
  String? _userId;
  num? _moneyBalance;
  num? _metalBalance;
  String? _createdAt;
  String? _updatedAt;
  num? _frozenMetalBalance;
  num? _loanAmountBalance;
  num? _v;
  WalletExists copyWith({
    String? id,
    String? userId,
    num? moneyBalance,
    num? metalBalance,
    String? createdAt,
    String? updatedAt,
    num? frozenMetalBalance,
    num? loanAmountBalance,
    num? v,
  }) => WalletExists(
    id: id ?? _id,
    userId: userId ?? _userId,
    moneyBalance: moneyBalance ?? _moneyBalance,
    metalBalance: metalBalance ?? _metalBalance,
    createdAt: createdAt ?? _createdAt,
    updatedAt: updatedAt ?? _updatedAt,
    frozenMetalBalance: frozenMetalBalance ?? _frozenMetalBalance,
    loanAmountBalance: loanAmountBalance ?? _loanAmountBalance,
    v: v ?? _v,
  );
  String? get id => _id;
  String? get userId => _userId;
  num? get moneyBalance => _moneyBalance;
  num? get metalBalance => _metalBalance;
  String? get createdAt => _createdAt;
  String? get updatedAt => _updatedAt;
  num? get frozenMetalBalance => _frozenMetalBalance;
  num? get loanAmountBalance => _loanAmountBalance;
  num? get v => _v;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['_id'] = _id;
    map['userId'] = _userId;
    map['moneyBalance'] = _moneyBalance;
    map['metalBalance'] = _metalBalance;
    map['createdAt'] = _createdAt;
    map['updatedAt'] = _updatedAt;
    map['frozenMetalBalance'] = _frozenMetalBalance;
    map['loanAmountBalance'] = _loanAmountBalance;
    map['__v'] = _v;
    return map;
  }
}
