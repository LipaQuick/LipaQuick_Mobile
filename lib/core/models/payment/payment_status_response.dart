class TransactionResponse {
  bool? status;
  String? message;
  List<String>? errors;
  TransactionStatus? data;

  TransactionResponse({
    this.status,
    this.data,
    this.errors,
    this.message,
  });

  factory TransactionResponse.fromJson(Map<String, dynamic> json) =>
      TransactionResponse()
        ..status = json['status'] ?? false
        ..message = json['message'] ?? ''
        ..errors = (json['errors'] as List<dynamic>? ?? []).cast<String>()
        ..data = TransactionStatus.fromJson(json['data']);

}

class TransactionStatus {
  String? id;
  String? sender;
  String? receiver;
  bool? isDebit;
  bool? isCredit;
  int? amount;
  dynamic service;
  dynamic remarks;
  String? bankReferenceId;
  dynamic referenceId;
  String? status;
  String? createdAt;
  String? createdBy;
  String? modifiedAt;
  String? modifiedBy;

  TransactionStatus({
    this.id,
    this.sender,
    this.receiver,
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
    this.modifiedBy,
  });

  factory TransactionStatus.fromJson(Map<String, dynamic> json) {
    //print('Reached Here');
    return TransactionStatus(
        id: json['id'] as String?,
        sender: json['sender'] as String?
        , receiver:json['receiver'] as String?
        , isDebit:json['isDebit'] as bool?
        , isCredit:json['isCredit'] as bool?
        , amount:json['amount'] ?? 0
        , service:json['service'] as String?
        , remarks:json['remarks'] as String?
        , bankReferenceId:json['bankReferenceId'] as String?
        , referenceId:json['referenceId'] as String?
        , status:json['status'] as String?
        , createdAt:json['createdAt'] as String?
        , createdBy:json['createdBy'] as String?
        , modifiedAt:json['modifiedAt'] as String?
        , modifiedBy:json['modifiedBy'] as String?
      );
  }

}