import 'dart:convert';

/// MetalreponseModel: Represents a metal transaction response model.
MetalreponseModel metalreponseModelFromJson(String str) =>
    MetalreponseModel.fromJson(json.decode(str));
String metalreponseModelToJson(MetalreponseModel data) =>
    json.encode(data.toJson());

class MetalreponseModel {
  MetalreponseModel({
    this.id,
    this.userId,
    this.transactionId,
    this.paymentMethod,
    this.orderType,
    this.transactionType,
    this.quantity,
    this.debit,
    this.credit,
    this.totalBalance,
    this.openPosition,
    this.closedPosition,
    this.date,
    this.triggerAt,
    this.triggerType,
    this.moneyBalance,
    this.metalBalance,
  });

  factory MetalreponseModel.fromJson(Map<String, dynamic> json) =>
      MetalreponseModel(
        id: json['_id']?.toString(),
        userId: json['userId']?.toString(),
        transactionId: json['transactionId']?.toString(),
        paymentMethod: json['paymentMethod']?.toString(),
        orderType: json['orderType']?.toString(),
        transactionType: json['transactionType']?.toString(),
        quantity: json['quantity']?.toString(),
        debit: json['debit']?.toString(),
        credit: json['credit'] != null
            ? int.tryParse(json['credit'].toString())
            : null,
        totalBalance: json['totalBalance']?.toString(),
        openPosition: json['openPosition']?.toString(),
        closedPosition: json['closedPosition']?.toString(),
        date: json['date']?.toString(),
        triggerAt: json['triggerAt']?.toString(),
        triggerType: json['triggerType']?.toString(),
        moneyBalance: json['moneyBalance']?.toString(),
        metalBalance: json['metalBalance']?.toString(),
      );

  String? id;
  String? userId;
  String? transactionId;
  String? paymentMethod;
  String? orderType;
  String? transactionType;
  String? quantity;
  String? debit;
  int? credit;
  String? totalBalance;
  String? openPosition;
  String? closedPosition;
  String? date;
  String? triggerAt;
  String? triggerType;
  String? moneyBalance;
  String? metalBalance;
  MetalreponseModel copyWith({
    String? id,
    String? userId,
    String? transactionId,
    String? paymentMethod,
    String? orderType,
    String? transactionType,
    String? quantity,
    String? debit,
    int? credit,
    String? totalBalance,
    String? openPosition,
    String? closedPosition,
    String? date,
    String? triggerAt,
    String? triggerType,
    String? moneyBalance,
    String? metalBalance,
  }) =>
      MetalreponseModel(
          id: id ?? this.id,
          userId: userId ?? this.userId,
          transactionId: transactionId ?? this.transactionId,
          paymentMethod: paymentMethod ?? this.paymentMethod,
          orderType: orderType ?? this.orderType,
          transactionType: transactionType ?? this.transactionType,
          quantity: quantity ?? this.quantity,
          debit: debit ?? this.debit,
          credit: credit ?? this.credit,
          totalBalance: totalBalance ?? this.totalBalance,
          openPosition: openPosition ?? this.openPosition,
          closedPosition: closedPosition ?? this.closedPosition,
          date: date ?? this.date,
          triggerAt: triggerAt ?? this.triggerAt,
          triggerType: triggerType ?? this.triggerType,
          moneyBalance: moneyBalance ?? this.metalBalance,
          metalBalance: metalBalance ?? this.metalBalance);

  Map<String, dynamic> toJson() => {
        '_id': id,
        'userId': userId,
        'transactionId': transactionId,
        'paymentMethod': paymentMethod,
        'orderType': orderType,
        'transactionType': transactionType,
        'quantity': quantity,
        'debit': debit,
        'credit': credit,
        'totalBalance': totalBalance,
        'openPosition': openPosition,
        'closedPosition': closedPosition,
        'date': date,
        'triggerAt': triggerAt,
        'triggerType': triggerType,
        'moneyBalance': moneyBalance,
        'metalBalance': metalBalance
      };
}
