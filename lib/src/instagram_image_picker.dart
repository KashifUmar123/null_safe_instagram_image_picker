import 'package:flutter/material.dart';
import 'package:null_safe_instagram_image_picker/src/image_picker.dart';

class InstagramImagePicker {
  String appId;
  String appSecret;
  Color backgroundColor;
  Color appbarColor;
  String appbarText;
  Color textColor;

  InstagramImagePicker({
    required this.appId,
    required this.appSecret,
    this.backgroundColor = Colors.white,
    this.appbarColor = Colors.white,
    this.appbarText = "Instagram Image picker",
    this.textColor = Colors.black,
  });

  Future<List> pickImages({required BuildContext context}) async {
    List mediaUrls = await Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => ImagesPicker(
        appId: appId,
        appSecret: appSecret,
        appbarColor: appbarColor,
        appbarText: appbarText,
        backgroundColor: backgroundColor,
        textColor: textColor,
      ),
    ));
    return mediaUrls;
  }
}
