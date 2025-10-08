import 'package:json_annotation/json_annotation.dart';

class FileUploadResponse {
  bool? status;
  String? message;
  FileUploadData? data;
  @JsonKey(name: 'errors', defaultValue: [])
  List<String>? errors;

  FileUploadResponse({this.status, this.message, this.data, this.errors});

  // RecentChatResponse({this.status, this.message,this.total});

  factory FileUploadResponse.fromJson(Map<String, dynamic> json) {
    return FileUploadResponse(
      status: json['status'],
      message: json['message'],
      data: json['data']!=null?FileUploadData.fromJson(json['data']):null,
      errors: (json['errors'] as List<dynamic>? ?? []).cast<String>()
    );
  }
}

class FileUploadData {
  String? type;
  String? message;
  String? file;

  FileUploadData({this.type, this.message, this.file});

  factory FileUploadData.fromJson(Map<String, dynamic> json) {
    return FileUploadData(
      type: json['type'],
      message: json['message'],
      file: json['file'],
    );
  }
}
