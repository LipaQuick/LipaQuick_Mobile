import 'package:equatable/equatable.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart';
import 'package:lipa_quick/core/models/api_exception/api_exception.dart';
import 'package:lipa_quick/core/models/banks/bloc/bank_state.dart';
import 'package:lipa_quick/core/models/chats/recent_chat/recent_chat_response.dart';
import 'package:lipa_quick/core/models/contacts/contacts.dart';
import 'package:lipa_quick/core/models/contacts/contacts_response_model.dart';

abstract class SignalRState extends Equatable {
  final List<Message> messages;

  SignalRState(this.messages);

  @override
  List<Object?> get props => [messages];
}

class SignalRInitial extends SignalRState {
  SignalRInitial(super.messages);
}

class SignalRMessageReceived extends SignalRState {
  final List<Object?>? message;

  SignalRMessageReceived(this.message) : super([]);

  @override
  List<Object?> get props => [message];
}

class SignalRLoading extends SignalRState {
  SignalRLoading(super.messages);
}

class SignalRLoadingMore extends SignalRState {
  SignalRLoadingMore(super.messages);
}

class SignalRLoadSuccess extends SignalRState {
  SignalRLoadSuccess(super.messages);

}

class SignalRUserState extends SignalRState {
  ContactsAPI response;
  SignalRUserState(super.messages, this.response);

  @override
  List<Object?> get props => [response];
}

class SignalRAuthFailed extends SignalRState {
  final ApiStatus status;

  SignalRAuthFailed(this.status) : super([]);

  SignalRAuthFailed copyWith({
    ApiStatus? status,
  }) {
    return SignalRAuthFailed(
      status ?? this.status,
    );
  }

  @override
  List<Object?> get props => [status];
}

class SignalRApiException extends SignalRState {
  final ApiStatus status;
  final APIException exception;

  SignalRApiException(this.status, this.exception) : super([]);

  SignalRApiException copyWith({
    ApiStatus? status,
    APIException? exception,
  }) {
    return SignalRApiException(
      status ?? this.status,
        exception?? this.exception
    );
  }

  @override
  List<Object?> get props => [status];
}

class SignalInvalidUserException extends SignalRState {
  final ApiStatus status;
  final APIException exception;

  SignalInvalidUserException(this.status, this.exception) : super([]);

  SignalRApiException copyWith({
    ApiStatus? status,
    APIException? exception,
  }) {
    return SignalRApiException(
        status ?? this.status,
        exception?? this.exception
    );
  }

  @override
  List<Object?> get props => [status];
}

class SignalRLoadFailure extends SignalRState {
  SignalRLoadFailure(super.messages);
}
