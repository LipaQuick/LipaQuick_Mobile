import 'package:json_annotation/json_annotation.dart';
import 'package:lipa_quick/core/models/profile/profile_details_response.dart';

@JsonSerializable()
class ProfileListResponse{
  bool? status;
  @JsonKey(name: 'message')
  String? errorMessage;
  @JsonKey(name: 'data')
  ProfileDetailsResponse? profileDetails;

  ProfileListResponse({this.status,this.errorMessage, this.profileDetails});

  factory ProfileListResponse.fromJson(Map<String, dynamic> json) => ProfileListResponse()
    ..errorMessage = json['message'] ?? ''
    ..status = json['status'] ?? false
    ..profileDetails = (json['data'] == null
        ? ProfileDetailsResponse.init()
        : ProfileDetailsResponse.fromJson(json['data'] as Map<String, dynamic>));



}
