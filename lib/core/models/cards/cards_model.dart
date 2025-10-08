import 'dart:core';
import 'dart:math';

import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

@JsonSerializable()
class CardListResponse {
  @JsonKey(name: 'status', defaultValue: false)
  bool? status;
  @JsonKey(name: 'message', defaultValue: '')
  String? message;
  @JsonKey(name: 'data')
  List<CardDetailsModel>? data;

  CardListResponse({this.status,this.message, this.data});

  factory CardListResponse.fromJson(Map<String, dynamic> json) => CardListResponse(
    status: json['status'] as bool?,
    message: json['message'] as String?,
    data: (json['data'] as List<dynamic>?)?.map((e) => CardDetailsModel.fromJson(e as Map<String, dynamic>))
        .toList(),
  );

  // Map<String, dynamic> toJson() => _$AccountListResponseToJson(this);

  @override
  List<Object?> get props => [status, message, data];

}

@JsonSerializable()
class CardDetailsModel extends Equatable{
  String? id;
  String? cardNumber;
  String? validTill;
  String? nameOnCard;
  bool? isPrimary;

  CardDetailsModel({this.id, this.cardNumber, this.validTill, this.nameOnCard, this.isPrimary});


  @override
  List<Object?> get props => [id, cardNumber, validTill, nameOnCard];

  factory CardDetailsModel.fromJson(Map<String, dynamic> json) =>  CardDetailsModel(id: json['id'] as String?,
      cardNumber: json['cardNumber'] as String?
      , validTill:json['validTill'] as String?
      , nameOnCard:json['nameOnCard'] as String?
      , isPrimary:json['isPrimary'] as bool? ?? false
  );

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['cardNumber'] = cardNumber;
    data['validTill'] = validTill;
    data['nameOnCard'] = nameOnCard;
    data['isPrimary'] = isPrimary;
    return data;
  }
}