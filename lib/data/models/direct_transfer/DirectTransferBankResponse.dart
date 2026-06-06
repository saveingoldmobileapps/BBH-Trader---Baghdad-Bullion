import 'dart:convert';

DirectTransferbankResponse directTransferbankResponseFromJson(String str) =>
    DirectTransferbankResponse.fromJson(json.decode(str));

String directTransferbankResponseToJson(DirectTransferbankResponse data) =>
    json.encode(data.toJson());

class DirectTransferbankResponse {
  final String? status;
  final num? code;
  final String? message;
  final Payload? payload;

  DirectTransferbankResponse({
    this.status,
    this.code,
    this.message,
    this.payload,
  });

  factory DirectTransferbankResponse.fromJson(Map<String, dynamic> json) {
    return DirectTransferbankResponse(
      status: json['status'],
      code: json['code'],
      message: json['message'],
      payload:
          json['payload'] != null ? Payload.fromJson(json['payload']) : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'status': status,
        'code': code,
        'message': message,
        'payload': payload?.toJson(),
      };
}
class Payload {
  final List<AllBanks>? allBanks;

  Payload({this.allBanks});

  factory Payload.fromJson(Map<String, dynamic> json) {
    return Payload(
      allBanks: json['allBanks'] != null
          ? List<AllBanks>.from(
              json['allBanks'].map((x) => AllBanks.fromJson(x)))
          : [],
    );
  }

  Map<String, dynamic> toJson() => {
        'allBanks': allBanks?.map((e) => e.toJson()).toList(),
      };
}
class MultiLang {
  final String? en;
  final String? ar;

  MultiLang({this.en, this.ar});

  factory MultiLang.fromJson(Map<String, dynamic> json) {
    return MultiLang(
      en: json['en'],
      ar: json['ar'],
    );
  }

  Map<String, dynamic> toJson() => {
        'en': en,
        'ar': ar,
      };
}

class AllBanks {
  final String? id;
  final MultiLang? bankName;
  final MultiLang? accountName;
  final String? accountNumber;
  final MultiLang? accountType;
  final MultiLang? currency;
  final String? iban;
  final String? logoUrl;
  final String? swiftCode;
  final String? createdAt;
  final String? updatedAt;
  final num? v;

  AllBanks({
    this.id,
    this.bankName,
    this.accountName,
    this.accountNumber,
    this.accountType,
    this.currency,
    this.iban,
    this.logoUrl,
    this.swiftCode,
    this.createdAt,
    this.updatedAt,
    this.v,
  });

  factory AllBanks.fromJson(Map<String, dynamic> json) {
    return AllBanks(
      id: json['_id'],
      bankName: json['bankName'] != null
          ? MultiLang.fromJson(json['bankName'])
          : null,
      accountName: json['accountName'] != null
          ? MultiLang.fromJson(json['accountName'])
          : null,
      accountNumber: json['accountNumber'],
      accountType: json['accountType'] != null
          ? MultiLang.fromJson(json['accountType'])
          : null,
      currency: json['currency'] != null
          ? MultiLang.fromJson(json['currency'])
          : null,
      iban: json['iban'],
      logoUrl: json['logoUrl'],
      swiftCode: json['swiftCode'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      v: json['__v'],
    );
  }

  Map<String, dynamic> toJson() => {
        '_id': id,
        'bankName': bankName?.toJson(),
        'accountName': accountName?.toJson(),
        'accountNumber': accountNumber,
        'accountType': accountType?.toJson(),
        'currency': currency?.toJson(),
        'iban': iban,
        'logoUrl': logoUrl,
        'swiftCode': swiftCode,
        'createdAt': createdAt,
        'updatedAt': updatedAt,
        '__v': v,
      };
}