import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'kinyarwanda_material_localizations.dart';

class KinyarwandaMaterialLocalizationsDelegate
    extends LocalizationsDelegate<MaterialLocalizations> {
  const KinyarwandaMaterialLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => locale.languageCode == 'rw';

  @override
  Future<MaterialLocalizations> load(Locale locale) async {
    return SynchronousFuture(KinyarwandaMaterialLocalizations());
  }

  @override
  bool shouldReload(LocalizationsDelegate old) => false;
}
