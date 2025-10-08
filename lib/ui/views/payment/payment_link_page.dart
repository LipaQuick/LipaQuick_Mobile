import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lipa_quick/core/models/response.dart';
import 'package:lipa_quick/core/services/local_shared_pref.dart';
import 'package:lipa_quick/gen/assets.gen.dart';
import 'package:lipa_quick/ui/shared/app_colors.dart';
import 'package:lipa_quick/ui/shared/app_theme.dart';
import 'package:lipa_quick/ui/views/add_account/add_account.dart';
import 'package:lipa_quick/ui/views/cards/add_card.dart';
import 'package:lipa_quick/ui/views/dashboard/dashboard_page.dart';
import 'package:lipa_quick/ui/views/wallet/wallet_link_page.dart';

class PaymentLinkPage extends StatelessWidget {
  //UserDetails userDetails;
  const PaymentLinkPage({super.key});

  Future<bool> _onBackPressed(bool canPop) {
    final Completer<bool> completer = Completer<bool>();
    completer.complete(true);

    return completer.future;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(onPopInvoked: _onBackPressed, child: Scaffold(
      appBar: AppTheme.getAppBarWithActions(
          context: context,
          title: 'Payment Method',
          subTitle: '',
          enableBack: true,
          actions: getActions(context)),
      backgroundColor: Color(0xFFEFF1F3),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CardWidget(
              iconPath: Assets.icon.mtnmomo,
              title: 'Link Wallet',
              subtitle: 'You can link your MTN wallet here.',
              onPressed: () async {
                // Handle button press for MTN wallet card
                var user = await LocalSharedPref().getUserDetails();
                UserDetails userDetail = UserDetails.fromJson(jsonDecode(user));
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => WalletLinkPage(
                      userDetails: userDetail,
                      goToHome: false,
                    ),
                  ),
                );
              },
            ),
            CardWidget(
              iconPath: Assets.icon.ecobankLogo,
              title: 'Link Eco Bank Account',
              subtitle: 'Add your eco bank account here.',
              onPressed: () {
                // Handle button press for Eco Bank card
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => AddAccountPage(true),
                  ),
                );
              },
            ),
            CardWidget(
              iconPath: Assets.icon.masterCardIcon,
              title: 'Link Credit/Debit Card',
              subtitle:
              'Add your credit or debit card, and use it to transfer money.',
              onPressed: () async {
                // Handle button press for Credit/Debit card
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => AddCardPage(goToHome: true),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    ));
  }

  List<Widget>? getActions(BuildContext context) {
    return <Widget>[
      InkWell(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: EdgeInsets.all(4),
              child: Text(
                'Skip',
                style: GoogleFonts.poppins(
                    color: appGreen400, fontWeight: FontWeight.w600),
              ),
            )
          ],
        ),
        onTap: () {
          Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => HomePage()),
              (Route<dynamic> route) => false);
        },
      )
    ];
  }
}

class CardWidget extends StatelessWidget {
  final dynamic iconPath;
  final String title;
  final String subtitle;
  final VoidCallback onPressed;

  CardWidget({
    required this.iconPath,
    required this.title,
    required this.subtitle,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    Widget icon = Container();
    try{
      icon =  iconPath is SvgGenImage
          ? (iconPath as SvgGenImage).svg(width: 150, height: 80)
          : (iconPath as AssetGenImage).image(width: 150, height: 80);
    }catch(e){
      print(e);
    }
    return Card(
      elevation: 5.0,
      margin: EdgeInsets.all(16.0),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            child: icon,
          ),
          Container(
            decoration: BoxDecoration(color: Color(0xE6FFFFFF)),
            child: Column(
              children: [
                ListTile(
                  leading: iconPath is SvgGenImage
                      ? (iconPath as SvgGenImage).svg(width: 60, height: 40)
                      : (iconPath as AssetGenImage)
                          .image(width: 40, height: 40),
                  title: Text(title, style: GoogleFonts.poppins(fontSize: 19)),
                  subtitle:
                      Text(subtitle, style: GoogleFonts.poppins(fontSize: 16)),
                ),
                ButtonBar(
                  children: [
                    TextButton(
                      onPressed: onPressed,
                      child: Text(title),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
