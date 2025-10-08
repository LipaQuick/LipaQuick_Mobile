import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

enum CardType {
  MasterCard,
  Visa,
  Verve,
  Others, // Any other card issuer
  Invalid // We'll use this when the card is invalid
}

class CardUtils{
  static CardType getCardTypeFrmNumber(String input) {
    CardType cardType;
    if (input.startsWith(RegExp(r'((5[1-5])|(222[1-9]|22[3-9][0-9]|2[3-6][0-9]{2}|27[01][0-9]|2720))'))) {
      cardType = CardType.MasterCard;
    } else if (input.startsWith(RegExp(r'[4]'))) {
      cardType = CardType.Visa;
    } else if (input
        .startsWith(RegExp(r'((506(0|1))|(507(8|9))|(6500))'))) {
      cardType = CardType.Verve;
    } else if (input.length <= 8) {
      cardType = CardType.Others;
    } else {
      cardType = CardType.Invalid;
    }
    return cardType;
  }

  static dynamic getCardIcon(CardType cardType) {
    String img = "";
    Icon? icon;
    switch (cardType) {
      case CardType.MasterCard:
        img = 'master_card_icon.png';
        break;
      case CardType.Visa:
        img = 'visa_icon.png';
        break;
      case CardType.Verve:
        img = 'verve_icon.png';
        break;
      case CardType.Others:
        icon = Icon(
          Icons.credit_card,
          size: 40.0,
          color: Colors.grey[600],
        );
        break;
      case CardType.Invalid:
        icon = Icon(
          Icons.warning,
          size: 40.0,
          color: Colors.grey[600],
        );
        break;
    }

    dynamic widget;
    if (img.isNotEmpty) {
      widget = Image.asset(
        'assets/icon/$img',
        width: 40.0,
      );
    } else {
      widget = icon;
    }
    return widget;
  }
}

