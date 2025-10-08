import 'package:lipa_quick/core/models/accounts/account_model.dart';
import 'package:lipa_quick/core/models/banks/bank_details.dart';
import 'package:lipa_quick/core/models/cards/cards_model.dart';
import 'package:uuid/uuid.dart';

class ResponsePaymentMethodDto {
  bool? status;
  String? title;
  String? message;
  List<String>? errors;
  PaymentMethodData? data;

  ResponsePaymentMethodDto();


  ResponsePaymentMethodDto.init(){
    this.status = false;
    this.title = '';
    this.message = '';
    this.errors = [];
    this.data = PaymentMethodData();
  }

  factory ResponsePaymentMethodDto.fromJson(Map<String, dynamic> json) =>
      ResponsePaymentMethodDto()
        ..status = json['status'] ?? false
        ..title = json['title'] ?? ''
        ..message = json['message'] ?? ''
        ..errors = (json['errors'] as List<dynamic>? ?? []).cast<String>()
        ..data = json['data'] != null
            ? PaymentMethodData.fromJson(json['data'])
            : PaymentMethodData.template();

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    data['message'] = message;
    data['errors'] = errors;
    data['title'] = title;
    data['data'] = PaymentMethodData().toJson();
    return data;
  }
}

class PaymentMethodData {
  CardDetailsModel? Defaultcarddetails;
  AccountDetails? DefaultBankAccount;
  MTNWalletDetails? DefaultWalletDetails;


  PaymentMethodData();


  PaymentMethodData.template(){
    this.Defaultcarddetails = CardDetailsModel.fromJson(getDummyCardDetails());
    this.DefaultBankAccount = AccountDetails.fromJson(getDummyBankAccount());
    this.DefaultWalletDetails = MTNWalletDetails.fromJson(getMtnWallet());
  }

  factory PaymentMethodData.fromJson(Map<String, dynamic> json) =>
      PaymentMethodData()
        ..Defaultcarddetails = json['defaultcarddetails'] != null
            ? CardDetailsModel.fromJson(json['defaultcarddetails'])
            : null
        ..DefaultBankAccount = json['defaultBankAccount'] != null
            ? AccountDetails.fromJson(json['defaultBankAccount'])
            : null
        ..DefaultWalletDetails = json['defaultWalletDetails'] != null
            ? MTNWalletDetails.fromJson(json['defaultWalletDetails'])
            : null;

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['defaultcarddetails'] = Defaultcarddetails?.toJson();
    data['defaultBankAccount'] = DefaultBankAccount?.toJson();
    data['defaultWalletDetails'] = DefaultWalletDetails?.toJson();
    return data;
  }

  Map<String, dynamic> getDummyCardDetails() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = Uuid().v4();
    data['cardNumber'] = Uuid().v4();
    data['validTill'] = '02/27';
    data['nameOnCard'] = 'Dummy Name';
    return data;
  }

  Map<String, dynamic> getDummyBankAccount() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = Uuid().v4();
    data['bank'] = 'Eco Bank';
    data['swiftCode'] = 'ECOCNGLAXXX';
    data['accountNumber'] = '12345678901';
    data['accountHolderName'] = 'Dummy Holder Name';
    data['primary'] = true;
    return data;
  }

  Map<String, dynamic> getMtnWallet() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = Uuid().v4();
    data['walletNumber'] = '9140542494';
    return data;
  }
}

class MTNWalletDetails {
  String? id;
  String? number;

  MTNWalletDetails.fromJson(Map<String, dynamic> json) {
    id = json['id'] ?? '';
    number = json['walletNumber'] ?? "";
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['walletNumber'] = number;
    return data;
  }
}
