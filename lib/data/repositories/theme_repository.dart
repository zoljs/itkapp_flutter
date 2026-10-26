import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeRepository {
  static const _oledKey = 'oledMode';
  static const _fabKey = 'actionButtonAsFab';

  ThemeRepository();
  static final instance = ThemeRepository();

  final ValueNotifier<bool> oledMode = ValueNotifier(false);
  final ValueNotifier<bool> actionButtonAsFab = ValueNotifier(false);

  Future<void> _saveToDisk(bool value, String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  Future<void> loadFromDisk() async {
    final prefs = await SharedPreferences.getInstance();
    oledMode.value = prefs.getBool(_oledKey) ?? false;
    actionButtonAsFab.value = prefs.getBool(_fabKey) ?? false;
  }

  Future<void> toggleOledMode(bool value) async {
    oledMode.value = value;
    await _saveToDisk(value, _oledKey);
  }

  Future<void> toggleActionButtonAsFab(bool value) async {
    actionButtonAsFab.value = value;
    await _saveToDisk(value, _fabKey);
  }
}
