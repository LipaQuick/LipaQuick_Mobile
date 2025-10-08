import 'package:json_annotation/json_annotation.dart';
part 'quick_action_model.g.dart';

@JsonSerializable()
class QuickActionModel{
  String? Id;
  String? iconPath;
  String? quickActionTitle;
  int? isEnabled;

  QuickActionModel();


  QuickActionModel.name(
      this.Id, this.iconPath, this.quickActionTitle, this.isEnabled);

  factory QuickActionModel.fromJson(Map<String, dynamic> json) => _$QuickActionModelFromJson(json);

  Map<String, dynamic> toJson() => _$QuickActionModelToJson(this);

}