import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:intl/intl.dart';
import 'package:lipa_quick/core/crypto/encryption.dart';
import 'package:lipa_quick/core/models/api_exception/api_exception.dart';
import 'package:lipa_quick/core/models/chats/file_upload_response.dart';
import 'package:lipa_quick/core/models/chats/recent_chat/recent_chat_response.dart';
import 'package:lipa_quick/core/models/chats/send_message_request.dart';
import 'package:lipa_quick/core/models/payment/qr_payment_model.dart' as details;
import 'package:lipa_quick/core/models/request_header_dto.dart';
import 'package:lipa_quick/core/services/api.dart';
import 'package:lipa_quick/core/services/device_details.dart';
import 'package:lipa_quick/core/services/local_shared_pref.dart';
import 'package:lipa_quick/main.dart';
import 'package:lipa_quick/ui/views/chat/utils/message_util.dart';
import 'package:lipa_quick/ui/views/chat/widgets/download_helpers.dart';
import 'package:path_provider/path_provider.dart';
import 'package:signalr_netcore/ihub_protocol.dart';
import 'package:signalr_netcore/signalr_client.dart';
import '../../../core/models/response.dart';
import 'utils/viewModel/viewModel.dart';
import 'utils/viewModel/viewModelProvider.dart';
import 'package:flutter/widgets.dart';
import 'package:logging/logging.dart';
import 'package:lipa_quick/core/global/Application.dart';


typedef HubConnectionProvider = Future<HubConnection> Function();


class ChatPageViewModel extends ViewModel {
// Properties
  String? _serverUrl;
  HubConnection? _hubConnection;
  Api _api = locator<Api>();
  Logger? _logger;
  StreamSubscription<LogRecord>? _logMessagesSub;
  //Total chat messages that needs to be loaded
  int _totalMessages = 0;
  // At the beginning, we fetch the first 20 posts
  int _page = 0;
  // you can change this value to fetch more or less posts per page (10, 15, 5, etc)
  int? _limit = 20;
  // Used to display loading indicators when _firstLoad function is running
  bool _isFirstLoadRunning = false;
  // Used to display loading indicators when _loadMore function is running
  bool _isLoadMoreRunning = false;
  List<RecentChats>? _chatMessages;
  bool? _connectionIsOpen;
  String? _receiversId;
  String? _senderId;

  static const String chatTotalPropName = "_totalMessages";
  int get getTotalMessages => _totalMessages;
  set chatTotalMessages(int value) {
    updateValue(chatTotalPropName, _totalMessages, value,
            (v) => _totalMessages = v);
  }


  static const String chatPagePropName = "_page";
  int get getPage => _page;
  set chatPage(int value) {
    updateValue(chatPagePropName, _page, value,
            (v) => _page = v);
  }

  static const String chatLimitPropName = "_limit";
  int get getLimit => _limit!;
  set chatLimit(int value) {
    updateValue(chatLimitPropName, _limit, value,
            (v) => _limit = v);
  }
  // There is next page or not
  bool _hasNextPage = true;
  static const String chatHasNextPagePropName = "_hasNextPage";
  bool get getHasNextPage => _hasNextPage;
  set hasNextPage(bool value) {
    updateValue(chatHasNextPagePropName, _hasNextPage, value,
            (v) => _hasNextPage = v);
  }


  static const String chatFirstLoadingPropName = "_isFirstLoadRunning";
  bool get getFirstLoading => _isFirstLoadRunning;
  set setFirstLoading(bool value) {
    updateValue(chatFirstLoadingPropName, _isFirstLoadRunning, value,
            (v) => _isFirstLoadRunning = v);
  }


  static const String chatLoadMorePropName = "_isLoadMoreRunning";
  bool get getLoadMore => _isLoadMoreRunning;
  set setLoadMore(bool value) {
    updateValue(chatLoadMorePropName, _isLoadMoreRunning, value,
            (v) => _isLoadMoreRunning = v);
  }

  //List<RecentChats>? _chatMessages;
  static const String chatMessagesPropName = "chatMessages";
  List<RecentChats> get chatMessages => _chatMessages!;


  static const String connectionIsOpenPropName = "connectionIsOpen";
  bool get connectionIsOpen => _connectionIsOpen!;
  set connectionIsOpen(bool value) {
    updateValue(connectionIsOpenPropName, _connectionIsOpen, value,
        (v) => _connectionIsOpen = v);
  }


  static const String receiversPropName = "_receiversId";
  String get receiversId => _receiversId!;
  set receiversId(String value) {
    updateValue(receiversPropName, _receiversId, value, (v) => _receiversId = v);
  }


  static const String sendersPropName = "_senderId";
  String get sendersId => _senderId!;
  set sendersId(String value) {
    updateValue(sendersPropName, _senderId, value, (v) => _senderId = v);
  }

// Methods
  void initAndOpenConnection([String? sendersId, String? receiversId]){
    _serverUrl = ApplicationData().kChatServerUrl;
    _chatMessages = [];
    _connectionIsOpen = false;
    //getUserId();

    _receiversId = receiversId!;
    _senderId = sendersId;

    Logger.root.level = Level.ALL;
    _logMessagesSub = Logger.root.onRecord.listen(_handleLogMessage);
    _logger = Logger("ChatPageViewModel");

    openChatConnection(receiversId);
  }

  @override
  Future<void> dispose() async {
    await _hubConnection!.stop().then((value) => {
      print('Hub Connection Closed.')
    });
    _logMessagesSub?.cancel();
    super.dispose();
  }

  void _handleLogMessage(LogRecord msg) {
    print(msg.message);
  }

  Future<void> openChatConnection([String? receiverId]) async {
    final logger = _logger;

    var messageHeader = MessageHeaders();
    String token  = '';
    getToken().then((value) => token = value);

    var deviceInfo = <String, dynamic>{};
    await DeviceInfo().getDeviceInfo().then((value) {
      deviceInfo = value;
    });
    RequestHeaderDto requestHeaderDto = RequestHeaderDto(
        deviceInfo['Source'], deviceInfo['Device'], deviceInfo['Version']);
    String headerEn =
    encryptAESCryptoJS(jsonEncode(requestHeaderDto.toJson()));

    // "content-type": "application/json",
    // "accept": "application/json",
    // 'User-Agent': headerEn,
    // 'Authorization': 'Bearer $token'
    messageHeader.setHeaderValue('Authorization', 'Bearer $token');
    messageHeader.setHeaderValue('content-type', 'application/json');
    messageHeader.setHeaderValue('accept', 'application/json');
    messageHeader.setHeaderValue('User-Agent', headerEn);

    if (_hubConnection == null) {
      final httpConnectionOptions = HttpConnectionOptions(
          httpClient: WebSupportingHttpClient(logger, httpClientCreateCallback: _httpClientCreateCallback),
          accessTokenFactory: getToken,
          logger: logger,
          skipNegotiation: false,
          //headers: messageHeader,
          logMessageContent: true);

      _hubConnection = HubConnectionBuilder()
          .withUrl(_serverUrl!, options: httpConnectionOptions)
          //.withHubProtocol(JSONProtocol())
          .withAutomaticReconnect()
          .configureLogging(logger!)
          .build();
      _hubConnection!.onclose(({error}) => connectionIsOpen = false);
      _hubConnection!.onreconnecting(({error}) {
        print("onreconnecting called");
        connectionIsOpen = false;
      });
      _hubConnection!.onreconnected(({connectionId}) {
        print("onreconnected called");
        connectionIsOpen = true;
      });
      _hubConnection!.on("ReceiveMessage", _handleIncommingChatMessage);
    }

    if (_hubConnection!.state != HubConnectionState.Connected
        || _hubConnection!.state != HubConnectionState.Connecting) {
      await _hubConnection!.start();
      connectionIsOpen = true;
    }

    loadInitialMessage(0, 20, receiverId);
  }

  Future<void> sendChatMessage(RecentChats chats, String chatMessage) async {
    if (chatMessage == null || chatMessage.length == 0) {
      return;
    }

    DateTime dateTime = DateTime.now();
    DateFormat dateFormat = DateFormat('yyyy-MM-dd hh:mm:ss aaa');

    SendMessageModel sendMessageModel = SendMessageModel(
      LocalMessageType.TEXT.name
      , chatMessage, "", null);

    _chatMessages!.insert(0,  RecentChats(minutesAgo: 0, timeAgo: "0", daysAgo: 0,messageCount: 0
        , senderId: _senderId, receiverId: _receiversId, message: sendMessageModel.message
        ,chatDoc: sendMessageModel.File, self: true, createdAt: '', createdBy: ''
        , modifiedAt: dateFormat.format(dateTime), paymentId: '', isOpened: true));

    notifyPropertyChanged(chatMessagesPropName);

    _hubConnection!.invoke("SendMessageToGroup", args: <Object>[chats.self!?chats.receiverId!:chats.senderId!
      , sendMessageModel]);

    //await openChatConnection();
  }

  //Chat Message Type
  /**
   * 1. Text
   * 2. Image, File
   *    Extension
   *    then load
   * 3. Payment Details
   * Later we have to de-crypt this entire message
   */

  void _handleIncommingChatMessage(List<Object?>? args) {
    print('Received a Message from Chat Socket');
    DateTime dateTime = DateTime.now();
    //2023-08-08 12:11:41 PM
    DateFormat dateFormat = DateFormat('yyyy-MM-dd hh:mm:ss aaa');

    final String _id = args![0] as String;
    final  Map<String, dynamic> _chatMessageObject = args[1] as Map<String, dynamic>;
    print('Id Received is:$_id\nMessage: $_chatMessageObject');
    SendMessageModel message = SendMessageModel.fromJson(_chatMessageObject);
    _chatMessages!.insert(0, RecentChats(minutesAgo: 0, timeAgo: "0", daysAgo: 0,messageCount: 0
        , senderId: _senderId, receiverId: _receiversId, message: message.message
        ,chatDoc: message.File, self: false, createdAt: '', createdBy: ''
        , modifiedAt: dateFormat.format(dateTime), paymentId: '', isOpened: true));
    notifyPropertyChanged(chatMessagesPropName);
  }

  void getUserId() async {
    var userDetails = await LocalSharedPref().getUserDetails();
    UserDetails details = UserDetails.fromJson(jsonDecode(userDetails));
    _receiversId = details.id;
  }

  void loadInitialMessage([int skip = 0, int pageSize = 20, String? receiversId]) async{
    var response = await _api.getAllChats(skip, pageSize, receiversId);
    if(response is RecentChatResponse){
      if(response.status!){
        _totalMessages = response.total!;

        if(response.data!.isNotEmpty){
          if(_chatMessages!.isNotEmpty){
            _chatMessages!.clear();
          }
          _chatMessages!.addAll(response.data!);
          if((_chatMessages!.length -1) < _totalMessages) {
            _isLoadMoreRunning = false;
            //_hasNextPage = true;
            notifyPropertyChanged(chatFirstLoadingPropName);
          }
          notifyPropertyChanged(chatMessagesPropName);
        }
      }
    }
    else if(response is APIException){

    }

  }

  Future<String> getToken() async{
    return LocalSharedPref().getToken();
  }

  void loadMoreChats(bool scrollMore) {
    print('Load More Triggered ${getHasNextPage} \n $getFirstLoading \n $getLoadMore \n $scrollMore');
    if (getHasNextPage &&
        getFirstLoading == false &&
        getLoadMore == false  &&
        scrollMore) {
      _isLoadMoreRunning = true;
      notifyPropertyChanged(chatLoadMorePropName);
      _page = _page + 1;
      if(_chatMessages!.length < _totalMessages){
        loadInitialMessage(_page, 20, _receiversId);
      }
    }
  }

  Future<void> uploadChatFile(File? image) async {
    var apiResponse = _api.uploadFile('',image, _receiversId);
    if(apiResponse is ApiResponse){
      FileUploadResponse response = apiResponse as FileUploadResponse;
      if(response.status!){
        loadInitialMessage(_page, 20, _receiversId);
      }
    }
  }

  bool checkIsImage(String? chatDoc) {
    return  chatDoc != null &&
        (chatDoc.toString().toLowerCase().contains('.jpeg')
    || chatDoc.toString().toLowerCase().contains('.jpg')
    || chatDoc.toString().toLowerCase().contains('.png'));
  }

  bool checkIsDocument(String? chatDoc) {
    return chatDoc != null && (
            chatDoc.toString().toLowerCase().contains('.pdf')
            || chatDoc.toString().toLowerCase().contains('.docx')
            || chatDoc.toString().toLowerCase().contains('.xlsx')
            || chatDoc.toString().toLowerCase().contains('.xls')
    );
  }

  Future<String> get localPath async {
    final directory = await getApplicationDocumentsDirectory();

    return directory.path;
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
}

void _httpClientCreateCallback(Client httpClient) {
  HttpOverrides.global = HttpOverrideCertificateVerificationInDev();
}

class HttpOverrideCertificateVerificationInDev extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

class ChatPageViewModelProvider extends ViewModelProvider<ChatPageViewModel> {
  // Properties

  // Methods
  ChatPageViewModelProvider(
      {Key? key, viewModel: ChatPageViewModel, WidgetBuilder? childBuilder})
      : super(key: key, viewModel: viewModel, childBuilder: childBuilder!);

  static ChatPageViewModel? of(BuildContext context) {
    return (context
            .dependOnInheritedWidgetOfExactType<ChatPageViewModelProvider>())
        ?.viewModel;
  }
}

