import 'package:flutter/material.dart';
import 'package:itk_app/data/services/shared_preferences_service.dart';

class OnboardingRepository {
  static const _hasSeenOnboarding = 'hasSeenOnboarding';

  OnboardingRepository({required SharedPreferencesService prefs})
      : _prefs = prefs,
        hasSeenOnboarding =
            ValueNotifier(prefs.getBool(_hasSeenOnboarding) ?? false);

  final SharedPreferencesService _prefs;
  final ValueNotifier<bool> hasSeenOnboarding;

  Future<void> markSeenOnboarding() async {
    await _prefs.setBool(_hasSeenOnboarding, true);
    hasSeenOnboarding.value = true;
  }

  Future<void> resetOnboarding() async {
    await _prefs.remove(_hasSeenOnboarding);
    hasSeenOnboarding.value = false;
  }
}
