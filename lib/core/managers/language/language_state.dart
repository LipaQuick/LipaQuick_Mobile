part of 'language_bloc.dart';

class LanguageState extends Equatable{
  const LanguageState({LanguageModel? selectedLanguage,})
      : selectedLanguage = selectedLanguage ?? LanguageModel.english;

  final LanguageModel selectedLanguage;

  @override
  List<Object> get props => [selectedLanguage];

  LanguageState copyWith({LanguageModel? selectedLanguage}) {
    return LanguageState(
      selectedLanguage: selectedLanguage ?? this.selectedLanguage,
    );
  }
}