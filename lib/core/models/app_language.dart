class AppLanguageModel {
  final String name;
  final String languageCode;
  final String currenyCode;

  AppLanguageModel(this.name, this.languageCode, this.currenyCode);

  static List<AppLanguageModel> languages() {
    return <AppLanguageModel>[
      AppLanguageModel('English', 'en', 'Rwf'),
      AppLanguageModel('French', 'fr', 'Rwf'),
      AppLanguageModel('Kinyarwanda', 'kin', 'Rwf'),
    ];
  }

  bool operator == (dynamic other) =>
      other != null && other is AppLanguageModel && this.name == other.name;

  @override
  int get hashCode => super.hashCode;
}
