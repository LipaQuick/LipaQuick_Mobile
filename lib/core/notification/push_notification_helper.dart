import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:lipa_quick/core/models/chats/recent_chat/recent_chat_response.dart';
import 'package:lipa_quick/core/services/local_shared_pref.dart';
import 'package:lipa_quick/main.dart';
import 'package:lipa_quick/ui/views/chat/chat_page/user_chat_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> backgroundHandler(RemoteMessage message) async {
  debugPrint("backgroundHandler:");
  debugPrint(message.data.toString());
  debugPrint(message.notification?.title ?? "");

  openNotification(message);
}

class PushNotificationHelper {
  static String fcmToken = "";
  static Future<void> initialized() async {
    await Firebase.initializeApp();

    if (Platform.isAndroid) {
      // Local Notification Initalized
      NotificationHelper.initialized();
      await FirebaseMessaging.instance.requestPermission();
    } else if (Platform.isIOS) {
      await FirebaseMessaging.instance.requestPermission();
    }
    FirebaseMessaging.onBackgroundMessage(backgroundHandler);

    getDeviceTokenToSendNotification();

    //Take Token Updates
    //FirebaseMessaging.instance.onTokenRefresh

    // If App is Terminated state & used click notification
    FirebaseMessaging.instance.getInitialMessage().then((message) {
      debugPrint("FirebaseMessaging.instance.getInitialMessage");

      if (message != null) {
        debugPrint("New Notification");
        debugPrint(message.data.toString());
        debugPrint(message.notification?.title ?? "");
      }
    });

    // App is Forground this method  work
    FirebaseMessaging.onMessage.listen((message) async {
      debugPrint("FirebaseMessaging.onMessage.listen");
      if (message.notification != null) {
        debugPrint(message.notification!.title);
        debugPrint(message.notification!.body);


        final SharedPreferences prefs = await SharedPreferences.getInstance();
        var isLoggedIn = prefs.getBool('login') ?? false;
        debugPrint('Logged In :$isLoggedIn');
        //debugPrint(message.data);

        if (Platform.isAndroid && isLoggedIn) {
          // Local Notification Code to Display Alert
          NotificationHelper.displayNotification(message);
        }
      }
    });

    // App on Backaground not Terminated
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      print("FirebaseMessaging.onMessageOpenedApp.listen");
      if (message.notification != null) {
        print(message.notification!.title);
        print(message.notification!.body);
        print(message.data);

        //openNotification(message);
      }
    });

    FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
        alert: true, badge: true, sound: true);
  }

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
    LocalSharedPref().setFcmToken(fcmToken);
    return fcmToken;
  }
}

class NotificationHelper {
  static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static void initialized() {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@drawable/ic_notification');
    const DarwinInitializationSettings darwinInitializationSettings =
    DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );



    flutterLocalNotificationsPlugin.initialize(
        const InitializationSettings(android: initializationSettingsAndroid
            , iOS: darwinInitializationSettings),
        onDidReceiveNotificationResponse: (details) {
      print(details.toString());
      print("localBackgroundHandler :");
      print(details.notificationResponseType ==
              NotificationResponseType.selectedNotification
          ? "selectedNotification"
          : "selectedNotificationAction");
      print(details.payload);

      try {
        var payloadObj = json.decode(details.payload ?? "{}") as Map? ?? {};
        //openNotification(payloadObj);
      } catch (e) {
        print(e);
      }
    }, onDidReceiveBackgroundNotificationResponse: localBackgroundHandler);
  }

  static void displayNotification(RemoteMessage message) async {
    try {
      MessagingStyleInformation notificationStyle
          = MessagingStyleInformation(Person(name: message.notification!.title)
              , conversationTitle: message.notification!.body);

      AndroidNotificationChannel channel = const AndroidNotificationChannel(
        'high_importance_channel', // id
        'High Importance Notifications', // title
        description:
        'This channel is used for important notifications.', // description
        importance: Importance.high,

      );

      final id = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      var notificationDetails = NotificationDetails(
        android: AndroidNotificationDetails(
            channel.id, channel.name,
             styleInformation:  notificationStyle,
            fullScreenIntent: true,
            importance: Importance.high, priority: Priority.high, playSound: true
        ),
        iOS: const DarwinNotificationDetails(
            presentAlert: true
            , presentBadge: true
            , presentSound: true,
            categoryIdentifier: 'plainCategory')
      );

      await flutterLocalNotificationsPlugin.show(
          id,
          message.notification!.title,
          message.notification!.body,
          notificationDetails,
          payload: json.encode(message.data));
    } on Exception catch (e) {
      print(e);
    }
  }
}


Future<void> _showNotification(FlutterLocalNotificationsPlugin
    flutterLocalNotificationsPlugin, RemoteMessage message) async {
  const AndroidNotificationDetails androidNotificationDetails =
  AndroidNotificationDetails('LipaQuick', 'Lipa Quick Application Channel Name',
      channelDescription: 'To show application related notification',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker');
  const NotificationDetails notificationDetails =
  NotificationDetails(android: androidNotificationDetails);
  await flutterLocalNotificationsPlugin.show(
      Random().nextInt(9999).toString().padLeft(4, '0') as int
      , message.notification!.title, message.notification!.body, notificationDetails,
      payload: message.notification!.body);
}


Future<void> localBackgroundHandler(NotificationResponse data) async {
  print(data.toString());
  print("localBackgroundHandler :");
  print(data.notificationResponseType ==
          NotificationResponseType.selectedNotification
      ? "selectedNotification"
      : "selectedNotificationAction");
  print(data.payload);

  try {
    var payloadObj = json.decode(data.payload ?? "{}") as Map? ?? {};
    //openNotification(payloadObj);
  } catch (e) {
    print(e);
  }
}

void openNotification(RemoteMessage message) async {
  await Future.delayed(const Duration(milliseconds: 300));
  print(message.data.toString());

  if(message.data['messageType'].toString() == 'Chat'){
        String currentActiveChat = await LocalSharedPref().getCurrentChatReceiversId();
        message.data.remove('messageType');
        RecentChats chats = RecentChats.fromJson(message.data);
        if(currentActiveChat.isNotEmpty && currentActiveChat != chats.receiverId){
          WidgetsBinding.instance
            .addPersistentFrameCallback((_){
            Navigator.of(GlobalVariable.navState.currentContext!)
                .push(MaterialPageRoute(builder: (context) => UserChatPage(recentChats: chats)));
          });

        }
      }

  // if(payloadObj["user_login_need"].toString() == "true" ) {
  //   if(Globs.udValueBool(Globs.userLogin)) {
  //     // App inside user login
  //     if( payloadObj["user_id"].toString() == userPayload["user_id"].toString() ) {
  //       // Notification Payload Data user id current
  //       openNotificationScreen(payloadObj);
  //     }else{
  //       // Notification Payload Data user id not match
  //       print("skip open screen");
  //     }
  //   }else{
  //     // App inside not user login
  //     pushRedirect = true;
  //     pushPayload = payloadObj;
  //
  //   }
  // }else{
  //   //User not need
  //   openNotificationScreen(payloadObj);
  // }
  
}

void openNotificationScreen(Map payloadObj) {
  try {
    print(payloadObj.toString());
    // if (payloadObj.isNotEmpty) {
    //   switch (payloadObj["page"] as String? ?? "") {
    //     case "detail":
    //       navigatorKey.currentState?.push(MaterialPageRoute(
    //           builder: (context) => DetailView(nObj: payloadObj)));
    //       break;
    //     case "data":
    //       navigatorKey.currentState?.push(MaterialPageRoute(
    //           builder: (context) => DataView(nObj: payloadObj)));
    //       break;
    //     default:
    //   }
    // }
  } catch (e) {
    print(e);
  }
}
