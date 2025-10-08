import 'dart:async';
import 'dart:convert';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_lock/flutter_app_lock.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:lipa_quick/core/bloc_observer.dart';
import 'package:lipa_quick/core/crypto/encryption.dart';
import 'package:lipa_quick/core/langauge/kinyarwanda_cupertino_localizations_delegate.dart';
import 'package:lipa_quick/core/langauge/kinyarwanda_material_localizations.dart';
import 'package:lipa_quick/core/langauge/kinyarwanda_material_localizations_delegate.dart';
import 'package:lipa_quick/core/local_db/repository/pin_repository.dart';
import 'package:lipa_quick/core/localization/app_language_pref.dart';
import 'package:lipa_quick/core/managers/language/language_bloc.dart';
import 'package:lipa_quick/core/managers/onboarding/onboarding_bloc.dart';
import 'package:lipa_quick/core/managers/pin_managers/pin_bloc.dart';
import 'package:lipa_quick/core/managers/social_post/social_bloc.dart';
import 'package:lipa_quick/core/models/password_login.dart';
import 'package:lipa_quick/core/notification/notification.dart';
import 'package:lipa_quick/core/notification/push_notification_helper.dart';
import 'package:lipa_quick/core/services/api.dart';
import 'package:lipa_quick/core/services/blocs/payment_method_bloc.dart';
import 'package:lipa_quick/core/view_models/TransactionViewModel.dart';
import 'package:lipa_quick/core/view_models/local_db_viewmodel.dart';
import 'package:lipa_quick/core/view_models/accounts_viewmodel.dart';
import 'package:lipa_quick/firebase_options.dart';
import 'package:lipa_quick/ui/shared/m3theme/theme.dart';
import 'package:lipa_quick/ui/shared/m3theme/util.dart';
import 'package:lipa_quick/ui/views/app_lock_pin/create_lock_pin.dart';
import 'package:lipa_quick/ui/views/app_lock_pin/verify_pin.dart';
import 'package:lipa_quick/ui/views/chat/chat_page/user_chat_page.dart';
import 'package:lipa_quick/ui/views/login_view.dart';
import 'package:lipa_quick/ui/views/onboarding_screen.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:workmanager/workmanager.dart';
import 'core/notification/firebase_notification.dart';
import 'core/view_models/contact_viewmodel.dart';
import 'locator.dart';
import 'ui/views/dashboard/dashboard_page.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter_android/google_maps_flutter_android.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';

const backgroundContactSync = "rw.lipaquick.contact.sync";

final GetIt locator = GetIt.instance;

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();

final StreamController<String?> selectNotificationStream =
StreamController<String?>.broadcast();

const String portName = 'notification_send_port';

class ReceivedNotification {
  ReceivedNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.payload,
  });

  final int id;
  final String? title;
  final String? body;
  final String? payload;
}

String? selectedNotificationPayload;

/// A notification action which triggers a url launch event
const String urlLaunchActionId = 'id_1';

/// A notification action which triggers a App navigation event
const String navigationActionId = 'id_3';

/// Defines a iOS/MacOS notification category for text input actions.
const String darwinNotificationCategoryText = 'textCategory';

/// Defines a iOS/MacOS notification category for plain actions.
const String darwinNotificationCategoryPlain = 'plainCategory';

@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse notificationResponse) {
  // ignore: avoid_print
  print('notification(${notificationResponse.id}) action tapped: '
      '${notificationResponse.actionId} with'
      ' payload: ${notificationResponse.payload}');
  if (notificationResponse.input?.isNotEmpty ?? false) {
    // ignore: avoid_print
    print(
        'notification action tapped with input: ${notificationResponse.input}');
  }
}

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((taskName, inputData) async {
    switch (taskName) {
      case backgroundContactSync:
        await setupLocator();
        ContactsDBViewModel dbViewModel = ContactsDBViewModel();
        await dbViewModel.syncContacts();
        break;
      case Workmanager.iOSBackgroundTask:
        await setupLocator();
        ContactsDBViewModel dbViewModel = ContactsDBViewModel();
        await dbViewModel.syncContacts();
        break;
    }
    return Future.value(true);
  });
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(name: "lipaquick",options: DefaultFirebaseOptions.currentPlatform);

  await NotificationService.initialize();


  Bloc.observer = SimpleBlocObserver();
  //Init Dependency injection module
  await setupLocator();

  // FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  final SharedPreferences prefs = await SharedPreferences.getInstance();
  var isLoggedIn = prefs.getBool('login') ?? false;
  //var isLanguageSelected = prefs.getString('language').toString();
  var isOnBoardingCompleted = prefs.getBool(onBoardPrefsKey) ?? false;
  var isApplicationLocked = prefs.getBool('twoFactorAuthentication') ?? false;

  //initQuickActions();
  // mount and run the flutter app
  runApp(MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AccountViewModel()),
        ChangeNotifierProvider(create: (_) => LocalDbViewModel()),
        ChangeNotifierProvider(create: (_) => ContactsDBViewModel()),
        ChangeNotifierProvider(create: (_) => TransactionViewModel()),
        ChangeNotifierProvider(create: (_) => AppLanguage())
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<OnBoardingBloc>(
              create: (BuildContext context) => OnBoardingBloc()),
          BlocProvider<SocialPostBloc>(
              create: (BuildContext context) => SocialPostBloc(locator<Api>())),
          BlocProvider<LanguageBloc>(
              create: (BuildContext context) =>
                  LanguageBloc()..add(GetLanguage())),
          BlocProvider<PaymentMethodBloc>(
              create: (BuildContext context) => PaymentMethodBloc()),
          BlocProvider<AppPinBloc>(
              create: (BuildContext context) =>
                  AppPinBloc(locator<AppPinRepository>())..add(AppPinStatus())),
        ],
        child: LipaQuickApplication(
            isOnBoardingCompleted, isLoggedIn, isApplicationLocked),
      )));
  //runApp(MyApp());
}

/// Global variables
/// * [GlobalKey<NavigatorState>]
class GlobalVariable {

  /// This global key is used in material app for navigation through firebase notifications.
  /// [navState] usage can be found in [notification_notifier.dart] file.
  static final GlobalKey<NavigatorState> navState = GlobalKey<NavigatorState>();

  static final GlobalKey<ChatListPage> chatKey = GlobalKey<ChatListPage>();
}

class LipaQuickApplication extends StatelessWidget {
  bool isLoggedIn = false;
  bool isLanguageSelected = false;
  bool isApplicationLocked = false;


  LipaQuickApplication(
      this.isLanguageSelected, this.isLoggedIn, this.isApplicationLocked,
      {Key? key})
      : super(key: key);

  List<LocalizationsDelegate<dynamic>> getLocalizationsDelegates() {
    return <LocalizationsDelegate<dynamic>>[
      AppLocalizations.delegate, // Your app-specific delegate
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
      const KinyarwandaCupertinoLocalizationsDelegate(), // Add custom Kinyarwanda Cupertino Localization
      const KinyarwandaMaterialLocalizationsDelegate(), // Add custom Kinyarwanda Cupertino Localization
    ];
  }

  @override
  Widget build(BuildContext context) {
    init();
    Widget mainWidget;
    //String initialRoute = LipaQuickAppRouteMap.onboarding;
    var passwordDto = PasswordDto('Test@123',
        DateFormat('dd/MM/yyyy HH:mm:ss').format(DateTime.now()));
    print(encryptAESCryptoJS(jsonEncode(passwordDto.toJson())));
    if (isLanguageSelected) {
      if (!isLoggedIn) {
        //User Not Logged in, go to Login Page
        if (kDebugMode) {
          print('User Not Logged In');
        }
        mainWidget = const LoginPage();
        //initialRoute = LipaQuickAppRouteMap.login;
      } else {
        //User Logged in, Go To HomePage
        if (kDebugMode) {
          print('User Logged In');
        }
        mainWidget = const HomePage();
        //initialRoute = LipaQuickAppRouteMap.home;
        // mainWidget = PaymentLinkPage(userDetails: UserDetails.initial());
        // widget = const LanguagePage();
      }
    } else {
      //App Language Not Selected, Go to Language Page
      mainWidget = const OnboardingScreen();
    }

    renderGoogleMaps();


    //GoRouter router = setUpGoRouter();

    return Builder(builder: (context) {
      final stateLanguage = context.watch<LanguageBloc>().state;
      final stateAppIn = context.watch<AppPinBloc>().state;

      final brightness = View.of(context).platformDispatcher.platformBrightness;

      // Retrieves the default theme for the platform
      //TextTheme textTheme = Theme.of(context).textTheme;

      // Use with Google Fonts package to use downloadable fonts
      TextTheme textTheme = createTextTheme(context, "Poppins", "Poppins");

      MaterialTheme theme = MaterialTheme(textTheme);

      // var delegates = List.from();
      // delegates.add(KinyarwandaCupertinoLocalizationsDelegate());
      // delegates.add(KinyarwandaMaterialLocalizationsDelegate());

      return MaterialApp(
        navigatorKey: GlobalVariable.navState,
          //routerConfig: LipaQuickAppRouter().router,
          theme: brightness == Brightness.light
              ? theme.lightMediumContrast()
              : theme.dark(),
          debugShowCheckedModeBanner: false,
          localizationsDelegates: getLocalizationsDelegates(),
          supportedLocales: AppLocalizations.supportedLocales,
          locale: stateLanguage.selectedLanguage.value,

          //initialRoute: initialRoute,
          // routes: {
          //   '/': (context) => OnboardingScreen(),
          //   '/login': (context) => LoginPage(),
          //   '/signup': (context) => RegisterPage(),
          //   '/forgot-password': (context) => ForgotPasswordPage(),
          //   '/dashboard': (context) => HomePage(),
          //   '/profile': (context) => ProfilePage(),
          //   '/profile/transactions': (context) => TransactionListPage(),
          //   '/profile/account': (context) => AccountListPage(),
          //   '/profile/card': (context) => CardListPage(),
          //   '/profile/payment': (context) => PrivacyPage(null),
          // },
          // onGenerateRoute: (setting) {
          //   print('Route Name ${setting.name}');
          //   switch (setting.name) {
          //     case '/':
          //       return MaterialPageRoute(builder: (_) => OnboardingScreen());
          //     case '/login':
          //       return MaterialPageRoute(builder: (_) => LoginPage());
          //     case '/signup':
          //       return MaterialPageRoute(builder: (_) => RegisterPage());
          //     case '/forgot-password':
          //       return MaterialPageRoute(builder: (_) => ForgotPasswordPage());
          //     case '/dashboard':
          //       return MaterialPageRoute(builder: (_) => HomePage());
          //     case '/profile':
          //       return MaterialPageRoute(builder: (_) => ProfilePage());
          //     case '/profile/transactions':
          //       return MaterialPageRoute(builder: (_) => TransactionListPage());
          //     case '/profile/account':
          //       return MaterialPageRoute(builder: (_) => AccountListPage());
          //     case '/profile/card':
          //       return MaterialPageRoute(builder: (_) => CardListPage());
          //     default:
          //       return MaterialPageRoute(builder: (_) => PrivacyPage(null));
          //   }
          // },
          //home: mainWidget,
          home: mainWidget,
          builder: (context, child) {
            return AppLock(
                builder: (context, childObj) => child!,
                enabled:
                    (stateAppIn is AppPinEnabled) ? stateAppIn.enabled : false,
                lockScreenBuilder: (context) => PinVerify(
                  pinAction: PinAction.VALIDATE_PIN,
                )
            );
          });
    });
  }

  void init() {
    initQuickActions();
  }

  void renderGoogleMaps() {
    final GoogleMapsFlutterPlatform mapsImplementation =
        GoogleMapsFlutterPlatform.instance;
    if (mapsImplementation is GoogleMapsFlutterAndroid) {
      mapsImplementation.useAndroidViewSurface = true;
      initializeMapRenderer();
    }
  }

  Completer<AndroidMapRenderer?>? _initializedRendererCompleter;

  /// Initializes map renderer to the `latest` renderer type for Android platform.
  ///
  /// The renderer must be requested before creating GoogleMap instances,
  /// as the renderer can be initialized only once per application context.
  Future<AndroidMapRenderer?> initializeMapRenderer() async {
    if (_initializedRendererCompleter != null) {
      return _initializedRendererCompleter!.future;
    }

    final Completer<AndroidMapRenderer?> completer =
        Completer<AndroidMapRenderer?>();
    _initializedRendererCompleter = completer;

    WidgetsFlutterBinding.ensureInitialized();

    final GoogleMapsFlutterPlatform mapsImplementation =
        GoogleMapsFlutterPlatform.instance;
    if (mapsImplementation is GoogleMapsFlutterAndroid) {
      unawaited(mapsImplementation
          .initializeWithRenderer(AndroidMapRenderer.latest)
          .then((AndroidMapRenderer initializedRenderer) =>
              completer.complete(initializedRenderer)));
    } else {
      completer.complete(null);
    }

    return completer.future;
  }

  Future<bool> _onWillPop(bool canPop, BuildContext context) async {
    print("Back button pressed");
    final NavigatorState navigator = Navigator.of(context);
    final bool? shouldPop = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Are you sure?'),
        content: Text('Do you want to exit the app?'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('Yes'),
          ),
        ],
      ),
    );
    if (shouldPop ?? false) {
      navigator.pop(true);
    }
    return false;
  }
}
