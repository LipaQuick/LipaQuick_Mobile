import 'package:flutter/cupertino.dart';

class ProfileItemModels {
  int itemId;
  int parentColorCode, iconColorCode;
  IconData icon;
  String title, subTitle;

  ProfileItemModels(this.itemId, this.parentColorCode, this.iconColorCode, this.icon, this.title, this.subTitle);
}