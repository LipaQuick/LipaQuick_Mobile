import 'package:json_annotation/json_annotation.dart';
import 'package:lipa_quick/core/models/response.dart';

class AddressModel extends ApiResponse {
  @JsonKey(name: 'status', defaultValue: false)
  bool? status;
  @JsonKey(name: 'message', defaultValue: '')
  String? message;
  @JsonKey(name: 'data')
  List<AddressDetails>? data;

  AddressModel.name({this.status, this.message, this.data});

  factory AddressModel.fromJson(Map<String, dynamic> json) => AddressModel.name(
        status: json['status'] ?? false,
        message: json['message'] ?? '',
        data: (json['data'] as List<dynamic>?)
            ?.map((e) => AddressDetails.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

class AddressDetails {
  String? id, name;

  AddressDetails.init(this.id, this.name);

  factory AddressDetails.fromJson(Map<String, dynamic> json) =>
      AddressDetails.init(json['id'] as String?, json['name'] as String?);

  @override
  String toString() {
    return name!;
  }

  @override
  int get hashCode => id!.hashCode ^ name!.hashCode;

  @override
  bool operator ==(Object other)=>
      identical(this, other) ||
          other is AddressDetails &&
              runtimeType == other.runtimeType &&
              id == other.id &&
              name == other.name;
}
