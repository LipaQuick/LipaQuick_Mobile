// user_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lipa_quick/core/services/api.dart';
import 'package:lipa_quick/core/services/events/user_events.dart';
import 'package:lipa_quick/core/services/states/user_states.dart';
import 'package:lipa_quick/main.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  late Api _api;

  UserBloc() : super(UserLoadingState()) {
    _api = locator<Api>();

    on<FetchUserDetailsEvent>((event, emit) async {
      emit(UserLoadingState());

      try {
        // Fetch user details from repository (API)
        final user = await _api.getUserProfile();
        emit(UserLoadedState(user: user));
      } catch (error) {
        emit(UserErrorState(message: error.toString()));
      }
    });

    on<UpdateUserLocationEvent>((event, emit) async {
      try {
        // Update user location in repository (API)

        event.userDetails.userLatLng = '${event.lat}, ${event.lng}';

        final updatedUser = await _api.updateUserProfile(
          event.userDetails
        );
        emit(UserLocationUpdatedState(user: updatedUser));
      } catch (error) {
        emit(UserErrorState(message: error.toString()));
      }
    });
  }
}
