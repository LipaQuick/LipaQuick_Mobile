import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

@JsonSerializable()
class UserDetailsModel {
  String id;
  String firstName;
  String lastName;
  String email;
  String phoneNumber;
  String dateOfBirth;
  String gender;
  String idNumber;
  String idType;
  String password;
  String? confirmPassword;
  String address;
  String location;
  String street;
  String city;
  String state;
  String country;
  String? inviteCode;
  String profilePicture;
  bool? emailConfirmed;
  bool? phoneNumberConfirmed;

  UserDetailsModel({required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phoneNumber,
    required this.dateOfBirth,
    required this.gender,
    required this.idNumber,
    required this.idType,
    required this.password,
    required this.address,
    required this.location,
    required this.profilePicture,
    required this.street,
    required this.city,
    required this.state,
    required this.country
    });

  UserDetailsModel.initial()
      : id = "0",
        firstName = '',
        lastName = '',
        email = '',
        phoneNumber = '',
        dateOfBirth = '',
        gender = '',
        idNumber = '',
        idType = '',
        password = '',
        address = '',
        location = '',
        profilePicture= '',
        street= '',
        city= '',
        state= '',
        country= '',
        inviteCode = '',
        emailConfirmed = false,
        phoneNumberConfirmed = false
        ;

  String getLogo(){
    var base64Image = profilePicture.split(",");
    return base64Image.last;
  }

  void setConfirmPassword(String value){
    confirmPassword = value;
  }

  factory UserDetailsModel.fromJson(Map<String, dynamic> json) =>
      _$UserDetailsModelFromJson(json);

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'firstName': firstName,
    'lastName': lastName,
    'email': email,
    'phoneNumber': phoneNumber,
    'dateOfBirth': dateOfBirth,
    'gender': gender,
    'identityNumber': idNumber,
    'identityType': idType,
    'password': password,
    'address': address,
    'location': location,
    'profilePicture': profilePicture,
    'street': street,
    'city': city,
    'state': state,
    'country': country,
    'confirmPassword': confirmPassword != null ? confirmPassword! : '',
    'inviteCode': inviteCode != null ? inviteCode! : '',
    'phoneNumberConfirmed': phoneNumberConfirmed != null ? phoneNumberConfirmed! : false,
    'emailConfirmed': emailConfirmed != null ? emailConfirmed! : false
  };
}
