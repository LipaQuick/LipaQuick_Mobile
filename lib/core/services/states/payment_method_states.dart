import 'package:equatable/equatable.dart';
import 'package:lipa_quick/core/models/api_exception/api_exception.dart';
import 'package:lipa_quick/core/models/banks/bloc/bank_state.dart';
import 'package:lipa_quick/core/models/payment/payment_methods.dart';
import 'package:lipa_quick/core/models/payment/user_payment_methods.dart';
import 'package:lipa_quick/core/models/profile/profile_details_response.dart';

enum PaymentMethodsStatus { initial, loading, success, failure }

class PaymentMethodState extends Equatable {
  const PaymentMethodState({
    this.status = PaymentMethodsStatus.initial,
    this.paymentMethods = const [],
    this.defaultUserPaymentMethod
  });

  final PaymentMethodsStatus status;
  final List<UserPaymentMethods> paymentMethods;
  final UserPaymentMethods? defaultUserPaymentMethod;

  PaymentMethodState copyWith({
    PaymentMethodsStatus Function()? status,
    List<UserPaymentMethods> Function()? paymentMethod,
    UserPaymentMethods? Function()? defaultPaymentMethod,
  }) {
    return PaymentMethodState(
      status: status != null ? status() : this.status,
      paymentMethods: paymentMethod != null ? paymentMethod() : paymentMethods,
      defaultUserPaymentMethod: defaultPaymentMethod != null ? defaultPaymentMethod() : defaultUserPaymentMethod,
    );
  }

  @override
  List<Object?> get props => [
        status,
        paymentMethods,
      ];
}
