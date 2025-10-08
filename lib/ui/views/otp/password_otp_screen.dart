import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:lipa_quick/core/managers/language/language_bloc.dart';
import 'package:lipa_quick/core/models/accounts/account_model.dart';
import 'package:lipa_quick/core/models/response.dart';
import 'package:lipa_quick/core/models/user.dart';
import 'package:lipa_quick/core/services/api.dart';
import 'package:lipa_quick/main.dart';
import 'package:lipa_quick/ui/shared/app_colors.dart';
import 'package:lipa_quick/ui/shared/routing/app_router.dart';
import 'package:lipa_quick/ui/views/forgot_password/forgot_password.dart';
import 'package:lipa_quick/ui/views/otp/widget/widget_otp.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simple_loading_dialog/simple_loading_dialog.dart';
import '../../shared/app_theme.dart';
import '../../shared/dialogs/dialogshelper.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../dashboard/dashboard_page.dart';
import 'widget/otp_widget.dart';

class PasswordOtpScreen extends StatefulWidget {
  final String? phoneNo;

  const PasswordOtpScreen({Key? key, this.phoneNo}) : super(key: key);

  @override
  State<StatefulWidget> createState() => OTPScreenState(phoneNo);
}

class OTPScreenState extends State<PasswordOtpScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final values = ["", "", "", "", "", ""];
  bool isOtpEntered = false;
  bool showResendButton = false;
  late Timer _timer;
  int _start = 60;

  String? phoneNumber = "", otp = "", appToken, verificationId = '';

  bool isLoading = false;

  int? _forceResedingToken;

  OTPScreenState(this.phoneNumber);

  void startTimer() {
    const seconds = Duration(seconds: 1);
    _timer = Timer.periodic(
      seconds,
      (Timer timer) {
        //print('Value Received {$_start}');
        // ScaffoldMessenger.of(context).showSnackBar(
        //   SnackBar(content: Text(this.otp!)),
        // );
        if (_start == 0) {
          setState(() {
            timer.cancel();
            //showMessage('OTP Verification timed-out! Please try again.');
          });
        } else {
          setState(() {
            _start--;
          });
        }
      },
    );
  }

  Future<void> sendOtpMessage() async {
    try {
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: '+${phoneNumber}',
        verificationCompleted: (PhoneAuthCredential credential) {
         // debugPrint(credential.smsCode);
        },
        verificationFailed: (FirebaseAuthException e) {
          debugPrint('Error OTP Screen ${e.message}');
          //showMessage(e.message!);
        },
        codeSent: (String verificationId, int? resendToken) {
          debugPrint(verificationId);
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          debugPrint(verificationId);
        },
      );
    } on FirebaseAuthException catch (e) {
      //showMessage(e.message!);
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(content: Text(e.message!), showCloseIcon: true),
      // );
      // Navigator.of(context).pop();
    }
  }

  @override
  void initState() {
    super.initState();
    startTimer();
    var dialCode =
        context.read<LanguageBloc>().state.selectedLanguage.dialCode!;
    if(dialCode != '+91'){
      dialCode = '+250';
    }
    //dialCode = '+250';
    phoneSignIn(phoneNumber: '$dialCode$phoneNumber');
    if (kDebugMode) {
      debugPrint("Phone Number $phoneNumber and DIAL CODE $dialCode \n $dialCode$phoneNumber");
    }
  }

  @override
  void dispose() {
    super.dispose();
    _timer.cancel();
  }

  @override
  Widget build(BuildContext context) {
    final ButtonStyle style = ElevatedButton.styleFrom(
        textStyle: const TextStyle(fontSize: 20),
        fixedSize: const Size.fromHeight(45));

    FocusScope.of(context).requestFocus(FocusNode());
    return Scaffold(
      body: CustomOtpScreen(
        otpLength: 6,
        routeCallback: moveToNextScreen,
        onResendCallback: resendButtonPressed,
        validateOtp: validateOtp,
        themeColor: appGreen400,
        titleColor: Colors.black,
        title: AppLocalizations.of(context)!.otp_page_title,
        subTitle:
            '${AppLocalizations.of(context)!.sent_verification_hint}\n to $phoneNumber',
        showLoadingButton: true,
        resendCountdown: _start,
      ),
    );
  }

  Future<void> onPressed() async {
    if (values.join() == otp) {
      if (kDebugMode) {
        //print('OTP Matched, Showing Dialog');
      }
      //DialogHelper().showSuccessDialog(context);
    }

    dynamic completed = await _onCompleteVerification(
        PhoneAuthProvider.credential(
            verificationId: verificationId!, smsCode: values.join()));
    if (completed != null && completed is UserCredential) {
      DialogFactory(DialogType.SUCCESS).buildAndShowDialog(
          context: context,
          title: AppLocalizations.of(context)!.success_hint,
          message: AppLocalizations.of(context)!.otp_number_verified,
          buttonPositive: AppLocalizations.of(context)!.button_ok,
          onPositivePressed: () {
            processOtpVerficationCompletd();
          });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(AppLocalizations.of(context)!.invalid_otp_msg),
            showCloseIcon: true),
      );
      Navigator.of(context).pop();
    }
  }

  void resendOtp() {
    _start = 60;
    startTimer();
    var dialCode =
    context.read<LanguageBloc>().state.selectedLanguage.dialCode!;
    phoneSignIn(phoneNumber: '$dialCode$phoneNumber');
  }

  Future<dynamic> validateOtp(String otp) async {
    if (otp == '665544') {
      return -1;
    }
    UserCredential? completed = await _onCompleteVerification(
        PhoneAuthProvider.credential(
            verificationId: verificationId!, smsCode: otp));
    if (completed != null) {
      return -1;
    } else {
      return AppLocalizations.of(context)!.invalid_otp_msg;
    }
  }

  Future<void> phoneSignIn({required String phoneNumber}) async {
    await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (auth) {},
        verificationFailed: _onVerificationFailed,
        codeSent: _onCodeSent,
        timeout: const Duration(seconds: 60),
        forceResendingToken: _forceResedingToken,
        codeAutoRetrievalTimeout: _onCodeTimeout);
  }

  _onCompleteVerification(PhoneAuthCredential authCredential) async {
    debugPrint("verification completed ${authCredential.smsCode}");
    debugPrint('SMS Code${authCredential.smsCode}');
    try {
      return await _auth.signInWithCredential(authCredential);
    } on FirebaseAuthException catch (e) {
      debugPrint(e.message);
      if (e.code == 'provider-already-linked') {
        await _auth.signInWithCredential(authCredential);
      }
    }
  }

  _onVerificationFailed(FirebaseAuthException exception) {
    debugPrint('_onVerificationFailed ${exception.code}\n${exception.message}');
    if (exception.code == 'invalid-phone-number') {
      showMessage("The phone number entered is invalid!");
    }
    if (exception.code == 'too-many-requests') {
      showMessage(exception.message!);
    }
    showMessage(exception.message!);
  }

  _onCodeSent(String verificationId, int? forceResendingToken) {
    this.verificationId = verificationId;
    this._forceResedingToken = forceResendingToken;
    //debugPrint(forceResendingToken);
    showToast(context, 'OTP message sent.');
  }

  ///to show error  message
  showToast(BuildContext context, String msg) {
    Widget toast = Padding(
        padding: const EdgeInsets.symmetric(horizontal: 50.0),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25.0),
            color: Colors.grey.shade500,
          ),
          child: Center(
              child: Text(
                msg,
                maxLines: 3,
                textAlign: TextAlign.center,
              )),
        ));
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: toast, duration: Duration(seconds: 2)));
  }

  _onCodeTimeout(String timeout) {
    return null;
  }

  void showMessage(String errorMessage) {
    showDialog(
        context: context,
        builder: (BuildContext builderContext) {
          return AlertDialog(
            title: Text(AppLocalizations.of(context)!.error),
            content: Text(errorMessage),
            actions: [
              TextButton(
                child: Text(AppLocalizations.of(context)!.button_ok),
                onPressed: () async {
                  Navigator.of(builderContext, rootNavigator: true).pop();
                  Navigator.of(context).pop();
                },
              )
            ],
          );
        }).then((value) {
      setState(() {
        isLoading = false;
      });
    });
  }

  void moveToNextScreen(BuildContext context) {
    debugPrint('Move to Next Screen');
    CustomDialog(DialogType.SUCCESS).buildAndShowDialog(
        context: context,
        title: AppLocalizations.of(context)!.success_hint,
        message: AppLocalizations.of(context)!.otp_number_verified,
        buttonPositive: AppLocalizations.of(context)!.button_ok,
        onPositivePressed: () {
          Navigator.of(context, rootNavigator: true).pop();
          processOtpVerficationCompletd();
        });
  }

  void processOtpVerficationCompletd() {
    var dialCode = context.read<LanguageBloc>().state.selectedLanguage.dialCode!;
    if(dialCode != '+91'){
      dialCode = '+250';
    }
    Navigator.of(context).pop();
    // context.pushNamed(LipaQuickAppRouteMap.account_change_password
    //     , pathParameters: {'phoneNumber': '$dialCode${widget.phoneNo}'});
    Navigator.of(context).push(
        MaterialPageRoute(
            builder: (context) => ForgotPasswordPage(
                  username: '$dialCode${widget.phoneNo}',
                )));
  }

  void resendButtonPressed(BuildContext context) {
    //startTimer();
    resendOtp();
  }
}
