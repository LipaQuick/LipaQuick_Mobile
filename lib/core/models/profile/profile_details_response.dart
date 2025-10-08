import 'dart:ffi';

import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:lipa_quick/core/models/accounts/account_model.dart';
import 'package:lipa_quick/core/models/cards/cards_model.dart';
import 'package:lipa_quick/core/models/response.dart';

class ProfileDetailsResponse {
  @JsonKey(name: 'id')
  String id;
  @JsonKey(name: 'role')
  String role;
  @JsonKey(name: 'firstName')
  String firstName;
  @JsonKey(name: 'lastName')
  String lastName;
  @JsonKey(name: 'phoneNumber')
  String phoneNumber;
  @JsonKey(name: 'email')
  String email;
  @JsonKey(name: 'dateOfBirth')
  String dateOfBirth;
  @JsonKey(name: 'gender')
  String gender;
  @JsonKey(name: 'country')
  String country;
  @JsonKey(name: 'state')
  String state;
  @JsonKey(name: 'city')
  String city;
  @JsonKey(name: 'street')
  String street;
  @JsonKey(name: 'active')
  bool active;
  @JsonKey(name: 'profilePicture')
  String profilePicture;
  @JsonKey(name: 'identityType')
  String identityType;
  @JsonKey(name: 'identityNumber')
  String identityNumber;
  @JsonKey(name: 'identityDocPhoto')
  String identityDocPhoto;
  @JsonKey(name: 'identityStatus')
  String identityStatus;
  @JsonKey(name: 'qrCode')
  String qrCode;
  @JsonKey(name: 'inviteCode')
  String inviteCode;
  @JsonKey(name: 'bankDetails')
  AccountDetails? bankDetails;
  @JsonKey(name: 'cardDetails')
  CardDetailsModel? cardDetails;
  @JsonKey(name: 'latLng')
  String? userLatLng;


  ProfileDetailsResponse.init()
      : id = '', role = '',
        firstName = '',
        lastName = '',
        phoneNumber = '',
        email = '',
        dateOfBirth = '',
        gender = '',
        country = '',
        state = '',
        city = '',
        street = '',
        active = false,
        profilePicture = '',
        identityType = '',
        identityNumber = '',
        identityDocPhoto = '',
        identityStatus = '',
        qrCode = '',
        inviteCode = '';

  ProfileDetailsResponse.name(
      this.id,
      this.role,
      this.firstName,
      this.lastName,
      this.phoneNumber,
      this.email,
      this.dateOfBirth,
      this.gender,
      this.country,
      this.state,
      this.city,
      this.street,
      this.active,
      this.profilePicture,
      this.identityType,
      this.identityNumber,
      this.identityDocPhoto,
      this.identityStatus,
      this.qrCode, this.inviteCode,this.userLatLng, this.bankDetails, this.cardDetails);


  String getProfilePictureLogo(){
    var base64Image = profilePicture.split(",");
    return base64Image.last;
  }

  String getIdentityLogo(){
    var base64Image = identityDocPhoto.split(",");
    return base64Image.last;
  }

  String getMyQRCode(){
    var base64Image = qrCode.split(",");
    return base64Image.last;
  }

  factory ProfileDetailsResponse.fromJson(Map<dynamic, dynamic> json) => ProfileDetailsResponse.name(
    json['id'] ?? '',
    json['role'] ?? '',
    json['firstName'] ?? '',
    json['lastName'] ?? '',
    json['phoneNumber'] ?? '',
    json['email'] ?? '',
    json['dateOfBirth'] ?? '',
    json['gender'] ?? '',
    json['country'] ?? '',
    json['state'] ?? '',
    json['city'] ?? '',
    json['street'] ?? '',
    json['active'],
    json['profilePicture'] ?? '',
    json['identityType'] ?? '',
    json['identityNumber'] ?? '',
    json['identityDocPhoto'] ?? '',
    json['identityStatus'] ?? '',
    json['qrCode'] ?? '',
    json['inviteCode'] ?? '',
    json['latLng'] ?? '',
    (json['bankDetails'] == null || json['bankDetails'] == '')?null:AccountDetails.fromJson(json['bankDetails']),
    (json['cardDetails'] == null || json['cardDetails'] == '')?null:CardDetailsModel.fromJson(json['cardDetails']),
  );

  Map<String, dynamic> toJson() =>  <String, dynamic>{
    'id': this.id,
    'role': this.role,
    'firstName': this.firstName,
    'lastName': this.lastName,
    'phoneNumber': this.phoneNumber,
    'email': this.email,
    'dateOfBirth': this.dateOfBirth,
    'gender': this.gender,
    'country': this.country,
    'state': this.state,
    'street': this.street,
    'active': this.active,
    //'profilePicture': this.profilePicture,
    'identityType': this.identityType,
    'identityNumber': this.identityNumber,
    //'identityDocPhoto': this.identityDocPhoto,
    'identityStatus': this.identityStatus,
    'qrCode': this.qrCode,
    'inviteCode': this.inviteCode,
    'latlng': this.userLatLng
  };

  Map<String, dynamic> toUpdateJson() =>  <String, dynamic>{
    'firstName': this.firstName,
    'lastName': this.lastName,
    //'phoneNumber': this.phoneNumber,
    'email': this.email,
    'dateOfBirth': this.dateOfBirth,
    'gender': this.gender,
    'country': this.country,
    'state': this.state,
    'street': this.street,
    'city': this.city,
    //'active': this.active,
    'profilePicture': '',
    'identityType': '',
    'identityNumber': '',
    'identityDocPhoto': '',
    'identityStatus': '',
  };

  Map<String, String> toCommonDetailsJson() =>  <String, String>{
    'Name': this.firstName + ' '+ this.lastName,
    'Phone': this.phoneNumber,
    'Email': this.email,
    'DOB': this.dateOfBirth,
    'Gender': this.gender
  };
  Map<String, String> toAddressDetailsJson() =>  <String, String>{
    'Street': this.street,
    'State': this.state,
    'Country': this.country,
  };
  Map<String, String> toIdentityDetailsJson() =>  <String, String>{
    'Document': this.identityType,
    this.identityType : this.identityNumber,
    'Status': this.identityStatus,
  };

  LatLng? getUserLatLng() {
    if(userLatLng == null){
      return null;
    }

    if(userLatLng!.isEmpty || !userLatLng!.contains(',')){
      return null;
    }

    List<String> latLng = userLatLng!.split(",");

    return LatLng(double.parse(latLng[0]), double.parse(latLng[1]));
  }

  @override
  String toString() {
    return 'ProfileDetailsResponse{role: $role, firstName: $firstName, lastName: $lastName'
        ', phoneNumber: $phoneNumber, email: $email, dateOfBirth: $dateOfBirth'
        ', gender: $gender, country: $country, state: $state'
        ', street: $street, active: $active, profilePicture: ${profilePicture.length}, identityType: $identityType'
        ', identityNumber: $identityNumber, identityDocPhoto: $identityDocPhoto'
        ', identityStatus: $identityStatus}}';
  }
}