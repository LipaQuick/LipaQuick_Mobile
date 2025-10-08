import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lipa_quick/ui/shared/colors/color_schemes.g.dart';
import 'package:material_dialogs/material_dialogs.dart';
import 'package:material_dialogs/widgets/buttons/icon_button.dart';
import 'package:material_dialogs/widgets/buttons/icon_outline_button.dart';

import '../app_colors.dart';

enum DialogType {
  SUCCESS,
  FAILURE,
  INFO
}



abstract class DialogFactory {
  factory DialogFactory(DialogType dialogType) {
    switch (dialogType) {
      case DialogType.SUCCESS:
        return CustomDialog(dialogType);
      case DialogType.FAILURE:
        return CustomDialog(dialogType);
      default:
        return CustomDialog(dialogType);
    }
  }

  void buildAndShowDialog({
    @required BuildContext context,
    @required String title,
    @required String message,
    String buttonPositive,
    String buttonNegative,
    VoidCallback onPositivePressed,
    VoidCallback onNegativePressed,
  });
}

class CustomDialog implements DialogFactory {
  late AnimationController controller;
  late Animation<double> scaleAnimation;

  var dialogType;
  var backgroundColor;
  late IconData icons;
  late EdgeInsets titleEdgeInset;

  var titleTextStyle;
  var messageEdgeInset;
  var messageTextStyle;

  var buttonStyle;
  var textStyleButton;

  CustomDialog(DialogType this.dialogType) {
    init_dialog_state(dialogType);
  }

  @override
  void buildAndShowDialog({
    BuildContext? context,
    String? title,
    String? message,
    String? buttonPositive,
    String? buttonNegative,
    bool? cancellable,
    VoidCallback? onPositivePressed,
    VoidCallback? onNegativePressed,
  }) {
    if(buttonNegative!=null && buttonNegative.isNotEmpty){
      showDialog(context: context!, builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: _getBackgroundDialogColor(),
          title: Column(
            mainAxisAlignment:MainAxisAlignment.center,
            children: [
              Icon(_getDialogIcon(), color: _getDialogColor(), size: 40),
              SizedBox(height: 10),
              Text(title!, style: titleTextStyle,),
            ],
          ),
          content: Text(message!, style: messageTextStyle),
          actions: <Widget>[
            TextButton(
              child: Text(buttonNegative!, style: GoogleFonts.poppins(
                  textStyle: TextStyle(color: lightColorScheme.secondary, fontWeight: FontWeight.bold)
              ),),
              onPressed: onNegativePressed ?? () => Navigator.of(context).pop(),
            ),
            TextButton(
              onPressed: onPositivePressed ?? () => Navigator.of(context).pop(),
              child: Text(buttonPositive!, style: GoogleFonts.poppins(
                  textStyle: TextStyle(color: lightColorScheme.tertiary, fontWeight: FontWeight.bold)
              ),),
            )
          ],
        );
      });

    }
    else{
      showDialog(context: context!, builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: _getBackgroundDialogColor(),
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(32.0))),
          title: Column(
            mainAxisAlignment:MainAxisAlignment.center,
            children: [
              Icon(_getDialogIcon(), color: _getDialogColor(), size: 40),
              SizedBox(height: 10),
              Text(title!, style: titleTextStyle,),
            ],
          ),
          content: Text(message!, style: messageTextStyle),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: lightColorScheme.onPrimary
              ),
              child: Text(buttonPositive!, style: GoogleFonts.poppins(
                textStyle: TextStyle(color: lightColorScheme.tertiary, fontWeight: FontWeight.bold)
              ),),
              onPressed: onPositivePressed ?? () => Navigator.of(context).pop(),
            ),
          ],
        );
      });
    }
  }

  Color _getDialogColor() {
    switch (dialogType) {
      case DialogType.SUCCESS:
        return Colors.green;
      case DialogType.FAILURE:
        return Colors.red;
      case DialogType.INFO:
        return Colors.blue;
      default:
        return Colors.black;
    }
  }

  Color _getBackgroundDialogColor() {
    switch (dialogType) {
      case DialogType.SUCCESS:
        return Color(0xFFF5FFF9);
      case DialogType.FAILURE:
        return Colors.red.shade50;
      case DialogType.INFO:
        return Colors.blue.shade50;
      default:
        return Colors.white;
    }
  }

  IconData _getDialogIcon() {
    switch (dialogType) {
      case DialogType.SUCCESS:
        return Icons.check_circle;
      case DialogType.FAILURE:
        return Icons.error;
      case DialogType.INFO:
        return Icons.info;
      default:
        return Icons.info;
    }
  }

  void init_dialog_state(dialogType) {
    switch (dialogType) {
      case DialogType.INFO:
        backgroundColor = const Color.fromARGB(255, 245, 255, 249);
        buttonStyle = TextButton.styleFrom(
          foregroundColor: appSecondary900,
          minimumSize: const Size(88, 36),
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(2.0)),
          ),
        );
        icons = Icons.check_circle;
        break;
      case DialogType.SUCCESS:
        backgroundColor = const Color.fromARGB(255, 245, 255, 249);
        buttonStyle = TextButton.styleFrom(
          foregroundColor: appGreen400,
          minimumSize: const Size(88, 36),
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(2.0)),
          ),
        );
        icons = Icons.info;
        break;
      case DialogType.FAILURE:
        backgroundColor = const Color.fromARGB(255, 245, 255, 249);
        buttonStyle = TextButton.styleFrom(
          foregroundColor: appGreen400,
          minimumSize: Size(88, 36),
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(2.0)),
          ),
        );
        icons = Icons.clear;
        break;
    }
    textStyleButton = const TextStyle(color: Colors.black, fontSize: 19);

    titleEdgeInset = const EdgeInsets.all(10.0);
    titleTextStyle = GoogleFonts.poppins(
      textStyle: TextStyle(
          color: Colors.black, fontSize: 19, fontWeight: FontWeight.bold)
    );

    messageEdgeInset = const EdgeInsets.all(10.0);
    messageTextStyle =  GoogleFonts.poppins(
      textStyle: TextStyle(
          color: Colors.black, fontSize: 19, fontWeight: FontWeight.normal)
    );
  }

  @override
  void show(Widget widget) {}
}
