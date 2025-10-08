import 'package:firebase_messaging/firebase_messaging.dart';

class FirebaseMessagingService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  Future<void> setupFirebase() async {
    // Initialize Firebase Messaging
    _firebaseMessaging.getToken().then((token) {
      print("Firebase Messaging Token: $token");
    });

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("onMessage: ${message.notification?.body}");
      // Handle the message here
    });

    // Handle messages opened from the system tray or terminated state
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print("onMessageOpenedApp: ${message.notification?.body}");
      // Handle the message here
    });

    // Handle background messages (requires platform-specific setup)
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Request permission for iOS (optional)
    await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  // This is the background message handler (platform-specific)
  Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    print("Handling background message: ${message.notification?.body}");
    // Handle the background message here
  }
}