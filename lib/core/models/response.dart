import 'package:flutter_chat_types/flutter_chat_types.dart';
import 'package:json_annotation/json_annotation.dart';

part 'response.g.dart';

@JsonSerializable()
class ApiResponse {
  @JsonKey(name: 'message', defaultValue: '')
  String? message;
  @JsonKey(name: 'status', defaultValue: false)
  bool? status;
  @JsonKey(name: 'errors', defaultValue: [])
  List<String>? errors;

  ApiResponse();


  ApiResponse.error(this.message, this.status, this.errors);

  factory ApiResponse.fromJson(Map<String, dynamic> json) =>
      _$ApiResponseFromJson(json);

  Map<String, dynamic> toJson() => _$ApiResponseToJson(this);
}

class PaymentApiResponse {
  bool? status;
  String? title;
  String? message;
  List<String>? errors;


  PaymentApiResponse(this.status, this.title, this.message, this.errors);

  factory PaymentApiResponse.fromJson(Map<String, dynamic> json) {
    return PaymentApiResponse(
      json['status'] ?? false,
      json['title'] ?? '',
      json['message'] ?? '',
      (json['errors'] as List<dynamic>? ?? []).cast<String>()
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'status': status,
    'title': title,
    'message': message,
    'errors': errors,
  };

}

@JsonSerializable()
class RegisterApiResponse extends ApiResponse {
  RegisterApiResponse();

  factory RegisterApiResponse.fromJson(Map<String, dynamic> json) =>
      _$RegisterApiResponseFromJson(json);

  Map<String, dynamic> toJson() => _$RegisterApiResponseToJson(this);
}

@JsonSerializable()
class LoginApiResponse {
  @JsonKey(name: 'message', defaultValue: '')
  String? message;
  @JsonKey(name: 'status', defaultValue: false)
  bool? status;
  @JsonKey(name: "access_token", defaultValue: '')
  String access_token = "";
  @JsonKey(name: "refresh_token", defaultValue: '')
  String refreshToken = "";
  @JsonKey(name: "data", defaultValue: '', includeToJson: true, includeFromJson: false)
  UserDetails? userData;

  LoginApiResponse();

  factory LoginApiResponse.fromJson(Map<String, dynamic> json) =>
      LoginApiResponse()
        ..message = json['message'] ?? ''
        ..status = json['status'] ?? false
        ..access_token = json['access_token']  ?? ''
        ..refreshToken = json['refresh_token'] ?? ''
        ..userData = (json['data'] == null
            ? UserDetails.initial()
            : UserDetails.fromJson(json['data'] as Map<String, dynamic>));

  Map<String, dynamic> toJson() => _$LoginApiResponseToJson(this);
}

class UserDetails {
  String id;
  String role;
  String firstName;
  String lastName;
  String email;
  String phoneNumber;
  String inviteCode;
  String profilePicture;
  bool emailConfirmed;
  bool phoneNumberConfirmed;
  bool twoFactorEnabled;
  bool active;

  UserDetails(
      this.id,
      this.role,
      this.firstName,
      this.lastName,
      this.email,
      this.phoneNumber,
      this.inviteCode,
      this.profilePicture,
      this.emailConfirmed,
      this.phoneNumberConfirmed,
      this.twoFactorEnabled,
      this.active
      );

  UserDetails.initial()
      : firstName = '',
        lastName = '',
        id = '',
        role = '',
        email = '',
        phoneNumber = '',
        inviteCode = '',
        profilePicture = '',
        emailConfirmed = false,
        phoneNumberConfirmed = false,
        twoFactorEnabled = false,
        active = false;

  String getProfilePictureLogo(){
    var base64Image = profilePicture.split(",");
    return base64Image.last;
  }

  User toUser(){
    return User(id: id, firstName: firstName, lastName: lastName, imageUrl: '');
  }

  factory UserDetails.fromJson(Map<String, dynamic> json) {
    return UserDetails(
      json['id'] ?? '',
      json['role'] ?? '',
      json['firstName'] ?? '',
      json['lastName'] ?? '',
      json['email'] ?? '',
      json['phoneNumber'] ?? '',
      json['inviteCode'] ?? '',
      '',
      json['emailConfirmed'] ??  false,
      json['phoneNumberConfirmed'] ?? false,
      json['twoFactorEnabled'] ?? false,
      json['active'] ?? false
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'firstName': firstName,
        'role': role,
        'lastName': lastName,
        'email': email,
        'phoneNumber': phoneNumber,
        'profilePicture': profilePicture,
        'inviteCode': inviteCode ?? '',
        'phoneNumberConfirmed': phoneNumberConfirmed ?? false,
        'emailConfirmed': emailConfirmed,
        'twoFactorEnabled': twoFactorEnabled,
        'active': active
      };

  @override
  String toString() {
    return 'UserDetails{id: $id,firstName: $firstName, lastName: $lastName, email: $email, phoneNumber: $phoneNumber, inviteCode: $inviteCode, emailConfirmed: $emailConfirmed, phoneNumberConfirmed: $phoneNumberConfirmed}';
  }
}
