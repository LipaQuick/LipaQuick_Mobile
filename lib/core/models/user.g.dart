// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserDetailsModel _$UserDetailsModelFromJson(Map<String, dynamic> json) =>
    UserDetailsModel(
      id: json['id'] as String,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      email: json['email'] as String,
      phoneNumber: json['phoneNumber'] as String,
      dateOfBirth: json['dateOfBirth'] as String,
      gender: json['gender'] as String,
      idNumber: json['idNumber'] as String,
      idType: json['idType'] as String,
      password: json['password'] as String,
      address: json['address'] as String,
      location: json['location'] as String,
      profilePicture: json['profilePicture'] as String,
      street: json['street'] as String,
      city: json['city'] as String,
      state: json['state'] as String,
      country: json['country'] as String,
    )
      ..confirmPassword = json['confirmPassword'] as String?
      ..inviteCode = json['inviteCode'] as String?
      ..emailConfirmed = json['emailConfirmed'] as bool?
      ..phoneNumberConfirmed = json['phoneNumberConfirmed'] as bool?;

Map<String, dynamic> _$UserDetailsModelToJson(UserDetailsModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'firstName': instance.firstName,
      'lastName': instance.lastName,
      'email': instance.email,
      'phoneNumber': instance.phoneNumber,
      'dateOfBirth': instance.dateOfBirth,
      'gender': instance.gender,
      'idNumber': instance.idNumber,
      'idType': instance.idType,
      'password': instance.password,
      'confirmPassword': instance.confirmPassword,
      'address': instance.address,
      'location': instance.location,
      'street': instance.street,
      'city': instance.city,
      'state': instance.state,
      'country': instance.country,
      'inviteCode': instance.inviteCode,
      'profilePicture': instance.profilePicture,
      'emailConfirmed': instance.emailConfirmed,
      'phoneNumberConfirmed': instance.phoneNumberConfirmed,
    };
