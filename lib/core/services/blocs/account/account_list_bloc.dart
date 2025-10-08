import 'dart:async';

import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lipa_quick/core/local_db/repository/payment_reposiroty_impl.dart';
import 'package:lipa_quick/core/models/api_exception/api_exception.dart';
import 'package:lipa_quick/core/services/blocs/account/account_list_event.dart';
import 'package:lipa_quick/core/models/banks/bloc/bank_event.dart';
import 'package:lipa_quick/core/models/banks/bloc/bank_state.dart';
import 'package:lipa_quick/core/models/payment/user_payment_methods.dart';
import 'package:lipa_quick/core/models/response.dart';
import 'package:lipa_quick/core/services/api.dart';
import 'package:lipa_quick/core/services/blocs/account/account_list_state.dart';
import 'package:lipa_quick/core/utils/diff_utils.dart';
import 'package:lipa_quick/main.dart';
import 'package:stream_transform/stream_transform.dart';

import '../../../models/banks/bloc/bank_bloc.dart';
import '../../../models/accounts/account_model.dart';

EventTransformer<E> throttleDroppable<E>(Duration duration) {
  return (events, mapper) {
    return droppable<E>().call(events.throttle(duration), mapper);
  };
}

class AccountBloc extends Bloc<ApiEvent, AccountState> {
  AccountBloc() : super(const AccountState()) {
    api = Api();
    paymentMethodsRepositoryImpl =  locator<PaymentMethodsRepositoryImpl>();
    on<AccountFetched>(_onPostFetched, transformer: throttleDroppable(throttleDuration),);
    on<AccountDeleteEvent>(_onAccountDelete, transformer: throttleDroppable(throttleDuration),);
    on<AccountDefaultEvent>(_onSetDefaultAccountDelete, transformer: throttleDroppable(throttleDuration),);
  }

  Api? api;
  late final PaymentMethodsRepositoryImpl paymentMethodsRepositoryImpl;

  Future<void> _onPostFetched(
      AccountFetched event,
      Emitter<AccountState> emit,
      ) async {
    if (state.hasReachedMax) {
      if (kDebugMode) {
        print("Limit has reached");
      }
      return;
    }
    try {
      if (state.status == ApiStatus.initial) {
        if (kDebugMode) {
          print("Initials Account");
        }
        var banks = await api?.getAccounts();
        if(banks is APIException){
          if(banks.statusCode == 404){
            return emit(
              state.copyWith(
                status: ApiStatus.success,
                posts: [],
                hasReachedMax: false,
              ),
            );
          }
        }
        if(banks is AccountListResponse?){
          if (kDebugMode) {
            print("${banks == null}");
          }
          if(banks != null){
            if(banks.message != null && banks.message!.contains("Unauthorized access")){
              return emit(state.copyWith(status: ApiStatus.authFailed));
            }
          }
          return emit(
            state.copyWith(
              status: ApiStatus.success,
              posts: banks!.data,
              hasReachedMax: false,
            ),
          );
        }
      }
      AccountListResponse? posts = await api?.getAccounts(state.accountList.length);
      var diffresult = DiffUtil.calculateDiff(state.accountList, posts!.data!);
      var data = DiffUtil.applyDiff(state.accountList, diffresult);
      posts.data!.isEmpty
          ? emit(state.copyWith(hasReachedMax: true))
          : emit(
        state.copyWith(
          status: ApiStatus.success,

          posts: List.of(state.accountList)..addAll(data),
          hasReachedMax: false,
        ),
      );
    } catch (e) {
      print(e);
      emit(state.copyWith(status: ApiStatus.failure));
    }
  }

  Future<void> _onAccountDelete(
      AccountDeleteEvent event,
      Emitter<AccountState> emit,
      ) async {
    try {
      emit(state.copyWith(status: ApiStatus.initial));
      final cardsData = event.accountDetails;
      final posts = await api?.removeAccount(cardsData!);
      if ((posts as ApiResponse).status!) {
        await paymentMethodsRepositoryImpl.deletePaymentMethod('Bank Account');
        add(AccountFetched());
      } else {
        state.copyWith(status: ApiStatus.failure, errorMessage: posts.message);
      }
    } catch (e) {
      print(e);
      emit(state.copyWith(status: ApiStatus.failure));
    }
  }

  FutureOr<void> _onSetDefaultAccountDelete(AccountDefaultEvent event, Emitter<AccountState> emit) async{
    try {
      emit(state.copyWith(status: ApiStatus.initial));
      final cardsData = event.accountDetails;
      final posts = await api?.setDefaultAccount(cardsData!);
      if ((posts as ApiResponse).status!) {
        List<UserPaymentMethods> data = await paymentMethodsRepositoryImpl
            .getAllUserPaymentMethods();
        for(int i=0;i<data.length;i++){
          if(data[i].methodName == 'Bank Account'){
            await paymentMethodsRepositoryImpl.deletePaymentMethod('Bank Account');
          }
        }
        paymentMethodsRepositoryImpl.insertUserPaymentMethod(UserPaymentMethods.bankAccount(
            event.accountDetails?.id
            , 'Bank Account'
            , event.accountDetails?.bank
            , event.accountDetails?.swiftCode,  event.accountDetails?.accountNumber
            ,  event.accountDetails?.accountHolderName
            , true));
        add(AccountFetched());
      }else if(!(posts as ApiResponse).status!){
        add(AccountFetched());
      }
      else {
        state.copyWith(status: ApiStatus.failure, errorMessage: posts.message);
      }
    } catch (e) {
      print(e);
      emit(state.copyWith(status: ApiStatus.failure));
    }
  }
}