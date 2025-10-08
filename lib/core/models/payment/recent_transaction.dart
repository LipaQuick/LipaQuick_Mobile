import 'package:lipa_quick/core/models/payment/payment.dart';

class RecentTransactionResponse {
  bool? status;
  String? message;
  int? skip;
  int? pageSize;
  int? total;
  List<RecentTransaction>? data;

  RecentTransactionResponse(
      {status, skip, pageSize, total, data});

  RecentTransactionResponse.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    skip = json['skip'];
    pageSize = json['pageSize'];
    total = json['total'];
    if (json['data'] != null) {
      data = <RecentTransaction>[];
      json['data'].forEach((v) {
        data?.add(RecentTransaction.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    data['message'] = message;
    data['skip'] = skip;
    data['pageSize'] = pageSize;
    data['total'] = total;
    data['data'] = this.data?.map((v) => v.toJson()).toList();
    return data;
  }
}

class RecentTransaction {
  String? id;
  String? sender;
  String? receiver;
  String? senderId;
  String? receiverId;
  bool? isDebit;
  bool? isCredit;
  int? amount;
  String? service;
  String? bankReferenceId;
  String? referenceId;
  String? status;
  String? createdAt;
  String? createdBy;
  String? modifiedAt;
  String? modifiedBy;
  String? remarks;

  RecentTransaction(
      {this.id,
        this.sender,
        this.receiver,
        this.senderId,
        this.receiverId,
        this.isDebit,
        this.isCredit,
        this.amount,
        this.service,
        this.remarks,
        this.bankReferenceId,
        this.referenceId,
        this.status,
        this.createdAt,
        this.createdBy,
        this.modifiedAt,
        this.modifiedBy});

  factory RecentTransaction.fromJson(Map<String, dynamic> json) {
    return RecentTransaction(
        id : json['id'],
        sender : json['sender'],
        receiver : json['receiver'],
        senderId : json['senderId'],
        receiverId : json['receiverId'],
        isDebit : json['isDebit'],
        isCredit : json['isCredit'],
        amount : json['amount'],
        service : json['service'],
        remarks : json['remarks'],
        bankReferenceId : json['bankReferenceId'],
        referenceId : json['referenceId'],
        status : json['status'],
        createdAt : json['createdAt'],
        createdBy : json['createdBy'],
        modifiedAt : json['modifiedAt'],
        modifiedBy : json['modifiedBy']
    );
  }

  factory RecentTransaction.fromChatJson(Map<String, dynamic> json) {
    return RecentTransaction(
        id : json['Id'],
        sender : json['Sender'],
        receiver : json['Receiver'],
        senderId : json['SenderId'],
        receiverId : json['ReceiverId'],
        isDebit : json['IsDebit'] == 1,
        isCredit : json['IsCredit'] == 1,
        amount : double.tryParse(json['Amount'].toString())?.toInt(),
        service : json['Service'],
        remarks: json['remarks'] ?? '',
        bankReferenceId : json['BankReferenceId'],
        referenceId : json['ReferenceId'],
        status : json['Status'],
        createdAt : json['CreatedAt'],
        createdBy : json['CreatedBy'],
        modifiedAt : json['ModifiedAt'],
        modifiedBy : json['ModifiedBy']
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['sender'] = sender;
    data['receiver'] = receiver;
    data['senderId'] = senderId;
    data['receiverId'] = receiverId;
    data['isDebit'] = isDebit;
    data['isCredit'] = isCredit;
    data['amount'] = amount;
    data['service'] = service;
    data['bankReferenceId'] = bankReferenceId;
    data['referenceId'] = referenceId;
    data['status'] = status;
    data['createdAt'] = createdAt;
    data['createdBy'] = createdBy;
    data['modifiedAt'] = modifiedAt;
    data['modifiedBy'] = modifiedBy;
    return data;
  }

  PaymentRequest toPaymentRequest(){
    return PaymentRequest(transactionId: id
        , amount: amount?.toInt(), sender: SenderModel(senderId, sender, '', '', '', '')
        , receiver: ReceiverModel(receiverId: receiverId, receiverName: receiver, receiverAccountNumber: ''
            ,receiverAddress: '',receiverPhoneNumber: '',
            receiverSwiftCode: ''));
  }

  @override
  String toString() {
    return 'RecentTransaction{sender: $sender, receiver: $receiver, senderId: $senderId'
        ', receiverId: $receiverId, amount: $amount, status: $status, remarks: $remarks}';
  }
}
