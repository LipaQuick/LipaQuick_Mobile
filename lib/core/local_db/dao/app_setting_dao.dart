import 'package:floor/floor.dart';
import 'package:lipa_quick/core/models/settings/UserSettings.dart';

@dao
abstract class AppSettingsDao{
  @Query('Select TOP 1 from AppSettings')
  Future<AppSettings?> getCurrentSettings();

  @insert
  Future<void> insertSetting(AppSettings appSettings);

  @Query('Select TOP 1 from AppSettings where userId = :userId')
  Future<AppSettings?> checkUserPin(String userId);

  @Insert(onConflict: OnConflictStrategy.replace)
  Future<void> insertSettings(List<AppSettings> appSettings);

  @Update()
  Future<void> updateSetting(AppSettings appSettings);
}