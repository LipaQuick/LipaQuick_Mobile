import 'package:lipa_quick/core/models/payment/user_payment_methods.dart';
import 'package:lipa_quick/core/models/settings/UserSettings.dart';

abstract class AppSettingsRepository{
  Future<AppSettings?> getAllUserSettings();

  Future<void> insertUserSetting(AppSettings contact);

  Future<void> updateUserSetting(AppSettings contact);

  Future<AppSettings?> checkUserPin(String userId);
}