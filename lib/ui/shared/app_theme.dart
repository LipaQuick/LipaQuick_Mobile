import 'dart:ffi';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:lipa_quick/gen/assets.gen.dart';
import 'package:lipa_quick/ui/shared/app_colors.dart';

class ColorsLib {
  static Color primary = const Color(0xFF3BB143);
  static Color primaryDarker = const Color(0xFF2E8934);
  static Color darkPrimary = const Color(0xFF1D2027);
  static Color blueGreyPrimary = const Color(0xFF819399);
  static Color blueGreySecondary = const Color(0xFFADC4CB);
  static Color lightGrey = const Color(0xFFF1F5F9);

  static Color  appSecondary900 = Color(0xFFA461b8);
  static Color  appSecondary600 = Color(0xffad7cbd);

  static Color  appErrorRed = Color(0xFFC5032B);

  static Color  appSurfaceWhite = Color(0xFFFFFBFA);
  static Color  appBackgroundBlack200 = Colors.black12;
  static Color  appSurfaceBlack = Color(0xFF000000);
  static Color  appBackgroundWhite = Colors.white;

  static Color  appGrey400 = Color(0xFFB1B1B1);
  static Color  appGrey200 = Color(0xFFDDDDDD);
  static Color  appGrey100 = Color(0xFFF6F6F6);

  //Transaction Status Color's
  static var transactionPendingLight = Color(0xfffffbe0);
  static var transactionPendingDark = Color(0xffffd233);

  static var transactionSuccessLight = Color(0xffE0FFF0);
  static var transactionSuccessDark = Color(0xff3BB143);

  static var transactionFailureLight = Color(0xffFFE0E0);
  static var transactionFailureDark = Color(0xffFF9790);
}

class AppTheme {

  static ThemeData? buildAppTheme() {
    final ThemeData base = ThemeData.light();
    return base.copyWith(
        colorScheme: base.colorScheme.copyWith(
          primary: appGreen400,
          secondary: appGreen300,
          error: appErrorRed,
        ),
        buttonTheme: ButtonThemeData(
          // 4
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.0)),
          buttonColor: appGreen400,
        ),
        // TODO: Add the text themes (103)
        textTheme: TextTheme(
          displaySmall: TextStyle(color: Colors.black),
          displayLarge: TextStyle(color: Colors.black),
          displayMedium: TextStyle(color: Colors.black),
          bodyLarge: TextStyle(color: Colors.black),
          bodyMedium: TextStyle(color: Colors.black),
          bodySmall: TextStyle(color: Colors.black),
          labelLarge: TextStyle(color: Colors.black),
          labelMedium: TextStyle(color: Colors.black),
          labelSmall: TextStyle(color: Colors.black),
          titleLarge: TextStyle(color: Colors.black),
          titleMedium: TextStyle(color: Colors.black),
          titleSmall: TextStyle(color: Colors.black),
        )
        // TODO: Add the icon themes (103)
        // TODO: Decorate the inputs (103)
        );
  }

  static PreferredSizeWidget getAppBar({required BuildContext context, required String title
    , required String subTitle,required  bool enableBack, VoidCallback? callback}) {
    return AppBar(
      leading: enableBack
          ? IconButton(
              icon: Icon(Icons.arrow_back_sharp, color: Colors.black),
              onPressed: () {
                //context.pop();
                Navigator.pop(context);
                if(callback != null){
                  callback();
                }
              },
            )
          : null,
      title: Text(title, style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 18),),
      titleTextStyle: const TextStyle(color: Colors.black),
      backgroundColor: Colors.white,
    );
  }
  static PreferredSizeWidget getAppBarWithActions({required BuildContext context, required String title
    , required String subTitle,required  bool enableBack, VoidCallback? callback, List<Widget>? actions}) {
    return AppBar(
      leading: enableBack
          ? IconButton(
              icon: Icon(Icons.arrow_back_sharp, color: Colors.black),
              onPressed: () {
                Navigator.pop(context);
                if(callback != null){
                  callback();
                }
              },
            )
          : null,
      title: Text(title, style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 18),),
      titleTextStyle: const TextStyle(color: Colors.black),
      backgroundColor: Colors.white,
      actions: actions,
    );
  }

  static PreferredSizeWidget getHomeBar({required BuildContext context
    , required VoidCallback onMenuPressed, required VoidCallback onSearchPressed, required VoidCallback onQrPressed}) {
    AssetImage image = AssetImage(Assets.icon.lauchericon.path);
    Image images =
    Image(image: image, width: 120, height: 50, fit: BoxFit.cover);
    return AppBar(
      leading: IconButton(
        icon: Icon(Icons.menu, color: appGreen400),
        onPressed: () {
          onMenuPressed();
        },
      ),
      title: Container(
        child: images,
      ),
      backgroundColor: Colors.white,
      actions: <Widget>[
        IconButton(
          icon: Icon(Icons.qr_code_scanner, color: appGreen400),
          onPressed: () {
            onQrPressed();
          },
        ),
        IconButton(
          icon:
              Icon(Icons.search, color: appGreen400),
          onPressed: () {
            onSearchPressed();
          },
        )
      ],
    );
  }
}
