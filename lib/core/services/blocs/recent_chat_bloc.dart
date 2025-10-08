import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lipa_quick/core/models/api_exception/api_exception.dart';
import 'package:lipa_quick/core/models/banks/bloc/bank_bloc.dart';
import 'package:lipa_quick/core/models/banks/bloc/bank_event.dart';
import 'package:lipa_quick/core/models/banks/bloc/bank_state.dart';
import 'package:lipa_quick/core/models/chats/recent_chat/recent_chat_response.dart';
import 'package:lipa_quick/core/services/api.dart';
import 'package:lipa_quick/core/services/events/recent_chat_events.dart';
import 'package:lipa_quick/core/services/states/recent_chat_state.dart';

class ChatBloc extends Bloc<ApiEvent, UserChatState> {
  bool isLastPage = false;
  int pageNumber = 0;
  final int numberOfPostsPerRequest = 20;
  int totalChats = -1;

  ChatBloc() : super(UserChatState()) {
    api = Api();

    on<RecentChatFetchEvent>(
      _onPostFetched,
      transformer: throttleDroppable(throttleDuration),
    );

    on<RecentChatRefresh>(
      _onChatRefresh,
      transformer: throttleDroppable(throttleDuration),
    );
  }

  Api? api;

  Future<void> _onPostFetched(
      RecentChatFetchEvent event,
      Emitter<UserChatState> emit,
      ) async {
    if (state.status == ApiStatus.initial) {
      dynamic banks = await api?.getRecentChats();
      //print("Received Response");
      if(banks is RecentChatResponse){
        totalChats = banks.total!;
        //print("Inside Recent Chat Response");

        //print("Inside banks not null");
        String message =banks.message??"EMPTY";
        if(message.contains("Unauthorized access")){
          return emit(state.copyWith(status: ApiStatus.authFailed));
        }
        if(banks.data!.length < totalChats){
          pageNumber = pageNumber + 1;
        }

        return emit(
          state.copyWith(
            status: ApiStatus.success,
            posts: banks.data!,
            hasReachedMax: false,
          ),
        );
      }
      else{
        //print("Exception API Exception");
        APIException apiException = banks as APIException;
        String message = apiException.message??"EMPTY";
        if(message.contains("Unauthorized access")){
          return emit(state.copyWith(status: ApiStatus.authFailed));
        }
        emit(state.copyWith(status:ApiStatus.failure, apiError: apiException.apiError
            , errorMessage: apiException.message));
      }
    }

    if (kDebugMode) {
      print("Initials Account");
    }
    dynamic? banks = await api?.getRecentChats(skip: pageNumber);
    //print("Received Response");
    if(banks is RecentChatResponse){
      //print("Inside Recent Chat Response");
      if (kDebugMode) {
        print("${banks == null}");
      }
      //print("Inside banks not null");
      String message =banks.message??"EMPTY";
      if(message.contains("Unauthorized access")){
        return emit(state.copyWith(status: ApiStatus.authFailed));
      }

      if(banks.data!.length < totalChats){
        pageNumber = pageNumber + 1;
      }

      List<RecentChats> chats = state.recentChats == null?[]:state.recentChats! ;
      chats.addAll(banks.data!);

      return emit(
        state.copyWith(
          status: ApiStatus.success,
          posts: banks.data,
          hasReachedMax: (banks.data!.length-1) == totalChats,
        ),
      );
    }else{
      //print("Exception API Exception");
      APIException apiException = banks as APIException;
      emit(state.copyWith(status:ApiStatus.failure, apiError: apiException.apiError
          , errorMessage: apiException.message));
    }
  }

  Future<void> _onChatRefresh(RecentChatRefresh event, Emitter<UserChatState> emit) async {
    emit(UserChatState());
    await Future.delayed(const Duration(seconds: 1));
    add(RecentChatFetchEvent());
  }
}