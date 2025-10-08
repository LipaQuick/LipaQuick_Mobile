import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:lipa_quick/core/models/banks/bank_details.dart';
part 'bank_response.g.dart';

@JsonSerializable()
class BankListResponse {
  bool? status;
  String? message;
  List<BankDetails>? data;

  BankListResponse({this.status,this.message, this.data});

  factory BankListResponse.fromJson(Map<String, dynamic> json) => BankListResponse(
    status: json['status'] as bool?,
    message: json['message'] as String?,
    data: (json['data'] as List<dynamic>?)?.map((e) => BankDetails.fromJson(e as Map<String, dynamic>))
        .toList(),
  );

  Map<String, dynamic> toJson() => _$BankListResponseToJson(this);
}