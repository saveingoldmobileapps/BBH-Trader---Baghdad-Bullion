import 'dart:convert';

IpassLoginResponse ipassLoginResponseFromJson(String str) =>
    IpassLoginResponse.fromJson(json.decode(str) as Map<String, dynamic>);

String ipassLoginResponseToJson(IpassLoginResponse data) =>
    json.encode(data.toJson());

class IpassLoginResponse {
  IpassLoginResponse({this.user});

  IpassLoginResponse.fromJson(dynamic json) {
    final userJson = json is Map ? json['user'] : null;
    user = userJson is Map ? IpassLoginUser.fromJson(userJson) : null;
  }

  IpassLoginUser? user;

  Map<String, dynamic> toJson() => {
        if (user != null) 'user': user!.toJson(),
      };
}

class IpassLoginUser {
  IpassLoginUser({
    this.userId,
    this.email,
    this.token,
    this.customerData,
  });

  IpassLoginUser.fromJson(Map<dynamic, dynamic> json) {
    userId = json['user_id']?.toString();
    email = json['email']?.toString();
    token = json['token']?.toString();
    final customer = json['customer_data'];
    customerData =
        customer is Map ? IpassCustomerData.fromJson(customer) : null;
  }

  String? userId;
  String? email;
  /// JWT used as `auth_token` in formdata APIs.
  String? token;
  IpassCustomerData? customerData;

  /// App token for `?token=` query param (falls back to customer_data.token).
  String? get appToken => customerData?.token;

  Map<String, dynamic> toJson() => {
        'user_id': userId,
        'email': email,
        'token': token,
        if (customerData != null) 'customer_data': customerData!.toJson(),
      };
}

class IpassCustomerData {
  IpassCustomerData({
    this.id,
    this.email,
    this.token,
    this.companyName,
    this.docScanAccess,
    this.docScanRemaining,
  });

  IpassCustomerData.fromJson(Map<dynamic, dynamic> json) {
    id = json['_id']?.toString();
    email = json['email']?.toString();
    token = json['token']?.toString();
    companyName = json['companyname']?.toString();
    docScanAccess = json['docScan_access']?.toString();
    docScanRemaining = json['docScan_remaining']?.toString();
  }

  String? id;
  String? email;
  String? token;
  String? companyName;
  String? docScanAccess;
  String? docScanRemaining;

  Map<String, dynamic> toJson() => {
        '_id': id,
        'email': email,
        'token': token,
        'companyname': companyName,
        'docScan_access': docScanAccess,
        'docScan_remaining': docScanRemaining,
      };
}
