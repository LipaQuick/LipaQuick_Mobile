part of 'onboarding_bloc.dart';

abstract class OnBoardingEvent extends Equatable {
  const OnBoardingEvent();

  @override
  List<Object> get props => [];
}

class OnBoardingCompleted extends OnBoardingEvent {
  OnBoardingCompleted({required this.onBoarding});
  final OnBoarding onBoarding;

  @override
  List<Object> get props => [onBoarding];
}

class CheckOnBoarding extends OnBoardingEvent {}