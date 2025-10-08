import 'dart:convert';

import 'package:android_intent_plus/android_intent.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:lipa_quick/core/app_states.dart';
import 'package:lipa_quick/core/models/api_exception/api_exception.dart';
import 'package:lipa_quick/core/models/chats/recent_chat/recent_chat_response.dart';
import 'package:lipa_quick/core/models/contacts/contacts.dart';
import 'package:lipa_quick/core/models/contacts/contacts_model.dart';
import 'package:lipa_quick/core/models/response.dart';
import 'package:lipa_quick/core/services/local_shared_pref.dart';
import 'package:lipa_quick/core/utils/diff_utils.dart';
import 'package:lipa_quick/core/view_models/accounts_viewmodel.dart';
import 'package:lipa_quick/core/view_models/contact_viewmodel.dart';
import 'package:lipa_quick/locator.dart';
import 'package:lipa_quick/main.dart';
import 'package:lipa_quick/ui/app_router.dart';
import 'package:lipa_quick/ui/shared/app_colors.dart';
import 'package:lipa_quick/ui/shared/app_theme.dart';
import 'package:lipa_quick/ui/shared/application_states/dead_end_page.dart';
import 'package:lipa_quick/ui/shared/application_states/internet_page.dart';
import 'package:lipa_quick/ui/shared/empty_error_states.dart';
import 'package:lipa_quick/ui/shared/routing/app_router.dart';
import 'package:lipa_quick/ui/views/chat/chat_page/user_chat_page.dart';
import 'package:lipa_quick/ui/views/chat/recent_chat_widget.dart';
import 'package:lipa_quick/ui/views/login_view.dart';
import 'package:lipa_quick/ui/views/payment/payment_screen.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../shared/dialogs/dialogshelper.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:share_plus/share_plus.dart';

class ContactsPage extends StatefulWidget {
  const ContactsPage({Key? key}) : super(key: key);

  @override
  _ContactsPageState createState() => _ContactsPageState();
}

class _ContactsPageState extends State<ContactsPage> {
  final ContactsDBViewModel _contactsDBViewModel =
      locator<ContactsDBViewModel>();
  Future<List<ContactsAPI>>? _future;

  Future<bool> _onWillPop() async {
    print("Back button pressed");
    return (await showDialog(
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
        )) ??
        true;
  }

  @override
  void initState() {
    //CheckPermissions(context);
    _future = CheckPermissions(context, false);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(onPopInvoked: AppRouter().onBackPressed
      , child: Scaffold(
        appBar: AppTheme.getAppBarWithActions(
            context: context,
            title: 'Contacts',
            subTitle: '',
            enableBack: true,
            actions: getActions()),
        body: Container(
          child: Column(
            children: [
              Container(
                margin: EdgeInsets.all(10.0),
                child: SearchAnchor(builder: (context, controller) {
                  return SearchBar(
                    controller: controller,
                    hintText: 'Search',
                    padding: const MaterialStatePropertyAll<EdgeInsets>(
                        EdgeInsets.symmetric(horizontal: 16.0)),
                    onChanged: (String data) {
                      //controller.openView();
                      if (data.isEmpty) {
                        loadData(false);
                      } else {
                        setState(() {
                          _future = _contactsDBViewModel.filterContacts(data);
                        });
                      }
                      //_future = _contactsDBViewModel.filterContacts(data);
                      setState(() {});
                    },
                    leading: const Icon(Icons.search),
                    onSubmitted: (String query) {
                      //print('$query');
                    },
                  );
                }, suggestionsBuilder:
                    (BuildContext context, SearchController controller) {
                  return List<ListTile>.empty();
                }),
              ),
              FutureBuilder<List<ContactsAPI>>(
                future: _future,
                builder: (context, snapshot) {
                  debugPrint(snapshot.connectionState.toString());
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else {
                    if (snapshot.hasData &&
                        snapshot.data!.isNotEmpty &&
                        snapshot.connectionState == ConnectionState.done) {
                      return Expanded(
                          child: ListView.builder(
                            itemCount: snapshot.data!.length ?? 0,
                            itemBuilder: (BuildContext context, int index) {
                              ContactsAPI? contact =
                              snapshot.data?.elementAt(index);
                              print(contact!.toJson().toString());
                              return ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                    vertical: 2, horizontal: 18),
                                leading: CircleAvatar(
                                  backgroundColor: appGreen400,
                                  child: Text(
                                    contact.name!.substring(0, 2).toUpperCase(),
                                    style:
                                    GoogleFonts.poppins(color: Colors.white),
                                  ),
                                ),
                                title: InkWell(
                                    child: Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [
                                        Text('${contact.name}' ?? '',
                                            style: GoogleFonts.poppins(
                                                color: Colors.black,
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold)),
                                        Text('${contact.phoneNumber}' ?? '',
                                            style: GoogleFonts.poppins(
                                                color: Colors.black,
                                                fontSize: 14))
                                      ],
                                    ),
                                    onTap: () {
                                      if (contact.id != null && contact.id!.isNotEmpty) {
                                        showPaymentPage(
                                            snapshot.data!.elementAt(index));
                                      }else{
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                              content: Text(
                                                  'Selected user is not registered!'),
                                              showCloseIcon: true),
                                        );
                                      }
                                    }),
                                subtitle: Visibility(
                                  visible: contact.id == null || contact.id!.isEmpty,
                                  child: InkWell(
                                    child: Text('Invite your friend to LipaQuick',
                                        style: GoogleFonts.poppins(
                                            color: Colors.grey, fontSize: 14)),
                                    onTap: () {
                                      _shareInvite(context);
                                    },
                                  ),
                                ),
                                trailing: Visibility(
                                  visible: contact.id != null,
                                  child: InkWell(
                                    child: const Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Icon(Icons.chat,
                                          color: appGreen400, size: 30),
                                    ),
                                    onTap: () {
                                      if (contact.id != null && contact.id!.isNotEmpty) {
                                        _openChatPage(
                                            snapshot.data!.elementAt(index));
                                      }else{
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                              content: Text(
                                                  'Selected user is not registered!'),
                                              showCloseIcon: true),
                                        );
                                      }
                                    },
                                  ),
                                ),
                                //trailing: contact.,
                                //This can be further expanded to showing contacts detail
                              );
                            },
                          ));
                    } else {
                      return Expanded(
                          child: EmptyViewFailedWidget(
                              title: "Contacts",
                              message: "No Contacts found.",
                              icon: Icons.contacts,
                              buttonHint: "REFRESH",
                              callback: () {
                                loadData(true);
                              }));
                    }
                  }
                },
              )
              //Build a list view of all contacts, displaying their avatar and,
            ],
          ),
        )),);
  }

  Future<List<ContactsAPI>> CheckPermissions(
      BuildContext context, bool refreshContacts) async {
    final PermissionStatus permissionStatus = await _getPermission();
    if (permissionStatus == PermissionStatus.granted) {
      print('Permission Granted');
      //We can now access our contacts here
      var response = await _contactsDBViewModel.getContacts(refreshContacts);
      //print('Showing Dialog $response');
      if (response is APIException) {
        if (response.apiError == APIError.BAD_REQUEST) {
          //show full screen internet dialog
          return <ContactsAPI>[];
        }
        if (response.apiError == APIError.UN_AUTHORIZED) {
          //show full screen internet dialog'
          Navigator.of(context).push(MaterialPageRoute<Null>(
              builder: (BuildContext context) {
                return AuthorizationFailedWidget(callback: () async{
                  Navigator.of(context).pop();
                  // LocalSharedPref().clearLoginDetails().then((value) => {
                  //       Navigator.of(context).pushAndRemoveUntil(
                  //           MaterialPageRoute(
                  //               builder: (context) => LoginPage()),
                  //           (Route<dynamic> route) => false)
                  //     });
                  //await LocalSharedPref().clearLoginDetails();
                  goToLoginPage(context);
                });
              },
              fullscreenDialog: true));
          return <ContactsAPI>[];
        } else if (response.apiError == APIError.INTERNET_NOT_AVAILABLE) {
          //show full screen internet dialog
          Navigator.of(context).push(MaterialPageRoute<Null>(
              builder: (BuildContext context) {
                return NoInternetPage(
                    buttonHint: 'Try Again',
                    callback: () {
                      Navigator.of(context).pop();
                      _contactsDBViewModel.getContacts(true);
                    });
              },
              fullscreenDialog: true));
        } else {
          Navigator.of(context).push(MaterialPageRoute<Null>(
              builder: (BuildContext context) {
                return DeadEndPage(
                    buttonHint: 'Try Again',
                    callback: () {
                      Navigator.of(context).pop();
                      _contactsDBViewModel.getContacts(true);
                    });
              },
              fullscreenDialog: true));
        }
        return <ContactsAPI>[];
      }
      if (response is List<ContactsAPI>) {
        return response;
      } else {
        return <ContactsAPI>[];
      }
    } else {
      //If permissions have been denied show standard alert dialog
      print('Showing Dialog');
      CustomDialog(DialogType.FAILURE).buildAndShowDialog(
          context: context,
          title: 'Permissions Error',
          message: 'Please enable contacts access '
              'permission in system settings',
          onPositivePressed: () {
            Navigator.of(context, rootNavigator: true).pop();
            Navigator.of(context).pop();
          },
          buttonPositive: 'OK');
      return <ContactsAPI>[];
    }
  }

  //Check contacts permission
  Future<PermissionStatus> _getPermission() async {
    final PermissionStatus permission = await Permission.contacts.status;
    if (permission != PermissionStatus.granted &&
        permission != PermissionStatus.permanentlyDenied) {
      final Map<Permission, PermissionStatus> permissionStatus =
          await [Permission.contacts].request();
      return permissionStatus[Permission.contacts] ?? PermissionStatus.granted;
    } else {
      return permission;
    }
  }

  getLocalContacts(List<Contact> systemContacts) async {
    List<Contacts> mainList = <Contacts>[];
    await _contactsDBViewModel.getContacts(false).then((value) => {
          //Value will contain a list of all Contacts in the system
          // DB Contacts > 0, Remove Similar Contacts, Get Unique items
          // mainList = processContacts(systemContacts, value),
        });
    return mainList;
  }

  Future<void> _shareInvite(BuildContext context) async {
    final box = (context.findRenderObject() as RenderSliverList?)!.firstChild!;
    String jsonDetails = await LocalSharedPref().getUserDetails();
    UserDetails userDetails = UserDetails.fromJson(jsonDecode(jsonDetails));

    var text = AppLocalizations.of(context)!
        .invite_message(userDetails.inviteCode ?? '');
    debugPrint(userDetails.toJson()['inviteCode']);
    debugPrint(text);
    // var inviteMessage =
    //     AppLocalizations.of(context)!.invite_message(userDetails.inviteCode);
    // print(userDetails.toJson());
    // var intent = AndroidIntent(
    //   data: '',
    //   action: 'android.intent.action.SEND',
    //   arguments: {'android.intent.extra.EXTRA_TEXT': '${AppConstants.inviteMessage} ${userDetails.inviteCode}',
    //     'android.intent.extra.EXTRA_SUBJECT': 'Invite your friend.'},
    //   type: 'plain/text',
    // );
    // intent.launchChooser('Share Via');
    await Share.share(text,
        subject: 'Invite your friend.',
        sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size);
  }

  showPaymentPage(ContactsAPI contact) {
    // context.go(LipaQuickAppRouteMap.payment_screen, extra: contact);
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                PaymentPage(true, contact: contact)));
  }

  _openChatPage(ContactsAPI contacts) async {
    var userDetails = await LocalSharedPref().getUserDetails();
    UserDetails details = UserDetails.fromJson(jsonDecode(userDetails));
    var userId = await AccountViewModel().getUserId();
    RecentChats recentChat = RecentChats(
        receiver: contacts.name,
        receiverId: contacts.id,
        sender: '${details.firstName} ${details.lastName}',
        senderId: userId,
        profilePicture: contacts.profilePicture,
        self: true,
        paymentId: '', isOpened: true);

    Navigator.of(context).push(MaterialPageRoute(
        builder: (context) =>
            //DeadEndPage(buttonHint:"OK",callback: (){Navigator.of(context).pop();},)
            UserChatPage(recentChats: recentChat)));
  }

  List<Widget>? getActions() {
    return <Widget>[
      IconButton(
        icon: const Icon(
          Icons.refresh_rounded,
          color: appGreen400,
        ),
        tooltip: 'Sync Contacts Again',
        onPressed: () {
          loadData(false);
        },
      )
    ];
  }

  void loadData(bool refresh) {
    setState(() {
      _future = CheckPermissions(context, refresh);
    });
  }
}

class AppConstants {
  static const String inviteMessage =
      'I am inviting you to use LipaQuick, a simple and easy payment application'
      '.\n Here'
      's my code- just enter while creating a account. On your first payment,you will get a cashback';
}
