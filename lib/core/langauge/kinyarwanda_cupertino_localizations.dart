import 'package:flutter/cupertino.dart';

class KinyarwandaCupertinoLocalizations implements CupertinoLocalizations {
  @override
  String get clearButtonLabel => 'Sukura'; // Clear

  @override
  String get anteMeridiemAbbreviation => 'AM'; // Morning abbreviation

  @override
  String get postMeridiemAbbreviation => 'PM'; // Afternoon abbreviation

  @override
  String? datePickerHourSemanticsLabel(int hour) => '$hour isaha'; // Hour label

  @override
  String datePickerMediumDate(DateTime date) =>
      '${date.day}/${date.month}/${date.year}'; // Medium date format

  @override
  String? datePickerMinuteSemanticsLabel(int minute) =>
      '$minute iminota'; // Minute label

  @override
  String datePickerStandaloneMonth(int monthIndex) {
    const months = [
      'Mutarama', // January
      'Gashyantare', // February
      'Werurwe', // March
      'Mata', // April
      'Gicurasi', // May
      'Kamena', // June
      'Nyakanga', // July
      'Kanama', // August
      'Nzeli', // September
      'Ukwakira', // October
      'Ugushyingo', // November
      'Ukuboza', // December
    ];
    return months[monthIndex - 1];
  }

  @override
  String get lookUpButtonLabel => 'Shakisha'; // Lookup

  @override
  String get menuDismissLabel => 'Funga'; // Dismiss menu

  @override
  String get noSpellCheckReplacementsLabel =>
      'Nta byasimbuzwa bisanzwe'; // No replacements

  @override
  String get searchTextFieldPlaceholderLabel => 'Shakisha hano'; // Search placeholder

  @override
  String get searchWebButtonLabel => 'Shakisha kuri web'; // Search web

  @override
  String get shareButtonLabel => 'Sangira'; // Share

  @override
  String tabSemanticsLabel({required int tabIndex, required int tabCount}) =>
      'Taburi $tabIndex muri $tabCount'; // Tab label

  @override
  String timerPickerHour(int hour) => '$hour isaha'; // Timer hour

  @override
  String? timerPickerHourLabel(int hour) => '$hour isaha'; // Timer hour label

  @override
  String timerPickerMinute(int minute) => '$minute iminota'; // Timer minute

  @override
  String? timerPickerMinuteLabel(int minute) => '$minute iminota'; // Timer minute label

  @override
  String timerPickerSecond(int second) => '$second isegonda'; // Timer second

  @override
  String? timerPickerSecondLabel(int second) => '$second isegonda'; // Timer second label

  @override
  DatePickerDateOrder get datePickerDateOrder =>
      DatePickerDateOrder.dmy; // Date order

  @override
  DatePickerDateTimeOrder get datePickerDateTimeOrder =>
      DatePickerDateTimeOrder.date_time_dayPeriod;

  @override
  String get modalBarrierDismissLabel => 'Funga'; // Modal dismiss

  @override
  String get todayLabel => 'Uyu munsi'; // Today

  @override
  String get tomorrowLabel => 'Ejo'; // Tomorrow

  @override
  String get yesterdayLabel => 'Ejo hashize';

  @override
  // TODO: implement alertDialogLabel
  String get alertDialogLabel => 'Alert';

  @override
  // TODO: implement copyButtonLabel
  String get copyButtonLabel => throw UnimplementedError();

  @override
  // TODO: implement cutButtonLabel
  String get cutButtonLabel => throw UnimplementedError();

  @override
  String datePickerDayOfMonth(int dayIndex, [int? weekDay]) {
    // TODO: implement datePickerDayOfMonth
    throw UnimplementedError();
  }

  @override
  String datePickerHour(int hour) {
    // TODO: implement datePickerHour
    throw UnimplementedError();
  }

  @override
  String datePickerMinute(int minute) {
    // TODO: implement datePickerMinute
    throw UnimplementedError();
  }

  @override
  String datePickerMonth(int monthIndex) {
    // TODO: implement datePickerMonth
    throw UnimplementedError();
  }

  @override
  String datePickerYear(int yearIndex
      ) {
    // TODO: implement datePickerYear
    throw UnimplementedError();
  }

  @override
  // TODO: implement pasteButtonLabel
  String get pasteButtonLabel => throw UnimplementedError();

  @override
  // TODO: implement selectAllButtonLabel
  String get selectAllButtonLabel => throw UnimplementedError();

  @override
  // TODO: implement timerPickerHourLabels
  List<String> get timerPickerHourLabels => throw UnimplementedError();

  @override
  // TODO: implement timerPickerMinuteLabels
  List<String> get timerPickerMinuteLabels => throw UnimplementedError();

  @override
  // TODO: implement timerPickerSecondLabels
  List<String> get timerPickerSecondLabels => throw UnimplementedError(); // Yesterday
}
