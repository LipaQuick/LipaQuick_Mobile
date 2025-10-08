import 'package:floor/floor.dart';

@entity
class AppSettings {
  @primaryKey
  String userId;
  String id;
  String settingsTitle;
  bool settingsValue;
  String twoFactorPin;

  AppSettings({
    required this.id,
    required this.userId,
    required this.settingsTitle,
    required this.twoFactorPin,
    required this.settingsValue,
  });

  // Factory method to create an instance from a JSON object
  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      settingsTitle: json['settingsTitle'] ?? '',
      twoFactorPin: json['twoFactorPin'] ?? '',
      settingsValue: json['enableNotification'] ?? false,
    );
  }

  // Method to convert the object to a JSON object
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'settingsTitle': settingsTitle,
      'twoFactorPin': twoFactorPin,
      'enableNotification': settingsValue,
    };
  }
}
