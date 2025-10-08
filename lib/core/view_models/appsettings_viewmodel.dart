import 'dart:async';
import 'dart:convert';

import 'package:intl/intl.dart';
import 'package:lipa_quick/core/local_db/repository/settings_repository_impl.dart';
import 'package:lipa_quick/core/models/api_exception/api_exception.dart';
import 'package:lipa_quick/core/models/payment/recent_transaction.dart';
import 'package:lipa_quick/core/models/response.dart';
import 'package:lipa_quick/core/models/settings/UserSettings.dart';
import 'package:lipa_quick/core/services/api.dart';
import 'package:lipa_quick/core/view_models/base_viewmodel.dart';
import 'package:lipa_quick/main.dart';
import 'package:lipa_quick/main.dart';
import 'package:uuid/uuid.dart';

import '../services/local_shared_pref.dart';


class AppSettingsViewModel extends BaseModel{
  final Api _api = locator<Api>();
  final AppSettingsRepositoryImpl appSettingsRepo = locator<AppSettingsRepositoryImpl>();

  Future<AppSettings?> getAppSettings(){
    return appSettingsRepo.getAllUserSettings();
  }

  Future<void> enableUserLock(String twoFactorPin) async {
    String userDetails = "";
    userDetails = await LocalSharedPref().getUserDetails();
    var currentUserDetails = UserDetails.fromJson(jsonDecode(userDetails));
    AppSettings appSettings = AppSettings(
        id: Uuid().v4(),
        userId: currentUserDetails.id,
        settingsTitle: 'Enable App Lock',
        twoFactorPin: twoFactorPin, settingsValue: true);
    var isPinCreated = await checkPin(currentUserDetails.id);
    if(!isPinCreated) {
      await _api.enableTwoFactorAuthentication(currentUserDetails.id, true);
      return appSettingsRepo.updateUserSetting(appSettings);
    }else{
      return appSettingsRepo.insertUserSetting(appSettings);
    }
  }

  Future<bool> checkPin(String userId) async {
    final Completer<bool> completer = Completer<bool>();
    AppSettings? data = await appSettingsRepo.checkUserPin(userId);
    completer.complete(data==null);
    return completer.future;
  }
  Future<void> enableLocalTwoFactor(bool enable) async {
    await LocalSharedPref().setTwoFactor(enable);
  }
}