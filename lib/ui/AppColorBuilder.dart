import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:lipa_quick/ui/shared/app_theme.dart';
import 'package:provider/provider.dart';
import '../core/localization/app_language_pref.dart';
import 'base_view.dart';
import 'shared/app_colors.dart';
import 'shared/colors/color_schemes.g.dart';
import 'shared/colors/custom_color.g.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class MaterialAppBuilder extends StatelessWidget {
  MaterialAppBuilder({
    Key? key,
    required this.widget,
  }) : super(key: key);

  late AppLanguage _appLocale;
  final Widget widget;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Locale?>(
        future: loadAppLocale(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return MaterialApp(home: DynamicColorBuilder(
              builder: (ColorScheme? lightDynamic,
                  ColorScheme? darkDynamic) {
                ColorScheme lightScheme;
                ColorScheme darkScheme;

                if (lightDynamic != null && darkDynamic != null) {
                  lightScheme = lightDynamic.harmonized();
                  lightCustomColors =
                      lightCustomColors.harmonized(lightScheme);

                  // Repeat for the dark color scheme.
                  darkScheme = darkDynamic.harmonized();
                  darkCustomColors =
                      darkCustomColors.harmonized(darkScheme);
                } else {
                  // Otherwise, use fallback schemes.
                  lightScheme = lightColorScheme;
                  darkScheme = darkColorScheme;
                }

                print('Not Null Preference, Loading ${_appLocale.appLocal
                    .languageCode}');

                return MaterialApp(
                    debugShowCheckedModeBanner: false,
                    theme: ThemeData(
                      useMaterial3: true,
                      colorScheme: lightScheme,
                      extensions: [lightCustomColors],
                    ),
                    darkTheme: ThemeData(
                      useMaterial3: true,
                      colorScheme: darkScheme,
                      extensions: [darkCustomColors],
                    ),
                    localizationsDelegates: const [
                      AppLocalizations.delegate, // Add this line
                      GlobalMaterialLocalizations.delegate,
                      GlobalWidgetsLocalizations.delegate,
                      GlobalCupertinoLocalizations.delegate,
                    ],
                    supportedLocales: const[
                      const Locale('en', ''),
                      const Locale('fr', ''),
                    ],
                    locale: _appLocale.appLocal,
                    home: widget);
              },
            ));
          } else if (snapshot.hasError) {
            return Text("${snapshot.error}");
          }
          return Center(child: CircularProgressIndicator());
        },
    );
    // return BaseView<AppLanguage>(
    //     onModelReady: (model) {
    //       _appLocale = model;
    //       _appLocale.fetchLocale();
    //       print('Not Null Preference, Loading ${_appLocale.appLocal
    //           .languageCode}');
    //     },
    //     builder: (context, model, child) =>);
  }

  Future<Locale?> loadAppLocale() async{
    _appLocale = AppLanguage();
    return _appLocale.fetchLocale();
  }
}

class MaterialApp_Builder extends StatefulWidget {
  MaterialApp_Builder({
    Key? key,
    required this.widget,
  }) : super(key: key);

  final Widget widget;

  @override
  State<StatefulWidget> createState() =>
      MaterialAppBuilderState(mCurrentWidget: widget);
}


class MaterialAppBuilderState extends State<MaterialApp_Builder> {

  MaterialAppBuilderState({Key? key, required this.mCurrentWidget});

  var _appLocale;
  final Widget? mCurrentWidget;

  @override
  void initState() {
    super.initState();
    _appLocale = Provider.of<AppLanguage>(context);
  }

  @override
  void didChangeDependencie() {
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        theme: AppTheme.buildAppTheme()!,
        debugShowCheckedModeBanner: false,
        localizationsDelegates: const [
          AppLocalizations.delegate, // Add this line
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const[
          const Locale('en', ''),
          const Locale('fr', ''),
        ],
        locale: _appLocale.appLocal,
        home: mCurrentWidget);
  }

}
