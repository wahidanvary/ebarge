import 'dart:core';

class shopModel {
  String? productId;
  int? priceAmount;
  int? bonusPercent;
  double? bonusZafran;
  int? goldAmount;
  String? sellStatus;

  shopModel({
    this.productId,
    this.priceAmount,
    this.bonusPercent,
    this.bonusZafran,
    this.goldAmount,
    this.sellStatus});


  factory shopModel.fromJson(Map<String, dynamic> json) => shopModel(
    productId: json["product_id"],
    priceAmount: json["price_amount"],
    bonusPercent: json["bonus_percent"],
    bonusZafran: json["bonus_zafran"],
    goldAmount: json["gold_amount"],
    sellStatus: json["sell_status"],
  );

  Map<String, dynamic> toJson() => {
    "product_id": productId,
    "price_amount": priceAmount,
    "bonus_percent": bonusPercent,
    "bonus_zafran": bonusZafran,
    "gold_amount": goldAmount,
    "sell_status": sellStatus,
  };
}
