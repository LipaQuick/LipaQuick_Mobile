
import 'package:lipa_quick/core/models/discount/discount_model.dart';
import 'package:lipa_quick/core/models/service/service_response.dart';

class SenderModel{
  String? senderId;
  String? senderName, senderPhoneNumber, senderAccountNumber, senderSwiftCode, senderAddress;

  SenderModel(this.senderId, this.senderName, this.senderPhoneNumber, this.senderAccountNumber
      , this.senderSwiftCode,this.senderAddress);

  SenderModel.fromJson(Map<String, dynamic> json) {
    senderId = json['senderId'];
    senderName = json['senderName'];
    senderPhoneNumber = json['senderPhoneNumber'];
    senderAccountNumber = json['senderAccountNumber'];
    senderSwiftCode = json['senderSwiftCode'];
    senderAddress = json['senderAddress'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['senderId'] = senderId;
    data['senderName'] = senderName;
    data['senderPhoneNumber'] = senderPhoneNumber;
    data['senderAccountNumber'] = senderAccountNumber;
    data['senderSwiftCode'] = senderSwiftCode;
    data['senderAddress'] = senderAddress;
    return data;
  }


  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is SenderModel &&
              runtimeType == other.runtimeType &&
              senderId == other.senderId &&
              senderName == other.senderName &&
              senderAccountNumber == other.senderAccountNumber &&
              senderPhoneNumber == other.senderPhoneNumber;

  @override
  int get hashCode => senderId.hashCode ^ senderName.hashCode ^ senderPhoneNumber.hashCode ^ senderAccountNumber.hashCode;

  @override
  String toString() {
    return 'Contacts{id: $senderId, name: $senderName, phoneNumber: $senderPhoneNumber, accountNumber: $senderAccountNumber}';
  }
}

class ReceiverModel{
  String? receiverId;
  String? receiverName;

  String receiverPhoneNumber = '', receiverAccountNumber = '';
  String? receiverSwiftCode, receiverAddress;

  ReceiverModel({this.receiverId, this.receiverName, this.receiverPhoneNumber = '', this.receiverAccountNumber = ''
      , this.receiverSwiftCode,this.receiverAddress});

  ReceiverModel.fromJson(Map<String, dynamic> json) {
    receiverId = json['receiverId'];
    receiverName = json['receiverName'];
    receiverPhoneNumber = json['receiverPhoneNumber'] ?? '';
    receiverAccountNumber = json['receiverAccountNumber'] ?? '' ;
    receiverSwiftCode = json['receiverSwiftCode'];
    receiverAddress = json['receiverAddress'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['receiverId'] = receiverId;
    data['receiverName'] = receiverName;
    data['receiverPhoneNumber'] = receiverPhoneNumber;
    data['receiverAccountNumber'] = receiverAccountNumber;
    data['receiverSwiftCode'] = receiverSwiftCode;
    data['receiverAddress'] = receiverAddress;
    return data;
  }


  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is SenderModel &&
              runtimeType == other.runtimeType &&
              receiverId == other.senderId &&
              receiverName == other.senderName &&
              receiverAccountNumber == other.senderAccountNumber &&
              receiverPhoneNumber == other.senderPhoneNumber;

  @override
  int get hashCode => receiverId.hashCode ^ receiverName.hashCode ^ receiverPhoneNumber.hashCode ^ receiverAccountNumber.hashCode;

  @override
  String toString() {
    return 'Contacts{id: $receiverId, name: $receiverName, phoneNumber: $receiverPhoneNumber, accountNumber: $receiverAccountNumber}';
  }
}

class PaymentRequest{
  String? transactionId;
  int? amount;
  SenderModel? sender;
  ReceiverModel? receiver;
  DiscountItems? discountItem;
  ServiceChargeCommissionModel? serviceChargeDetails;
  ServiceChargeCommissionModel? serviceCommissionDetails;
  String? paymentMode;
  String? message;


  PaymentRequest({this.transactionId, this.amount, this.sender, this.receiver
    , this.message, this.discountItem, this.serviceChargeDetails, this.serviceCommissionDetails});

  PaymentRequest.fromJson(Map<String, dynamic> json) {
    transactionId = json['transactionId'] as String? ?? '';
    amount = json['amount'] ?? 0;
    paymentMode = json['paymentMode'] ?? '';
    message = json['message'] ?? '';
    sender =  json['sender'] as SenderModel? ?? SenderModel.fromJson(json);
    receiver =  json['receiver'] as ReceiverModel? ?? ReceiverModel.fromJson(json);
    discountItem =  json['discountItem'] as DiscountItems? ?? DiscountItems.fromJson(json);
    serviceChargeDetails =  json['serviceChargeDetails'] as ServiceChargeCommissionModel? ?? ServiceChargeCommissionModel.fromJson(json);
    serviceChargeDetails =  json['serviceChargeDetails'] as ServiceChargeCommissionModel? ?? ServiceChargeCommissionModel.fromJson(json);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['transactionId'] = transactionId;
    data['amount'] = amount;
    data['sender'] = sender;
    data['receiver'] = receiver;
    data['discountItem'] = discountItem?.toJson();
    data['paymentMode'] = paymentMode;
    data['message'] = message;
    return data;
  }
}

class PaymentRequestPayload{
  String? request;


  PaymentRequestPayload(this.request);

  PaymentRequestPayload.fromJson(Map<String, dynamic> json) {
    request = json['request'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['request'] = request;
    return data;
  }
}


