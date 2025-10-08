import 'package:equatable/equatable.dart';
import 'package:lipa_quick/core/models/accounts/account_model.dart';
import 'package:lipa_quick/core/models/banks/bloc/bank_state.dart';
import 'package:lipa_quick/core/models/cards/add_card_model.dart';
import 'package:lipa_quick/core/models/cards/cards_model.dart';

class CardsState extends Equatable {
  const CardsState({
    this.status = ApiStatus.initial,
    this.cardList = const <CardDetailsModel>[],
    this.cardModel,
    this.errorMessage,
    this.hasReachedMax = false,
  });

  final ApiStatus status;
  final List<CardDetailsModel> cardList;
  final AddCardModel? cardModel;
  final bool hasReachedMax;
  final String? errorMessage;

  CardsState copyWith({
    ApiStatus? status,
    List<CardDetailsModel>? posts,
    bool? hasReachedMax,
  }) {
    return CardsState(
      status: status ?? this.status,
      cardList: posts ?? cardList,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
    );
  }

  CardsState copyWithDelete({
    ApiStatus? status,
    String? errorMessage
  }) {
    return CardsState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage
    );
  }

  @override
  String toString() {
    return '''CardsState { status: $status, hasReachedMax: $hasReachedMax, posts: ${cardList.length} }''';
  }

  @override
  List<Object> get props => [status, cardList, hasReachedMax];
}
