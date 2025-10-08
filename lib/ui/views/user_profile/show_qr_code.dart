import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lipa_quick/core/models/profile/profile_details_response.dart';
import 'package:lipa_quick/ui/app_router.dart';
import 'package:lipa_quick/ui/shared/app_colors.dart';
import 'package:lipa_quick/ui/shared/app_theme.dart';
import 'package:lipa_quick/ui/shared/image_util.dart';

class ShowQrCodeScreen extends StatelessWidget {
  final ProfileDetailsResponse? myQRCode;

  const ShowQrCodeScreen(this.myQRCode, {super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(child: Scaffold(
      appBar: AppTheme.getAppBar(
          context: context, title: '', subTitle: '', enableBack: true),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width/1.5,
              height: MediaQuery.of(context).size.width/1.5,
              child: Card(
                child: myQRCode != null
                    ? ImageUtil().imageFromBase64String(myQRCode!.getMyQRCode()
                    , MediaQuery.of(context).size.width/1.5, MediaQuery.of(context).size.width/1.5)
                    : const Icon(Icons.question_mark),
              ),
            ),
            Padding(
                padding: EdgeInsets.all(20),
                child: Text.rich(getDescription(myQRCode!))),
          ],
        ),
      ),
    ), onPopInvoked: AppRouter().onBackPressed,);
  }
}

TextSpan getDescription(ProfileDetailsResponse myQRCode) {
  return TextSpan(
      text: 'Payment made to this QR, will be received in your',
      children: <InlineSpan>[
        TextSpan(
          text: ' default linked bank account.',
          style: TextStyle(color: appGreen400),
        )
      ]);
}
