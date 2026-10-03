import 'package:flutter/material.dart';

extension SnackBarExtension on BuildContext {
  void showMessage(String message) {
    ScaffoldMessenger.of(this).showSnackBar(SnackBar(content: Text(message)));
  }
}
