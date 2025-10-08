import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:encrypt/encrypt.dart';

const String _KEY = 'G-KaNdRgOfXp2s5v8y/B?E(H+MbQeShV';

String encryptAESCryptoJS(String plainText) {
  try {
    final key = Key.fromUtf8(_KEY);
    final iv = IV.fromLength(16);

    final encrypter = Encrypter(AES(key, mode: AESMode.cbc));
    return encrypter.encrypt(plainText, iv: iv).base64;
  } catch (error) {
    throw error;
  }
}

String decryptAESCryptoJS(String encrypted) {
  try {
    final key = Key.fromUtf8(_KEY);
    final iv = IV.fromLength(16);

    final encrypter = Encrypter(AES(key, mode: AESMode.cbc));
    // String data = base64.decode().toString();
    return encrypter.decrypt(Encrypted.fromBase64(encrypted), iv: iv).toString();
  } catch (error) {
    throw error;
  }
}
