import 'package:country_codes/country_codes.dart';
import 'package:flutter/services.dart';

class PhoneEmailInputFormatter extends TextInputFormatter {
  final String? defaultCountryCode;

  PhoneEmailInputFormatter({this.defaultCountryCode});

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue,
      TextEditingValue newValue,
      ) {
    final inputValue = newValue.text;
    final firstCharacter = inputValue.isNotEmpty ? inputValue.substring(0, 1) : '';

    if (firstCharacter.isNotEmpty && firstCharacter.contains(RegExp(r'[A-Za-z]'))) {
      // Input starts with a letter, treat it as an email address
      return newValue;
    } else {
      // Input starts with a digit, treat it as a phone number
      final strippedValue = inputValue.replaceAll(RegExp(r'\D+'), '');
      final formattedValue = _formatPhoneNumber(strippedValue);
      return newValue.copyWith(
        text: formattedValue,
        selection: TextSelection.collapsed(offset: formattedValue.length),
      );
    }
  }

  String _formatPhoneNumber(String input) {
    final countryCode = _getCountryCode();
    final phoneNumberRegExp = RegExp(r'^(\d{1,3})(\d{1,3})?(\d{1,4})?$');
    final match = phoneNumberRegExp.firstMatch(input);

    if (match == null) return input;

    final firstGroup = match.group(1);
    final secondGroup = match.group(2);
    final thirdGroup = match.group(3);

    if (secondGroup == null) {
      return '$countryCode $firstGroup';
    } else if (thirdGroup == null) {
      return '$countryCode $firstGroup-$secondGroup';
    } else {
      return '$countryCode $firstGroup-$secondGroup-$thirdGroup';
    }
  }

  String _getCountryCode() {
    try {
      // Get the ISO 3166-1 alpha-2 country code based on the user's SIM card
      final CountryDetails details = CountryCodes.detailsForLocale();
      return details.dialCode!;
    } catch (e) {
      // If an error occurs, return the default country code
      return defaultCountryCode ?? '';
    }
  }
}
