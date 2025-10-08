import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

abstract class ThemeText {
  static TextStyle headingTextStyle = GoogleFonts.poppins(textStyle: TextStyle(
      color: Colors.black,
      fontSize: 24,
      fontWeight: FontWeight.w700));
  static TextStyle subHeadingTextStyle = GoogleFonts.poppins(textStyle: TextStyle(
      color: Colors.black,
      fontSize: 18,
      fontWeight: FontWeight.w600));
  static TextStyle titleTextStyle = GoogleFonts.poppins(textStyle: TextStyle(
    color: Colors.black,
    fontSize: 16,));
  static TextStyle subTitleTextStyle = GoogleFonts.poppins(textStyle: TextStyle(
      color: Colors.black,
      fontSize: 14));
}