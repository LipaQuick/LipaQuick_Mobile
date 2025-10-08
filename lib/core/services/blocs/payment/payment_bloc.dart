import 'dart:async';

import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lipa_quick/core/local_db/repository/payment_reposiroty_impl.dart';
import 'package:lipa_quick/core/models/cards/cards_model.dart';
import 'package:lipa_quick/core/services/blocs/account/account_list_event.dart';
import 'package:lipa_quick/core/services/blocs/account/account_list_state.dart';
import 'package:lipa_quick/core/models/banks/bloc/bank_event.dart';
import 'package:lipa_quick/core/models/banks/bloc/bank_state.dart';
import 'package:lipa_quick/core/models/payment/default_payments.dart';
import 'package:lipa_quick/core/models/payment/user_payment_methods.dart';
import 'package:lipa_quick/core/models/response.dart';
import 'package:lipa_quick/core/services/api.dart';
import 'package:lipa_quick/core/services/blocs/payment/payment_state.dart';
import 'package:lipa_quick/main.dart';
import 'package:stream_transform/stream_transform.dart';

import '../../../models/banks/bloc/bank_bloc.dart';
import '../../../models/accounts/account_model.dart';

EventTransformer<E> throttleDroppable<E>(Duration duration) {
  return (events, mapper) {
    return droppable<E>().call(events.throttle(duration), mapper);
  };
}

class PaymentBloc extends Bloc<ApiEvent, PaymentState> {
  PaymentBloc() : super(PaymentState()) {
    api = Api();
    paymentMethodsRepositoryImpl =  locator<PaymentMethodsRepositoryImpl>();
    on<DefaultPaymentFetchEvent>(_onPostFetched, transformer: throttleDroppable(throttleDuration),);
  }

  Api? api;
  late final PaymentMethodsRepositoryImpl paymentMethodsRepositoryImpl;

  Future<void> _onPostFetched(
      DefaultPaymentFetchEvent event,
      Emitter<PaymentState> emit,
      ) async {
    try {
      if (kDebugMode) {
        print("Initials Account");
      }
      ResponsePaymentMethodDto? banks = await api?.getDefaultPaymentMethods();
      if (kDebugMode) {
        print("${banks == null}");
      }
      if(banks != null){
        if(banks.message != null && banks.message!.contains("Unauthorized access")){
          return emit(state.copyWith(status: ApiStatus.authFailed));
        }
        if(!banks.status!){
          if(banks.message!.contains('Object reference')){
            return emit(
              state.copyWith(
                status: ApiStatus.success,
                posts: null,
                hasReachedMax: false,
              ),
            );
          }
          return emit(state.copyWith(status: ApiStatus.failure, errorMessage: banks.message));
        }
      }

      if(banks!.data!.DefaultWalletDetails!.number == null
          && banks.data!.DefaultBankAccount!.accountNumber == null
          && banks.data!.Defaultcarddetails!.cardNumber==null){
        return emit(PaymentState(status: ApiStatus.empty
            , responsePaymentMethodDto: null, errorMessage: ''));
      }

      return emit(
        state.copyWith(
          status: ApiStatus.success,
          posts: banks,
          hasReachedMax: false,
        ),
      );
    } catch (e) {
      print(e);
      emit(state.copyWith(status: ApiStatus.failure));
    }
  }

  bool isWalletDataReceivedIsNull(MTNWalletDetails defaultWalletDetails) {
    return defaultWalletDetails.number == null
    && defaultWalletDetails.id == null;
  }

  bool isBankDataReceivedIsNull(AccountDetails defaultAccountDetails) {
    return defaultAccountDetails.accountNumber == null
        && defaultAccountDetails.id == null;
  }

  bool isCreditCardDataReceivedIsNull(CardDetailsModel cardDetailsModel) {
    return cardDetailsModel.cardNumber == null
        && cardDetailsModel.id == null;
  }
}