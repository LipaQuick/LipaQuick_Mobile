

import 'dart:convert';

import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:lipa_quick/core/models/api_exception/api_exception.dart';
import 'package:lipa_quick/core/models/chats/recent_chat/recent_chat_response.dart';
import 'package:lipa_quick/core/models/contacts/contacts.dart';
import 'package:lipa_quick/core/models/contacts/contacts_model.dart';
import 'package:lipa_quick/core/models/contacts/contacts_response_model.dart';
import 'package:lipa_quick/core/models/payment/qr_payment_model.dart';
import 'package:lipa_quick/core/models/profile/profile_details_response.dart';
import 'package:lipa_quick/core/models/profile/profile_list_reponse.dart';
import 'package:lipa_quick/core/services/api.dart';
import 'package:lipa_quick/core/services/local_shared_pref.dart';
import 'package:lipa_quick/core/view_models/accounts_viewmodel.dart';
import 'package:lipa_quick/core/view_models/contact_viewmodel.dart';
import 'package:lipa_quick/locator.dart';
import 'package:lipa_quick/main.dart';
import 'package:lipa_quick/main.dart';
import 'package:lipa_quick/ui/app_router.dart';
import 'package:lipa_quick/ui/base_view.dart';
import 'package:lipa_quick/ui/shared/app_colors.dart';
import 'package:lipa_quick/ui/shared/empty_error_states.dart';
import 'package:lipa_quick/ui/shared/routing/app_router.dart';
import 'package:lipa_quick/ui/views/chat/chat_page/user_chat_page.dart';
import 'package:lipa_quick/ui/views/login_view.dart';
import 'package:lipa_quick/ui/views/payment/payment_screen.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../shared/dialogs/dialogshelper.dart';

class ContactsSearchDelegate extends SearchDelegate<ContactsAPI> {
  final AccountViewModel _api = locator<AccountViewModel>();

  @override
  List<Widget> buildActions(BuildContext context) {
    return <Widget>[];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, ContactsAPI.name('', '', '', '', '', '', '', ''));
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return PopScope(onPopInvoked: AppRouter().onBackPressed, child: FutureBuilder<dynamic>(
      future: _api.searchContacts(query, context),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          //Check if Snapshot has Related Data?
          if(snapshot.hasData){
            if(snapshot.data is ContactsResponse){
              ContactsResponse contactsResponse = snapshot.data as ContactsResponse;
              return ListView.builder(
                itemBuilder: (context, index) {
                  ContactsAPI? contact = contactsResponse.data!.elementAt(index);
                  return ListTile(
                    contentPadding:
                    const EdgeInsets.symmetric(vertical: 2, horizontal: 18),
                    leading: CircleAvatar(child: Text(contact!.name!.substring(0, 2).toUpperCase(), style: GoogleFonts.poppins(color: Colors.white),), backgroundColor: appGreen400,
                    ),
                    title: InkWell(
                      child: Text('${contact.name} \n ${contact.phoneNumber}' ?? '', style: GoogleFonts.poppins(color: Colors.black, fontSize: 17)),
                      onTap: (){
                        // _api.isUserActive().then((value) => {
                        //   if(value){
                        //     CustomDialog(DialogType.INFO).buildAndShowDialog(
                        //     context: context,
                        //     title: 'Account',
                        //     message: 'Your account is not active. Please connect with Support Team',
                        //     onPositivePressed: () {
                        //       Navigator.of(context, ro).pop();
                        //     },
                        //     buttonPositive: 'OK')
                        //   }else{
                        //   Navigator.push(context,MaterialPageRoute(
                        //              builder: (context) =>
                        //              PaymentPage(true, contact: contact,)))
                        //   }


                        // context.go(LipaQuickAppRouteMap.payment_screen, extra: contact);
                        if(contact.id != null && contact.id!.trim().isNotEmpty){
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      PaymentPage(true, contact: contact,)));
                        }else{
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text('${contact.name} is not registered with LipaQuick, cannot initiate payment.'),
                              duration: const Duration(seconds: 2)));
                        }
                        // });
                      },
                    ),
                    trailing: Visibility( visible: (contact.id != null && contact.id!.trim().isNotEmpty),
                      child: InkWell(
                        child: const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Icon(Icons.chat, color: appGreen400, size: 30),
                        ),
                        onTap: () => {
                          //print(contact.toString())
                          _openChatPage(context,contact)
                        },
                      ),),
                    //This can be further expanded to showing contacts detail
                  );
                },
                itemCount: contactsResponse.data!.length,
              );
            }
            else if(snapshot.data is APIException){
              if(snapshot.data is APIException
                  && (snapshot.data as APIException).apiError == APIError.UN_AUTHORIZED){
                return AuthorizationFailedWidget(callback: ()async{
                  // LocalSharedPref().clearLoginDetails().then((value) => {
                  //   // Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => LoginPage())
                  //   //     , (Route<dynamic> route) => false)
                  //   context.go(LipaQuickAppRouteMap.login)

                  // });
                  //await LocalSharedPref().clearLoginDetails();
                  goToLoginPage(context);
                });
              }else{
                return EmptyViewFailedWidget(title:AppLocalizations.of(context)!.search_title
                  , message: (snapshot.data as APIException).message!
                  , icon:Icons.search, buttonHint: AppLocalizations.of(context)!.try_again_hint,
                );
              }
            }
          }
          return EmptyViewFailedWidget(title:""
              , message: AppLocalizations.of(context)!.no_contact_hint
              , icon:Icons.search
          );
        } else {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    ));
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return SizedBox();
  }

  _openChatPage(BuildContext contexts, ContactsAPI contacts) async {
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
        paymentId: '',
        isOpened: true);

    Navigator.of(contexts).push(MaterialPageRoute(
        builder: (context) =>
        //DeadEndPage(buttonHint:"OK",callback: (){Navigator.of(context).pop();},)
        UserChatPage(recentChats: recentChat)));
  }
}
