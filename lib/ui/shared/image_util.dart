import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:lipa_quick/gen/assets.gen.dart';

class ImageUtil{
  Image imageFromBase64String(String base64String, double width, double height, [Color? color]) {
    try{
      return Image.memory(base64Decode(base64String), width: width, height: height
          , color: color, errorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace){
        return Image.asset(Assets.icon.invalidImage.path, width: width, height: height, color: color);
        },);
    }catch(e){
      return Image.asset(Assets.icon.invalidImage.path, width: width, height: height, color: color);
    };
  }

  String getBase64Logo(String logo){
    var base64Image = logo.split(",");
    return base64Image.last;
  }
}