import 'package:lipa_quick/core/models/banks/bloc/bank_event.dart';
import 'package:lipa_quick/core/models/profile/profile_details_response.dart';

class ProfileFetch extends ApiEvent {}

class UpdateUserLocationEvent extends ApiEvent {
  final double lat;
  final double lng;
  final ProfileDetailsResponse userDetails;

  UpdateUserLocationEvent(
      {required this.lat, required this.lng, required this.userDetails});
}
