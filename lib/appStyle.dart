// ignore_for_file: file_names

import 'package:flutter/material.dart';

class AppStyles {
  static Color primaryColor(BuildContext context) {
    return Theme.of(context).primaryColor;
  }

  static TextStyle welcomeText(BuildContext context) {
    return TextStyle(
      color: primaryColor(context),
      fontSize: 32,
      fontWeight: FontWeight.w500,
    );
  }

  static TextStyle greyText(BuildContext context) {
    return const TextStyle(
      color: Colors.grey,
    );
  }

  static TextStyle purpleText(BuildContext context) {
    return TextStyle(
      color: primaryColor(context),
    );
  }

  static InputDecoration inputDecoration(String hintText,
      {bool isPassword = false}) {
    return InputDecoration(
      hintText: hintText,
      suffixIcon: isPassword
          ? const Icon(Icons.remove_red_eye)
          : const Icon(Icons.done),
    );
  }

  static ButtonStyle loginButtonStyle(Color color) {
    return ElevatedButton.styleFrom(
      shape: const StadiumBorder(),
      elevation: 12,
      minimumSize: const Size.fromHeight(60),
    );
  }
}
