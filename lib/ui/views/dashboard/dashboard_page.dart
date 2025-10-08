import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lipa_quick/core/models/profile/profile_list_reponse.dart';
import 'package:lipa_quick/core/models/response.dart';
import 'package:lipa_quick/core/services/local_shared_pref.dart';
import 'package:lipa_quick/locator.dart';
import 'package:lipa_quick/main.dart';
import 'package:lipa_quick/ui/shared/app_theme.dart';
import 'package:lipa_quick/ui/views/chat/recent_chat_widget.dart';
import 'package:lipa_quick/ui/views/contacts/search_contacts.dart';
import 'package:lipa_quick/ui/views/dashboard/home/social_post_home.dart';
import 'package:lipa_quick/ui/views/dashboard/payment/payment_page.dart';
import 'package:lipa_quick/ui/views/login_view.dart';
import 'package:lipa_quick/ui/views/nearby_merchant/merchant_location.dart';
import 'package:lipa_quick/ui/views/nearby_merchant/nearby_merchant.dart';
import 'package:lipa_quick/ui/views/payment/transaction_history.dart';
import 'package:lipa_quick/ui/views/qrcode/barcode_scanner_window.dart';
import 'package:lipa_quick/ui/views/settings/SettingsPage.dart';
import 'package:lipa_quick/ui/views/social_post/social_post_create.dart';
import 'package:provider/provider.dart';
import '../../../core/localization/app_language_pref.dart';
import '../../../core/models/contacts/contacts.dart';
import '../../../core/view_models/accounts_viewmodel.dart';
import '../../shared/app_colors.dart';
import '../../shared/dialogs/dialogshelper.dart';
import '../user_profile/customer_profile.dart';
import 'headerview/drawer_header.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:share_plus/share_plus.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  static Route route() {
    return MaterialPageRoute<void>(builder: (_) => const HomePage());
  }

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  static const List<Tab> myTabs = <Tab>[
    Tab(text: 'Home'),
    Tab(text: 'Chat'),
    Tab(text: 'Payment'),
  ];
  final GlobalKey<ScaffoldState> _key = GlobalKey();
  late TabController _tabController;
  int? _currentSelectedItem;

  BuildContext? buildContext;
  bool drawerIsOpen = false;

  callback(newValue) {
    setState(() {
      _currentSelectedItem = newValue;
    });
    if (_currentSelectedItem == 7) {
      performLogout();
    }
  }

  void performLogout() {
    CustomDialog(DialogType.INFO).buildAndShowDialog(
        context: buildContext!,
        cancellable: false,
        title: AppLocalizations.of(context)!.logout_title,
        message: AppLocalizations.of(context)!.logout_msg,
        buttonPositive: AppLocalizations.of(context)!.btn_yes,
        buttonNegative: AppLocalizations.of(context)!.btn_no,
        onPositivePressed: () {
          Navigator.of(context, rootNavigator: true).pop();

          goToLoginPage(context);
        },
        onNegativePressed: () {
          Navigator.of(context, rootNavigator: true).pop();
        });
  }

  void _onWillPop(bool didPop) async {
    print("Back button pressed");

    // final NavigatorState navigator = Navigator.of(context);
    //if(drawerIsOpen){
      //navigator.pop(true);
    //}

    if(didPop){
      return;
    }
    final NavigatorState navigator = Navigator.of(context);
    final bool? shouldPop = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Are you sure?'),
        content: Text('Do you want to exit the app?'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('Yes'),
          ),
        ],
      ),
    );

    if (shouldPop ?? false) {
      print("Exit Application");
      if (Platform.isAndroid) {
        SystemNavigator.pop();
      } else if (Platform.isIOS) {
        exit(0);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, length: myTabs.length);
    //ServicesBinding.instance.keyboard.addHandler(_onKey);
  }

  @override
  void dispose() {
    _tabController.dispose();
    //ServicesBinding.instance.keyboard.removeHandler(_onKey);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    buildContext = context;
    return Consumer2(builder: (BuildContext context, AppLanguage appLang,
        AccountViewModel model, Widget? child) {
      return StreamBuilder(
          stream: locator<Connectivity>().onConnectivityChanged,
          builder: (context, snapshot) {
            return PopScope(onPopInvoked: _onWillPop, canPop: false,child: Scaffold(
                key: _key,
                appBar: AppTheme.getHomeBar(
                    context: context,
                    onMenuPressed: () {
                      if (!_key.currentState!.isDrawerOpen) {
                        setState(() {
                          _key.currentState!.openDrawer();
                        });
                      }
                    },
                    onSearchPressed: () async {
                      await showSearch<ContactsAPI>(
                        context: context,
                        delegate: ContactsSearchDelegate(),
                      );
                    },
                    onQrPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => BarcodePage(),
                        ),
                      );
                    }),
                body: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    SizedBox(
                        height: 50.0,
                        child: TabBar(
                          controller: _tabController,
                          tabs: myTabs,
                          labelColor: appGreen400,
                          unselectedLabelColor: Colors.black,
                          indicatorColor: appGreen400,
                          labelStyle: GoogleFonts.poppins(
                              fontSize: 14, fontWeight: FontWeight.w600),
                        )),
                    Visibility(
                      visible: (snapshot.hasData &&
                          (snapshot.data == null ||
                              snapshot.data == ConnectivityResult.none)),
                      child: Card(
                        color: appErrorRed100,
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                              AppLocalizations.of(context)!.no_internet,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(
                                  color: Colors.white, fontSize: 14)),
                        ),
                      ),
                    ),
                    Expanded(
                        child: TabBarView(
                          controller: _tabController,
                          children: myTabs.map((Tab tab) {
                            final String label = tab.text!.toLowerCase();
                            if (label.compareTo('home') == 0) {
                              //print('Home: ${label.compareTo('home')}');
                              return FloatingBottomNavigationWidget();
                            } else if (label
                                .toLowerCase()
                                .compareTo('payment') ==
                                0) {
                              //print('Home: ${label.compareTo('home')}');
                              return RecentPaymentPage();
                            } else {
                              return RecentChat();
                            }
                          }).toList(),
                        ))
                  ],
                ),
                onDrawerChanged: (isOpen){
                  setState(() {
                    drawerIsOpen = isOpen;
                  });
                },
                drawer: Drawer(
                  // Add a ListView to the drawer. This ensures the user can scroll
                  // through the options in the drawer if there isn't enough vertical
                  // space to fit everything.
                  child: SideNavigation(
                      currentSelectedItem: _currentSelectedItem,
                      callback: callback),
                )));
          });
    });
  }
}

class SideNavigation extends StatefulWidget {
  Function? callback;
  int? currentSelectedItem;

  SideNavigation({this.currentSelectedItem, this.callback});

  @override
  State<StatefulWidget> createState() => SideNavigationState();
}

class SideNavigationState extends State<SideNavigation> {
  UserDetails? userDetails;

  @override
  void initState() {
    // TODO: implement initState
    initUserDetails();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return ListView(
      // Important: Remove any padding from the ListView.
      padding: EdgeInsets.zero,
      children: [
        const MainDrawerHeader(),
        _buildListTile(context, l10n.nav_profile, Icons.person, 1, widget),
        _buildListTile(context, userDetails!=null && userDetails!.role.toLowerCase() == 'customer'?l10n.nav_merchant:'Shop Landmark', Icons.store, 2, widget),
        _buildListTile(context, l10n.nav_history, Icons.add_chart, 3, widget),
        _buildListTile(
            context, l10n.nav_invite, Icons.person_add_alt_1, 4, widget),
        _buildListTile(context, l10n.nav_settings, Icons.settings, 5, widget),
        //_buildListTile(context, l10n.nav_more, Icons.more_horiz, 6, widget),
        _buildListTile(context, l10n.nav_logout, Icons.logout, 7, widget),
      ],
    );
  }

  Widget _buildListTile(
    BuildContext context,
    String title,
    IconData? icons,
    int position,
    SideNavigation parentWidget,
  ) {
    var style1 = GoogleFonts.poppins(
        fontSize: 17, fontWeight: FontWeight.w500, color: Colors.black);
    Widget widget = Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 8),
          child: Icon(icons, color: Colors.grey),
        ),
        const SizedBox(width: 20),
        Container(
          margin: const EdgeInsets.only(top: 8),
          child: Text(
            title,
            style: style1,
            textAlign: TextAlign.start,
          ),
        )
      ],
    );
    return ListTile(
      // selectedTileColor: appGreen400,
      // selected: parentWidget.currentSelectedItem == position,
      dense: true,
      title: widget,
      onTap: () async {
        // Update the state of the app
        // ...
        // Then close the drawer
        Navigator.pop(context);
        parentWidget.currentSelectedItem = position;
        parentWidget.callback!(parentWidget.currentSelectedItem);
        if (position == 1) {
          // Navigator.pushNamed(
          //     context, '/profile');
          Navigator.of(context).push(MaterialPageRoute(builder: (context) => ProfilePage()));
        } else if (position == 6) {
          // Navigator.push(context,
          //     MaterialPageRoute(builder: (context) => FeedbackPageWidget()));
        } else if (position == 2) {

          _openMaps(context);
        } else if (position == 3) {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => TransactionListPage(),
                  settings: const RouteSettings(name: 'Transaction')));
        } else if (position == 5) {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => SettingsPage(),
                  settings: const RouteSettings(name: 'Transaction')));
        } else if (position == 4) {
          _shareInvite(context);
        }
      },
    );
  }

  Future<void> _shareInvite(BuildContext context) async {
    final box = context.findRenderObject() as RenderBox?;
    String jsonDetails = await LocalSharedPref().getUserDetails();
    UserDetails userDetails = UserDetails.fromJson(jsonDecode(jsonDetails));
    print('UserDetails: ${userDetails.toJson()}');

    var text = AppLocalizations.of(context)!
        .invite_message(userDetails.inviteCode ?? '');
    debugPrint(userDetails.toJson()['inviteCode']);
    debugPrint(text);
    await Share.share(text,
        subject: 'Invite your friend.',
        sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size);
  }

  SnackBar getResultSnackBar(ShareResult result) {
    return SnackBar(
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Share result: ${result.status}"),
          if (result.status == ShareResultStatus.success)
            Text("Shared to: ${result.raw}")
        ],
      ),
    );
  }

  Future<void> _openMaps(BuildContext context) async {

    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>  MapsLocationWidget()));

    // Future.delayed(const Duration(microseconds: 300));
    //
    // ProfileListResponse? user = await locator<AccountViewModel>().getUserDetails();
    // debugPrint(user?.profileDetails!.toJson().toString());
    // if(user != null && user.profileDetails!.role == 'Merchant'){
    //   if(!context.mounted){return;}
    //
    // }else{
    //   if(!context.mounted){return;}
    //   Navigator.push(
    //       context,
    //       MaterialPageRoute(
    //           builder: (context) => const NearByMerchantScreen()));
    // }
  }

  Future<void> initUserDetails() async {
    final prefs = await LocalSharedPref().getUserDetails();
    userDetails = UserDetails.fromJson(jsonDecode(prefs));
    setState(() {

    });
  }
}
