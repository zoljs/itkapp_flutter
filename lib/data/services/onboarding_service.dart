import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingService {
  static const _hasSeenOnboarding = 'hasSeenOnboarding';

  OnboardingService.internal();
  static final OnboardingService instance = OnboardingService.internal();

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
}
