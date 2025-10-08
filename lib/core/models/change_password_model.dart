import 'dart:convert';

import 'package:intl/intl.dart';
import 'package:lipa_quick/core/crypto/encryption.dart';
import 'package:lipa_quick/core/models/password_login.dart';

class ChangePasswordRequest {
  String? currentPassword, newPassword, confirmPassword;

  ChangePasswordRequest({this.currentPassword,this.newPassword, this.confirmPassword}){
    var dateTime = DateFormat('dd/MM/yyyy HH:mm:ss').format(DateTime.now());
    currentPassword = encryptAESCryptoJS(jsonEncode(PasswordDto(currentPassword!
        , dateTime)));
    newPassword = encryptAESCryptoJS(jsonEncode(PasswordDto(newPassword!
        , dateTime)));
    confirmPassword = encryptAESCryptoJS(jsonEncode(PasswordDto(confirmPassword!
        , dateTime)));
  }

  ChangePasswordRequest.fromJson(Map<String, dynamic> json) {
    currentPassword = json['currentPassword'];
    newPassword = json['newPassword'];
    confirmPassword = json['confirmPassword'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['currentPassword'] = currentPassword;
    data['newPassword'] = newPassword;
    data['confirmPassword'] = confirmPassword;
    return data;
  }

  Map<String, dynamic> toForgotPasswordJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['phoneNumber'] = currentPassword;
    data['password'] = newPassword;
    data['confirmPassword'] = confirmPassword;
    return data;
  }
}

class ChangePasswordResponse {
  bool? status;
  String? message;

  ChangePasswordResponse({this.status,this.message});

  ChangePasswordResponse.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    data['message'] = message;
    return data;
  }
}