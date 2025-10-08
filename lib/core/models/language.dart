import 'dart:ui';

import 'package:country_codes/country_codes.dart';

import '../../../gen/assets.gen.dart';
enum LanguageModel {
  english,
  french,
  kinyarwanda;
// Add more language options here

// Define values for each language
Locale? get value {
  switch (this) {
    case LanguageModel.english:
      return Locale('en', 'US');
    case LanguageModel.french:
      return Locale('fr', 'FR');
    case LanguageModel.kinyarwanda:
      return Locale("rw", 'RW');
  // Add cases for more languages here
  }
}

// Define asset image for each language (Optional)
AssetGenImage? get image {
  switch (this) {
    case LanguageModel.english:
      return Assets.icon.english;
    case LanguageModel.french:
      return Assets.icon.france;
    case LanguageModel.kinyarwanda:
      return Assets.icon.rwanda;
  // Add cases for more languages here
  }
}

// Define display text for each language (Optional)
String? get text {
  switch (this) {
    case LanguageModel.english:
      return 'English';
    case LanguageModel.french:
      return 'French';
    case LanguageModel.kinyarwanda:
      return 'Kinyarwanda';
  // Add cases for more languages here
  }
}

// Define currency text for each language (Optional)
String? get currency {
  switch (this) {
    case LanguageModel.english:
      return '\$';
    case LanguageModel.french:
      return 'FRw';
    case LanguageModel.kinyarwanda:
      return 'FRw';

  // Add cases for more languages here
  }
}
String? get dialCode {
  CountryDetails details = CountryCodes.detailsForLocale();
  return details.dialCode;
}
}
