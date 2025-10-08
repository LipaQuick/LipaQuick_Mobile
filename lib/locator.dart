
import 'dart:async';
import 'dart:ui';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:country_codes/country_codes.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:lipa_quick/core/local_db/repository/payment_reposiroty_impl.dart';
import 'package:lipa_quick/core/local_db/repository/pin_repository.dart';
import 'package:lipa_quick/core/local_db/repository/settings_repository_impl.dart';
import 'package:lipa_quick/core/localization/app_language_pref.dart';
import 'package:lipa_quick/core/models/quick_action_model.dart';
import 'package:lipa_quick/core/provider/DBProvider.dart';
import 'package:lipa_quick/core/services/db_helper.dart';
import 'package:lipa_quick/core/services/local_shared_pref.dart';
import 'package:lipa_quick/core/services/signalr/connection_hub.dart';
import 'package:lipa_quick/core/view_models/TransactionViewModel.dart';
import 'package:lipa_quick/core/view_models/contact_viewmodel.dart';
import 'package:lipa_quick/core/view_models/discount_viewmodel.dart';
import 'package:lipa_quick/core/view_models/merchant_viewmodel.dart';
import 'package:lipa_quick/main.dart';
import 'package:lipa_quick/ui/views/chat/chatPageViewModel.dart';
import 'package:lipa_quick/ui/views/login_view.dart';
import 'core/services/api.dart';
import 'core/view_models/accounts_viewmodel.dart';
import 'core/view_models/local_db_viewmodel.dart';


Future<void> setupLocator() async {

  // final messaging = FirebaseMessaging.instance;
  // if (kDebugMode) {
  //   debugPrint('Registration Token=$token');
  // }
  //final _messageStreamController = BehaviorSubject<RemoteMessage>();

  //Remote Instance DI
  locator.registerSingleton<Api>(Api(), signalsReady: true);
  locator.registerSingleton<ConnectionHub>(ConnectionHub(), signalsReady: true);
  //Local DB Instance Creation
  locator.registerLazySingleton<DBHelper>(() {
    return DBHelper.instance;
  });

  locator.registerLazySingleton<DBProvider>(() => DBProvider.db);
  //Remote Instance ViewModel DI
  locator.registerLazySingleton<AccountViewModel>(() => AccountViewModel());
  locator.registerLazySingleton<DiscountViewModel>(() => DiscountViewModel());
  locator.registerLazySingleton<AppLanguage>(() => AppLanguage());
  locator.registerFactory<ContactsDBViewModel>(() => ContactsDBViewModel());
  locator.registerLazySingleton<TransactionViewModel>(() => TransactionViewModel());
  locator.registerLazySingleton<MerchantViewModel>(() => MerchantViewModel());
  locator.registerLazySingleton<ChatPageViewModel>(() => ChatPageViewModel());
  locator.registerLazySingleton<Connectivity>(() => Connectivity());

  //Local DB ViewModel DI
  locator.registerLazySingleton<LocalDbViewModel>(() => LocalDbViewModel());
  locator.registerFactory<PaymentMethodsRepositoryImpl>(() => PaymentMethodsRepositoryImpl());
  locator.registerFactory<AppSettingsRepositoryImpl>(() => AppSettingsRepositoryImpl());
  locator.registerFactory<AppPinRepository>(() => AppPinRepository());

  // FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
  //   if (kDebugMode) {
  //     debugPrint('Handling a foreground message: ${message.messageId}');
  //     debugPrint('Message data: ${message.data}');
  //     debugPrint('Message notification: ${message.notification?.title}');
  //     debugPrint('Message notification: ${message.notification?.body}');
  //   }
  //   await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  //   await setupFlutterNotifications();
  //   showFlutterNotification(message.notification!);
  //   // If you're going to use other Firebase services in the background, such as Firestore,
  //   // make sure you call `initializeApp` before using other Firebase services.
  //   debugPrint('Handling a background message ${message.messageId}');
  //   _messageStreamController.sink.add(message);
  // });

}

Future<void> initQuickActions() async {
  try{
    locator<ContactsDBViewModel>().getContact();
  }catch(e){
    //print(e.toString());
  }

  List<QuickActionModel> data = getQuickActions();
  await DBHelper.instance.inseryItems(data);

  await CountryCodes.init(); // Optionally, you may provide a `Locale` to get countrie's localizadName


  // final Locale? deviceLocale = CountryCodes.getDeviceLocale();
  //print(deviceLocale!.languageCode); // Displays en
  //print(deviceLocale.countryCode); // Displays US

  // final CountryDetails details = CountryCodes.detailsForLocale();
  //print(details.alpha2Code); // Displays alpha2Code, for example US.
  //print(details.dialCode); // Displays the dial code, for example +1.
  //print(details.name); // Displays the extended name, for example United States.
  //print(details.localizedName);
  // Displays the extended name based on device's language (or other, if provided on init)

}

List<QuickActionModel> getQuickActions() {
  List<QuickActionModel> model = <QuickActionModel>[];
  model.add(QuickActionModel.name("1", "assets/icon/Users.png", "Pay\nContacts", 1));
  model.add(QuickActionModel.name("2", "assets/icon/Call.png", "Find \nUser", 1));
  model.add(QuickActionModel.name("3", "assets/icon/Bills.png", "Transfer to\nBank", 1));
  model.add(QuickActionModel.name("4", "assets/icon/QR.png", "Scan QR\nCode", 1));
  model.add(QuickActionModel.name("5", "assets/icon/Store.png", "Merchant\nID", 1));
  return model;
}

void goToLoginPage(BuildContext context) async {
  await LocalSharedPref().clearLoginDetails();
  Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => LoginPage())
      , (Route<dynamic> route) => route.isFirst);
  // context.go(LipaQuickAppRouteMap.login);
}

