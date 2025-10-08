import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lipa_quick/core/app_states.dart';
import 'package:lipa_quick/core/models/contacts/contacts.dart';
import 'package:lipa_quick/core/models/contacts/contacts_response_model.dart';
import 'package:lipa_quick/core/models/quick_action_model.dart';
import 'package:lipa_quick/core/view_models/local_db_viewmodel.dart';
import 'package:lipa_quick/gen/assets.gen.dart';
import 'package:lipa_quick/main.dart';
import 'package:lipa_quick/ui/base_view.dart';
import 'package:lipa_quick/ui/shared/app_colors.dart';
import 'package:lipa_quick/ui/shared/ui_helpers.dart';
import 'package:lipa_quick/ui/views/contacts/search_contacts.dart';
import 'package:lipa_quick/ui/views/payment/payment_screen.dart';
import 'package:lipa_quick/ui/views/payment/transfer_account.dart';
import 'package:lipa_quick/ui/views/qrcode/barcode_scanner_window.dart';
import 'package:lipa_quick/ui/views/quick_actions.dart';

import '../../contacts/user_contacts.dart';

class MainHomePage extends StatefulWidget {
  const MainHomePage({Key? key}) : super(key: key);

  @override
  State<MainHomePage> createState() => HomePageState();
}

class HomePageState extends State<MainHomePage> with WidgetsBindingObserver {
  List<QuickActionModel?> list = [];
  LocalDbViewModel? localModel;

  methodInParent() => {
        if (localModel != null) {loadData(localModel!)}
      };

  @override
  Widget build(BuildContext context) {
    return BaseView<LocalDbViewModel>(
        builder: (BuildContext context, LocalDbViewModel model, Widget? child) {
      return SafeArea(
          child: Stack(
        children: [
          Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 5),
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(left: 10, right: 10),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          "Quick Actions",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                              color: appSurfaceBlack,
                              fontSize: 14,
                              fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(width: 10),
                        Container(
                          padding: const EdgeInsets.all(2),
                          child: Stack(
                            alignment: AlignmentDirectional.center,
                            children: [
                              CircleAvatar(
                                backgroundImage:
                                    AssetImage(Assets.icon.lauchericon.path),
                                radius: 15,
                                backgroundColor: appGreen400,
                              ),
                              IconButton(
                                  onPressed: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                QuickActionsPage(
                                                  funtion: methodInParent,
                                                )));
                                  },
                                  iconSize: 15,
                                  icon: const Icon(Icons.edit,
                                      color: Colors.white)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  GridView.builder(
                      physics: ScrollPhysics(),
                      scrollDirection: Axis.vertical,
                      itemCount: list.length,
                      shrinkWrap: true,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 4,
                              childAspectRatio: 0.76,
                              crossAxisSpacing: 4,
                              mainAxisSpacing: 5),
                      itemBuilder: (context, index) {
                        var item = list[index];
                        return InkWell(
                          onTap: () async {
                            print(item.quickActionTitle);
                            onQuickActions(item);
                          },
                          child: GridTile(
                              child: Card(
                            color: Colors.white,
                            surfaceTintColor: Colors.white,
                            elevation: 1,
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10.0)),
                            ),
                            child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  const SizedBox(height: 10),
                                  Card(
                                    color: appGrey100,
                                    child: Padding(
                                      padding: UIHelper.smallSymmetricPadding(),
                                      child: Image(
                                          //backgroundImage: AssetImage('assets/icon/lauchericon.png'),
                                          image: AssetImage(item!.iconPath!),
                                          width: 20,
                                          height: 20,
                                          fit: BoxFit.cover),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(item.quickActionTitle!,
                                      textAlign: TextAlign.center,
                                      // 'Text',
                                      style: GoogleFonts.poppins(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500))
                                ]),
                          )),
                        );
                      })
                ],
              ),
            ],
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
      //Insert QuickActions
      //initQuickActions();
      localModel = model;
      loadData(model);
    });
  }

  void loadData(LocalDbViewModel model) {
    model.getHomeQuickActions().then((value) => {
          print("Fetch Data, ${value.length}"),
          setState(() {
            list = value!;
          })
        });
  }

  void onQuickActions(QuickActionModel item) async {
    if (item.quickActionTitle?.contains('Contacts') == true) {
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => const ContactsPage()));
    } else if (item.quickActionTitle?.contains('Phone') == true) {
      await showSearch<ContactsAPI>(
        context: context,
        delegate: ContactsSearchDelegate(),
      );
    } else if (item.quickActionTitle?.contains('Scan') == true) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => BarcodePage(),
        ),
      );
    } else if (item.quickActionTitle?.contains('Account') == true) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => const TransferAccountPage(true),
        ),
      );
    }
  }
}
