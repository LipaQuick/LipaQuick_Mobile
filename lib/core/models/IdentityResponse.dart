import 'package:image_picker/image_picker.dart';
import 'package:json_annotation/json_annotation.dart';

@JsonSerializable()
class IdentityResponse {
  bool? status;
  String? message;
  List<IdentityDetails>? data;

  IdentityResponse({this.status,this.message, this.data});

  IdentityResponse.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    if (json['data'] != null) {
      data = <IdentityDetails>[];
      json['data'].forEach((v) {
        data!.add(IdentityDetails.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

@JsonSerializable()
class IdentityDetails {
  String? id;
  String? name;
  String? description;
  int? maxLength;
  bool? alphaNumeric;
  String? regex;
  @JsonKey(ignore: true)
  XFile? identityPhoto;

  IdentityDetails({this.id, this.name, this.description, this.maxLength, this.alphaNumeric, this.regex});

  void setIdentityPhoto(XFile identityPhoto){
    this.identityPhoto = identityPhoto;
  }

  IdentityDetails.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    description = json['description'];
    maxLength = json['maxLength'];
    alphaNumeric = json['alphaNumeric'];
    regex = json['regex'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    return data;
  }
}