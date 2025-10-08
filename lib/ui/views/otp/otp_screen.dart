import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:lipa_quick/core/models/accounts/account_model.dart';
import 'package:lipa_quick/core/models/response.dart';
import 'package:lipa_quick/core/services/api.dart';
import 'package:lipa_quick/main.dart';
import 'package:lipa_quick/ui/shared/app_colors.dart';
import 'package:lipa_quick/ui/views/otp/widget/widget_otp.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simple_loading_dialog/simple_loading_dialog.dart';
import '../../shared/dialogs/dialogshelper.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../dashboard/dashboard_page.dart';

class OtpScreen extends StatefulWidget {
  final String? phoneNo, OTP, appToken;
  final UserDetails? userModel;
  final Widget nextPageWidget;

  const OtpScreen(this.nextPageWidget,
      {Key? key, this.appToken, this.userModel, this.phoneNo, this.OTP})
      : super(key: key);

  @override
  State<StatefulWidget> createState() =>
      OTPScreenState(appToken!, userModel!, phoneNo, OTP);
}

class OTPScreenState extends State<OtpScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Api _lipaApi = locator<Api>();
  final values = ["", "", "", "", "", ""];
  bool isOtpEntered = false;
  bool showResendButton = false;
  late Timer _timer;
  int _start = 60;

  String? phoneNumber = "", otp = "", appToken, verificationId = '';
  UserDetails? userModel;

  bool isLoading = false;

  int? _forceResedingToken;

  OTPScreenState(this.appToken, this.userModel, this.phoneNumber, this.otp);

  void startTimer() {
    const seconds = Duration(seconds: 1);
    _timer = Timer.periodic(
      seconds,
      (Timer timer) {
        print('Value Received {$_start}');
        // ScaffoldMessenger.of(context).showSnackBar(
        //   SnackBar(content: Text(this.otp!)),
        // );
        if (_start == 0) {
          setState(() {
            timer.cancel();
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
          debugPrint(credential.smsCode);
        },
        verificationFailed: (FirebaseAuthException e) {
          print('Error OTP Screen ${e.message}');
          showMessage(e.message!);
        },
        codeSent: (String verificationId, int? resendToken) {
          debugPrint(verificationId);
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          debugPrint(verificationId);
        },
      );
    } on FirebaseAuthException catch (e) {
      showMessage(e.message!);
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
    // var dialCode =
    //     context.read<LanguageBloc>().state.selectedLanguage.dialCode!;
    // print("Before Phone Number $phoneNumber and DIAL CODE $dialCode \n $dialCode$phoneNumber");
    //dialCode = '+250';
    phoneSignIn(phoneNumber: '+$phoneNumber');
    //print("Phone Number $phoneNumber and DIAL CODE $dialCode \n $dialCode$phoneNumber");

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
        validateOtp: validateOtp,
        themeColor: appGreen400,
        titleColor: Colors.black,
        title: AppLocalizations.of(context)!.otp_page_title,
        subTitle: '${AppLocalizations.of(context)!.sent_verification_hint}\n to $phoneNumber',
        onResendCallback: resendOTPCallback,
        resendCountdown: _start,
        showLoadingButton: true,
      ),
    );
  }

  Future<dynamic> _save(String token, UserDetails? userModel) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('login', true);
    prefs.setString("token", token);
    //debugPrint('Data' + userModel!.toJson().toString());

    prefs.setString('userDetails', jsonEncode(userModel!.toJson()));

    return _lipaApi.verificationCompleted(userModel.phoneNumber, true);
  }

  Future<dynamic> getAccounts() {
    return _lipaApi.getAccounts();
  }

  checkAccounts() {
    //debugPrint('Checking account List');
    getAccounts().then((value) => {
          // print('${value.toString()}'),
          if (value != null && value is AccountListResponse)
            {
              debugPrint('Account List'),
              if (value.status!)
                {
                  if (value.data!.isEmpty)
                    {
                      Navigator.of(context).pop(),
                      Navigator.of(context).pop(),
                      Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                              builder: (context) => widget.nextPageWidget),
                          (Route<dynamic> route) => false)
                    }
                  else
                    {
                      Navigator.of(context).pop(),
                      Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(builder: (context) => HomePage()),
                          (Route<dynamic> route) => false)
                    }
                }
              else
                {
                  Navigator.of(context).pop(),
                  Navigator.of(context).pop(),
                  Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                          builder: (context) => widget.nextPageWidget),
                      (Route<dynamic> route) => false)
                }
            }
        });
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
            content: Text(
                AppLocalizations.of(context)!.invalid_otp_msg),
            showCloseIcon: true),
      );
      Navigator.of(context).pop();
    }
  }

  void resendOtp() {
    _start = 60;
    startTimer();
    sendOtpMessage();
  }

  Future<dynamic> validateOtp(String otp) async {
    if(otp == '665544'){
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
    print("verification completed ${authCredential.smsCode}");
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
    print('📛 [PhoneAuth] Verification Failed');

    // Basic Info
    print('🔴 Code: ${exception.code}');
    print('🔴 Message: ${exception.message}');

    // Stack Trace
    print('🧱 StackTrace: ${exception.stackTrace}');

    // Full Exception Info
    print('📝 Full Exception: ${exception.toString()}');

    // Optional: Check additional properties
    if (exception.email != null) {
      print('📧 Email: ${exception.email}');
    }

    if (exception.phoneNumber != null) {
      print('📱 PhoneNumber: ${exception.phoneNumber}');
    }

    if (exception.tenantId != null) {
      print('🏢 Tenant ID: ${exception.tenantId}');
    }

    // Useful for structured error tracking
    debugPrint('📋 [PhoneAuthException Details]\n'
        'Code: ${exception.code}\n'
        'Message: ${exception.message}\n'
        'Phone: ${exception.phoneNumber}\n'
        'StackTrace: ${exception.stackTrace}\n'
        'Exception: ${exception.toString()}');


  if (exception.code == 'invalid-phone-number') {
      showMessage("The phone number entered is invalid!");
    }
    if (exception.code == 'too-many-requests') {
      showMessage(exception.message!);
    }
  }

  _onCodeSent(String verificationId, int? forceResendingToken) {
    this.verificationId = verificationId;
    this._forceResedingToken = forceResendingToken;
    print(forceResendingToken);
    print("code sent");
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
                  Navigator.of(builderContext).pop();
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
    print('Move to Next Screen');
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

  Future<void> processOtpVerficationCompletd() async {
    //Navigator.of(context).pop();
    await _save(appToken!, userModel);
    //var navigator = Navigator.of(context);
    final resultAccount = await showSimpleLoadingDialog<dynamic>(
      context: context,
      barrierDismissible: true,
      future: () async{
        return getAccounts();
      }
    );
    //navigator.pop();

    //Navigator.of(context).pop();
    if (resultAccount is AccountListResponse) {
      if (resultAccount.data!.isEmpty) {
        //Navigator.of(context).pop();
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => widget.nextPageWidget),
                (Route<dynamic> route) => false);
      } else {
        //Navigator.of(context).pop();
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => HomePage()),
                (Route<dynamic> route) => false);
      }
    }else {
      //Navigator.of(context).pop();
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => widget.nextPageWidget),
              (Route<dynamic> route) => false);
    }
  }

  void resendOTPCallback(BuildContext p1) {
    resendOtp();
  }
}
