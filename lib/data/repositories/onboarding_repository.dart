import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingRepository {
  static const _hasSeenOnboarding = 'hasSeenOnboarding';

  OnboardingRepository();
  static final OnboardingRepository instance = OnboardingRepository();

  final ValueNotifier<bool> hasSeenOnboarding = ValueNotifier(false);

  Future<void> loadFromDisk() async {
    final prefs = await SharedPreferences.getInstance();
    hasSeenOnboarding.value = prefs.getBool(_hasSeenOnboarding) ?? false;
  }

  Future<void> markSeenOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_hasSeenOnboarding, true);
    hasSeenOnboarding.value = true;
  }

  Future<void> resetOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove(_hasSeenOnboarding);
    hasSeenOnboarding.value = false;
  }
}
