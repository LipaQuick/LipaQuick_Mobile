import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lipa_quick/gen/assets.gen.dart';
import 'package:lipa_quick/ui/shared/app_colors.dart';

class AuthorizationFailedWidget extends StatelessWidget {
  final VoidCallback? callback;

  const AuthorizationFailedWidget({Key? key, this.callback}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final TextStyle headline2 = Theme.of(context).textTheme.displayMedium!;
    AssetImage image = AssetImage(Assets.icon.timeout.path);
    Image images = Image(image: image, width: 20, height: 20);
    final ButtonStyle style = ElevatedButton.styleFrom(
        textStyle: const TextStyle(fontSize: 14),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ));
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [Color(0x8be3ffe7), Color(0x11d9e7ff)])),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(width: 120, height: 120, child: images),
              const SizedBox(height: 30),
              Text(
                "Oops, Your session\nhas expired",
                style: GoogleFonts.poppins(
                    textStyle: headline2.copyWith(
                        fontSize: 21,
                        fontWeight: FontWeight.bold,
                        color: appSurfaceBlack)),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Text(
                "Your session has expired due to your inactivity. \n No worry, simply login again.",
                style: GoogleFonts.poppins(
                    textStyle: headline2.copyWith(fontSize: 16)),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                style: style,
                onPressed: () {
                  callback!();
                },
                child: Text("LOGIN",
                    style: GoogleFonts.poppins(
                        textStyle: headline2.copyWith(
                            fontSize: 19,
                            fontWeight: FontWeight.bold,
                            color: appSurfaceBlack))),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class EmptyViewFailedWidget extends StatelessWidget {
  final VoidCallback? callback;
  final String title, message;
  final String? buttonHint;
  final IconData icon;

  const EmptyViewFailedWidget(
      {Key? key,
      this.callback,
      required this.title,
      required this.message,
      required this.icon,
      this.buttonHint})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    print(icon);
    final TextStyle headline2 = Theme.of(context).textTheme.displayMedium!;
    final ButtonStyle style = ElevatedButton.styleFrom(
        textStyle: const TextStyle(fontSize: 14),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ));
    return Scaffold(
      body: Container(
        // width: MediaQuery.of(context).size.width,
        // height: MediaQuery.of(context).size.height,
        decoration: const BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [Color(0x8be3ffe7), Color(0x11d9e7ff)])),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 100,
                height: 100,
                child: Card(
                  color: const Color(0x8be3ffe7),
                  child: Icon(
                    icon,
                    size: 50,
                  ),
                ),
              ),
              const SizedBox(height: 30),
              Text(
                title,
                style: GoogleFonts.poppins(
                    textStyle: headline2.copyWith(
                        fontSize: 21,
                        fontWeight: FontWeight.bold,
                        color: appSurfaceBlack)),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Text(
                message,
                style: GoogleFonts.poppins(
                    textStyle: headline2.copyWith(fontSize: 16)),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              Visibility(
                visible: buttonHint != null,
                child: ElevatedButton(
                  style: style,
                  onPressed: () => callback!(),
                  child: Text(buttonHint ?? '',
                      style: GoogleFonts.poppins(
                          textStyle: headline2.copyWith(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: appSurfaceWhite))),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
