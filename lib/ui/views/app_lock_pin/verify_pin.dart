import 'package:flutter/material.dart';
import 'package:flutter_app_lock/flutter_app_lock.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lipa_quick/core/local_db/repository/pin_repository.dart';
import 'package:lipa_quick/core/managers/pin_managers/pin_bloc.dart';
import 'package:lipa_quick/main.dart';
import 'package:lipa_quick/ui/app_router.dart';
import 'package:lipa_quick/ui/shared/app_theme.dart';
import 'package:lipa_quick/ui/shared/dialogs/dialogshelper.dart';
import 'package:lipa_quick/ui/views/app_lock_pin/create_lock_pin.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:lipa_quick/ui/views/otp/widget/widget_otp.dart';

class PinVerify extends StatelessWidget {
  PinAction pinAction;

  PinVerify({Key? key, required this.pinAction}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        create: (_) => AppPinBloc(locator<AppPinRepository>()),
        child: AppPinLock(pinAction));
  }
}

class AppPinLock extends StatefulWidget {
  PinAction pinAction;

  AppPinLock(this.pinAction);

  @override
  State<StatefulWidget> createState() => AppPinLockState();
}

class AppPinLockState extends State<AppPinLock> {
  AppPinBloc? pinBloc;

  String? currentOtp;

  @override
  void initState() {
    pinBloc = context.read<AppPinBloc>();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return BlocBuilder<AppPinBloc, PinState>(buildWhen: (blocContext, state) {
      if (state is PinVerified) {
        AppLock.of(context)!.didUnlock();
        return false;
      } else if (state is PinVerificationFailed) {
        showInvalidDialog(l10n);
      }
      return true;
    }, builder: (context, state) {
      return PopScope(child: Scaffold(
        body: CustomOtpScreen.withObsfucatedKey(
          validateOtp: _validatePin,
          routeCallback: routeCallback,
          title: l10n.enter_app_lock_pin,
        ),
      ), canPop: false,onPopInvoked: AppRouter().onBackPressed);
    });
  }

  Future<dynamic> _validatePin(String otp) async {
    if (widget.pinAction == PinAction.CREATE_PIN) {
      currentOtp = otp;
      return -1;
    } else if (widget.pinAction == PinAction.VALIDATE_PIN) {
      pinBloc!.add(VerifyPin(otp));
      return '';
    } else {
      return 0;
    }
  }

  void routeCallback(BuildContext p1) {
    AppLock.of(context)!.didUnlock();
  }

  void showInvalidDialog(AppLocalizations l10n) {
    CustomDialog(DialogType.FAILURE).buildAndShowDialog(
        context: context,
        title: l10n.enter_valid_pin,
        message: '',
        onPositivePressed: () {
          Navigator.of(context, rootNavigator: true).pop();
        },
        buttonPositive: l10n.button_ok);
  }
}
