import 'package:equatable/equatable.dart';
import 'package:lipa_quick/core/models/banks/bloc/bank_state.dart';
import 'package:lipa_quick/core/models/payment/default_payments.dart';

class PaymentState extends Equatable {
  PaymentState({
    this.status = ApiStatus.initial,
    this.responsePaymentMethodDto = null,
    this.errorMessage = ""
  });

  final ApiStatus status;
  final ResponsePaymentMethodDto? responsePaymentMethodDto;
  final String? errorMessage;

  PaymentState copyWith({
    ApiStatus? status,
    ResponsePaymentMethodDto? posts,
    bool? hasReachedMax,
    String? errorMessage
  }) {
    return PaymentState(
      status: status ?? this.status,
        responsePaymentMethodDto: posts ?? responsePaymentMethodDto,
      errorMessage: errorMessage ?? this.errorMessage
    );
  }

  @override
  String toString() {
    return '''PostState { status: $status, posts: ${responsePaymentMethodDto?.toJson()}, errorMessage: $errorMessage }''';
  }

  @override
  List<Object> get props => [status, errorMessage!];
}