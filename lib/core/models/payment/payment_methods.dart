import 'package:floor/floor.dart';
import 'package:lipa_quick/core/models/payment/user_payment_methods.dart';

class PaymentMethodResponse {
  bool? status;
  String? message;
  int? skip;
  int? pageSize;
  int? total;
  List<PaymentMethods>? data;

  PaymentMethodResponse(
      {status, skip, pageSize, total, data});

  PaymentMethodResponse.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    skip = json['skip'];
    pageSize = json['pageSize'];
    total = json['total'];
    if (json['data'] != null) {
      data = <PaymentMethods>[];
      json['data'].forEach((v) {
        data?.add(PaymentMethods.fromJson(v));
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


@Entity()
class PaymentMethods {
  @PrimaryKey(autoGenerate: true)
  String? id;
  String? methodName;

  PaymentMethods();

  PaymentMethods.name(this.methodName);


  PaymentMethods.fromJson(Map<String, dynamic> json) {
    id = json['id'] ?? '';
    methodName = json['methodName'] ?? '';
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['bank'] = methodName;
    return data;
  }
}
