import 'package:flutter/material.dart';
import 'package:itk_app/data/services/shared_preferences_service.dart';

class ThemeRepository {
  static const _oledKey = 'oledMode';
  static const _fabKey = 'actionButtonAsFab';

  ThemeRepository({required SharedPreferencesService prefs})
      : _prefs = prefs,
        oledMode = ValueNotifier(prefs.getBool(_oledKey) ?? false),
        actionButtonAsFab = ValueNotifier(prefs.getBool(_fabKey) ?? false);

  final SharedPreferencesService _prefs;
  final ValueNotifier<bool> oledMode;
  final ValueNotifier<bool> actionButtonAsFab;

  Future<void> toggleOledMode(bool value) async {
    oledMode.value = value;
    await _prefs.setBool(_oledKey, value);
  }

  Future<void> toggleActionButtonAsFab(bool value) async {
    actionButtonAsFab.value = value;
    await _prefs.setBool(_fabKey, value);
  }
}
