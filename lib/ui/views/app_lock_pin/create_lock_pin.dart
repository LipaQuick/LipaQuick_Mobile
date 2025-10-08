import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lipa_quick/core/managers/pin_managers/pin_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:lipa_quick/ui/app_router.dart';
import 'package:lipa_quick/ui/shared/app_theme.dart';
import 'package:lipa_quick/ui/shared/dialogs/dialogshelper.dart';
import 'package:lipa_quick/ui/views/otp/widget/widget_otp.dart';

enum PinAction {
  CREATE_PIN,
  CONFIRM_PIN,
  VALIDATE_PIN
}

class AppLockPinWidget extends StatefulWidget {
  PinAction pinAction;
  String? pinConfirm;

  AppLockPinWidget({Key? key, required this.pinAction, this.pinConfirm}) : super(key: key);

  @override
  State<StatefulWidget> createState() => AppPinLockState();
}

class AppPinLockState extends State<AppLockPinWidget> {
  AppPinBloc? pinBloc;

  String? currentOtp;

  var _start = 0;

  @override
  void initState() {
    pinBloc = context.read<AppPinBloc>();
    pinBloc!.add(AppPinStatus());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return BlocBuilder<AppPinBloc, PinState>(
      buildWhen: (previousState, currentState) {
        if(currentState is AppLockEnabled){
          return false;
        }
        return true;
      },
      builder:(context, state) {
        return PopScope(onPopInvoked: AppRouter().onBackPressed,child: Scaffold(
          appBar: AppTheme.getAppBar(context: context,
              title: '',
              subTitle: '',
              enableBack: true),
          body: CustomOtpScreen(validateOtp: _validatePin
            , routeCallback: routeCallback
            , title: widget.pinAction == PinAction.CREATE_PIN
                ?l10n.create_app_pin:'Confirm App Lock Pin'
            ,subTitle: widget.pinAction == PinAction.CREATE_PIN
                ?'Create a 4-digit PIN for App Lock':'Confirm your new App Lock PIN',
            onResendCallback: resendOTPCallback,
            resendCountdown: _start,
            showLoadingButton: true,),
        ),);
      });
  }

  Future<dynamic> _validatePin(String otp) async{
    if(widget.pinAction == PinAction.CREATE_PIN){
      currentOtp = otp;
      return -1;
    } else if(widget.pinAction == PinAction.CONFIRM_PIN){
      if(otp == widget.pinConfirm!){
        return -1;
      }else{
        return 'PIN mismatch. Please re-enter your PIN to confirm.';
      }
    }else{
      return 0;
    }
  }

  void routeCallback(BuildContext p1) {
    if(widget.pinAction == PinAction.CONFIRM_PIN){
      pinBloc!.add(CreateAppLock(widget.pinConfirm!));
      CustomDialog(DialogType.SUCCESS).buildAndShowDialog(
          context: context,
          title: AppLocalizations.of(context)!.success_hint,
          message: AppLocalizations.of(context)!.pin_create_success,
          buttonPositive: AppLocalizations.of(context)!.button_ok,
          onPositivePressed: () {
            Navigator.of(context, rootNavigator: true).pop();
            Navigator.popUntil(context, (route) => route.isFirst);
          });
    }else{
      Navigator.push(context,
          MaterialPageRoute(builder: (context)
          => AppLockPinWidget(pinAction: PinAction.CONFIRM_PIN, pinConfirm: currentOtp)));
    }
  }

  void resendOTPCallback(BuildContext p1) {
  }
}