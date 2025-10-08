import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:lipa_quick/core/managers/language/language_bloc.dart';
import 'package:lipa_quick/core/managers/password_recovery/recover_account.dart';
import 'package:lipa_quick/core/services/api.dart';
import 'package:lipa_quick/main.dart';
import 'package:lipa_quick/ui/shared/app_colors.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:lipa_quick/ui/shared/app_theme.dart';
import 'package:lipa_quick/ui/shared/dialogs/dialogshelper.dart';
import 'package:lipa_quick/ui/shared/routing/app_router.dart';
import 'package:lipa_quick/ui/shared/ui_styles.dart';
import 'package:lipa_quick/ui/views/forgot_password/create_new_password.dart';

class AccountRecovery extends StatelessWidget {
  const AccountRecovery({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => PasswordRecoveryBloc(locator<Api>()),
      child: AccountRecoveryWidget(),
    );
  }
}

class AccountRecoveryWidget extends StatefulWidget {
  const AccountRecoveryWidget({super.key});

  @override
  State<StatefulWidget> createState() => AccountRecoveryWidgetState();
}

class AccountRecoveryWidgetState extends State<AccountRecoveryWidget> {
  String? userName;

  var _globalKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return BlocListener<PasswordRecoveryBloc, PasswordState>(
        listener: (context, state) async {
          if(state is AccountExistState){
            //Navigator.of(context).pop();
            unawaited(
                // context.pushNamed(LipaQuickAppRouteMap.account_summary_name, pathParameters: {'phoneNumber': userName!})
                Navigator.of(context).push(MaterialPageRoute(builder: (context) =>AccountSummary(userName!)))
            );
          }else if(state is AccountNotFoundState){
            CustomDialog(DialogType.FAILURE).buildAndShowDialog(
                context: context,
                title: AppLocalizations.of(context)!.error_hint,
                message: 'No account found with the details you have entered.',
                onPositivePressed: () {
                  Navigator.of(context, rootNavigator: true).pop();
                },
                buttonPositive: AppLocalizations.of(context)!.button_ok);
          }else if(state is InvalidApiState){
            //var exception = state as InvalidApiState;
            CustomDialog(DialogType.FAILURE).buildAndShowDialog(
                context: context,
                title: AppLocalizations.of(context)!.error_hint,
                message: state.apiException.message,
                onPositivePressed: () {
                  Navigator.of(context, rootNavigator: true).pop();
                },
                buttonPositive: AppLocalizations.of(context)!.button_ok);
          }
        },
        child: BlocBuilder<PasswordRecoveryBloc, PasswordState>(
          builder: (BuildContext context, PasswordState state){
            return Scaffold(
              appBar: AppTheme.getAppBar(
                  context: context,
                  title: '',
                  subTitle: "",
                  enableBack: true),
              body: SafeArea(
                child: Stack(
                  children: [
                    Padding(
                      padding: EdgeInsets.all(20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 10),
                          ElevatedButton(
                            onPressed: null,
                            child: Icon(
                              Icons.lock_clock,
                              color: appSurfaceWhite,
                            ),
                            style: ButtonStyle(
                              shape: WidgetStateProperty.all(CircleBorder()),
                              padding:
                              WidgetStateProperty.all(EdgeInsets.all(20)),
                              backgroundColor:
                              WidgetStateProperty.all(appGreen300),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Password Recovery',
                            style: GoogleFonts.poppins(
                                fontWeight: FontWeight.bold,
                                fontSize: 24,
                                color: appGreen400),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Text.rich(
                            TextSpan(
                              text: 'Enter your registered phone number',
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.normal,
                                color: Color(0xFF6B7280),
                              ),
                              children: <TextSpan>[
                                TextSpan(
                                  text: ' without your country code',
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey.shade900,
                                  ),
                                ),
                                TextSpan(
                                  text: ' below to proceed to account recovery.',
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.normal,
                                    color: Color(0xFF6B7280),
                                  ),
                                ),
                              ],
                            ),
                          )
                          ,
                          const SizedBox(height: 20),
                          Form(
                              key: _globalKey,
                              child: TextFormField(
                                cursorColor: Theme.of(context).primaryColorDark,
                                maxLength: 10,
                                style: Theme.of(context)
                                    .textTheme
                                    .copyWith(
                                    headlineSmall: Theme.of(context)
                                        .textTheme
                                        .headlineSmall
                                        ?.copyWith(
                                        color: appSurfaceBlack,
                                        fontSize: 16))
                                    .headlineSmall,
                                keyboardType: TextInputType.phone,
                                onChanged: (String value) {
                                  setState(() {
                                    userName = value;
                                  });
                                },
                                textInputAction: TextInputAction.next,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return AppLocalizations.of(context)!
                                        .validation_phone;
                                  }
                                  return null;
                                },
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                      borderRadius:
                                      BorderRadius.all(Radius.circular(8.0))),
                                  hintText:
                                  AppLocalizations.of(context)!.phone_hint,
                                ),
                              )),
                          const SizedBox(height: 40),
                          Container(
                              width: MediaQuery.of(context).size.width,
                              height: MediaQuery.of(context).size.height / 12,
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        flex: 1,
                                        child: Visibility(
                                          visible: true,
                                          // (_globalKey.currentState != null &&
                                          //     _globalKey.currentState!.validate()),
                                          child: ElevatedButton(
                                            style: buttonStyle,
                                            onPressed: () {
                                              if (_globalKey.currentState!
                                                  .validate()) {
                                                //API Hit and Then Get Account Details Here
                                                //Send these details to Account Summary Page for the next Steps
                                                //Navigator.push(context, MaterialPageRoute(builder: (context) => AccountSummary(phoneNumber!)));
                                                //print()
                                                // FocusManager.instance.primaryFocus
                                                //     ?.unfocus();

                                                if(userName!.startsWith('0')){
                                                  userName = userName!.substring(1);
                                                }

                                                var dialCode = context.read<LanguageBloc>().state.selectedLanguage.dialCode!.substring(1);

                                                if(dialCode != '91'){
                                                  dialCode = '250';
                                                }

                                                context.read<PasswordRecoveryBloc>()
                                                  ..add(GetAccountEvent("${dialCode!}${userName!}"));
                                              }
                                            },
                                            child: Text(
                                                AppLocalizations.of(context)!
                                                    .btn_next),
                                          ),
                                        ),
                                      )
                                    ],
                                  )
                                ],
                              ))
                        ],
                      ),
                    ),
                    Visibility(
                        visible: state is PasswordLoading,
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.height,
                          decoration: BoxDecoration(
                              shape: BoxShape.rectangle,
                              color: appBackgroundBlack200,
                              borderRadius: BorderRadius.circular(8)),
                          child: Center(
                            child: Container(
                              width: 30,
                              height: 30,
                              decoration: BoxDecoration(
                                  shape: BoxShape.rectangle,
                                  color: appSurfaceWhite,
                                  borderRadius: BorderRadius.circular(20)),
                              child: const CircularProgressIndicator(),
                            ),
                          ),
                        ))
                  ],
                ),
              ),
            );
          },
        ));
  }
}
