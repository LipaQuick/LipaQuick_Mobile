import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:lipa_quick/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguagePreference{
  static const String prefSelectedLanguageCode = "SelectedLanguageCode";

  Future<Locale> setLocale(String languageCode) async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    await _prefs.setString(prefSelectedLanguageCode, languageCode);
    return _locale(languageCode);
  }

  static Future<Locale> getLocale() async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    String languageCode = _prefs.getString(prefSelectedLanguageCode) ?? "en";
    return _locale(languageCode);
  }

  Future<Locale> getLocales() async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    String languageCode = _prefs.getString(prefSelectedLanguageCode) ?? "en";
    return _locale(languageCode);
  }

  static Locale _locale(String languageCode) {
    return languageCode != null && languageCode.isNotEmpty
        ? Locale(languageCode, '')
        : Locale('en', '');
  }
}