import 'package:equatable/equatable.dart';
import 'package:lipa_quick/core/models/banks/bloc/bank_state.dart';
import 'package:lipa_quick/core/models/profile/profile_details_response.dart';

class ProfileState extends Equatable {
  const ProfileState({
    this.status = ApiStatus.initial,
    this.profileDetailsResponse,
  });

  final ApiStatus status;
  final ProfileDetailsResponse? profileDetailsResponse;

  ProfileState copyWith({
    ApiStatus? status,
    ProfileDetailsResponse? posts,
    bool? hasReachedMax,
  }) {
    return ProfileState(
      status: status ?? this.status,
      profileDetailsResponse: posts,
    );
  }

  @override
  String toString() {
    return '''PostState { status: $status, banks: ${profileDetailsResponse.toString()} }''';
  }

  @override
  List<Object> get props => [status, profileDetailsResponse.toString()];
}