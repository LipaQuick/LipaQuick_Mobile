import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lipa_quick/ui/shared/app_colors.dart';
import 'package:flutter_svg/flutter_svg.dart';


class DeadEndPage extends StatelessWidget{
  final VoidCallback? callback;
  final String? buttonHint;

  const DeadEndPage({Key? key, this.callback, this.buttonHint}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final TextStyle headline2 = Theme.of(context).textTheme.displayMedium!;
    final ButtonStyle style = ElevatedButton.styleFrom(
        textStyle: const TextStyle(fontSize: 14, color: appGreen400),
        backgroundColor: appSurfaceWhite,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ));
    return Scaffold(
      body: Stack(
        children: [
          SvgPicture.asset('assets/icon/dead_end.svg'
              , height: MediaQuery.of(context).size.height
              , width: MediaQuery.of(context).size.width),
          Container(
            width: double.infinity,
            height: double.infinity,
            child: Padding(padding: EdgeInsets.all(10.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: MediaQuery.of(context).size.width / 1.3),
                  Text(
                    'Dead End',
                    style: GoogleFonts.poppins(
                        textStyle: headline2.copyWith(fontSize: 21, fontWeight: FontWeight.bold, color: appSurfaceBlack)),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Oops! The page you\'re looking for does\'nt exist',
                    style: GoogleFonts.poppins(
                        textStyle: headline2.copyWith(fontSize: 19, color: appSurfaceBlack)),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 20),
                  Center(
                    child: Visibility(visible: buttonHint != null,child: ElevatedButton(
                      style: style,
                      onPressed: (){callback!();},
                      child: Text(buttonHint == null ? '' : buttonHint!,
                          style: GoogleFonts.poppins(
                              textStyle: headline2.copyWith(fontSize: 19,fontWeight: FontWeight.bold, color: Colors.white))),
                    ),),
                  ),
                ],
              ),),
          )
        ],
      ),
    );
  }

}