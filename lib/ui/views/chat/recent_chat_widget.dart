import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lipa_quick/core/models/api_exception/api_exception.dart';
import 'package:lipa_quick/core/models/banks/bloc/bank_state.dart';
import 'package:lipa_quick/core/models/chats/recent_chat/recent_chat_response.dart';
import 'package:lipa_quick/core/services/blocs/recent_chat_bloc.dart';
import 'package:lipa_quick/core/services/events/recent_chat_events.dart';
import 'package:lipa_quick/core/services/local_shared_pref.dart';
import 'package:lipa_quick/core/services/states/recent_chat_state.dart';
import 'package:lipa_quick/locator.dart';
import 'package:lipa_quick/ui/shared/app_colors.dart';
import 'package:lipa_quick/ui/shared/empty_error_states.dart';
import 'package:lipa_quick/ui/shared/image_util.dart';
import 'package:lipa_quick/ui/shared/routing/app_router.dart';
import 'package:lipa_quick/ui/views/chat/chat_page/user_chat_page.dart';
import 'package:lipa_quick/ui/views/contacts/user_contacts.dart';
import 'package:lipa_quick/ui/views/login_view.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class RecentChat extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        create: (_) => ChatBloc(),
      child: RecentChatPage(),
    );
  }

}

class RecentChatPage extends StatefulWidget {
  @override
  _RecentChatPageState createState() => _RecentChatPageState();
}

class _RecentChatPageState extends State<RecentChatPage> {
  ChatBloc? chatBloc;
  final _scrollController = ScrollController();
  @override
  void initState() {
    super.initState();
    chatBloc = context.read<ChatBloc>()..add(RecentChatFetchEvent());
    _scrollController.addListener(_onScroll);
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      body: BlocBuilder<ChatBloc, UserChatState>(
        bloc: context.read<ChatBloc>(),
        builder: (context, state) {
          //debugPrint('Page State${state.status}');
          if(state.status == ApiStatus.success){
            if (state.recentChats!.isEmpty) {
              return EmptyViewFailedWidget(title: AppLocalizations.of(context)!.chat_title
                  , message: AppLocalizations.of(context)!.no_recent_chat_hint
                  , icon: Icons.chat
                  , buttonHint: AppLocalizations.of(context)!.start_chat_hint
                  , callback: (){
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => const ContactsPage()));
                },);
            }
            return ListView.builder(
              itemCount: state.recentChats!.length,
              controller: _scrollController,
              itemBuilder: (context, index) {
                final chat = state.recentChats![index];
                Widget message = getChatMessageWidget(chat);
                return ListTile(
                  tileColor: Theme.of(context).colorScheme.onPrimary,
                  leading: Container(
                    color: appBackgroundWhite,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(MediaQuery.of(context).size.width / 8),
                      child: ImageUtil().imageFromBase64String(chat.getProfilePictureLogo()
                          , MediaQuery.of(context).size.width/8
                          , MediaQuery.of(context).size.width/8),
                    ),
                  ),
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(chat.self!?chat.receiver!:chat.sender!, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16)),
                      Visibility(
                        visible: !chat.self! && chat.minutesAgo! <= 2,
                          child: Text(chat.timeAgo!, style: GoogleFonts.poppins(fontSize: 12
                              , fontWeight: FontWeight.w600))
                      )
                    ],
                  ),
                  subtitle: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      message,
                      Visibility(
                          visible: !chat.self! && chat.timeAgo!.contains('seconds'),
                          child: Card(
                            color: appGreen400,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(100)
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(5),
                              child: Text('1+', style: GoogleFonts.poppins(color: appBackgroundWhite),),
                            ),
                          )
                      )
                    ],
                  ),
                  onTap: (){
                    Navigator.of(context).push(MaterialPageRoute(builder: (context) =>
                        //DeadEndPage(buttonHint:"OK",callback: (){Navigator.of(context).pop();},)
                    UserChatPage(recentChats: chat)
                    ));
                  },
                );
              },
            );
          }
          else if(state.status == ApiStatus.initial){
            return Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              child: Center(
                child: Container(
                  width: 30,
                  height: 30,
                  child: const CircularProgressIndicator(),
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
            );
          }
          else {
            if(state.status == ApiStatus.authFailed){
              return AuthorizationFailedWidget(callback: () async {
                //await LocalSharedPref().clearLoginDetails();
                goToLoginPage(context);
              });
            }
            else if(state.status == ApiStatus.failure){
              return EmptyViewFailedWidget(title:AppLocalizations.of(context)!.chat_title
                  , message:state.errorMessage??AppLocalizations.of(context)!.something_went_wrong_hint
                  , icon:Icons.message
                  , buttonHint:AppLocalizations.of(context)!.reload_hint
                  , callback: (){
                    context.read<ChatBloc>().add(RecentChatFetchEvent());
                    debugPrint('Callback Pressed');
                  });
            }
            else{
              return EmptyViewFailedWidget(title:AppLocalizations.of(context)!.chat_title
                  , message:state.errorMessage??AppLocalizations.of(context)!.something_went_wrong_hint
                  , icon:Icons.message
                  , buttonHint:AppLocalizations.of(context)!.reload_hint
                  , callback: (){
                    context.read<ChatBloc>().add(RecentChatFetchEvent());
                    debugPrint('Callback Pressed');
                  });
            }
          }

        },
      ),
      floatingActionButton: FloatingActionButton(onPressed: _openUserContactPage,
          //, label: const Text('Start Chat')
        child: const Icon(Icons.add),
        foregroundColor: Colors.white,
        backgroundColor: appGreen400,
          ),
    );
  }



  @override
  void dispose() {
    chatBloc!.close();
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isBottom) context.read<ChatBloc>().add(RecentChatFetchEvent());
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  void _openUserContactPage() {
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => const ContactsPage()));
  }

  Widget getChatMessageWidget(RecentChats chat) {
    if (chat.message != null && chat.message!.isEmpty) {
      if (chat.paymentId.isNotEmpty) {
        return Row(
          children: [
            Icon(Icons.receipt),
            SizedBox(width: 5),
            Text(chat.self! ? 'Payment Sent' : 'Payment Received', style: GoogleFonts.poppins(fontSize: 14)
                ,softWrap: true, overflow: TextOverflow.ellipsis, maxLines: 2),
          ],
        );
      }

      if (chat.chatDoc != null) {
        final type = chat.getDocumentType(chat.chatDoc!);

        if (type == 'image') {
          return Row(
            children: [
              Icon(Icons.photo,size: 20),
              SizedBox(width: 5),
              Text('Photo', style: GoogleFonts.poppins(fontSize: 14)
                  ,softWrap: true, overflow: TextOverflow.ellipsis, maxLines: 2),
            ],
          );
        } else if (type == 'document') {
          return Row(
            children: [
              Icon(Icons.file_present_outlined,size: 20),
              SizedBox(width: 5),
              Text('Document', style: GoogleFonts.poppins(fontSize: 14)
                  ,softWrap: true, overflow: TextOverflow.ellipsis, maxLines: 2),
            ],
          );
        } else if (type == 'audio') {
          return Row(
            children: [
              Icon(Icons.audiotrack,size: 20),
              SizedBox(width: 5),
              Text('Audio', style: GoogleFonts.poppins(fontSize: 14)
    ,softWrap: true, overflow: TextOverflow.ellipsis, maxLines: 2),
            ],
          );
        } else if (type == 'video') {
          return Row(
            children: [
              Icon(Icons.videocam,size: 20),
              SizedBox(width: 5),
              Text('Video', style: GoogleFonts.poppins(fontSize: 14)
                  ,softWrap: true, overflow: TextOverflow.ellipsis, maxLines: 2),
            ],
          );
        }
      }
    }
    String message  = chat.message != null && chat.message!.length > 35
        ? chat.message!.substring(0, 35)
        : chat.message!;
    return Text(message,
      style: GoogleFonts.poppins(fontSize: 14)
      ,softWrap: true, overflow: TextOverflow.ellipsis, maxLines: 2,);
  }

}
