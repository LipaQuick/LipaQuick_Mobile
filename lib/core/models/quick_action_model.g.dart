// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quick_action_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

QuickActionModel _$QuickActionModelFromJson(Map<String, dynamic> json) =>
    QuickActionModel()
      ..Id = json['Id'] as String?
      ..iconPath = json['iconPath'] as String?
      ..quickActionTitle = json['quickActionTitle'] as String?
      ..isEnabled = (json['isEnabled'] as num?)?.toInt();

Map<String, dynamic> _$QuickActionModelToJson(QuickActionModel instance) =>
    <String, dynamic>{
      'Id': instance.Id,
      'iconPath': instance.iconPath,
      'quickActionTitle': instance.quickActionTitle,
      'isEnabled': instance.isEnabled,
    };
