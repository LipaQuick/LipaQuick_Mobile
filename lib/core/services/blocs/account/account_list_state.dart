import 'package:equatable/equatable.dart';
import 'package:lipa_quick/core/models/accounts/account_model.dart';
import 'package:lipa_quick/core/models/banks/bloc/bank_state.dart';

class AccountState extends Equatable {
  const AccountState({
    this.status = ApiStatus.initial,
    this.accountList = const <AccountDetails>[],
    this.hasReachedMax = false,
    this.errorMessage = ""
  });

  final ApiStatus status;
  final List<AccountDetails> accountList;
  final bool hasReachedMax;
  final String? errorMessage;

  AccountState copyWith({
    ApiStatus? status,
    List<AccountDetails>? posts,
    bool? hasReachedMax,
    String? errorMessage
  }) {
    return AccountState(
      status: status ?? this.status,
      accountList: posts ?? accountList,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      errorMessage: errorMessage ?? this.errorMessage
    );
  }

  @override
  String toString() {
    return '''PostState { status: $status, hasReachedMax: $hasReachedMax, posts: ${accountList.length}, errorMessage: $errorMessage }''';
  }

  @override
  List<Object> get props => [status, accountList, hasReachedMax, errorMessage!];
}