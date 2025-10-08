import 'package:flutter/material.dart';

const Color backgroundColor = Color.fromARGB(255, 179, 179, 179);

const appGreen50 = Color(0xFFCDE4C7);
const appGreen100 = Color(0xFFAED3A4);
const appGreen300 = Color(0xFF8FC380);
const appGreen400 = Color(0xFF3BB143);

const appSecondary900 = Color(0xFFA461b8);
const appSecondary600 = Color(0xffad7cbd);

const appErrorRed = Color(0xFFC5032B);
const appErrorRed100 = Color(0xFFF92828);

const appSurfaceWhite = Color(0xFFFFFBFA);
const appBackgroundBlack200 = Colors.black12;
const appSurfaceBlack = Color(0xFF000000);
const appBackgroundWhite = Colors.white;

const appGrey400 = Color(0xFFB1B1B1);
const appGrey200 = Color(0xFFDDDDDD);
const appGrey100 = Color(0xFFF6F6F6);

Color getColor(Set<MaterialState> states) {
  const Set<MaterialState> interactiveStates = <MaterialState>{
    MaterialState.pressed,
    MaterialState.hovered,
    MaterialState.focused,
  };
  if (states.any(interactiveStates.contains)) {
    return appGreen100;
  }
  return appGreen400;
}


