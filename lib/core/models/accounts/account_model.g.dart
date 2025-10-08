// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'account_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AccountListResponse _$AccountListResponseFromJson(Map<String, dynamic> json) =>
    AccountListResponse(
      status: json['status'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      data: (json['data'] as List<dynamic>?)
          ?.map((e) => AccountDetails.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$AccountListResponseToJson(
        AccountListResponse instance) =>
    <String, dynamic>{
      'status': instance.status,
      'message': instance.message,
      'data': instance.data,
    };

AccountDetails _$AccountDetailsFromJson(Map<String, dynamic> json) =>
    AccountDetails(
      id: json['id'] as String?,
      bank: json['bank'] as String?,
      swiftCode: json['swiftCode'] as String?,
      accountNumber: json['accountNumber'] as String?,
      accountHolderName: json['accountHolderName'] as String?,
      primary: json['primary'] as bool?,
      logo: json['logo'] as String?,
    );

Map<String, dynamic> _$AccountDetailsToJson(AccountDetails instance) =>
    <String, dynamic>{
      'id': instance.id,
      'bank': instance.bank,
      'swiftCode': instance.swiftCode,
      'accountNumber': instance.accountNumber,
      'accountHolderName': instance.accountHolderName,
      'primary': instance.primary,
      'logo': instance.logo,
    };
