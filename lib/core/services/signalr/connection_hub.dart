import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart';
import 'package:lipa_quick/core/crypto/encryption.dart';
import 'package:lipa_quick/core/global/Application.dart';
import 'package:lipa_quick/core/models/request_header_dto.dart';
import 'package:lipa_quick/core/services/device_details.dart';
import 'package:lipa_quick/core/services/local_shared_pref.dart';
import 'package:lipa_quick/main.dart';
import 'package:logging/logging.dart';
import 'package:signalr_netcore/hub_connection.dart';
import 'package:signalr_netcore/ihub_protocol.dart';
import 'package:signalr_netcore/signalr_client.dart';

class ConnectionHub {
  static ConnectionHub? _instance;
  late final HubConnection _hubConnection;
  late final HttpConnectionOptions _httpConnectionOptions;
  Logger? _logger;
  StreamSubscription<LogRecord>? _logMessagesSub;

  ConnectionHub._internal(){
    getHubConnection();
  }

  factory ConnectionHub() {
    _instance ??= ConnectionHub._internal();
    return _instance!;
  }

  Future<void> getHubConnection() async {
    Logger.root.level = Level.ALL;
    _logMessagesSub = Logger.root.onRecord.listen(_handleLogMessage);
    _logger = Logger("ConnectionHub");

    var messageHeader = MessageHeaders();

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
    messageHeader.setHeaderValue('Authorization', 'Bearer $getToken');
    messageHeader.setHeaderValue('content-type', 'application/json');
    messageHeader.setHeaderValue('accept', 'application/json');
    messageHeader.setHeaderValue('User-Agent', headerEn);

    _httpConnectionOptions = HttpConnectionOptions(
        httpClient: WebSupportingHttpClient(
            _logger!, httpClientCreateCallback: _httpClientCreateCallback),
        accessTokenFactory: getToken,
        logger: _logger!,
        skipNegotiation: false,
        //headers: messageHeader,
        logMessageContent: true);

    _hubConnection = HubConnectionBuilder()
        .withUrl(ApplicationData().kChatServerUrl, options: _httpConnectionOptions)
    //.withHubProtocol(JSONProtocol())
        .withAutomaticReconnect()
        .configureLogging(_logger!)
        .build();
    locator.signalReady(this);
  }

  HubConnection get hubConnection => _hubConnection;

  Future<String> getToken() async {
    return LocalSharedPref().getToken();
  }


  void _handleLogMessage(LogRecord event) {
    print('Hub Event ${event.message}');
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