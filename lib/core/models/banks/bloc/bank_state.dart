
import 'package:equatable/equatable.dart';
import 'package:lipa_quick/core/models/banks/bank_details.dart';

enum ApiStatus { initial, success, failure, authFailed, empty }

class BankState extends Equatable {
  const BankState({
    this.status = ApiStatus.initial,
    this.banks = const <BankDetails>[],
    this.hasReachedMax = false,
  });

  final ApiStatus status;
  final List<BankDetails> banks;
  final bool hasReachedMax;

  BankState copyWith({
    ApiStatus? status,
    List<BankDetails>? posts,
    bool? hasReachedMax,
  }) {
    return BankState(
      status: status ?? this.status,
      banks: posts ?? banks,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
    );
  }

  @override
  String toString() {
    return '''PostState { status: $status, hasReachedMax: $hasReachedMax, posts: ${banks.length} }''';
  }

  @override
  List<Object> get props => [status, banks, hasReachedMax];
}