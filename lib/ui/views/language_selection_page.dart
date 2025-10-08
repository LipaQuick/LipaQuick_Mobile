import 'package:flutter/material.dart';
import 'package:lipa_quick/core/models/app_language.dart';
import 'package:lipa_quick/ui/views/login_view.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../gen/assets.gen.dart';
import '../shared/ui_helpers.dart';
import 'dart:math' as math;

import '../widgets/button.dart';
import '../widgets/custom_loading.dart';

class MyInheritedWidget extends InheritedWidget {
  int selectionPosition = -1;

  MyInheritedWidget(this.selectionPosition, {Key? key, child})
      : super(key: key, child: child);

  static MyInheritedWidget of(BuildContext context) {
    final MyInheritedWidget? result = context.dependOnInheritedWidgetOfExactType<MyInheritedWidget>();
    //assert(result != null, 'No MyInheritedWidget found in context');
    return result!;
  }

  @override
  bool updateShouldNotify(MyInheritedWidget oldWidget) => selectionPosition != oldWidget.selectionPosition;
}

class LanguagePage extends StatefulWidget {
  static Route route() {
    return MaterialPageRoute<void>(builder: (_) => const LanguagePage());
  }

  const LanguagePage({Key? key}) : super(key: key);

  @override
  State<LanguagePage> createState() => LanguagePageView();
}

class LanguagePageView extends State<LanguagePage> {
  late List<AppLanguageModel> items;
  int selectionPosition = -1;
  final _formKey = GlobalKey<LanguagePageView>();

  @override
  void initState() {
    createItems();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    AssetImage image = AssetImage(Assets.icon.lauchericon.path);
    Image images = Image(image: image, width: 200, height: 100);
    EdgeInsets insets = UIHelper.smallSymmetricPadding();
    var selectionWidget = SelectItemWidget(items);
    return Scaffold(
      body: SafeArea(
        child: MyInheritedWidget(
          selectionPosition,
          key: _formKey,
          child: Container(
              decoration: buildBoxDecoration,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width,
                        child: images,
                      )),
                  Expanded(
                      flex: 2,
                      child: Column(
                        children: [
                          Padding(
                              padding: insets,
                              child: Text(
                                'Select your default language',
                                style: buildTextStyle,
                              )),
                          SizedBox(
                            height: MediaQuery.of(context).size.height / 2.5,
                            child: selectionWidget,
                          )
                        ],
                      )),
                  Container(
                      padding: EdgeInsets.all(10.0),
                      child: CustomLoadingButton(
                        defaultWidget: const Text('Proceed',
                            style:
                            TextStyle(color: Colors.white, fontSize: 20)),
                        progressWidget: ThreeSizeDot(),
                        color: Colors.green,
                        height: 45,
                        borderRadius: 24,
                        animate: false,
                        onPressed: () async {
                          savePreference(selectionPosition);
                        },
                      ))
                ],
              )),
        ),
      ),
    );
  }

  TextStyle get buildTextStyle {
    return const TextStyle(
        fontStyle: FontStyle.normal, color: Colors.black, fontSize: 21, fontFamily: 'Poppins');
  }

  BoxDecoration get buildBoxDecoration {
    return const BoxDecoration(
        gradient: LinearGradient(
            begin: Alignment.bottomRight,
            end: Alignment.topLeft,
            colors: [Colors.white, Colors.white]));
  }

  void createItems() {
    items = <AppLanguageModel>[];
    items.addAll(AppLanguageModel.languages());
  }

  savePreference(int select) async {
    var pref = await SharedPreferences.getInstance();
    String? code = pref.getString('language');
    print('Language Code Saved {$code} and Position:${select}');
    //Navigator.pushAndRemoveUntil(context, LoginPage.route(), (route) => false);
  }
}

class SelectItemWidget extends StatefulWidget {
  var items;

  SelectItemWidget(this.items, {Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => SelectItemState(items);
}

class SelectItemState extends State<SelectItemWidget> {
  List<AppLanguageModel> items;

  SelectItemState(this.items);

  savePreference() async {
    var pref = await SharedPreferences.getInstance();
    print('Selected Pref ${items[MyInheritedWidget.of(context).selectionPosition].languageCode}');
    pref.setString('language', items[MyInheritedWidget.of(context).selectionPosition].languageCode);
    //Navigator.pushAndRemoveUntil(context, LoginPage.route(), (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Flexible(
        child: ListView.builder(
          // Let the ListView know how many items it needs to build.
          itemCount: items.length,
          // Provide a builder function. This is where the magic happens.
          // Convert each item into a widget based on the type of item it is.
          itemBuilder: (context, index) {
            final item = items[index];
            return ListTile(
              title: buildItem(context, item, index),
              onTap: () {
                setState(() {
                  try{
                    savePreference();
                    MyInheritedWidget.of(context).selectionPosition = index;
                  }catch(e){
                    print(e);
                  }
                });
              },
            );
          },
        ),
      ),
    );
  }

  Widget buildItem(BuildContext context, AppLanguageModel item, index) {
    return Card(
      color: Colors.white,
      elevation: 4,
      child: Padding(
          padding: EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.black38),
                child: Center(
                  child: Text(
                    item.languageCode.toUpperCase(),
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
              Expanded(
                  child: Padding(
                padding: EdgeInsets.all(7.0),
                child: Text(
                  item.name,
                  style: TextStyle(
                      fontSize: 16.0,
                      color: MyInheritedWidget.of(context).selectionPosition != -1 && MyInheritedWidget.of(context).selectionPosition == index
                          ? Colors.green
                          : Colors.black),
                ),
              )),
              Padding(
                padding: EdgeInsets.all(7.0),
                child: Icon(Icons.check_circle,
                    color: MyInheritedWidget.of(context).selectionPosition != -1 && MyInheritedWidget.of(context).selectionPosition == index
                        ? Colors.green
                        : Colors.black),
              )
            ],
          )),
    );
  }

  _onItemSelected() {}
}
