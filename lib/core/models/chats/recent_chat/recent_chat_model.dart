import 'package:equatable/equatable.dart';
import 'package:floor/floor.dart';
import 'package:lipa_quick/core/global/Application.dart';

@entity
class RecentChatModel extends Equatable{
  @primaryKey
  String? id;
  String? sender;
  String? receiver;
  String? senderPhone;
  String? receiverPhone;
  String? senderId;
  String? receiverId;
  String? paymentId;
  String? message;
  String? chatDoc;
  bool? self;
  String? modifiedAt;
  String? profilePicture;
  bool? isOpened;
  int? messageCount;
  int? minutesAgo;
  int? daysAgo;
  String? timeAgo;

  RecentChatModel({
      this.id,
      this.sender,
      this.receiver,
      this.senderPhone,
      this.receiverPhone,
      this.senderId,
      this.receiverId,
      this.paymentId,
      this.message,
      this.chatDoc,
      this.self,
      this.modifiedAt,
      this.profilePicture,
      this.isOpened,
      this.messageCount,
      this.minutesAgo,
      this.daysAgo,
      this.timeAgo});

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

  factory RecentChatModel.fromJson(Map<String, dynamic> json) {
    return RecentChatModel(
      minutesAgo: json['minutesAgo'] ?? -1,
      daysAgo: json['daysAgo'] ?? -1,
      timeAgo: json['timeAgo'] ?? '',
      messageCount: json['messageCount'] ?? -1,
      id: json['id'] as String,
      sender: json['sender'] ?? '',
      receiver: json['receiver'] ?? '',
      senderPhone: json['senderPhone'] ?? '',
      receiverPhone: json['receiverPhone'] ?? '',
      senderId: json['senderId'] ?? '',
      paymentId: json['paymentId'] ?? '',
      receiverId: json['receiverId'] ?? '',
      message: json['message'] ?? '',
      chatDoc: json['chatDoc'] ?? '',
      self: json['self'] ?? false,
      modifiedAt: json['modifiedAt'] ?? '',
      profilePicture: json['profilePicture'] ?? '',
      isOpened: false,
    );
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
      'modifiedAt': modifiedAt,
      'profilePicture': profilePicture,
    };
  }


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