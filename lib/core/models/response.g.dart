// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ApiResponse _$ApiResponseFromJson(Map<String, dynamic> json) => ApiResponse()
  ..message = json['message'] as String? ?? ''
  ..status = json['status'] as bool? ?? false
  ..errors =
      (json['errors'] as List<dynamic>?)?.map((e) => e as String).toList() ??
          [];

Map<String, dynamic> _$ApiResponseToJson(ApiResponse instance) =>
    <String, dynamic>{
      'message': instance.message,
      'status': instance.status,
      'errors': instance.errors,
    };

RegisterApiResponse _$RegisterApiResponseFromJson(Map<String, dynamic> json) =>
    RegisterApiResponse()
      ..message = json['message'] as String? ?? ''
      ..status = json['status'] as bool? ?? false
      ..errors = (json['errors'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [];

Map<String, dynamic> _$RegisterApiResponseToJson(
        RegisterApiResponse instance) =>
    <String, dynamic>{
      'message': instance.message,
      'status': instance.status,
      'errors': instance.errors,
    };

LoginApiResponse _$LoginApiResponseFromJson(Map<String, dynamic> json) =>
    LoginApiResponse()
      ..message = json['message'] as String? ?? ''
      ..status = json['status'] as bool? ?? false
      ..access_token = json['access_token'] as String? ?? ''
      ..refreshToken = json['refresh_token'] as String? ?? '';

Map<String, dynamic> _$LoginApiResponseToJson(LoginApiResponse instance) =>
    <String, dynamic>{
      'message': instance.message,
      'status': instance.status,
      'access_token': instance.access_token,
      'refresh_token': instance.refreshToken,
      'data': instance.userData,
    };
