import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';

import 'app_colors.dart';
import 'text_styles.dart';
import 'ui_helpers.dart';

class DatePickerWidget extends StatefulWidget {
  const DatePickerWidget(
      {Key? key, this.restorationId, this.onChanged, this.hint, this.format, this.isCreditDebitCardDate})
      : super(key: key);

  final String? restorationId;
  final ValueChanged<String>? onChanged;
  final String? hint;
  final DateFormat? format;
  final bool? isCreditDebitCardDate;

  @override
  State<DatePickerWidget> createState() => _DatePickerWidgetState(isCreditDebitCardDate);
}

/// RestorationProperty objects can be used because of RestorationMixin.
class _DatePickerWidgetState extends State<DatePickerWidget>
    with RestorationMixin {
  final bool? isCreditDebitCardDate;
  _DatePickerWidgetState(this.isCreditDebitCardDate){
    _firstDate = isCreditDebitCardDate!?DateTime.now():DateTime(1970);
    final eighteenY = DateTime(DateTime.now().year - 17);
    final nineTeenYears = DateTime(DateTime.now().year - 17);
    _lastDate = isCreditDebitCardDate!?DateTime(2040):eighteenY;
    _selectedDate = RestorableDateTime(isCreditDebitCardDate!?DateTime.now():nineTeenYears);
  }

  // In this example, the restoration ID for the mixin is passed in through
  // the [StatefulWidget]'s constructor.
  @override
  String? get restorationId => widget.restorationId;

  late RestorableDateTime _selectedDate;
  static DateTime _firstDate = DateTime.now();
  static DateTime _lastDate = DateTime.now();
  late final RestorableRouteFuture<DateTime?> _restorableDatePickerRouteFuture =
      RestorableRouteFuture<DateTime?>(
    onComplete: _selectDate,
    onPresent: (NavigatorState navigator, Object? arguments) {
      return navigator.restorablePush(
        _datePickerRoute,
        arguments: _selectedDate.value.millisecondsSinceEpoch,
      );
    },
  );

  static Route<DateTime> _datePickerRoute(
    BuildContext context,
    Object? arguments,
  ) {
    return DialogRoute<DateTime>(
      context: context,
      builder: (BuildContext context) {
        return DatePickerDialog(
          restorationId: 'date_picker_dialog',
          initialEntryMode: DatePickerEntryMode.calendarOnly,
          initialDate: DateTime.fromMillisecondsSinceEpoch(arguments! as int),
          firstDate: _firstDate,
          lastDate: _lastDate,
        );
      },
    );
  }

  @override
  void restoreState(RestorationBucket? oldBucket, bool initialRestore) {
    registerForRestoration(_selectedDate, 'selected_date');
    registerForRestoration(
        _restorableDatePickerRouteFuture, 'date_picker_route_future');
  }

  void _selectDate(DateTime? newSelectedDate) {
    if (newSelectedDate != null) {
      setState(() {
        _selectedDate.value = newSelectedDate;
        widget.onChanged!(widget.format!.format(_selectedDate.value));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var outlineStyle = const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(8.0)));
    var inputDecoration = InputDecoration(
      border: outlineStyle,
      suffixIcon: IconButton(
        icon: Icon(Icons.calendar_today),
        color: appGreen400,
        onPressed: () {
          _restorableDatePickerRouteFuture.present();
        },
      ),
      hintText: _selectedDate.value == null
          ? widget.hint
          : widget.format!.format(_selectedDate.value),
    );

    return Padding(
      padding: UIHelper.mediumSymmetricPadding(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.hint!, style: InputTitleStyle),
          const SizedBox(height: 10),
          TextFormField(
            decoration: inputDecoration,
            style: Theme.of(context).textTheme.copyWith(headlineSmall: Theme.of(context).textTheme
                .headlineSmall?.copyWith(color: appSurfaceBlack, fontSize: 16)).headlineSmall,
            autofocus: false,
            showCursor: false,
            readOnly: true,
            enabled: true,
            onTap: () {
              _restorableDatePickerRouteFuture.present();
            },
          )
        ],
      ),
    );
  }
}
