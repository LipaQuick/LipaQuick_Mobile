import 'package:uuid/uuid.dart';

class DiscountRequest{
  String? userId;
  int? amount;

  DiscountRequest({this.userId,this.amount});

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['userId'] = userId;
    data['amount'] = amount;
    return data;
  }
}

class DiscountResponse{
  bool? status;
  String? message;
  List<DiscountItems>? data;

  DiscountResponse({this.status,this.message, this.data});

  DiscountResponse.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    if (json['data'] != null) {
      data = <DiscountItems>[];
      json['data'].forEach((v) {
        data!.add(DiscountItems.fromJson(v));
      });
    }
  }
}

class DiscountItems {
  String? discountId;
  String? discountCode;
  int? flatAmount;
  int? maxAmount;
  int? minAmount;
  int? amountPercentage;
  bool? amountPercentageActive;

  DiscountItems({this.discountId, this.discountCode, this.flatAmount, this.maxAmount, this.minAmount
    , this.amountPercentage, this.amountPercentageActive}){
  }


  DiscountItems.fromJson(Map<String, dynamic> json) {
    discountId = json['discountId'];
    discountCode = json['discountCode'];
    flatAmount = json['flatAmount'];
    maxAmount = json['maxAmount'];
    minAmount = json['minAmount'];
    amountPercentage = json['amountPercentage'];
    amountPercentageActive = json['amountPercentageActive'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['discountId'] = discountId;
    data['discountCode'] = discountCode;
    data['flatAmount'] = flatAmount;
    data['maxAmount'] = maxAmount;
    data['minAmount'] = minAmount;
    data['amountPercentage'] = amountPercentage;
    data['amountPercentageActive'] = amountPercentageActive;
    return data;
  }
}