
import 'package:uuid/uuid.dart';
import 'package:json_annotation/json_annotation.dart';

@JsonSerializable()
class AddCardModel{
  String? id = const Uuid().v1();
  String? cardNumber;
  String? validTill;
  String? nameOnCard;
  bool? isPrimary;

  AddCardModel();

  AddCardModel.name({this.id, this.cardNumber, this.validTill, this.nameOnCard, this.isPrimary});

  @override
  List<Object?> get props => [id, cardNumber, validTill, nameOnCard, isPrimary];

  factory AddCardModel.fromJson(Map<String, dynamic> json) =>  AddCardModel.name(
      id: json['id'] as String?
      , cardNumber: json['cardNumber'] as String?
      , validTill:json['validTill'] as String?
      , nameOnCard:json['nameOnCard'] as String?
      , isPrimary:json['isPrimary'] as bool?
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'cardNumber': cardNumber!.replaceAll(' ', ''),
    'validTill': validTill,
    'nameOnCard': nameOnCard,
    'isPrimary': isPrimary,
  };
}