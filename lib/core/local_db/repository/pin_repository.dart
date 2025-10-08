import 'dart:async';

import 'package:lipa_quick/core/local_db/database/database.dart';
import 'package:lipa_quick/core/provider/DBProvider.dart';
import 'package:lipa_quick/main.dart';

import '../../models/app_pin/app_pin_lock.dart';

abstract class AppPinImpl{
  Future<List<AppLockPin?>> getAppLockPins();

  Future<void> insertAppLock(AppLockPin appLockPin);

  Future<List<AppLockPin?>> getUserPin(String userId);

  Future<void> updateAppLock(AppLockPin appLockPin);
}

class AppPinRepository
   extends AppPinImpl
{
  late AppDatabase appDatabase;

  AppPinRepository(){
    initDb();
  }

  initDb() async {
    appDatabase = await locator<DBProvider>().database;
    //locator.signalReady(this);
  }

  @override
  Future<void> insertAppLock(AppLockPin appLockPin) {
    return appDatabase.appLockDao.insertAppLock(appLockPin);
  }

  @override
  Future<List<AppLockPin?>> getAppLockPins() {
    try{
      return appDatabase.appLockDao.getAppLockPins();
    }catch(e){
      final Completer<List<AppLockPin?>> completer =
      Completer<List<AppLockPin?>>();
      completer.complete(List.empty());
      return completer.future;
    }

  }

  @override
  Future<List<AppLockPin?>> getUserPin(String userId) {
    return appDatabase.appLockDao.getUserPin(userId);
  }

  @override
  Future<void> updateAppLock(AppLockPin appLockPin) {
    return appDatabase.appLockDao.updateAppLock(appLockPin);
  }
}