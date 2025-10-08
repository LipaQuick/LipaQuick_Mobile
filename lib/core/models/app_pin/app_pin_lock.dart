import 'package:floor/floor.dart';
import 'package:flutter/foundation.dart';

@entity
class AppLockPin {
  @primaryKey
  final String id;
  final String username;
  final String pinHash;
  bool isAppLockEnabled;

  AppLockPin({
    required this.id,
    required this.username,
    required this.pinHash,
    this.isAppLockEnabled = false,
  });

  AppLockPin copyWith({bool? isAppLockEnabled}) {
    var appLock = AppLockPin(
      id: id,
      username: username,
      pinHash: pinHash,
      isAppLockEnabled: isAppLockEnabled ?? this.isAppLockEnabled,
    );
    print("Copying Continue ${appLock.toString()}");
    return appLock;
  }

  AppLockPin copyWithPin({required String newPinhash}) {
    return AppLockPin(
      id: id,
      username: username,
      pinHash: newPinhash,
      isAppLockEnabled: isAppLockEnabled,
    );
  }

  // Method to check if the entered PIN matches the stored PIN hash
  bool isValidPin(String enteredPin) {
    // Logic to hash enteredPin and compare it with this.pinHash
    return true; // Return true if matched, false otherwise
  }

  @override
  String toString() {
    return 'AppLockPin{id: $id, username: $username, pinHash: $pinHash, isAppLockEnabled: $isAppLockEnabled}';
  }
}
