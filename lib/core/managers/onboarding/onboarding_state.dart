part of 'onboarding_bloc.dart';

class OnBoardingState extends Equatable {
  OnBoardingState({
    OnBoarding? selectedLanguage,
  }) : onBoard = selectedLanguage ?? OnBoarding(false);

  final OnBoarding onBoard;

  @override
  List<Object> get props => [onBoard];

  OnBoardingState copyWith({OnBoarding? selectedLanguage}) {
    return OnBoardingState(
      selectedLanguage: selectedLanguage ?? this.onBoard,
    );
  }
}
