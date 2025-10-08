import 'package:json_annotation/json_annotation.dart';
import 'package:lipa_quick/core/models/profile/profile_details_response.dart';

@JsonSerializable()
class UserDetailsApiResponse{
  bool? status;
  @JsonKey(name: 'message')
  String? errorMessage;
  @JsonKey(name: 'data')
  ProfileDetailsResponse? profileDetails;

  UserDetailsApiResponse({this.status,this.errorMessage, this.profileDetails});

  factory UserDetailsApiResponse.fromJson(Map<String, dynamic> json) => UserDetailsApiResponse()
    ..errorMessage = json['message'] ?? ''
    ..status = json['status'] ?? false
    ..profileDetails = (json['data'] == null
        ? ProfileDetailsResponse.init()
        : ProfileDetailsResponse.fromJson(json['data'] as Map<String, dynamic>));


}

