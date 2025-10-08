import 'dart:async';

import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lipa_quick/core/models/api_exception/api_exception.dart';
import 'package:lipa_quick/core/models/banks/bloc/bank_event.dart';
import 'package:lipa_quick/core/models/banks/bloc/bank_state.dart';
import 'package:lipa_quick/core/models/cards/add_card_model.dart';
import 'package:lipa_quick/core/models/cards/bloc/card_list_state.dart';
import 'package:lipa_quick/core/models/response.dart';
import 'package:lipa_quick/core/services/api.dart';
import 'package:stream_transform/stream_transform.dart';

import '../../banks/bloc/bank_bloc.dart';
import '../cards_model.dart';
import 'card_list_event.dart';

EventTransformer<E> throttleDroppable<E>(Duration duration) {
  return (events, mapper) {
    return droppable<E>().call(events.throttle(duration), mapper);
  };
}

class CardBloc extends Bloc<ApiEvent, CardsState> {
  CardBloc() : super(CardsState()) {
    on<CardsFetched>(
      _onCardsFetched,
      transformer: throttleDroppable(throttleDuration),
    );

    on<CardDefaultEvent>(
      _onCardUpdateEvent,
      transformer: throttleDroppable(throttleDuration),
    );

    on<CardDeleteEvent>(
      _onCardDeleted,
      transformer: throttleDroppable(throttleDuration),
    );
    api = Api();
  }

  Api? api;

  Future<void> _onCardsFetched(
    CardsFetched event,
    Emitter<CardsState> emit,
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
        var cards = await api?.getCards();
        if (cards is APIException) {
          print("Inside API Exception");
          if (cards.statusCode == 404) {
            return emit(
              state.copyWith(
                status: ApiStatus.success,
                posts: [],
                hasReachedMax: false,
              ),
            );
          } else {
            return emit(
              state.copyWith(
                status: cards.statusCode == 401
                    ? ApiStatus.authFailed
                    : ApiStatus.failure,
                posts: [],
                hasReachedMax: false,
              ),
            );
          }
        } else {
          if (kDebugMode) {
            print("${cards == null}");
          }
          if (cards != null) {
            if (cards.message != null &&
                cards.message!.contains("Unauthorized access")) {
              print("Unauthorized ${cards}");
              return emit(state.copyWith(status: ApiStatus.authFailed));
            }
          }
          return emit(
            state.copyWith(
              status: ApiStatus.success,
              posts: cards!.data,
              hasReachedMax: false,
            ),
          );
        }
      }
      final posts = await api?.getCards(state.cardList.length);
      if (posts is CardListResponse) {
        if (posts.status!) {
          posts.data!.isEmpty
              ? emit(state.copyWith(hasReachedMax: true))
              : emit(
                  state.copyWith(
                    status: ApiStatus.success,
                    posts: List.of(state.cardList)..addAll(posts.data!),
                    hasReachedMax: false,
                  ),
                );
        } else {
          emit(
            state.copyWith(
              status: ApiStatus.failure,
              posts: [],
              hasReachedMax: false,
            ),
          );
        }
      } else {
        if (posts is APIException) {
          print("Inside API Exception");
          if (posts.statusCode == 404) {
            return emit(
              state.copyWith(
                status: ApiStatus.success,
                posts: [],
                hasReachedMax: false,
              ),
            );
          } else {
            return emit(
              state.copyWith(
                status: posts.statusCode == 401
                    ? ApiStatus.authFailed
                    : ApiStatus.failure,
                posts: [],
                hasReachedMax: false,
              ),
            );
          }
        }
      }
    } catch (e) {
      print(e);
      emit(state.copyWith(status: ApiStatus.failure));
    }
  }

  Future<void> _onCardDeleted(
    CardDeleteEvent event,
    Emitter<CardsState> emit,
  ) async {
    try {
      emit(state.copyWith(status: ApiStatus.initial));
      final cardsData = event.model;
      final posts = await api?.deleteCard(cardsData);
      if (posts is CardListResponse && (posts).status!) {
        var newBenefitsList = List<CardDetailsModel>.from(state.cardList);
        if (newBenefitsList.remove(cardsData)) {
          emit(state.copyWith(
              status: ApiStatus.success,
              posts: newBenefitsList,
              hasReachedMax: state.hasReachedMax));
        }
      } else {

        if(posts is APIException) {
          print('_onCardDeleted delete response');
          APIException apiException = posts as APIException;
          if(apiException.message!.contains('delete primary card')){
            var newBenefitsList = List<CardDetailsModel>.from(state.cardList);
            emit(state.copyWithDelete(
                status: ApiStatus.failure, errorMessage: apiException.message));
            emit(state.copyWith(
                status: ApiStatus.success,
                posts: newBenefitsList,
                hasReachedMax: state.hasReachedMax));
          }else{
            emit(state.copyWithDelete(
                status: ApiStatus.failure, errorMessage: apiException.message));
          }

        }else{
          print('_onCardDeleted delete response posts');
          emit(state.copyWithDelete(
              status: ApiStatus.failure, errorMessage: posts.message));
        }
      }
    } catch (e) {
      print(e);
      emit(state.copyWith(status: ApiStatus.failure));
    }
  }

  FutureOr<void> _onCardUpdateEvent(CardDefaultEvent event, Emitter<CardsState> emit) async{
    try {
      emit(state.copyWith(status: ApiStatus.initial));
      final posts = await api?.setDefaultCard(event.model!);
      if ((posts as ApiResponse).status!) {
        add(CardsFetched());
      }else if(!(posts as ApiResponse).status!){
        emit(state.copyWithDelete(
            status: ApiStatus.failure, errorMessage: posts.message!));
      }
      else {
        state.copyWithDelete(status: ApiStatus.failure, errorMessage: posts.message);
      }
    } catch (e) {
      print(e);
      emit(state.copyWith(status: ApiStatus.failure));
    }
  }
}
