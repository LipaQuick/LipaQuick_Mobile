import 'dart:core';

import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
part 'account_model.g.dart';

@JsonSerializable()
class AccountListResponse {
  @JsonKey(name: 'status', defaultValue: false)
  bool? status;
  @JsonKey(name: 'message', defaultValue: '')
  String? message;
  @JsonKey(name: 'data')
  List<AccountDetails>? data;

  AccountListResponse({this.status,this.message, this.data});

  factory AccountListResponse.fromJson(Map<String, dynamic> json) => AccountListResponse(
    status: json['status'] as bool?,
    message: json['message'] as String?,
    data: json['data'] == null?[]:(json['data'] as List<dynamic>?)?.map((e) => AccountDetails.fromJson(e as Map<String, dynamic>))
        .toList(),
  );

  Map<String, dynamic> toJson() => _$AccountListResponseToJson(this);

  @override
  List<Object?> get props => [status, message, data];

}

@JsonSerializable()
class AccountDetails extends Equatable{
  String? id;
  String? bank;
  String? swiftCode;
  String? accountNumber;
  String? accountHolderName;
  bool? primary;
  String? logo;


  AccountDetails({this.id, this.bank, this.swiftCode, this.accountNumber,
      this.accountHolderName, this.primary, this.logo});

  String? getLogo(){
    if(logo== null){
      return null;
    }
    var base64Image = logo!.split(",");
    return base64Image.last;
  }

  @override
  List<Object?> get props => [id, bank, swiftCode, accountNumber, accountHolderName, primary, logo];

  factory AccountDetails.fromJson(Map<String, dynamic> json) {
    //print('Reached Here');
    return AccountDetails(
        id: json['id'] as String?,
        bank: json['bank'] as String?
        , swiftCode:json['swiftCode'] as String?
        , accountNumber:json['accountNumber'] as String?
        , accountHolderName:json['accountHolderName'] as String?
        , primary:json['primary'] ?? false
        , logo:json['logo'] as String?);
  }

  @override
  String toString() {
    return 'AccountDetails{id: $id, bank: $bank, swiftCode: $swiftCode, accountNumber: $accountNumber, accountHolderName: $accountHolderName, primary: $primary}';
  }

Map<String, dynamic> toJson() => _$AccountDetailsToJson(this);


}