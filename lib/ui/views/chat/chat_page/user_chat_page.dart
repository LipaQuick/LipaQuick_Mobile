import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as type;
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:lipa_quick/core/models/api_exception/api_exception.dart';
import 'package:lipa_quick/core/models/banks/bloc/bank_state.dart';
import 'package:lipa_quick/core/models/chats/recent_chat/recent_chat_response.dart';
import 'package:lipa_quick/core/models/payment/recent_transaction.dart';
import 'package:lipa_quick/core/services/blocs/chat_bloc.dart';
import 'package:lipa_quick/core/services/events/chat_events.dart';
import 'package:lipa_quick/core/services/local_shared_pref.dart';
import 'package:lipa_quick/core/services/states/chat_state.dart';
import 'package:lipa_quick/locator.dart';
import 'package:lipa_quick/main.dart';
import 'package:lipa_quick/ui/shared/app_colors.dart';
import 'package:lipa_quick/ui/shared/empty_error_states.dart';
import 'package:lipa_quick/ui/shared/image_util.dart';
import 'package:lipa_quick/ui/views/chat/chat_page/widgets/chat_widgets.dart';
import 'package:lipa_quick/ui/views/chat/chat_page/widgets/media_widgets.dart';
import 'package:lipa_quick/ui/views/chat/widgets/player_video.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:lipa_quick/ui/views/payment/payment_screen.dart';
import 'package:open_file/open_file.dart';

class UserChatPage extends StatelessWidget {
  RecentChats? recentChats;

  UserChatPage({super.key, this.recentChats});

  @override
  Widget build(BuildContext context) {
    //context.read<SignalRBloc>().add(LoadInitialMessagesEvent());
    return Scaffold(
        body: BlocProvider(
            create: (_) => SignalRBloc(chats: recentChats)
              ..add(const ConnectEvent())
              ..add(const LoadInitialMessagesEvent()),
            child: ChatList(
              recentChats: recentChats,
            )));
  }
}

class ChatList extends StatefulWidget {
  RecentChats? recentChats;

  ChatList({super.key, this.recentChats});

  @override
  State<StatefulWidget> createState() => ChatListPage();
}

class ChatListPage extends State<ChatList> {
  late ScrollController _controller;

  @override
  Widget build(BuildContext context) {
    //Provider.of<NotifyState.ChatState>(context, listen: false).openChatPage();
    return PopScope(
        onPopInvoked: _onBackPressed,
        child: Scaffold(
          appBar: AppBar(
            elevation: 2,
            automaticallyImplyLeading: false,
            backgroundColor: Colors.white,
            flexibleSpace: SafeArea(
              child: Container(
                padding: const EdgeInsets.only(right: 16),
                child: Row(
                  children: <Widget>[
                    IconButton(
                      onPressed: () {
                        context
                            .read<SignalRBloc>()
                            .add(const DisconnectEvent());
                        context
                            .read<SignalRBloc>()
                            .add(const DisconnectEvent());
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.chevron_left, color: Colors.black),
                    ),
                    const SizedBox(
                      width: 2,
                    ),
                    CircleAvatar(
                      maxRadius: 20,
                      backgroundColor: Colors.black,
                      child: ImageUtil().imageFromBase64String(
                          ImageUtil().getBase64Logo(
                              widget.recentChats!.getProfilePictureLogo()),
                          30,
                          30),
                    ),
                    const SizedBox(
                      width: 12,
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            widget.recentChats!.self!
                                ? widget.recentChats!.receiver!
                                : widget.recentChats!.sender!,
                            style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.black),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
          body: Stack(
            children: [
              BlocListener<SignalRBloc, SignalRState>(
                listener: (context, state) {
                  if (state is SignalRUserState) {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => PaymentPage(
                                  true,
                                  contact: state.response,
                                )));
                  }
                },
                child: BlocBuilder<SignalRBloc, SignalRState>(
                  builder: (context, state) {
                    print('Current State: $state');
                    if (state is SignalRMessageReceived) {
                      return Center(
                        child: Text('Received: ${state.message}'),
                      );
                    } else if (state is SignalRLoading) {
                      return const SafeArea(
                          child: Center(
                        child: CircularProgressIndicator(),
                      ));
                    } else if (state is SignalInvalidUserException) {
                      return EmptyViewFailedWidget(
                          title: AppLocalizations.of(context)!.chat_title,
                          message: state.exception.message!,
                          icon: Icons.chat,
                          buttonHint: AppLocalizations.of(context)!.button_ok,
                          callback: () {
                            Navigator.of(context).pop();
                          });
                    } else if (state is SignalRApiException) {
                      if (state.exception.apiError == APIError.NOT_FOUND) {
                        return Chat(
                          key: GlobalVariable.chatKey,
                          theme:
                              const DefaultChatTheme(primaryColor: appGreen400),
                          messages: state.messages,
                          onMessageTap: _onMessageTap,
                          customDateHeaderText: (date){

                            final now = DateTime.now();
                            final messageDate = DateTime(date.year, date.month, date.day);
                            final today = DateTime(now.year, now.month, now.day);
                            final yesterday = DateTime(now.year, now.month, now.day - 1);

                            String label;
                            if (messageDate == today) {
                              label = 'Today';
                            } else if (messageDate == yesterday) {
                              label = 'Yesterday';
                            } else {
                              label = DateFormat.yMMMMd().format(date);
                            }

                            return label;
                          },
                          showUserNames: true,
                          onSendPressed: (var text) {},
                          user: type.User(
                              id: widget.recentChats!.self!
                                  ? widget.recentChats!.senderId!
                                  : widget.recentChats!.receiverId!),
                          customMessageBuilder: (message,
                              {required int messageWidth}) {
                            return PaymentMessage(
                                message,
                                widget.recentChats!.self!
                                    ? widget.recentChats!.senderId!
                                    : widget.recentChats!.receiverId!);
                          },
                          customBottomWidget:
                              MessageComposeView(widget.recentChats),
                          videoMessageBuilder: (message, {required int messageWidth}){
                            return VideoPlayerWidget(message, (){
                              showVideoBottomSheet(context, message.uri);
                            });
                          },
                          audioMessageBuilder: (message, {required int messageWidth}){
                            return AudioPlayerWidget(url: message.uri);
                          },
                          onEndReached: _handleEndReached,
                        );
                      }
                      if (state.status == ApiStatus.authFailed) {
                        return AuthorizationFailedWidget(
                          callback: () async {
                            //await LocalSharedPref().clearLoginDetails();
                            goToLoginPage(context);
                            // LocalSharedPref()
                            //     .clearLoginDetails()
                            //     .then((value) => {
                            //           Navigator.of(context).pushAndRemoveUntil(
                            //               MaterialPageRoute(
                            //                   builder: (context) =>
                            //                       const LoginPage()),
                            //               (Route<dynamic> route) => false)
                            //         });
                          },
                        );
                      }
                      return EmptyViewFailedWidget(
                          title: AppLocalizations.of(context)!.chat_title,
                          message: state.exception.message!,
                          icon: Icons.chat,
                          buttonHint: AppLocalizations.of(context)!.button_ok,
                          callback: () {
                            Navigator.of(context).pop();
                          });
                    } else if (state is SignalRLoadFailure) {
                      return EmptyViewFailedWidget(
                          title: AppLocalizations.of(context)!.chat_title,
                          message:
                              'Something went wrong while loading your chats, please try again',
                          icon: Icons.account_balance,
                          buttonHint: AppLocalizations.of(context)!.reload_hint,
                          callback: () {
                            context
                                .read<SignalRBloc>()
                                .add(LoadInitialMessagesEvent());
                          });
                    } else {
                      return Chat(
                        key: GlobalVariable.chatKey,
                        theme:
                            const DefaultChatTheme(primaryColor: appGreen400),
                        messages: state.messages,
                        onMessageTap: _onMessageTap,
                        onSendPressed: (var text) {},
                        customDateHeaderText: (date){

                          final now = DateTime.now();
                          final messageDate = DateTime(date.year, date.month, date.day);
                          final today = DateTime(now.year, now.month, now.day);
                          final yesterday = DateTime(now.year, now.month, now.day - 1);

                          String label;
                          if (messageDate == today) {
                            label = 'Today';
                          } else if (messageDate == yesterday) {
                            label = 'Yesterday';
                          } else {
                            label = DateFormat.yMMMMd().format(date);
                          }

                          return label;
                        },
                        user: type.User(
                            id: widget.recentChats!.self!
                                ? widget.recentChats!.senderId!
                                : widget.recentChats!.receiverId!),
                        customMessageBuilder: (message,
                            {required int messageWidth}) {
                          return PaymentMessage(
                              message,
                              widget.recentChats!.self!
                                  ? widget.recentChats!.senderId!
                                  : widget.recentChats!.receiverId!);
                        },
                        videoMessageBuilder: (message, {required int messageWidth}){
                          return VideoPlayerWidget(message, (){
                            showVideoBottomSheet(context, message.uri);
                          });
                        },
                        audioMessageBuilder: (message, {required int messageWidth}){
                          return AudioPlayerWidget(url: message.uri);
                        },
                        customBottomWidget:
                            MessageComposeView(widget.recentChats),
                        onEndReached: _handleEndReached,
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ));
  }

  @override
  void initState() {
    _controller = ScrollController()..addListener(_loadMore);
    super.initState();
  }

  @override
  void dispose() {
    _controller
      ..removeListener(_loadMore)
      ..dispose();
    super.dispose();
  }

  String getTime(String dateTimeM) {
    DateTime dateTime =
        DateTime.parse(dateTimeM.substring(0, dateTimeM.length - 3));
    DateFormat format = DateFormat('hh:mm');
    var result =
        '${format.format(dateTime).toString()}${(dateTimeM.substring(dateTimeM.length - 3, dateTimeM.length))}';
    //print(result);
    return result;
  }

  void _loadMore() {
    var bloc = context.read<SignalRBloc>();
    print(
        'All Messages: ${bloc.allChatMessages!.length}\n Total Messages\n ${bloc.totalMessages}\n Extent: ${_controller.position.extentAfter}');
    if (_controller.position.extentAfter < 200) {
      if ((bloc.allChatMessages!.length - 1) < bloc.totalMessages) {
        bloc.currentPage = bloc.currentPage + 1;
        bloc.add(const LoadMoreEvent());
      }
    }
  }

  Future<bool> _onBackPressed(bool canPop) {
    final Completer<bool> completer = Completer<bool>();
    completer.complete(true);

    //Provider.of<NotifyState.ChatState>(context, listen: false).closeChatPage();

    context.read<SignalRBloc>()
      ..add(const DisconnectEvent())
      ..add(const DisposeEvent());
    return completer.future;
  }

  Future<void> _handleEndReached() async {
    var bloc = context.read<SignalRBloc>();
    if ((bloc.allChatMessages!.length - 1) < bloc.totalMessages) {
      bloc.currentPage = bloc.currentPage + 1;
      bloc.add(const LoadMoreEvent());
    }
  }

  void _onMessageTap(BuildContext context, type.Message message) {
    if(message is type.FileMessage){
      var file = message as type.FileMessage;
      //print(file.toString());
      print('OnMessage TAP ${file.toJson()}');
      if (file.uri.startsWith('https') || file.uri.startsWith('http')) {
        context.read<SignalRBloc>().add(FileDownloadEvent(file));
      } else {
        print('No HTTPS ${file.toJson()}');
        //Show File Viewer Local
        if(File(file.uri).existsSync()){
          OpenFile.open(file.uri);
        }else {
          context.read<SignalRBloc>().add(FileDownloadEvent(file));
        }
      }
    }else if(message is type.VideoMessage){
      var file = message as type.VideoMessage;
      showVideoBottomSheet(context, file.uri);
    }

  }

  void showVideoBottomSheet(BuildContext context, String filePath, [SignalRBloc? model]) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      backgroundColor: Colors.black87,
      builder: (context) {
        return FractionallySizedBox(
          heightFactor: 0.9,
          child: Padding(
            padding: const EdgeInsets.all(5.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10.0),
                Align(
                  alignment: Alignment.center,
                  child: RemoteVideoPlayer(filePath, (){
                    Navigator.of(context).pop();
                    //model!.add(SignalRUploadEvent(File(filePath)));
                  }),
                )
              ],
            ),
          ),
        );
      },
    );
  }
}

class PaymentMessage extends StatelessWidget {
  final type.CustomMessage message;
  final String userId;

  PaymentMessage(this.message, this.userId);

  @override
  Widget build(BuildContext context) {
    var custom = message.metadata;
    print(custom);
    RecentTransaction recentTransaction =
        RecentTransaction.fromChatJson(custom!);
    return Container(
      width: MediaQuery.of(context).size.width / 1.5,
      decoration: BoxDecoration(
          color: const Color(0xE0FFFFFF),
          borderRadius: BorderRadius.circular(10)),
      child: PaymentSentWidget(recentTransaction),
    );
  }
}

class PaymentSentWidget extends StatelessWidget {
  RecentTransaction recentTransaction;

  PaymentSentWidget(this.recentTransaction);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(8.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // First Row: Amount and Status Icon
          Text(
            recentTransaction.isDebit!
                ? 'Paid to ${recentTransaction.receiver}'
                : 'Received from ${recentTransaction.sender}',
            style: GoogleFonts.poppins(
                textStyle: TextStyle(fontSize: 16, color: Colors.grey)),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                "Rwf ${recentTransaction.amount!}",
                style: GoogleFonts.poppins(
                    textStyle: TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.bold,
                        color: Colors.black)),
              ),
              SizedBox(
                width: 25,
              ),
              _buildStatusIcon(),
            ],
          ),
          // Second Row: Status Message
          Padding(
            padding: EdgeInsets.zero,
            child: Text(
              recentTransaction.status!,
              style: GoogleFonts.poppins(
                  textStyle: TextStyle(fontSize: 16, color: Colors.grey)),
            ),
          ),
          Visibility(visible: (recentTransaction.remarks != null && recentTransaction.remarks!.isNotEmpty), child: Padding(
            padding: EdgeInsets.zero,
            child: Text(
              recentTransaction.remarks!,
              style: GoogleFonts.poppins(
                  textStyle: TextStyle(fontSize: 16, color: Colors.grey)),
            ),
          )),
          // Third Row: Date and Time
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                _formatDateTime(DateFormat('yyyy-MM-dd hh:mm:ss aaa')
                    .parse(recentTransaction.modifiedAt!)),
                style: GoogleFonts.poppins(
                    textStyle: TextStyle(fontSize: 14, color: Colors.grey)),
              )
            ],
          ),
          Visibility(
            child: InkWell(
              child: Container(
                padding: EdgeInsets.all(4),
                decoration: BoxDecoration(
                    color: const Color(0xE0FFFFFF),
                    borderRadius: BorderRadius.circular(10)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('More'),
                    Icon(
                      Icons.chevron_right,
                      color: appGreen400,
                      size: 25,
                    )
                  ],
                ),
              ),
              onTap: () {
                //
              },
            ),
            visible: false,
          )
        ],
      ),
    );
  }

  Widget _buildStatusIcon() {
    IconData? iconData;
    Color? iconColor;

    switch (recentTransaction.status!.toLowerCase()) {
      case 'success':
        iconData = Icons.check_circle;
        iconColor = Colors.green;
        break;
      case 'pending':
        iconData = Icons.access_time;
        iconColor = Colors.orange;
        break;
      case 'failed':
        iconData = Icons.cancel;
        iconColor = Colors.red;
        break;
    }

    return Icon(
      iconData,
      color: iconColor,
      size: 25,
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final formattedDate = DateFormat('dd, MMM').add_jm().format(dateTime);
    return formattedDate;
  }
}

class FileUtils {
  String getFile(String fileName) {
    if (fileName.contains("\\")) {
      return fileName.split("\\").last;
    }
    return fileName.split("/").last;
  }

  String getFileExtension(String fileName) {
    return fileName.split("//").last.split("\.").last.toUpperCase();
  }
}
