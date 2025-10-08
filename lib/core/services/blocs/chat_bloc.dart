import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'package:lipa_quick/core/crypto/encryption.dart';
import 'package:lipa_quick/core/models/api_exception/api_exception.dart';
import 'package:lipa_quick/core/models/banks/bloc/bank_bloc.dart';
import 'package:lipa_quick/core/models/banks/bloc/bank_state.dart';
import 'package:lipa_quick/core/models/chats/file_upload_response.dart';
import 'package:lipa_quick/core/models/chats/recent_chat/recent_chat_response.dart';
import 'package:lipa_quick/core/models/chats/send_message_request.dart';
import 'package:lipa_quick/core/models/contacts/contacts.dart';
import 'package:lipa_quick/core/models/contacts/contacts_response_model.dart';
import 'package:lipa_quick/core/models/profile/profile_list_reponse.dart';
import 'package:lipa_quick/core/models/profile/user_details.dart';
import 'package:lipa_quick/core/models/response.dart';
import 'package:lipa_quick/core/services/api.dart';
import 'package:lipa_quick/core/services/events/chat_events.dart';
import 'package:lipa_quick/core/services/local_shared_pref.dart';
import 'package:lipa_quick/core/services/signalr/connection_hub.dart';
import 'package:lipa_quick/core/services/states/chat_state.dart';
import 'package:lipa_quick/core/utils/file_path_utils.dart';
import 'package:lipa_quick/core/utils/token_helper.dart';
import 'package:lipa_quick/core/view_models/accounts_viewmodel.dart';
import 'package:lipa_quick/core/view_models/local_db_viewmodel.dart';
import 'package:lipa_quick/main.dart';
import 'package:lipa_quick/ui/views/chat/chat_page/user_chat_page.dart';
import 'package:lipa_quick/ui/views/chat/utils/message_util.dart';
import 'package:lipa_quick/ui/views/chat/widgets/download_helpers.dart';
import 'package:logging/logging.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:signalr_netcore/signalr_client.dart';
import 'package:uuid/uuid.dart';

class SignalRBloc extends Bloc<SignalREvent, SignalRState> {
  late Api _api;
  late ConnectionHub _connectionHub;

  bool _connectionIsOpen = false;

  //Total chat messages that needs to be loaded
  int totalMessages = 0;

  // At the beginning, we fetch the first 20 posts
  int currentPage = 0;

  // you can change this value to fetch more or less posts per page (10, 15, 5, etc)
  final int loadLimit = 20;

  List<Message>? allChatMessages = [];
  RecentChats? _recentChats;

  UserDetails? currentUserDetails;

  SignalRBloc({RecentChats? chats}) : super(SignalRInitial([])) {
    _api = locator<Api>();
    _recentChats = chats;

    debugPrint('SignalRBloc'+_recentChats.toString());

    loadUserDetails();

    on<ConnectEvent>(_onConnect,
        transformer: throttleDroppable(throttleDuration));
    on<LoadMoreEvent>(_onLoadMoreEvent,
        transformer: throttleDroppable(throttleDuration));
    on<FileDownloadEvent>(_onDownloadFileEvent,
        transformer: throttleDroppable(throttleDuration));
    //on<LoadMoreEvent>(_onLoadMoreEvent, transformer: throttleDroppable(throttleDuration));
    on<DisconnectEvent>(_onDisconnect,
        transformer: throttleDroppable(throttleDuration));
    on<LoadInitialMessagesEvent>(_onLoadMessages,
        transformer: throttleDroppable(throttleDuration));
    on<IncomingMessageEvent>(_onInComingMessage,
        transformer: throttleDroppable(throttleDuration));
    on<SendMessagesEvent>(_onSendMessageEvent,
        transformer: throttleDroppable(throttleDuration));
    on<SignalRUploadEvent>(_onDocumentUploadEvent,
        transformer: throttleDroppable(throttleDuration));
    on<SignalRFindUserDetailsEvent>(_getUserDetailsEvent,
        transformer: throttleDroppable(throttleDuration));
    on<SignalRMessageDelete>(onDeleteChat,
        transformer: throttleDroppable(throttleDuration));
    on<DisposeEvent>(_onDispose,
        transformer: throttleDroppable(throttleDuration));
  }

  Future<String> getToken() async {
    return LocalSharedPref().getToken();
  }

  Future<String> get localPath async {
    final directory = await getApplicationDocumentsDirectory();

    return directory.path;
  }

  FutureOr<void> _onConnect(
      ConnectEvent event, Emitter<SignalRState> emit) async {
    debugPrint('Connect Function');
    try {
      locator.isReady<ConnectionHub>().then((value) => {
            debugPrint('isReady'),
            _connectionHub = value as ConnectionHub,
            startHubConection(emit),
          });
      //emit(SignalRConnected(allChatMessages!));
    } catch (e) {
      debugPrint(e.toString());
      //emit(SignalRDisconnected());
    }
  }

  FutureOr<void> _onDisconnect(
      DisconnectEvent event, Emitter<SignalRState> emit) async {
    try {
      await _connectionHub.hubConnection.stop();
      //emit(SignalRDisconnected());
    } catch (_) {}
  }

  FutureOr<void> _onLoadMessages(
      LoadInitialMessagesEvent event, Emitter<SignalRState> emit) async {
    emit(SignalRLoading([]));
    try {
      var receiversId = _recentChats!.self!
          ? _recentChats!.receiverId!
          : _recentChats!.senderId!;

      await LocalSharedPref().setCurrentChatId(receiversId);

      String userId = await AccountViewModel().getUserId();

      if(userId == receiversId){
        emit(SignalInvalidUserException(ApiStatus.authFailed
            , const APIException('Something went wrong, cannot initiate a chat.'
            , 404, APIError.NOT_FOUND)));
        return;
      }

      dynamic userChatMessages =
          await _api.getAllChats(currentPage, loadLimit, receiversId);
      debugPrint("Received Response");
      if (userChatMessages is RecentChatResponse) {
        debugPrint("Inside Recent Chat Response");
        if (kDebugMode) {
          debugPrint("${userChatMessages == null}");
        }
        debugPrint("Inside userChatMessages not null");
        String message = userChatMessages.message ?? "EMPTY";
        if (message.contains("Unauthorized access")) {
          emit(SignalRAuthFailed(ApiStatus.authFailed));
        }

        if (userChatMessages.total! != -1) {
          totalMessages = userChatMessages.total!;
        }

        allChatMessages ??= [];

        String userDetails = "";
        userDetails = await LocalSharedPref().getUserDetails();
        UserDetails details = UserDetails.fromJson(jsonDecode(userDetails));
        details.id = _recentChats!.self!
            ? _recentChats!.senderId!
            : _recentChats!.receiverId!;

        allChatMessages =
            userChatMessages.data!.map((e) => e.toMessage(details)).toList();

        emit(SignalRLoadSuccess(allChatMessages!));
        //yield SignalRLoadSuccess(allChatMessages!);
      } else {
        APIException apiException = userChatMessages as APIException;

        if (apiException.message!.contains("Unauthorized access")) {
          emit(SignalRApiException(ApiStatus.authFailed, apiException));
        } else if (apiException.errors!.isNotEmpty) {
          var message = apiException.errors!.first;
          if (message.contains('Receiver')) {
            debugPrint("Exception API Exception ${apiException.message}");
            apiException = const APIException(
                'The chosen contact is not registered with LipaQuick.',
                500,
                APIError.NOT_FOUND);
          }
          emit(SignalRApiException(ApiStatus.failure, apiException));
        } else {
          emit(SignalRApiException(ApiStatus.failure, apiException));
        }
        //yield SignalRApiException(ApiStatus.failure, apiException);
      }
    } catch (e) {
      debugPrint(e.toString());
      emit(SignalRLoadFailure([]));
    }
  }

  FutureOr<void> _onInComingMessage(
      IncomingMessageEvent event, Emitter<SignalRState> emit) {
    debugPrint('Received a Message from Chat Socket');
    // var senderId = _recentChats!.self!
    //     ?_recentChats!.senderId!
    //     :_recentChats!.receiverId!;

    final String _id = event.args![0] as String;
    final Map<String, dynamic> _chatMessageObject =
        event.args![1] as Map<String, dynamic>;
    debugPrint('Id Received is:$_id\nMessage: $_chatMessageObject');
    SendMessageModel message = SendMessageModel.fromJson(_chatMessageObject);
    var type = getMessageType(message);
    Message receivedMessage = getMessage(type, message, _id);
    allChatMessages!.insert(0, receivedMessage);
    emit(SignalRLoading([]));
    emit(SignalRLoadSuccess(allChatMessages!));
  }

  FutureOr<void> _onLoadMoreEvent(
      LoadMoreEvent event, Emitter<SignalRState> emit) async {
    //allChatMessages!.add(RecentChats(isLoadMore: true, self: false));
    emit(SignalRLoadingMore(allChatMessages!));
    try {
      var receiversId = _recentChats!.self!
          ? _recentChats!.receiverId!
          : _recentChats!.senderId!;
      dynamic chatMessageResponse =
          await _api.getAllChats(currentPage, loadLimit, receiversId);
      debugPrint("Received Response");
      if (chatMessageResponse is RecentChatResponse) {
        String message = chatMessageResponse.message ?? "EMPTY";
        if (message.contains("Unauthorized access")) {
          emit(SignalRAuthFailed(ApiStatus.authFailed));
        }
        currentPage = chatMessageResponse.skip!;
        //allChatMessages!.removeAt(allChatMessages!.length-1);
        if (chatMessageResponse.data!.isNotEmpty) {
          debugPrint("Inside data!.isNotEmpty");
          List<Message> chatMessages = [];

          String userDetails = "";
          userDetails = await LocalSharedPref().getUserDetails();
          UserDetails details = UserDetails.fromJson(jsonDecode(userDetails));
          details.id = _recentChats!.self!
              ? _recentChats!.senderId!
              : _recentChats!.receiverId!;

          chatMessages = chatMessageResponse.data!
              .map((e) => e.toMessage(details))
              .toList();

          allChatMessages!.addAll(chatMessages);
        }
        emit(SignalRLoadSuccess(allChatMessages!));
        //yield SignalRLoadSuccess(allChatMessages!);
      } else {
        debugPrint("Exception API Exception");
        APIException apiException = chatMessageResponse as APIException;
        emit(SignalRApiException(ApiStatus.authFailed, apiException));
        //yield SignalRApiException(ApiStatus.failure, apiException);
      }
    } catch (_) {
      emit(SignalRLoadFailure([]));
    }
  }

  bool checkIsImage(String? chatDoc) {
    return chatDoc != null &&
        (chatDoc.toString().toLowerCase().contains('.jpeg') ||
            chatDoc.toString().toLowerCase().contains('.jpg') ||
            chatDoc.toString().toLowerCase().contains('.png'));
  }

  bool checkIsDocument(String? chatDoc) {
    return chatDoc != null &&
        (chatDoc.toString().toLowerCase().contains('.pdf') ||
            chatDoc.toString().toLowerCase().contains('.docx') ||
            chatDoc.toString().toLowerCase().contains('.xlsx') ||
            chatDoc.toString().toLowerCase().contains('.xls'));
  }

  Future<DownloadStatus> checkIfFileDownloaded(String fileName) async {
    var directory = await getApplicationDocumentsDirectory();
    directory = directory.absolute.parent;
    var path = '${directory.path}/files';
    var Filepath = '${path}/${fileName}';
    return File(Filepath).existsSync()
        ? DownloadStatus.downloaded
        : DownloadStatus.notDownloaded;
  }

  Future<FutureOr<void>> _onSendMessageEvent(
      SendMessagesEvent event, Emitter<SignalRState> emit) async {
    DateTime dateTime = DateTime.now();
    DateFormat dateFormat = DateFormat('yyyy-MM-dd hh:mm:ss aaa');

    SendMessageModel sendMessageModel =
        SendMessageModel(LocalMessageType.TEXT.name, event.message, "", null);

    var senderId = _recentChats!.self!
        ? _recentChats!.senderId!
        : _recentChats!.receiverId!;
    var receiversId = _recentChats!.self!
        ? _recentChats!.receiverId!
        : _recentChats!.senderId!;

    String userDetails = "";

    userDetails = await LocalSharedPref().getUserDetails();

    UserDetails details = UserDetails.fromJson(jsonDecode(userDetails));

    var message = RecentChats(
        minutesAgo: 0,
        timeAgo: "0",
        daysAgo: 0,
        messageCount: 0,
        senderId: senderId,
        receiverId: receiversId,
        message: sendMessageModel.message,
        sender: "${details.firstName} ${details.lastName}",
        chatDoc: sendMessageModel.File,
        self: true,
        createdAt: '',
        createdBy: '',
        modifiedAt: dateFormat.format(dateTime),
        paymentId: '', isOpened:true);

    Message currentMessage = message.toMessage(details);

    String userMessage =
        encryptAESCryptoJS(jsonEncode(sendMessageModel.toJson()));

    Map<String, dynamic> body = <String, dynamic>{
      'request': userMessage,
    };

    allChatMessages!.insert(0, currentMessage);

    _connectionHub.hubConnection
        .invoke("SendMessageToGroup", args: <Object>[receiversId, body]);

    emit(SignalRLoading([]));
    emit(SignalRLoadSuccess(allChatMessages!));
  }

  FutureOr<void> _onDispose(DisposeEvent event, Emitter<SignalRState> emit) {
    close();
  }

  startHubConection(Emitter<SignalRState> emit) async {
    // _connectionHub.hubConnection.stateStream.listen((state) async {
    //   debugPrint(state.name);
    //   if(state == HubConnectionState.Disconnected){
    //     await LocalSharedPref().setCurrentChatId('');
    //   }
    // });
    _connectionHub.hubConnection.onclose(({error}) async* {
      debugPrint('onclose');
      _connectionIsOpen = false;
      //emit(SignalRConnected(allChatMessages!));
    });
    _connectionHub.hubConnection.onreconnecting(({error}) async* {
      debugPrint("onreconnecting called");
      _connectionIsOpen = false;
      debugPrint('onreconnecting');
      // emit(SignalRDisconnected());
    });
    _connectionHub.hubConnection.onreconnected(({connectionId}) async* {
      debugPrint("onreconnected called");
      _connectionIsOpen = true;
      debugPrint('onreconnected');
      //emit(SignalRConnected(allChatMessages!));
    });
    // _connectionHub.hubConnection.on("ReceiveMessage", (args) async* {
    //   //yield SignalRMessageReceived(_args);
    //   handleIncomingMessage(args, emit);
    // });
    _connectionHub.hubConnection
        .on("ReceiveMessage", (arguments) => _handleIncomingMessage(arguments));

    if (_connectionHub.hubConnection.state != HubConnectionState.Connected ||
        _connectionHub.hubConnection.state != HubConnectionState.Connecting) {
      await _connectionHub.hubConnection.start()?.then((value) => {},
          onError: (Object error, StackTrace stackTrace) {
        debugPrint('OnError ${stackTrace}');
      });
      _connectionIsOpen = true;
      debugPrint('OnConnectStart');
      //emit(SignalRConnected(allChatMessages!));
    }
  }

  _handleIncomingMessage(List<Object?>? arguments) {
    if (!isClosed) {
      debugPrint('Controller is Not Closed');
      add(IncomingMessageEvent(arguments));
    } else {
      debugPrint('Controller is Closed');
    }
  }

  FutureOr<void> _onDocumentUploadEvent(
      SignalRUploadEvent event, Emitter<SignalRState> emit) async {
    var receiversId = _recentChats!.self!
        ? _recentChats!.receiverId!
        : _recentChats!.senderId!;
    var senderName = _recentChats!.self!
        ? _recentChats!.receiver!
        : _recentChats!.sender!;
    emit(SignalRLoading([]));
    var apiResponse = await _api.uploadFile(senderName, event.file, receiversId);
    debugPrint('Received Document Upload');
    if (apiResponse is FileUploadResponse) {
      FileUploadResponse response = apiResponse as FileUploadResponse;
      debugPrint('Received Document Successfull');
      if (response.status!) {
        debugPrint('Received Document Loading Initial Message');
        add(const LoadInitialMessagesEvent());
      } else {
        debugPrint('Received Document Error');
        var exception = APIException(response.message,
            APIError.SYSTEM_ERROR.value as int?, APIError.SYSTEM_ERROR);
        emit(SignalRApiException(ApiStatus.authFailed, exception));
      }
    }
    if (apiResponse is APIException) {
      debugPrint('Received API Exception');
      var message = apiResponse.errors != null ? getErrorMessage(apiResponse.errors!): apiResponse.message;
      APIException exception = new APIException(message, apiResponse.apiError.value as int?, apiResponse.apiError);
      debugPrint('Received API Exception ${exception.toString()}');
      emit(SignalRApiException(ApiStatus.failure, exception));
    }
  }

  getErrorMessage(List<String> list) {
    var buffer = StringBuffer();
    for (var i = 0; i < list.length; i++) {
      buffer.write('${(i + 1)}. ${list[i]}\n');
    }
    return buffer.toString();
  }

  bool checkIsVideo(String chatDoc) {
    return chatDoc.contains('.mp4') || chatDoc.contains('.mov');
  }

  FutureOr<void> onDeleteChat(
      SignalRMessageDelete event, Emitter<SignalRState> emit) async {
    emit(SignalRLoading([]));
    var apiResponse = await _api.deleteChat(event.messageId!);
    if (apiResponse is ApiResponse) {
      ApiResponse response = apiResponse as ApiResponse;
      if (response.status!) {
        allChatMessages!.removeAt(event.position!);
        emit(SignalRLoadSuccess(allChatMessages!));
      } else {
        var exception = APIException(response.message,
            APIError.SYSTEM_ERROR.value as int?, APIError.SYSTEM_ERROR);
        emit(SignalRApiException(ApiStatus.failure, exception));
      }
    }
    if (apiResponse is APIException) {
      emit(SignalRApiException(ApiStatus.failure, apiResponse as APIException));
    }
  }

  MessageType getMessageType(SendMessageModel message) {
    if (message.File != null && message.File!.isNotEmpty) {
      if (message.File!.toLowerCase().contains('jpeg') ||
          message.File!.toLowerCase().contains('jpg') ||
          message.File!.toLowerCase().contains('png')) {
        return MessageType.image;
      }

      if (message.File!.toLowerCase().contains('pdf') ||
          message.File!.toLowerCase().contains('xlsx')) {
        return MessageType.file;
      }
      if (message.File!.toLowerCase().contains('mp3') ||
          message.File!.toLowerCase().contains('aac')) {
        return MessageType.audio;
      }
      if (message.File!.toLowerCase().contains('mp4') ||
          message.File!.toLowerCase().contains('wav')) {
        return MessageType.video;
      }
    }
    return MessageType.text;
  }

  Message getMessage(
      MessageType type, SendMessageModel message, String senderId) {
    switch (type) {
      case MessageType.image:
        return ImageMessage(
            id: Uuid().v1(),
            type: MessageType.image,
            author: User(id: senderId),
            name: FilePathUtils().getFileName(message.File!),
            size: 1000,
            uri: FilePathUtils().getFilePathUrl(message.File!),
            status: Status.seen);
      case MessageType.audio:
        return AudioMessage(
            id: Uuid().v1(),
            type: MessageType.audio,
            author: User(id: senderId),
            name: FilePathUtils().getFileName(message.File!),
            size: 1000,
            uri: FilePathUtils().getFilePathUrl(message.File!),
            status: Status.seen,
            duration: Duration.zero);
      case MessageType.video:
        return VideoMessage(
            id: Uuid().v1(),
            type: MessageType.video,
            author: User(id: senderId),
            name: FilePathUtils().getFileName(message.File!),
            size: 1000,
            uri: FilePathUtils().getFilePathUrl(message.File!),
            status: Status.seen);
      case MessageType.file:
        return FileMessage(
            id: Uuid().v1(),
            type: MessageType.file,
            author: User(id: senderId),
            name: FilePathUtils().getFileName(message.File!),
            size: 1000,
            uri: FilePathUtils().getFilePathUrl(message.File!),
            status: Status.seen);
      default:
        return TextMessage(
            id: Uuid().v1(),
            type: MessageType.text,
            author: User(id: senderId),
            text: message.message!,
            status: Status.seen);
    }
  }

  void loadUserDetails() async {
    String userDetails = "";
    userDetails = await LocalSharedPref().getUserDetails();
    currentUserDetails = UserDetails.fromJson(jsonDecode(userDetails));
  }

  Future<FutureOr<void>> _onDownloadFileEvent(
      FileDownloadEvent event, Emitter<SignalRState> emit) async {
    //emit(SignalRLoading([]));
    var directory = await getApplicationCacheDirectory();
    directory = directory.absolute.parent;
    var path =
        '${directory.path}/files/${FileUtils().getFile(event.message!.uri)}';
    debugPrint('FilePath : $path');
    final dio = Dio();
    final index = allChatMessages!
        .indexWhere((element) => element.id == event.message!.id);
    //debugdebugPrint(index);
    try {
      if (!File(path).existsSync()) {
        debugPrint('File Does not exist on local path : $path');
        final updatedMessage =
            (allChatMessages![index] as FileMessage).copyWith(
          isLoading: true,
        );
        allChatMessages![index] = updatedMessage;
        emit(SignalRLoadSuccess(allChatMessages!));
        debugPrint('Starting Download');
        await dio.download(event.message!.uri, '$path',
            onReceiveProgress: (int count, int total) {
          double percentage = ((count / total) * 100);
          debugPrint('Percent Download: $percentage');
          if (percentage == 100) {
            final updatedMessage = (allChatMessages![index] as FileMessage)
                .copyWith(isLoading: false, uri: path);
            allChatMessages![index] = updatedMessage;
            emit(SignalRLoadSuccess(allChatMessages!));
            OpenFile.open(path);
          }
        });
      }else{
        debugPrint('File Does exist on local path : $path');
        debugPrint('Updating File Path URI and Returning : $path');
        final updatedMessage = (allChatMessages![index] as FileMessage)
            .copyWith(isLoading: false, uri: path);
        debugPrint('Updating Chat Message at index $index with ${updatedMessage.toJson()}');
        allChatMessages!.removeAt(0);
        allChatMessages!.add(updatedMessage);
        //allChatMessages![index] = ;
        emit(SignalRLoadSuccess(allChatMessages!));

        OpenFile.open(path);
      }
    } catch (e) {
      debugPrint(e.toString());
      final updatedMessage =
          (allChatMessages![index] as FileMessage).copyWith(isLoading: false);
      allChatMessages![index] = updatedMessage;
      emit(SignalRLoadSuccess(allChatMessages!));
    }
  }

  FutureOr<void> _getUserDetailsEvent(SignalRFindUserDetailsEvent event, Emitter<SignalRState> emit) async{
    emit(SignalRLoading([]));
    try{
      var apiResponse = await _api.searchUserDetails(event.receiversId!);
      if (apiResponse is UserDetailsApiResponse) {
        UserDetailsApiResponse response = apiResponse as UserDetailsApiResponse;
        debugPrint('Bloc Response');
        if (response.status!) {
          debugPrint('Bloc Response status true');
          var model = response.profileDetails;
          ContactsAPI contactsAPI = ContactsAPI.name(model!.id,
            '${model!.firstName} ${model.lastName}',
            model.phoneNumber,
            '',
            model.bankDetails != null ? model.bankDetails!.bank: '',
            model.bankDetails != null ? model.bankDetails!.accountHolderName: '',
            model.bankDetails != null ? model.bankDetails!.swiftCode: '',
            model.bankDetails != null ? model.bankDetails!.accountNumber: '',
          );

          debugPrint('Contacts API is Ready ${contactsAPI.toJson()}');
          emit(SignalRUserState(allChatMessages!, contactsAPI));
          emit(SignalRLoadSuccess(allChatMessages!));
        } else {
          // var exception = APIException(response.message,
          //     APIError.SYSTEM_ERROR.value as int?, APIError.SYSTEM_ERROR);
          emit(SignalRLoadSuccess(allChatMessages!));
        }
      }
      if (apiResponse is APIException) {
        emit(SignalRLoadSuccess(allChatMessages!));
      }
    }catch(e){
      emit(SignalRLoadSuccess(allChatMessages!));
    }
  }
}
