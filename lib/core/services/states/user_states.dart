// user_state.dart
import 'package:equatable/equatable.dart';
import 'package:lipa_quick/core/models/profile/profile_details_response.dart';


abstract class UserState extends Equatable {
  const UserState();

  @override
  List<Object?> get props => [];
}

class UserLoadingState extends UserState {}

class UserLoadedState extends UserState {
  final ProfileDetailsResponse user;

  const UserLoadedState({required this.user});

  @override
  List<Object?> get props => [user];
}

class UserErrorState extends UserState {
  final String message;

  const UserErrorState({required this.message});

  @override
  List<Object?> get props => [message];
}

class UserLocationUpdatedState extends UserState {
  final ProfileDetailsResponse user;

  const UserLocationUpdatedState({required this.user});

  @override
  List<Object?> get props => [user];
}
