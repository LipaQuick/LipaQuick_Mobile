import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lipa_quick/core/models/chats/recent_chat/recent_chat_response.dart';
import 'package:lipa_quick/core/services/local_shared_pref.dart';
import 'package:lipa_quick/ui/views/chat/chat_page/user_chat_page.dart';
import 'package:lipa_quick/main.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _localNotificationsPlugin =
  FlutterLocalNotificationsPlugin();
  static final StreamController<String?> _selectNotificationStream =
  StreamController<String?>.broadcast();

  static const String _navigationActionId = 'id_3';

  static String? fcmToken;

  static Future<void> initialize() async {
    // Initialize Firebase
    await Firebase.initializeApp();

    //Initialize Firebase Token;
    getDeviceTokenToSendNotification();

    // Setup local notifications
    _initializeLocalNotifications();

    // Request notification permissions
    await FirebaseMessaging.instance.requestPermission();

    // Background message handler
    FirebaseMessaging.onBackgroundMessage(_backgroundHandler);

    // Listen for messages when the app is in different states
    _setupMessageHandlers();
  }

  static void _initializeLocalNotifications() async {
    final AndroidInitializationSettings androidSettings =
    AndroidInitializationSettings('@drawable/ic_notification');

    final DarwinInitializationSettings iOSSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
      notificationCategories: _getiOSNotificationCategories(),
    );

    final InitializationSettings initializationSettings = InitializationSettings(
      android: androidSettings,
      iOS: iOSSettings,
    );

    final AndroidFlutterLocalNotificationsPlugin? androidPlugin =
    flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    AndroidNotificationChannel channel = const AndroidNotificationChannel('lipaquick_rw_id'
        , 'lipaquick_notification_channel', importance: Importance.max);

    await androidPlugin?.createNotificationChannel(channel);

    await _localNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationResponse,
      onDidReceiveBackgroundNotificationResponse: _onNotificationResponse
    );
  }

  static Future<void> _backgroundHandler(RemoteMessage message) async {
    debugPrint("Handling background message: ${message.data}");
    _processNotification(message);
  }

  static void _setupMessageHandlers() {
    FirebaseMessaging.instance.getInitialMessage().then((message) {
      if (message != null) _processNotification(message);
    });

    FirebaseMessaging.onMessage.listen((message) async {
      if (message.notification != null) {
        _showLocalNotification(message);
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      _processNotification(message);
    });
  }

  static List<DarwinNotificationCategory> _getiOSNotificationCategories() {
    return [
      DarwinNotificationCategory(
        'textCategory',
        actions: [
          DarwinNotificationAction.text('text_1', 'Reply', buttonTitle: 'Send', placeholder: 'Type here'),
        ],
      ),
      DarwinNotificationCategory(
        'plainCategory',
        actions: [
          DarwinNotificationAction.plain('id_1', 'Open App'),
          DarwinNotificationAction.plain('id_2', 'Dismiss'),
        ],
        options: {DarwinNotificationCategoryOption.hiddenPreviewShowTitle},
      ),
    ];
  }

  static void _onNotificationResponse(NotificationResponse response) async {
    // if (response.notificationResponseType == NotificationResponseType.selectedNotification ||
    //     response.actionId == _navigationActionId) {
    //   _selectNotificationStream.add(response.payload);
    // }
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    var isLoggedIn = prefs.getBool('login') ?? false;

    if (!isLoggedIn) {
      debugPrint("Notification ignored as the user is not logged in.");
      return;
    }

    debugPrint('Notification tapped: ${response.payload}');
    if (response.payload != null) {
      // Create a dummy RemoteMessage from the payload for consistent processing
      final Map<String, dynamic> payloadData = {
        'data': response.payload,
      };

      final RemoteMessage message = RemoteMessage.fromMap(payloadData);

      // Process the notification
      await _processNotification(message);
    }
  }

  // Future<String> getFcmToken() async {
  //   fcmToken = await FirebaseMessaging.instance.getToken();
  //   debugPrint("FCM Token: $fcmToken");
  //   LocalSharedPref().setFcmToken(fcmToken ?? '');
  //   return fcmToken!;
  // }

  static Future<String> getDeviceTokenToSendNotification() async {
    if(Platform.isIOS){
      String? apnsToken = await FirebaseMessaging.instance.getAPNSToken();
      if (apnsToken != null) {
        fcmToken = (await FirebaseMessaging.instance.getToken()).toString();
      } else {
        await Future<void>.delayed(
          const Duration(
            seconds: 3,
          ),
        );
        apnsToken = await FirebaseMessaging.instance.getAPNSToken();
        if (apnsToken != null) {
          fcmToken = (await FirebaseMessaging.instance.getToken()).toString();
        }
      }
    }else{
      fcmToken = (await FirebaseMessaging.instance.getToken()).toString();
    }
    print("FCM Token: $fcmToken");
    LocalSharedPref().setFcmToken(fcmToken!);
    return fcmToken!;
  }

  static Future<void> _showLocalNotification(RemoteMessage message) async {

    AndroidNotificationChannel channel = const AndroidNotificationChannel('lipaquick_rw_id'
        , 'lipaquick_notification_channel', importance: Importance.max);

    final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      channel.id,
      channel.name,
      channelDescription: 'This show application notification',
      importance: Importance.max,
      priority: Priority.high,
    );


    const DarwinNotificationDetails iosNotificationDetails =
    DarwinNotificationDetails(
      presentAlert: true, // Display an alert
      presentBadge: true, // Update the app badge
      presentSound: true, // Play a sound
    );

    NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosNotificationDetails,
    );


    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool('login') ?? false;

    if(!isLoggedIn){
      return;
    }

    if(Platform.isAndroid){
      await _localNotificationsPlugin.show(
        Random().nextInt(100000),
        message.notification!.title,
        message.notification!.body,
        notificationDetails,
        payload: message.data['payload'],
      );
    }

  }

  static Future<void> _processNotification(RemoteMessage message) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    var isLoggedIn = prefs.getBool('login') ?? false;

    if (!isLoggedIn) {
      debugPrint("Notification ignored as the user is not logged in.");
      return;
    }

    debugPrint("Processing notification:");
    debugPrint(message.toMap().toString());

    // Check for message type or other keys in the payload
    if (message.data['messageType'].toString().toLowerCase() == 'chat') {
      String currentActiveChat =
      await LocalSharedPref().getCurrentChatReceiversId();

      debugPrint('Checking Active Chat $currentActiveChat');


      //message.data.remove('messageType');
      RecentChats chats = RecentChats.fromRemoteNotificationJson(message.data);

      debugPrint('Checking Ids Chat $currentActiveChat ==> ${chats.toJson()}');

      if (currentActiveChat.isEmpty ) {
        debugPrint('Opening Chat Activity');
        WidgetsBinding.instance.addPostFrameCallback((_) {
          debugPrint('Reached Post Frame Callback');
          Navigator.of(GlobalVariable.navState.currentContext!).push(
            MaterialPageRoute(
              builder: (context) => UserChatPage(recentChats: chats),
            ),
          );
        });
      }else if(currentActiveChat != chats.receiverId){
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.of(GlobalVariable.navState.currentContext!).push(
            MaterialPageRoute(
              builder: (context) => UserChatPage(recentChats: chats),
            ),
          );
        });
      }else{
        debugPrint("Chat is Active");
      }
    } else {
      // Add more processing for other notification types
      debugPrint("Unhandled notification type.");
    }
  }

}
