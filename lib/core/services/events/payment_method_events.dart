import 'package:equatable/equatable.dart';
import 'package:lipa_quick/core/models/payment/payment_methods.dart';
import 'package:lipa_quick/core/models/payment/user_payment_methods.dart';

abstract class PaymentMethodEvent extends Equatable {
  const PaymentMethodEvent();

  @override
  List<Object?> get props => [];
}

class PaymentFetchEvent extends PaymentMethodEvent {}

class PaymentAddEvent extends PaymentMethodEvent {
  const PaymentAddEvent(this.paymentMethods);

  final UserPaymentMethods paymentMethods;

  @override
  List<Object?> get props => [paymentMethods];
}
class PaymentsDefaultEvent extends PaymentMethodEvent {
  const PaymentsDefaultEvent();
}

class PaymentUpdateEvent extends PaymentMethodEvent {
  const PaymentUpdateEvent(this.paymentMethods);

  final UserPaymentMethods paymentMethods;

  @override
  List<Object?> get props => [paymentMethods];
}

class PaymentDeleteEvent extends PaymentMethodEvent {
  const PaymentDeleteEvent(this.paymentMethods);

  final UserPaymentMethods paymentMethods;

  @override
  List<Object?> get props => [paymentMethods];
}
