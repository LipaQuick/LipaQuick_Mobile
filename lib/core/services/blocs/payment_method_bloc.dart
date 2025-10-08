import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lipa_quick/core/local_db/repository/payment_reposiroty_impl.dart';
import 'package:lipa_quick/core/models/banks/bloc/bank_bloc.dart';
import 'package:lipa_quick/core/models/payment/user_payment_methods.dart';
import 'package:lipa_quick/core/services/api.dart';
import 'package:lipa_quick/core/services/events/payment_method_events.dart';
import 'package:lipa_quick/core/services/states/payment_method_states.dart';
import 'package:lipa_quick/main.dart';

class PaymentMethodBloc extends Bloc<PaymentMethodEvent, PaymentMethodState> {
  PaymentMethodBloc() : super(const PaymentMethodState(paymentMethods: []
    ,status: PaymentMethodsStatus.initial, )) {
    paymentMethodsRepositoryImpl =  locator<PaymentMethodsRepositoryImpl>();
    api = locator<Api>();
    on<PaymentFetchEvent>(_onPaymentMethodLoad, transformer: throttleDroppable(throttleDuration));
    on<PaymentAddEvent>(onPaymentAdd, transformer: throttleDroppable(throttleDuration));
    on<PaymentsDefaultEvent>(onPaymentGetDefault, transformer: throttleDroppable(throttleDuration));
    on<PaymentUpdateEvent>(onPaymentUpdate, transformer: throttleDroppable(throttleDuration));
    on<PaymentDeleteEvent>(onPaymentDelete, transformer: throttleDroppable(throttleDuration));
  }

  late final PaymentMethodsRepositoryImpl paymentMethodsRepositoryImpl;
  late final Api api;

  Future<void> _onPaymentMethodLoad(PaymentMethodEvent event, Emitter<PaymentMethodState> emit) async {
    try {
      emit(state.copyWith(status: () => PaymentMethodsStatus.loading));
      if (kDebugMode) {
        print("Initials Account");
      }
      List<UserPaymentMethods>? paymentMethods = await paymentMethodsRepositoryImpl.getAllUserPaymentMethods();
      UserPaymentMethods? defaultPaymentMethods = await paymentMethodsRepositoryImpl.getDefaultUserPayment();

      if(paymentMethods.isEmpty && defaultPaymentMethods == null){
        return emit(
          state.copyWith(
            status: () => PaymentMethodsStatus.success,
            paymentMethod: () =>  paymentMethods,
            defaultPaymentMethod: () =>  defaultPaymentMethods,
          ),
        );
      }
      return emit(
        state.copyWith(
          status: () => PaymentMethodsStatus.success,
          paymentMethod: () =>  paymentMethods,
          defaultPaymentMethod: () =>  defaultPaymentMethods!,
        ),
      );
    } catch (e) {
      print(e);
      emit(state.copyWith(status: () => PaymentMethodsStatus.failure));
    }
  }

  FutureOr<void> onPaymentAdd(PaymentAddEvent event, Emitter<PaymentMethodState> emit) async {
    try {
      emit(state.copyWith(status: () => PaymentMethodsStatus.loading));
      if (kDebugMode) {
        print("Initials Account");
      }
      await paymentMethodsRepositoryImpl.insertUserPaymentMethod(event.paymentMethods);

      state.paymentMethods.add(event.paymentMethods);

      return emit(
        state.copyWith(
          status: () => PaymentMethodsStatus.success,
          paymentMethod: () =>  state.paymentMethods,
        ),
      );
    } catch (e) {
      print(e);
      emit(state.copyWith(status: () => PaymentMethodsStatus.failure));
    }

  }

  FutureOr<void> onPaymentUpdate(PaymentUpdateEvent event, Emitter<PaymentMethodState> emit) async {
    try {
      emit(state.copyWith(status: () => PaymentMethodsStatus.loading));
      if (kDebugMode) {
        print("Initials Account");
      }
      await paymentMethodsRepositoryImpl.updateUserPaymentMethod(event.paymentMethods);

      await paymentMethodsRepositoryImpl.updatePaymentMethod(event.paymentMethods.id!);

      List<UserPaymentMethods>? paymentMethods = await paymentMethodsRepositoryImpl.getAllUserPaymentMethods();

      return emit(
        state.copyWith(
          status: () => PaymentMethodsStatus.success,
          paymentMethod: () =>  paymentMethods,
        ),
      );
    } catch (e) {
      print(e);
      emit(state.copyWith(status: () => PaymentMethodsStatus.failure));
    }

  }

  FutureOr<void> onPaymentGetDefault(PaymentsDefaultEvent event, Emitter<PaymentMethodState> emit) async {
    try {
      emit(state.copyWith(status: () => PaymentMethodsStatus.loading));
      if (kDebugMode) {
        print("Initials Default Account");
      }

      UserPaymentMethods? paymentMethods = await paymentMethodsRepositoryImpl.getDefaultUserPayment();

      return emit(
        state.copyWith(
          status: () => PaymentMethodsStatus.success,
          defaultPaymentMethod: () =>  paymentMethods!,
        ),
      );
    } catch (e) {
      print(e);
      emit(state.copyWith(status: () => PaymentMethodsStatus.failure));
    }
  }

  FutureOr<void> onPaymentDelete(PaymentDeleteEvent event, Emitter<PaymentMethodState> emit) async {
    try {
      emit(state.copyWith(status: () => PaymentMethodsStatus.loading));
      if (kDebugMode) {
        print("Initials Account");
      }
      await paymentMethodsRepositoryImpl.deletePaymentMethod(event.paymentMethods.methodName!);

      List<UserPaymentMethods>? paymentMethods = await paymentMethodsRepositoryImpl.getAllUserPaymentMethods();

      return emit(
        state.copyWith(
          status: () => PaymentMethodsStatus.success,
          paymentMethod: () =>  paymentMethods,
        ),
      );
    } catch (e) {
      print(e);
      emit(state.copyWith(status: () => PaymentMethodsStatus.failure));
    }

  }
}