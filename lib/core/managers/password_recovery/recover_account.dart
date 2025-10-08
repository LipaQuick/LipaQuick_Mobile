import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:lipa_quick/core/crypto/encryption.dart';
import 'package:lipa_quick/core/local_db/repository/pin_repository.dart';
import 'package:lipa_quick/core/models/api_exception/api_exception.dart';
import 'package:lipa_quick/core/models/app_pin/app_pin_lock.dart';
import 'package:lipa_quick/core/models/password_login.dart';
import 'package:lipa_quick/core/models/response.dart';
import 'package:lipa_quick/core/services/api.dart';
import 'package:lipa_quick/core/services/local_shared_pref.dart';

// Define User Event
abstract class PasswordEvent {}

class GetAccountEvent extends PasswordEvent {
  final String userName;

  GetAccountEvent(this.userName);
}

class SendOTPEvent extends PasswordEvent {}

class ChangePasswordEvent extends PasswordEvent {}

// Define User State
abstract class PasswordState {}

class Initial extends PasswordState {}

class PasswordLoading extends PasswordState {}

class AccountExistState extends PasswordState {
  final String phoneNumber;

  AccountExistState(this.phoneNumber);
}

class AccountNotFoundState extends PasswordState {
  final APIException apiException;

  AccountNotFoundState(this.apiException);
}

class InvalidApiState extends PasswordState {
  final APIException apiException;

  InvalidApiState(this.apiException);
}

class ValidOtpState extends PasswordState {}

class InvalidOtpState extends PasswordState {
  final APIException apiException;

  InvalidOtpState(this.apiException);
}

class InvalidOtpApiState extends PasswordState {
  final APIException apiException;

  InvalidOtpApiState(this.apiException);
}

// Define User Bloc
class PasswordRecoveryBloc extends Bloc<PasswordEvent, PasswordState> {
  final Api api;

  PasswordRecoveryBloc(this.api) : super(Initial()) {
    on<GetAccountEvent>(_getUserAccount);
  }

  FutureOr<void> _getUserAccount(
      GetAccountEvent event, Emitter<PasswordState> emit) async {
    emit(PasswordLoading());
    var apiresponse = await api.getUserAccount(event.userName);
    if (apiresponse is APIException) {
      return emit(AccountNotFoundState(apiresponse));
    } else {
      var result = apiresponse as ApiResponse;
      if (kDebugMode) {
        print("${result == null}");
      }

      if (result.status!) {
        return emit(AccountExistState(event.userName));
      } else {
        return emit(AccountNotFoundState(
            APIException(result.message, 502, APIError.NOT_FOUND)));
      }
    }
  }
}
