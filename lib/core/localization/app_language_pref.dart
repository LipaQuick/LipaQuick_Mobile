import 'dart:async';
import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../view_models/base_viewmodel.dart';

class AppLanguage extends BaseModel {
  Locale? _appLocale = const Locale('en');

  Locale get appLocal => _appLocale ?? const Locale("en");

  Future<Locale?> fetchLocale() async {
    var prefs = await SharedPreferences.getInstance();
    final Completer<Locale> completer =
    Completer<Locale>();
    if (prefs.getString('language') == null) {
      // print('Null Preference, Loading Default EN');
      _appLocale = const Locale('en');
      completer.complete(_appLocale);
    }
    _appLocale = Locale(prefs.getString('language')!);
    completer.complete(_appLocale);
    return completer.future;
  }

  void changeLanguage(Locale type) async {
    var prefs = await SharedPreferences.getInstance();
    if (_appLocale == type) {
      return;
    }
    if (type == const Locale("fr")) {
      _appLocale = const Locale("fr");
      await prefs.setString('language', 'fr');
    } else {
      _appLocale = const Locale("en");
      await prefs.setString('language', 'en');
    }
    notifyListeners();
  }
}
