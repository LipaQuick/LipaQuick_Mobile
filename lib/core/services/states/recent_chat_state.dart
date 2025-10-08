import 'package:equatable/equatable.dart';
import 'package:lipa_quick/core/models/api_exception/api_exception.dart';
import 'package:lipa_quick/core/models/banks/bloc/bank_state.dart';
import 'package:lipa_quick/core/models/chats/recent_chat/recent_chat_response.dart';

class UserChatState extends Equatable {
  const UserChatState({
    this.apiError = APIError.NONE,
    this.status = ApiStatus.initial,
    this.recentChats,
    this.errorMessage
  });

  final ApiStatus status;
  final APIError? apiError;
  final List<RecentChats>? recentChats;
  final String? errorMessage;

  UserChatState copyWith({
    APIError? apiError,
    ApiStatus? status,
    List<RecentChats>? posts,
    bool? hasReachedMax,
    String? errorMessage
  }) {
    return UserChatState(
      apiError: apiError??this.apiError,
      status: status ?? this.status,
      recentChats: posts,
      errorMessage: errorMessage
    );
  }

  @override
  String toString() {
    return '''PostState { status: $status, recentChats: ${recentChats??"Null"}, Error: $errorMessage}''';
  }

  @override
  List<Object> get props => [status,apiError??'Null Error', recentChats ?? "Null",errorMessage ?? "Null"];
}