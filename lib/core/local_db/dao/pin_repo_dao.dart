import 'package:floor/floor.dart';

import '../../models/app_pin/app_pin_lock.dart';

@dao
abstract class AppPinsDao{
  @Query('Select * from AppLockPin')
  Future<List<AppLockPin>> getAppLockPins();

  @Insert(onConflict: OnConflictStrategy.replace)
  Future<void> insertAppLock(AppLockPin appLockPin);

  @Query('Select * from AppLockPin where id LIKE :userId')
  Future<List<AppLockPin?>> getUserPin(String userId);

  @Update()
  Future<void> updateAppLock(AppLockPin appLockPin);
}