import 'package:json_annotation/json_annotation.dart';
part 'requests.g.dart';
@JsonSerializable()
class LoginRequest {
  @JsonKey(name: 'userName')
  String username;
  @JsonKey(name: 'password')
  String password;

  LoginRequest(this.username, this.password);

  factory LoginRequest.fromJson(Map<String, dynamic> json) => _$LoginRequestFromJson(json);

  Map<String, dynamic> toJson() => _$LoginRequestToJson(this);

}