import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';

import 'kinyarwanda_cupertino_localizations.dart';

class KinyarwandaCupertinoLocalizationsDelegate
    extends LocalizationsDelegate<CupertinoLocalizations> {
  const KinyarwandaCupertinoLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => locale.languageCode == 'rw';

  @override
  Future<CupertinoLocalizations> load(Locale locale) async {
    return SynchronousFuture(KinyarwandaCupertinoLocalizations());
  }

  @override
  bool shouldReload(LocalizationsDelegate old) => false;
}
