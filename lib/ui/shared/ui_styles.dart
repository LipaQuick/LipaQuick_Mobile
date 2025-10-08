import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

final ButtonStyle buttonStyle = ElevatedButton.styleFrom(
    textStyle: GoogleFonts.poppins(textStyle: const TextStyle(fontSize: 20)),
    fixedSize: const Size.fromHeight(45),
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(4))),
    foregroundColor: appSurfaceWhite,
    backgroundColor: appGreen400);