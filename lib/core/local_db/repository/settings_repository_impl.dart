import 'package:lipa_quick/core/local_db/database/database.dart';
import 'package:lipa_quick/core/local_db/repository/local_settings_repository.dart';
import 'package:lipa_quick/core/local_db/repository/payment_method_repository.dart';
import 'package:lipa_quick/core/models/payment/user_payment_methods.dart';
import 'package:lipa_quick/core/models/settings/UserSettings.dart';
import 'package:lipa_quick/core/provider/DBProvider.dart';
import 'package:lipa_quick/main.dart';

class AppSettingsRepositoryImpl extends AppSettingsRepository{
  late AppDatabase appDatabase;

  AppSettingsRepositoryImpl(){
    initDb();
  }

  initDb() async {
    appDatabase = await locator<DBProvider>().database;
    //locator.signalReady(this);
  }

  @override
  Future<AppSettings?> getAllUserSettings() {
    return appDatabase.appSettingsDao.getCurrentSettings();
  }

  @override
  Future<void> insertUserSetting(AppSettings contact) {
    return appDatabase.appSettingsDao.insertSetting(contact);
  }

  @override
  Future<void> updateUserSetting(AppSettings contact) {
    return appDatabase.appSettingsDao.updateSetting(contact);
  }

  @override
  Future<AppSettings?> checkUserPin(String userId){
    return appDatabase.appSettingsDao.checkUserPin(userId);
  }
}