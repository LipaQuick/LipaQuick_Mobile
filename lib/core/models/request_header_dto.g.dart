// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'request_header_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RequestHeaderDto _$RequestHeaderDtoFromJson(Map<String, dynamic> json) =>
    RequestHeaderDto(
      json['Source'] as String,
      json['Device'] as String,
      json['Version'] as String,
    );

Map<String, dynamic> _$RequestHeaderDtoToJson(RequestHeaderDto instance) =>
    <String, dynamic>{
      'Source': instance.source,
      'Device': instance.Device,
      'Version': instance.Version,
    };
