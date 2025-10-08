
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

@JsonSerializable()
class AddAccountModel{
  String? bank;
  String? bankName;
  String? swiftCode;
  String? accountNumber;
  String? accountHolderName;
  bool? primary;

  AddAccountModel({this.bank,this.bankName, this.swiftCode, this.accountNumber,
    this.accountHolderName, this.primary});


  @override
  List<Object?> get props => [bank, bankName, swiftCode, accountNumber, accountHolderName, primary];

  factory AddAccountModel.fromJson(Map<String, dynamic> json) =>  AddAccountModel(
      bank: json['bank'] as String?
      , swiftCode:json['swiftCode'] as String?
      , accountNumber:json['accountNumber'] as String?
      , accountHolderName:json['accountHolderName'] as String?
      , primary:json['primary'] as bool?);

  Map<String, dynamic> toJson() => <String, dynamic>{
    'bank': bank,
    'swiftCode': swiftCode,
    'accountNumber': accountNumber,
    'accountHolderName': accountHolderName,
    'primary': primary,
  };
}