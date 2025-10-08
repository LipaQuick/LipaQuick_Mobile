import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:lipa_quick/core/managers/onboarding/onboarding_bloc.dart';
import 'package:lipa_quick/core/models/app_router/app_route_model.dart';
import 'package:lipa_quick/core/models/contacts/contacts.dart';
import 'package:lipa_quick/core/models/resgister_steps_data.dart';
import 'package:lipa_quick/ui/views/dashboard/dashboard_page.dart';
import 'package:lipa_quick/ui/views/forgot_password/create_new_password.dart';
import 'package:lipa_quick/ui/views/forgot_password/forgot_password.dart';
import 'package:lipa_quick/ui/views/forgot_password/recovery_password.dart';
import 'package:lipa_quick/ui/views/login_view.dart';
import 'package:lipa_quick/ui/views/onboarding_screen.dart';
import 'package:lipa_quick/ui/views/otp/otp_screen.dart';
import 'package:lipa_quick/ui/views/otp/password_otp_screen.dart';
import 'package:lipa_quick/ui/views/payment/payment_screen.dart';
import 'package:lipa_quick/ui/views/payment/transaction_history.dart';
import 'package:lipa_quick/ui/views/payment/transaction_summary.dart';
import 'package:lipa_quick/ui/views/register/register.dart';
import 'package:lipa_quick/ui/views/register/register_step_2.dart';
import 'package:lipa_quick/ui/views/register/register_step_3.dart';
import 'package:lipa_quick/ui/views/register/register_step_4.dart';
import 'package:lipa_quick/ui/views/user_profile/customer_profile.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LipaQuickAppRouter {
  final GoRouter router = GoRouter(
    routes: <GoRoute>[
      GoRoute(
        path: LipaQuickAppRouteMap.onboarding,
        builder: (BuildContext context, GoRouterState state) =>
            const OnboardingScreen(),
      ),
      GoRoute(
        path: LipaQuickAppRouteMap.login,
        builder: (BuildContext context, GoRouterState state) =>
            const LoginPage(),
      ),
      GoRoute(
        name: LipaQuickAppRouteMap.home,
        path: LipaQuickAppRouteMap.home,
        builder: (BuildContext context, GoRouterState state) => const HomePage(),
      ),
      //Forgot Password Route
      // GoRoute(
      //   name: LipaQuickAppRouteMap.account_recovery,
      //   path: LipaQuickAppRouteMap.account_recovery,
      //   builder: (BuildContext context, GoRouterState state) =>
      //       const AccountRecovery(),
      // ),
      //
      // GoRoute(
      //   name: LipaQuickAppRouteMap.account_otp_verification_name,
      //   path: LipaQuickAppRouteMap.account_otp_verification_path,
      //   builder: (BuildContext context, GoRouterState state) {
      //     var phoneNumber = state.pathParameters['phoneNumber'];
      //     return PasswordOtpScreen(phoneNo: phoneNumber);
      //   },
      // ),GoRoute(
      //     name: LipaQuickAppRouteMap.account_change_password,
      //     path: LipaQuickAppRouteMap.account_change_password_path,
      //     builder: (BuildContext context, GoRouterState state) {
      //       var phoneNumber = state.pathParameters['phoneNumber'];
      //       return ForgotPasswordPage(username: phoneNumber);
      //     }
      // ),
      //
      // GoRoute(
      //   name: LipaQuickAppRouteMap.account_summary_name,
      //   path: LipaQuickAppRouteMap.account_summary_path,
      //   builder: (BuildContext context, GoRouterState state) {
      //     var phoneNumber = state.pathParameters['phoneNumber'];
      //     return AccountSummary(phoneNumber!);
      //   },
      // ),

      GoRoute(
        path: LipaQuickAppRouteMap.register,
        builder: (BuildContext context, GoRouterState state) =>
            const RegisterPage(),
      ),
      GoRoute(
        path: LipaQuickAppRouteMap.registerStep2,
        builder: (BuildContext context, GoRouterState state) {
          RegisterStep stepData = state.extra as RegisterStep;
          return RegisterStepTwo(registerStep: stepData);
        },
      ),
      GoRoute(
        path: LipaQuickAppRouteMap.registerStep3,
        builder: (BuildContext context, GoRouterState state) {
          RegisterStep stepData = state.extra as RegisterStep;
          return RegisterThirdStep(registerStep: stepData);
        },
      ),
      GoRoute(
        path: LipaQuickAppRouteMap.registerStep4,
        builder: (BuildContext context, GoRouterState state) {
          RegisterStep stepData = state.extra as RegisterStep;
          return RegisterFourthStep(registerStep: stepData);
        },
      ),

      // GoRoute(
      //   name: LipaQuickAppRouteMap.profile,
      //   path: LipaQuickAppRouteMap.profile,
      //   builder: (BuildContext context, GoRouterState state) =>
      //   const ProfilePage(),
      // ),
      // GoRoute(
      //   name: LipaQuickAppRouteMap.transactions,
      //   path: LipaQuickAppRouteMap.transactions,
      //   builder: (BuildContext context, GoRouterState state) =>
      //       TransactionListPage(),
      // ),
      // GoRoute(
      //     path: LipaQuickAppRouteMap.payment_screen,
      //     builder: (BuildContext context, GoRouterState state) {
      //       ContactsAPI? api = state.extra as ContactsAPI;
      //       return PaymentPage(false, contact: api);
      //     }
      //
      // ),
      // GoRoute(
      //     path: LipaQuickAppRouteMap.payment_summary,
      //     builder: (BuildContext context, GoRouterState state) {
      //       TransactionPageItems? api = state.extra as TransactionPageItems;
      //       return TransactionSummaryPage(
      //         paymentRequest: api.paymentRequest,
      //         contact: api.contact,
      //       );
      //     }
      //
      // ),
      // GoRoute(
      //     path: LipaQuickAppRouteMap.payment_summary,
      //     builder: (BuildContext context, GoRouterState state) {
      //       TransactionPageItems? api = state.extra as TransactionPageItems;
      //       return TransactionSummaryPage(
      //         paymentRequest: api.paymentRequest,
      //         contact: api.contact,
      //       );
      //     }
      //
      // ),
    ],

    // redirect to the login page if the user is not logged in
    redirect: (BuildContext context, GoRouterState state) async {
      // Using `of` method creates a dependency of SharedPreference. It will
      // cause go_router to reparse current route has new sign-in
      // information.
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      var loggedIn = prefs.getBool('login') ?? false;
      var isOnBoardingCompleted = prefs.getBool(onBoardPrefsKey) ?? false;
      if(isOnBoardingCompleted){
        if(loggedIn){
          return LipaQuickAppRouteMap.home;
        }else{
          return LipaQuickAppRouteMap.login;
        }
      }else{
        return '/';
      }
      // var currentLocation = state.name;
      // print('Current Location: $currentLocation');
      // // List of registration pages
      // const registrationPages = [
      //   LipaQuickAppRouteMap.register,
      //   LipaQuickAppRouteMap.registerStep2,
      //   LipaQuickAppRouteMap.registerStep3,
      //   LipaQuickAppRouteMap.registerStep4,
      // ];
      //
      // // Handle redirects based on the user's authentication and onboarding status
      // if (!isOnBoardingCompleted && currentLocation != '/onboarding') {
      // return '/onboarding';
      // }
      //
      // if (!loggedIn && !registrationPages.contains(currentLocation) && currentLocation != '/login') {
      // return '/login';
      // }
      //
      // if (loggedIn && currentLocation == null) {
      // return '/home';
      // }

      return null; // No redirect needed
    },
  );
}

class LipaQuickAppRouteMap {
  static const String onboarding = '/';
  static const String login = '/login';

  //Register Steps
  static const String register = "/register";
  static const String registerStep2 = "/register/register_step_2";
  static const String registerStep3 = "/register/register_step_3";
  static const String registerStep4 = "/register/register_step_4";

  static const String home = '/home';

  //profile and others
  static const String profile = '/profile';
  static const String transactions = '/transaction';

  static const String otp_verification = "/otp_verification";
  static const String privacy = "/privacy_page";
  static const String user_details = "/user_details_page";
  static const String change_password = "/change_password";

  //Forgot Password Pages
  static const String account_recovery = "/account";
  static const String account_summary_name = "account_summary";
  static const String account_summary_path = "/account_summary/:phoneNumber";
  static const String account_otp_verification_name = "account_otp_verification";
  static const String account_otp_verification_path = "/account_otp_verification/:phoneNumber";
  static const String account_change_password = "account_password_reset";
  static const String account_change_password_path = "/account_password_reset/:phoneNumber";

  //QR
  static const String scan_qr = "/scan_qr_page";
  static const String show_qr = "/show_qr_page";

  //settings
  static const String settings = "/settings";

  //Account
  static const String add_account = '/addAccount';
  static const String list_account = '/listAccount';

  //Cards
  static const String add_cards = '/add_cards';
  static const String list_cards = '/list_cards';

  //Chats
  static const String recent_chats = '/recent_chats';
  static const String chat_page = '/chat_page';

  //Contacts
  static const String contacts = '/contacts';
  static const String search_contacts = '/search_contacts';

  //App Lock
  static const String app_lock = "/app_lock";
  static const String app_lock_create_pin = "/app_lock_create_pin";
  static const String app_lock_confirm_pin = "/app_lock_confirm_pin";

  //Payment
  static const String default_payment_page = "/default_payment_page";
  static const String payment_screen = "/payment_page";
  static const String payment_summary = "/payment_summary";
  static const String payment_waiting = "/payment_waiting_page";

  //Wallet
  static const String wallet_link_page = "/wallet_link_page";
}
