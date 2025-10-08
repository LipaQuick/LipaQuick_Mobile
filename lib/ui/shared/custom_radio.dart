import 'package:flutter/material.dart';

import 'app_colors.dart';

class MyRadioListTile<T> extends StatelessWidget {
  final T value;
  final T groupValue;
  final String leading;
  final Widget? title;
  final ValueChanged<T?> onChanged;

  const MyRadioListTile({
    required this.value,
    required this.groupValue,
    required this.onChanged,
    required this.leading,
    this.title,
  });

  @override
  Widget build(BuildContext context) {
    final title = this.title;
    return InkWell(
      onTap: () => onChanged(value),
      child: Container(
        height: 56,
        padding: EdgeInsets.symmetric(horizontal: 10),
        child: Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            _customRadioButton,
            SizedBox(width: 6),
            if (title != null) title,
          ],
        ),
      ),
    );
  }

  Widget get _customRadioButton {
    final isSelected = value == groupValue;
    return Container(
      width: 25,
      height: 25,
      decoration: BoxDecoration(
        color: isSelected ? appGreen400 : null,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isSelected ? appGreen400 : Colors.grey[400]!,
          width: 4,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: appBackgroundWhite,
          shape: BoxShape.circle
        ),
      ),
    );
  }
}