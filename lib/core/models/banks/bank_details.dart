import 'dart:math';

import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
part 'bank_details.g.dart';

@JsonSerializable()
class BankDetails extends Equatable{
  String? id;
  String? name;
  String? logo;

  BankDetails({this.id, this.name,this.logo});
  
  String getLogo(){
    var base64Image = logo!.split(",");
    return base64Image.last;
  }

  factory BankDetails.fromJson(Map<String, dynamic> json) => BankDetails(
    id: json['id'] as String?,
    name: json['name'] as String?,
    logo: json['logo'] as String?,
  );

  Map<String, dynamic> toJson() => _$BankDetailsToJson(this);

  @override
  List<Object?> get props => [id, name, logo];
}