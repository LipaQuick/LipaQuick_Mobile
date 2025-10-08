import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';

import 'package:lipa_quick/core/models/onboarding.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'onboarding_event.dart';
part 'onboarding_state.dart';

const onBoardPrefsKey = 'onboardPrefs';

class OnBoardingBloc extends Bloc<OnBoardingEvent, OnBoardingState> {
  OnBoardingBloc() : super( OnBoardingState()) {
    on<OnBoardingCompleted>(onOnBoarding);
    on<CheckOnBoarding>(onGetOnBoarding);
  }

  onOnBoarding(OnBoardingCompleted event, Emitter<OnBoardingState> emit) async {
    // # 1
    // debugPrint('Calling On Boarding Function');
    final prefs = await SharedPreferences.getInstance();
    debugPrint('Calling On Boarding Function: ${prefs}');
    await prefs.setBool(
      onBoardPrefsKey,
      event.onBoarding.isCompleted,
    );
    emit(state.copyWith(selectedLanguage: event.onBoarding));
  }

  // # 2
  onGetOnBoarding(CheckOnBoarding event, Emitter<OnBoardingState> emit) async {
    final prefs = await SharedPreferences.getInstance();
    final isOnBoardingCompleted = prefs.getBool(onBoardPrefsKey);
    debugPrint('Calling On Boarding Function: ${isOnBoardingCompleted}');
    emit(state.copyWith(
      selectedLanguage: isOnBoardingCompleted != null && isOnBoardingCompleted
          ? OnBoarding(isOnBoardingCompleted):OnBoarding(false),
    ));
  }
}