import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:lipa_quick/core/managers/password_recovery/recover_account.dart';
import 'package:lipa_quick/core/services/api.dart';
import 'package:lipa_quick/main.dart';
import 'package:lipa_quick/ui/shared/app_colors.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:lipa_quick/ui/shared/routing/app_router.dart';
import 'package:lipa_quick/ui/shared/ui_styles.dart';
import 'package:lipa_quick/ui/views/otp/otp_screen.dart';
import 'package:lipa_quick/ui/views/otp/password_otp_screen.dart';

class AccountSummary extends StatelessWidget {
  final String phoneNumber;

  AccountSummary(this.phoneNumber, {super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => PasswordRecoveryBloc(locator<Api>()),
      child: AccountRecoveryWidget(phoneNumber),
    );
  }
}

class AccountRecoveryWidget extends StatefulWidget {
  final String phoneNumber;

  const AccountRecoveryWidget(this.phoneNumber, {super.key});

  @override
  State<StatefulWidget> createState() => AccountRecoveryWidgetState();
}

class AccountRecoveryWidgetState extends State<AccountRecoveryWidget> {
  String? phoneNumber;

  final _globalKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PasswordRecoveryBloc, PasswordState>(
        builder: (context, state) {
      return Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: null,
                  child: const Icon(
                    Icons.person_pin,
                    color: appSurfaceWhite,
                  ),
                  style: ButtonStyle(
                    shape: MaterialStateProperty.all(const RoundedRectangleBorder()),
                    padding: MaterialStateProperty.all(const EdgeInsets.all(20)),
                    backgroundColor: MaterialStateProperty.all(appGreen300),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Verify Identity',
                  style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                      color: appGreen400),
                ),
                const SizedBox(
                  height: 20,
                ),
                Text(
                  'LipaQuick will send a security code to the below mobile number to validate your account.',
                  style: GoogleFonts.poppins(
                      fontWeight: FontWeight.normal, color: const Color(0xFF6B7280)),
                ),
                const SizedBox(height: 20),
                Container(
                  decoration: const BoxDecoration(
                    color: Color(0x409CA3AF),
                    borderRadius: BorderRadius.all(Radius.circular(10.0))
                  ),
                  child: ListTile(
                    title: const Text('Phone'),
                    subtitle: Text(getObsfucatedPhone(widget.phoneNumber)),
                    leading: const Icon(
                      Icons.check_circle,
                      color: appGreen400,
                    ),
                    trailing: const Icon(Icons.phone),
                    titleTextStyle: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                      color: appSurfaceBlack
                    ),
                  ),
                ),
                SizedBox(height: (MediaQuery.of(context).size.height / 10)),
                Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height / 7,
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
                                    Navigator.of(context).pop();
                                    // Navigator.of(context)
                                    //     .push(MaterialPageRoute(builder: (context) => ));
                                    Navigator.of(context).push(
                                        MaterialPageRoute(builder: (context) => PasswordOtpScreen(phoneNo: widget.phoneNumber)));
                                    // context.pushNamed(LipaQuickAppRouteMap.account_otp_verification_name
                                    //     , pathParameters: {'phoneNumber': widget.phoneNumber});
                                  },
                                  child: Text(
                                      AppLocalizations.of(context)!.button_continue),
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
        ),
      );
    });
  }
}

String getObsfucatedPhone(String phoneNumber) {
  return '${phoneNumber.substring(0, 2)}******${phoneNumber.substring(phoneNumber.length - 2, phoneNumber.length)}';
}
