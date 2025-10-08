import 'package:floor/floor.dart';

@Entity()
class UserPaymentMethods {
  @primaryKey
  String? id;
  String? methodId;
  String? methodName;
  String? cardNumber;
  String? validTill;
  String? nameOnCard;
  String? bank;
  String? swiftCode;
  String? accountNumber;
  String? accountHolderName;
  String? phoneNumber;
  bool? isDefault;


  UserPaymentMethods(
      this.id,
      this.methodId,
      this.methodName,
      this.cardNumber,
      this.validTill,
      this.nameOnCard,
      this.bank,
      this.swiftCode,
      this.accountNumber,
      this.accountHolderName,
      this.phoneNumber,
      this.isDefault);

  UserPaymentMethods.bankAccount(
      this.id,
      this.methodName,
      this.bank,
      this.swiftCode,
      this.accountNumber,
      this.accountHolderName,
      this.isDefault);


  UserPaymentMethods.cardMethod(
      this.id,
      this.methodName,
      this.cardNumber,
      this.validTill,
      this.nameOnCard,
      this.isDefault);


  UserPaymentMethods.wallet(
      this.id,
      this.methodName,
      this.accountHolderName,
      this.phoneNumber,
      this.isDefault);

  UserPaymentMethods.fromJson(Map<String, dynamic> json) {
    id = json['id'] ?? '';
    methodId = json['methodId'] ?? '';
    methodName = json['methodName'] ?? '';
    validTill = json['validTill'] ?? '';
    cardNumber = json['cardNumber'] ?? '';
    nameOnCard = json['nameOnCard'] ?? '';
    bank = json['bank'] ?? '';
    swiftCode = json['swiftCode'] ?? '';
    accountNumber = json['accountNumber'] ?? '';
    accountHolderName = json['accountHolderName'] ?? '';
    phoneNumber = json['phoneNumber'] ?? '';
    isDefault = json['isDefault'] ?? '';
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['methodId'] = methodId;
    data['methodName'] = methodName;
    data['validTill'] = validTill;
    data['cardNumber'] = cardNumber;
    data['nameOnCard'] = nameOnCard;
    data['bank'] = bank;
    data['swiftCode'] = swiftCode;
    data['accountNumber'] = accountNumber;
    data['accountHolderName'] = accountHolderName;
    data['phoneNumber'] = phoneNumber;
    data['isDefault'] = isDefault;
    return data;
  }
}
