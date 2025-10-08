import 'package:flutter/material.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:lipa_quick/core/app_states.dart';
import 'package:lipa_quick/core/models/api_exception/api_exception.dart';
import 'package:lipa_quick/core/models/contacts/contacts.dart';
import 'package:lipa_quick/core/models/contacts/contacts_response_model.dart';
import 'package:lipa_quick/core/models/quick_action_model.dart';
import 'package:lipa_quick/core/models/recent_user_transaction.dart';
import 'package:lipa_quick/core/services/api.dart';
import 'package:lipa_quick/core/services/local_shared_pref.dart';
import 'package:lipa_quick/core/view_models/accounts_viewmodel.dart';
import 'package:lipa_quick/core/view_models/local_db_viewmodel.dart';
import 'package:lipa_quick/locator.dart';
import 'package:lipa_quick/main.dart';
import 'package:lipa_quick/ui/base_view.dart';
import 'package:lipa_quick/ui/shared/app_colors.dart';
import 'package:lipa_quick/ui/shared/dialogs/dialogshelper.dart';
import 'package:lipa_quick/ui/shared/empty_error_states.dart';
import 'package:lipa_quick/ui/shared/routing/app_router.dart';
import 'package:lipa_quick/ui/shared/ui_helpers.dart';
import 'package:lipa_quick/ui/views/contacts/search_contacts.dart';
import 'package:lipa_quick/ui/views/login_view.dart';
import 'package:lipa_quick/ui/views/payment/payment_screen.dart';
import 'package:lipa_quick/ui/views/payment/transfer_account.dart';
import 'package:lipa_quick/ui/views/qrcode/barcode_scanner_window.dart';
import 'package:lipa_quick/ui/views/quick_actions.dart';

import '../../contacts/user_contacts.dart';

class RecentPaymentPage extends StatefulWidget {
  const RecentPaymentPage({Key? key}) : super(key: key);

  @override
  State<RecentPaymentPage> createState() => RecentPaymentPageState();
}

class RecentPaymentPageState extends State<RecentPaymentPage>
    with WidgetsBindingObserver {
  LocalDbViewModel? localModel = locator<LocalDbViewModel>();
  AccountViewModel? accountViewModel = locator<AccountViewModel>();

  List<QuickActionModel?> list = [];
  late List<Customers> _recentUsers;

  late List<Customers> _recentMerchants;

  Future<dynamic>? recentUserTransactions;
  Future<List<QuickActionModel>>? quickActions;

  @override
  void initState() {
    // TODO: implement initState
    recentUserTransactions =  accountViewModel!.getRecentUserTransaction();
    quickActions = localModel?.getAllQuickActions();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height / 2.6;
    final TextStyle headline2 = Theme.of(context).textTheme.displayMedium!;
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          //height: height,
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                child: FutureBuilder<List<QuickActionModel>>(
                  future: quickActions,
                  builder: (context, snapshotData) {
                    if (snapshotData.connectionState == ConnectionState.done) {
                      if (snapshotData.hasData) {
                        list = snapshotData.data!;
                        return Stack(
                          children: [
                            SizedBox(
                              height: height,
                              child: Padding(
                                padding: EdgeInsets.all(8.0),
                                child: GridView.builder(
                                    physics: const ScrollPhysics(),
                                    scrollDirection: Axis.vertical,
                                    itemCount: list.length,
                                    shrinkWrap: false,
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
                                            child: SizedBox(
                                              width: double.infinity,
                                              height: MediaQuery.of(context).size.width/6,
                                              child: Card(
                                                color: Colors.white,
                                                surfaceTintColor: Colors.white,
                                                elevation: 1,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.all(
                                                      Radius.circular(10.0)),
                                                ),
                                                child: Column(
                                                    mainAxisSize:
                                                    MainAxisSize.min,
                                                    crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                    mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceAround,
                                                    children: [
                                                      const SizedBox(height: 10),
                                                      Card(
                                                        color: appGrey100,
                                                        child: Padding(
                                                          padding: UIHelper
                                                              .smallSymmetricPadding(),
                                                          child: Image(
                                                            //backgroundImage: AssetImage('assets/icon/lauchericon.png'),
                                                              image: AssetImage(
                                                                  item!
                                                                      .iconPath!),
                                                              width: 20,
                                                              height: 20,
                                                              fit: BoxFit.cover),
                                                        ),
                                                      ),
                                                      const SizedBox(height: 6),
                                                      Text(item.quickActionTitle!,
                                                          textAlign:
                                                          TextAlign.center,
                                                          // 'Text',
                                                          style:
                                                          GoogleFonts.poppins(
                                                              fontSize: 12,
                                                              fontWeight:
                                                              FontWeight
                                                                  .w500))
                                                    ]),
                                              ),
                                            )),
                                      );
                                    }),
                              )
                            )
                          ],
                        );
                      } else {
                        return Text(
                          'No Data',
                          style: GoogleFonts.poppins(
                              textStyle: Theme.of(context)
                                  .textTheme
                                  .displayMedium!
                                  .copyWith(
                                      fontSize: 21,
                                      fontWeight: FontWeight.bold,
                                      color: appSurfaceBlack)),
                          textAlign: TextAlign.center,
                        );
                      }
                    } else {
                      return SafeArea(
                        child: Visibility(
                            visible: snapshotData.connectionState ==
                                ConnectionState.waiting,
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
                      );
                    }
                  },
                ),
              ),
              FutureBuilder<dynamic>(
                future: recentUserTransactions!,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    if (snapshot.hasData) {
                      if (snapshot.data is RecentTransactionModel) {
                        _recentUsers =
                            (snapshot.data! as RecentTransactionModel)
                                .data!
                                .customers!;
                        _recentMerchants =
                            (snapshot.data! as RecentTransactionModel)
                                .data!
                                .merchants!;
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              height: height / 9,
                              child: Text(
                                'Users',
                                style: GoogleFonts.poppins(
                                    textStyle: Theme.of(context)
                                        .textTheme
                                        .displayMedium!
                                        .copyWith(
                                        fontSize: 19,
                                        fontWeight: FontWeight.bold,
                                        color: appSurfaceBlack)),
                                textAlign: TextAlign.start,
                              ),
                            ),
                            Container(
                              height: _recentUsers.length > 5
                                  ? height
                                  : MediaQuery.of(context).size.height / 6,
                              child: GridView.builder(
                                  physics: const ScrollPhysics(),
                                  scrollDirection: Axis.vertical,
                                  itemCount: _recentUsers.length,
                                  shrinkWrap: true,
                                  gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 4,
                                      childAspectRatio: 0.76,
                                      crossAxisSpacing: 4,
                                      mainAxisSpacing: 5),
                                  itemBuilder: (context, index) {
                                    var item = _recentUsers[index];
                                    return InkWell(
                                      onTap: () async {
                                        print(item.name);
                                        openPayment(item);
                                      },
                                      child: GridTile(
                                          child: Card(
                                            color: Colors.white,
                                            surfaceTintColor: Colors.white,
                                            elevation: 1,
                                            shape: const RoundedRectangleBorder(
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(10.0)),
                                            ),
                                            child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                                mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                                children: [
                                                  const SizedBox(height: 10),
                                                  CircleAvatar(
                                                      backgroundColor: appGreen400,
                                                      child: Text(
                                                        item.name!
                                                            .substring(0, 2)
                                                            .toUpperCase(),
                                                        style: GoogleFonts.poppins(
                                                            color: Colors.white),
                                                      )),
                                                  const SizedBox(height: 6),
                                                  Text(item.name!,
                                                      textAlign: TextAlign.center,
                                                      style: GoogleFonts.poppins(
                                                          fontSize: 12,
                                                          fontWeight:
                                                          FontWeight.w500))
                                                ]),
                                          )),
                                    );
                                  }),
                            ),
                            Container(
                              height: height / 9,
                              child: Text(
                                'Merchant',
                                style: GoogleFonts.poppins(
                                    textStyle: Theme.of(context)
                                        .textTheme
                                        .displayMedium!
                                        .copyWith(
                                        fontSize: 19,
                                        fontWeight: FontWeight.bold,
                                        color: appSurfaceBlack)),
                                textAlign: TextAlign.start,
                              ),
                            ),
                            Container(
                              height: _recentMerchants.length > 5
                                  ? height
                                  : MediaQuery.of(context).size.height / 6,
                              child: GridView.builder(
                                  physics: const ScrollPhysics(),
                                  scrollDirection: Axis.vertical,
                                  itemCount: _recentMerchants.length,
                                  shrinkWrap: true,
                                  gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 4,
                                      childAspectRatio: 0.76,
                                      crossAxisSpacing: 4,
                                      mainAxisSpacing: 5),
                                  itemBuilder: (context, index) {
                                    var item = _recentMerchants[index];
                                    return InkWell(
                                      onTap: () async {
                                        print(item.name);
                                        openPayment(item);
                                      },
                                      child: GridTile(
                                          child: Card(
                                            color: Colors.white,
                                            surfaceTintColor: Colors.white,
                                            elevation: 1,
                                            shape: const RoundedRectangleBorder(
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(10.0)),
                                            ),
                                            child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                                mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                                children: [
                                                  const SizedBox(height: 10),
                                                  CircleAvatar(
                                                      backgroundColor: appGreen400,
                                                      child: Text(
                                                        item.name!
                                                            .substring(0, 2)
                                                            .toUpperCase(),
                                                        style: GoogleFonts.poppins(
                                                            color: Colors.white),
                                                      )),
                                                  const SizedBox(height: 6),
                                                  Text(item.name!,
                                                      textAlign: TextAlign.center,
                                                      style: GoogleFonts.poppins(
                                                          fontSize: 12,
                                                          fontWeight:
                                                          FontWeight.w500))
                                                ]),
                                          )),
                                    );
                                  }),
                            )
                          ],
                        );
                      }
                      else {
                        if ((snapshot.data as APIException).apiError ==
                            APIError.UN_AUTHORIZED) {
                          return SizedBox(
                            height: MediaQuery.of(context).size.height / 2,
                            width: MediaQuery.of(context).size.width,
                            child: AuthorizationFailedWidget(callback: () async{
                              // LocalSharedPref()
                              //     .clearLoginDetails()
                              //     .then((value) => {
                              //           Navigator.of(context)
                              //               .pushAndRemoveUntil(
                              //                   MaterialPageRoute(
                              //                       builder: (context) =>
                              //                           LoginPage()),
                              //                   (Route<dynamic> route) => false)
                              //         });
                              //await LocalSharedPref().clearLoginDetails();
                              goToLoginPage(context);
                            }),
                          );
                        } else {
                          return SizedBox(
                            height: MediaQuery.of(context).size.height / 2.6,
                            width: MediaQuery.of(context).size.width,
                            child: EmptyViewFailedWidget(
                              title: "Search",
                              message: (snapshot.data as APIException).message!,
                              icon: Icons.search,
                              buttonHint: 'Try Again',
                            ),
                          );
                        }
                      }
                    } else {
                      return Container(
                        height: height,
                        decoration: const BoxDecoration(
                            gradient: LinearGradient(
                                begin: Alignment.topRight,
                                end: Alignment.bottomLeft,
                                colors: [Color(0x8be3ffe7), Color(0x11d9e7ff)])),
                        child: Center(
                          child:  Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 100,
                                height: 100,
                                child: Card(
                                  color: const Color(0x8be3ffe7),
                                  child: Icon(
                                    Icons.person,
                                    size: 50,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 30),
                              Text(
                                'Transactions',
                                style: GoogleFonts.poppins(
                                    textStyle: headline2.copyWith(
                                        fontSize: 21,
                                        fontWeight: FontWeight.bold,
                                        color: appSurfaceBlack)),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 20),
                              Text(
                                'No recent transactions. ',
                                style: GoogleFonts.poppins(
                                    textStyle: headline2.copyWith(fontSize: 16)),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                  } else {
                    return const Center(child: CircularProgressIndicator());
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    //accountViewModel!.dispose();
    super.dispose();
  }

  void openPayment(Customers item) {
    ContactsAPI contactsAPI = ContactsAPI.name(
      item.id,
      item.name!,
      item.phoneNumber,
      item.profilePicture,
      item.bank,
      item.accountHolderName,
      item.swiftCode,
      item.accountNumber,
    );


    // context.go(LipaQuickAppRouteMap.payment_screen, extra: contactsAPI);
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => PaymentPage(true, contact: contactsAPI)));
  }

  void onQuickActions(QuickActionModel item) async {
    if (item.Id! == '1') {
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => const ContactsPage()));
    } else if (item.Id! == '2') {
      await showSearch<ContactsAPI>(
        context: context,
        delegate: ContactsSearchDelegate(),
      );
    } else if (item.Id! == '4') {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) =>  BarcodePage(),
        ),
      );
    }else if (item.Id! == '5') {
      await showSearch<ContactsAPI>(
        context: context,
        delegate: ContactsSearchDelegate(),
      );
    }else if (item.Id! == '3'){
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => const TransferAccountPage(true),
        ),
      );
    }
  }
}
