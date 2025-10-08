import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lipa_quick/core/models/banks/bloc/bank_bloc.dart';
import 'package:lipa_quick/core/models/banks/bloc/bank_state.dart';
import 'package:lipa_quick/core/models/profile/profile_list_reponse.dart';
import 'package:lipa_quick/core/services/api.dart';
import 'package:lipa_quick/core/services/events/profile_events.dart';
import 'package:lipa_quick/core/services/states/app_states.dart';
import 'package:lipa_quick/main.dart';

import '../../models/banks/bloc/bank_event.dart';

class ProfileBloc extends Bloc<ApiEvent, ProfileState> {
  ProfileBloc() : super(const ProfileState()) {
    api = locator<Api>();
    on<ProfileFetch>(
      _onPostFetched,
      transformer: throttleDroppable(throttleDuration),
    );
  }

  Api? api;

  Future<void> _onPostFetched(
      ProfileFetch event,
      Emitter<ProfileState> emit,
      ) async {
    try {
      if (state.status == ApiStatus.initial) {
        if (kDebugMode) {
          print("Initials Account");
        }
        ProfileListResponse? banks = await api?.getUserProfile();
        if (kDebugMode) {
          print("${banks == null}");
        }
        if(banks != null){
          if(banks.errorMessage != null && banks.errorMessage!.contains("Unauthorized access")){
            return emit(state.copyWith(status: ApiStatus.authFailed));
          }
        }

        return emit(
          state.copyWith(
            status: ApiStatus.success,
            posts: banks!.profileDetails,
            hasReachedMax: false,
          ),
        );
      }
    } catch (e) {
      print(e);
      emit(state.copyWith(status: ApiStatus.failure));
    }
  }
}