// user_event.dart
import 'package:equatable/equatable.dart';
import 'package:lipa_quick/core/models/profile/profile_details_response.dart';

abstract class UserEvent extends Equatable {
  const UserEvent();

  @override
  List<Object?> get props => [];
}

class FetchUserDetailsEvent extends UserEvent {}

class UpdateUserLocationEvent extends UserEvent {
  final double lat;
  final double lng;
  final ProfileDetailsResponse userDetails;

  const UpdateUserLocationEvent({required this.lat, required this.lng, required this.userDetails});

  @override
  List<Object?> get props => [lat, lng];
}
