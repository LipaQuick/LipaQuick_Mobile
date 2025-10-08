import 'dart:convert';

import 'package:intl/intl.dart';
import 'package:lipa_quick/core/crypto/encryption.dart';
import 'package:lipa_quick/core/models/password_login.dart';

class ResetPasswordRequest {
  String? phoneNumber, newPassword, confirmPassword;

  ResetPasswordRequest(
      {this.phoneNumber, this.newPassword, this.confirmPassword}) {
    var dateTime = DateFormat('dd/MM/yyyy HH:mm:ss').format(DateTime.now());
    newPassword = encryptAESCryptoJS(jsonEncode(PasswordDto(newPassword!
        , dateTime)));
    confirmPassword = encryptAESCryptoJS(jsonEncode(PasswordDto(confirmPassword!
        , dateTime)));
  }

  ResetPasswordRequest.fromJson(Map<String, dynamic> json) {
    phoneNumber = json['phoneNumber'];
    newPassword = json['password'];
    confirmPassword = json['confirmPassword'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['phoneNumber'] = phoneNumber;
    data['password'] = newPassword;
    data['confirmPassword'] = confirmPassword;
    return data;
  }
}