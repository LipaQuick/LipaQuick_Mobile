import 'dart:convert';
import 'dart:ffi';

import 'package:equatable/equatable.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as message_type;
import 'package:lipa_quick/core/global/Application.dart';
import 'package:lipa_quick/core/models/payment/recent_transaction.dart';
import 'package:lipa_quick/core/models/response.dart';

class RecentChatResponse {
  bool? status;
  String? message;
  int? skip;
  int? total;
  List<RecentChats>? data;
  List<String>? errors;

  RecentChatResponse(
      {this.status, this.message, this.skip, this.total, this.errors, this.data});

  // RecentChatResponse({this.status, this.message,this.total});

  factory RecentChatResponse.fromJson(Map<String, dynamic> json) {

    return RecentChatResponse(
      status: json['status'],
      message: json['message'],
      skip: json['skip'] ?? 0,
      total: json['total'] ??  0,
      errors: (json['errors'] as List<dynamic>? ?? []).cast<String>(),
      data: json['data'] == null
          ? []
          : List<RecentChats>.from(
              json['data'].map((x) => RecentChats.fromJson(x))),
    );
  }
}

class RecentChats extends Equatable {
  int? minutesAgo;
  int? daysAgo;
  String? timeAgo;
  int? messageCount;
  String? id;
  String? sender;
  String? receiver;
  String? senderPhone;
  String? receiverPhone;
  String? senderId;
  String? receiverId;
  String paymentId = '';
  String? paymentDetails;
  String? message;
  String? chatDoc;
  String? chatDocSize;
  bool? self;
  String? createdAt;
  String? createdBy;
  String? modifiedAt;
  String? modifiedBy;
  String? profilePicture;
  bool? isLoadMore;
  bool isOpened = false;


  RecentChats({
    this.minutesAgo,
    this.daysAgo,
    this.timeAgo,
    this.messageCount,
    this.id,
    this.sender,
    this.receiver,
    this.senderPhone,
    this.receiverPhone,
    this.senderId,
    this.receiverId,
    required this.paymentId,
    this.paymentDetails,
    this.message,
    this.chatDoc,
    this.chatDocSize,
    this.self,
    this.createdAt,
    this.createdBy,
    this.modifiedAt,
    this.modifiedBy,
    this.profilePicture,
    this.isLoadMore,
    required this.isOpened,
  });


  RecentChats.name();

  factory RecentChats.fromJson(Map<String, dynamic> json) {
    return RecentChats(
      minutesAgo: json['minutesAgo'] ?? -1,
      daysAgo: json['daysAgo'] ?? -1,
      timeAgo: json['timeAgo'] ?? '',
      messageCount: json['messageCount'] ?? -1,
      id: json['id'] ?? '',
      sender: json['sender'] ?? '',
      receiver: json['receiver'] ?? '',
      senderPhone: json['senderPhone'] ?? '',
      receiverPhone: json['receiverPhone'] ?? '',
      senderId: json['senderId'] ?? '',
      paymentId: json['paymentId'] ?? '',
      paymentDetails: json['paymentDetails'] ?? '',
      receiverId: json['receiverId'] ?? '',
      message: json['message'] ?? '',
      chatDoc: json['chatDoc'] ?? '',
      chatDocSize: json['chatDocSize'] ?? '0.0',
      self: json['self'] ?? false,
      createdAt: json['createdAt'] ?? '',
      createdBy: json['createdBy'] ?? '',
      modifiedAt: json['modifiedAt'] ?? '',
      modifiedBy: json['modifiedBy'] ?? '',
      profilePicture: json['profilePicture'] ?? '',
      isOpened: false,
    );
  }

  factory RecentChats.fromRemoteNotificationJson(Map<String, dynamic> json) {
    return RecentChats(
      minutesAgo: json['minutesAgo'] ?? -1,
      daysAgo: json['daysAgo'] ?? -1,
      timeAgo: json['timeAgo'] ?? '',
      messageCount: json['messageCount'] ?? -1,
      id: json['id'] ?? '',
      sender: json['Sender'] ?? '',
      receiver: json['Receiver'] ?? '',
      senderPhone: json['SenderPhone'] ?? '',
      receiverPhone: json['ReceiverPhone'] ?? '',
      senderId: json['SenderId'] ?? '',
      paymentId: json['PaymentId'] ?? '',
      paymentDetails: json['PaymentDetails'] ?? '',
      receiverId: json['ReceiverId'] ?? '',
      message: json['Message'] ?? '',
      chatDoc: json['ChatDoc'] ?? '',
      chatDocSize: json['ChatDocSize'] ?? '0.0',
      self: false,
      createdAt: json['CreatedAt'] ?? '',
      createdBy: json['CreatedBy'] ?? '',
      modifiedAt: json['ModifiedAt'] ?? '',
      modifiedBy: json['ModifiedBy'] ?? '',
      profilePicture: json['profilePicture'] ?? '',
      isOpened: false,
    );
  }

  message_type.Message toMessage(UserDetails userDetails) {
    final author = getAuthor(self, senderId, receiverId, sender: sender);
    //final author = userDetails.toUser();
    if(paymentId.isNotEmpty && paymentDetails != null){
      return message_type.CustomMessage(
          id: id!,
          type: message_type.MessageType.custom,
          author: author,
          metadata: jsonDecode(paymentDetails!),
          status: message_type.Status.seen);
    }

    if (chatDoc != null) {
      final type = getDocumentType(chatDoc!);
      print('type : $type, File Path ${chatDoc}, Author: $author}');

      if (type == 'image') {
        return message_type.ImageMessage(
            id: id!,
            type: message_type.MessageType.image,
            author: author,
            name: getFileName(chatDoc!),
            createdAt: getTimeInMs(modifiedAt),
            updatedAt: getTimeInMs(modifiedAt),
            size: 1000,
            uri: getFilePathUrl(chatDoc!),
            status: message_type.Status.seen);
      }
      else if (type == 'document') {
        return message_type.FileMessage(
            id: id!,
            type: message_type.MessageType.file,
            author: author,
            createdAt: getTimeInMs(modifiedAt),
            updatedAt: getTimeInMs(modifiedAt),
            name: getFileName(chatDoc!),
            size: double.parse(chatDocSize!),
            uri: getFilePathUrl(chatDoc!),
            status: message_type.Status.seen);
      }
      else if (type == 'audio') {
        return message_type.AudioMessage(
            id: id!,
            type: message_type.MessageType.audio,
            author: userDetails.toUser(),
            name: getFileName(chatDoc!),
            createdAt: getTimeInMs(modifiedAt),
            updatedAt: getTimeInMs(modifiedAt),
            size: 1000,
            uri: getFilePathUrl(chatDoc!),
            duration: Duration.zero,
            status: message_type.Status.seen);
      }
      else if (type == 'video') {
        Map<String, dynamic> metadata = {
          'type': 'video',
          'url': getFilePathUrl(chatDoc!),
          'timestamp': modifiedAt,
        };
        return message_type.VideoMessage(
            id: id!,
            type: message_type.MessageType.video,
            author: author,
            name: getFileName(chatDoc!),
            createdAt: getTimeInMs(modifiedAt),
            updatedAt: getTimeInMs(modifiedAt),
            size: 1000,
            uri: getFilePathUrl(chatDoc!),
            metadata: metadata,
            status: message_type.Status.seen);
      }
    }

    // Default to a text message if chatDoc type is unknown or missing
    return message_type.TextMessage(
        id: id ?? '',
        type: message_type.MessageType.text,
        createdAt: getTimeInMs(modifiedAt),
        updatedAt: getTimeInMs(modifiedAt),
        author: author,
        text: message!,
        status: message_type.Status.seen);
  }

  Map<String, dynamic> toJson() {
    return {
      'minutesAgo': minutesAgo,
      'daysAgo': daysAgo,
      'timeAgo': timeAgo,
      'messageCount': messageCount,
      'id': id,
      'sender': sender,
      'receiver': receiver,
      'senderId': senderId,
      'receiverId': receiverId,
      'paymentId': paymentId,
      'message': message,
      'chatDoc': chatDoc,
      'self': self,
      'createdAt': createdAt,
      'createdBy': createdBy,
      'modifiedAt': modifiedAt,
      'modifiedBy': modifiedBy,
      'profilePicture': profilePicture,
    };
  }

  @override
  List<Object?> get props => [
        id,
        sender,
        receiver,
        senderId,
        receiverId,
        paymentId,
        message,
        chatDoc,
        self,
        minutesAgo,
        daysAgo,
        timeAgo,
        messageCount,
        senderPhone,
        receiverPhone,
      ];

  String getProfilePictureLogo() {
    var base64Image = profilePicture != null ? profilePicture!.split(",") : ['',''];
    return base64Image.last;
  }

  String getDocumentType(String s) {
    if (s.toString().contains('jpeg') ||
        s.toString().contains('jpg') ||
        s.toString().contains('png')) {
      return 'image';
    }

    if (s.toString().contains('mp4')
        || s.toString().contains('mov')) {
      return 'video';
    }

    if (
    s.toString().contains('pdf')
    || s.toString().contains('docx')
    || s.toString().contains('doc')
    || s.toString().contains('xlsx')
    || s.toString().contains('xls')
    || s.toString().contains('zip')

    ) {
      return 'document';
    }

    if (s.toString().contains('mp3')) {
      return 'audio';
    }
    return 'text';
  }

  String getFilePathUrl(String chatDoc) {
    print(
        '${ApplicationData().FILE_PATH_BASE_URL}/${chatDoc.replaceAll(r'\', r'/')}');
    return '${ApplicationData().FILE_PATH_BASE_URL}/${chatDoc.replaceAll(r'\', r'/')}';
  }

  String getFileName(String chatDoc) {
    print(
        '${ApplicationData().FILE_PATH_BASE_URL}/${chatDoc.replaceAll(r'\', r'/')}'
            .split('/')
            .last);
    return '${ApplicationData().FILE_PATH_BASE_URL}/${chatDoc.replaceAll(r'\', r'/')}'
        .split('/')
        .last;
  }

  getAuthor(bool? isSelf, String? senderId, String? receiverId, {String? sender}) {
    return message_type.User(id: senderId!, firstName: sender!);
  }

  @override
  String toString() {
    return 'RecentChats{id: $id, sender: $sender, receiver: $receiver, senderPhone: $senderPhone'
        ', receiverPhone: $receiverPhone, self: $self, message: $message, chatDoc: $chatDoc, paymentDetails: $paymentId}';
  }

  int getTimeInMs(String? createdAt) {

    try{
      print('Message DateTime ${createdAt}');
      DateTime dateTime = DateTime.parse(createdAt!);

      // Get milliseconds since epoch
      int millisecondsSinceEpoch = dateTime.millisecondsSinceEpoch;
      return millisecondsSinceEpoch;
    }catch(e){
      return DateTime.now().millisecondsSinceEpoch;
    }
  }
}

