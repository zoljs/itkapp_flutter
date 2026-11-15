import 'package:flutter_test/flutter_test.dart';
import 'package:itk_app/data/repositories/onboarding_repository.dart';
import 'package:itk_app/data/services/shared_preferences_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _key = 'hasSeenOnboarding';

void main() {
  late SharedPreferences rawPrefs;

  Future<OnboardingRepository> build({Map<String, Object> stored = const {}}) async {
    SharedPreferences.setMockInitialValues(stored);
    rawPrefs = await SharedPreferences.getInstance();
    return OnboardingRepository(prefs: SharedPreferencesService(rawPrefs));
  }

  test('alapból még nem látta az onboardingot', () async {
    final repository = await build();

    expect(repository.hasSeenOnboarding.value, isFalse);
  });

  test('a mentett érték induláskor beolvasódik', () async {
    final repository = await build(stored: {_key: true});

    expect(repository.hasSeenOnboarding.value, isTrue);
  });

  test('markSeenOnboarding elmenti és értesít', () async {
    final repository = await build();
    final values = <bool>[];
    repository.hasSeenOnboarding.addListener(
        () => values.add(repository.hasSeenOnboarding.value));

    await repository.markSeenOnboarding();

    expect(repository.hasSeenOnboarding.value, isTrue);
    expect(rawPrefs.getBool(_key), isTrue);
    expect(values, [true]);
  });

  test('resetOnboarding törli a mentést és visszaáll', () async {
    final repository = await build(stored: {_key: true});

    await repository.resetOnboarding();

    expect(repository.hasSeenOnboarding.value, isFalse);
    expect(rawPrefs.containsKey(_key), isFalse);
  });
}
