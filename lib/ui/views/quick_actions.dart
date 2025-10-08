import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lipa_quick/core/app_states.dart';
import 'package:lipa_quick/core/models/app_language.dart';
import 'package:lipa_quick/core/models/quick_action_model.dart';
import 'package:lipa_quick/ui/AppColorBuilder.dart';
import 'package:lipa_quick/ui/base_view.dart';
import 'package:lipa_quick/ui/shared/app_colors.dart';
import 'package:lipa_quick/ui/shared/app_theme.dart';
import 'package:lipa_quick/ui/views/login_view.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/view_models/local_db_viewmodel.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../shared/ui_helpers.dart';
import 'dart:math' as math;

import '../widgets/button.dart';
import '../widgets/custom_loading.dart';

class QuickActionsPage extends StatefulWidget {

  final VoidCallback funtion;

  const QuickActionsPage({Key? key, required this.funtion}) : super(key: key);

  @override
  State<QuickActionsPage> createState() => QuickActionsView();
}

class QuickActionsView extends State<QuickActionsPage> {
  int selectionPosition = -1;
  late List<QuickActionModel>? list = [];
  late QuickActionsPage? currentWidget;

  @override
  void initState() {

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    currentWidget = widget;
    return BaseView(
        builder: (BuildContext context, LocalDbViewModel model, Widget? child) {
      return Scaffold(
          appBar:
          AppTheme.getAppBar(context: context
              , title: AppLocalizations.of(context)!.edit_quick_actions
              , subTitle: "", enableBack: true
              , callback: currentWidget!.funtion),
          body: Stack(
            children: [
              SafeArea(
                child: Container(
                    decoration: buildBoxDecoration,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                            flex: 2,
                            child: Column(
                              children: [
                                SizedBox(height: 15),
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Padding(
                                    padding: EdgeInsets.only(left: 15),
                                    child: Text(
                                      AppLocalizations.of(context)!.update_quick_actions,
                                      style: buildTitleStyle,
                                      textAlign: TextAlign.start,
                                    ),
                                  ),
                                ),
                                SizedBox(height: 5),
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Padding(
                                    padding: EdgeInsets.only(left: 15),
                                    child: Opacity(
                                      opacity: 0.50,
                                      child: Text(
                                        AppLocalizations.of(context)!.enable_disable_quick,
                                        style: buildSubTitleStyle,
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(height: 20),
                                Container(
                                  height: MediaQuery.of(context).size.height / 2 ,
                                  child: ListView.builder(
                                    // Let the ListView know how many items it needs to build.
                                    itemCount: list?.length,
                                    // Provide a builder function. This is where the magic happens.
                                    // Convert each item into a widget based on the type of item it is.
                                    itemBuilder: (context, index) {
                                      final item = list?[index];
                                      return ListTile(
                                        title: buildItem(
                                            context, item, index, model),
                                      );
                                    },
                                  ),
                                )
                              ],
                            )),
                      ],
                    )),
              ),
              SafeArea(
                child: Visibility(
                    visible: model.state == ViewState.Loading,
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height,
                      child: Center(
                        child: Container(
                          width: 30,
                          height: 30,
                          child: CircularProgressIndicator(),
                          decoration: BoxDecoration(
                              shape: BoxShape.rectangle,
                              color: appSurfaceWhite,
                              borderRadius: BorderRadius.circular(20)),
                        ),
                      ),
                      decoration: BoxDecoration(
                          shape: BoxShape.rectangle,
                          color: appBackgroundBlack200,
                          borderRadius: BorderRadius.circular(8)),
                    )),
              )
            ],
          ));
    }, onModelReady: (model) {
      var models = model as LocalDbViewModel;
      print('Fetching List');
      models.getAllQuickActions().then((value) => {
            list = value,
            print('Fetching List ${list?.length}'),
            setState(() {})
          });
    });
  }

  Widget buildItem(BuildContext context, QuickActionModel? item, index,
      LocalDbViewModel model) {
    print("Building Item${index}");
    var title = item!.quickActionTitle!.replaceAll('\n', " ");
    return Card(
      color: Colors.white,
      elevation: 1,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          SizedBox(
            width: 10,
          ),
          Container(
            height: MediaQuery.of(context).size.width/9,
            width: MediaQuery.of(context).size.width/9,
            decoration: BoxDecoration(
              image: DecorationImage(image:AssetImage(item.iconPath!),fit: BoxFit.scaleDown),
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(
            width: 10,
          ),
          Expanded(
              child: Text(
                title,
                style: buildTitleStyle,
              )),
          Container(
            padding: EdgeInsets.all(7.0),
            child: Switch(
              // This bool value toggles the switch.
              value: item.isEnabled == 1,
              activeColor: appGreen400,
              onChanged: (bool value) {
                item.isEnabled = item.isEnabled == 1 ? 0 : 1;
                // This is called when the user toggles the switch.
                model.updateItem(item).then((value) => {setState(() {})});
              },
            ),
          )
        ],
      ),
    );
  }

  TextStyle get buildTitleStyle {
    return GoogleFonts.poppins(
        fontSize: 14, color: Colors.black, fontWeight: FontWeight.w700);
  }

  TextStyle get buildSubTitleStyle {
    return GoogleFonts.poppins(
        fontSize: 11, color: Colors.black, fontWeight: FontWeight.w500);
  }

  BoxDecoration get buildBoxDecoration {
    return const BoxDecoration(
        gradient: LinearGradient(
            begin: Alignment.bottomRight,
            end: Alignment.topLeft,
            colors: [Colors.white, Colors.white]));
  }

  void createItems() {
    // items = <AppLanguageModel>[];
    // items.addAll(AppLanguageModel.languages());
  }

  savePreference(int select) async {
    var pref = await SharedPreferences.getInstance();
    String? code = pref.getString('language');
    print('Language Code Saved {$code} and Position:${select}');
    //Navigator.pushAndRemoveUntil(context, LoginPage.route(), (route) => false);
  }
}
