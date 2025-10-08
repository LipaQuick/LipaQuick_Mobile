import 'package:lipa_quick/core/models/payment/paymentresponse.dart';

class SendMessageModel {
  String? type;
  String? message;
  String? File;
  PaymentResponse? paymentDetails;

  SendMessageModel(this.type, this.message, this.File, this.paymentDetails);

  SendMessageModel.fromJson(Map<String, dynamic> json) {
    type = json['type'];
    message = json['message'];
    File = json['File'];
    paymentDetails = json['paymentDetails'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['type'] = type;
    data['message'] = message;
    data['File'] = File;
    data['paymentDetails'] = paymentDetails;
    return data;
  }


}