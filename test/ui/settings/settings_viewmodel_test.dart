import 'package:flutter_test/flutter_test.dart';
import 'package:itk_app/data/repositories/hint_repository.dart';
import 'package:itk_app/data/repositories/onboarding_repository.dart';
import 'package:itk_app/data/repositories/theme_repository.dart';
import 'package:itk_app/data/services/shared_preferences_service.dart';
import 'package:itk_app/ui/settings/viewmodels/settings_viewmodel.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../helpers/fake_http.dart';
import '../../helpers/fake_repositories.dart';
import '../../helpers/fixtures.dart';

void main() {
  late SharedPreferences rawPrefs;
  late FakeAuthRepository auth;
  late ThemeRepository theme;
  late OnboardingRepository onboarding;
  late SettingsViewModel viewModel;

  Future<void> build({Map<String, Object> stored = const {}}) async {
    SharedPreferences.setMockInitialValues(stored);
    rawPrefs = await SharedPreferences.getInstance();
    final prefs = SharedPreferencesService(rawPrefs);
    auth = FakeAuthRepository()..cachedUser = user();
    theme = ThemeRepository(prefs: prefs);
    onboarding = OnboardingRepository(prefs: prefs);
    viewModel = SettingsViewModel(
      authRepository: auth,
      themeRepository: theme,
      apiClient: TestApiClient(),
      onboardingRepository: onboarding,
      hintRepository: HintRepository(prefs: prefs),
    );
  }

  group('téma', () {
    setUp(() => build());
    tearDown(() => viewModel.dispose());

    test('induláskor a mentett beállítások látszanak', () async {
      // a setUp által épített példány helyett egy újat építünk, a tearDown ezt
      // zárja le
      await build(stored: {'oledMode': true, 'actionButtonAsFab': true});

      expect(viewModel.isOledMode, isTrue);
      expect(viewModel.isActionButtonAsFab, isTrue);
    });

    test('toggleOledMode átállít, értesít és elment', () async {
      var notified = 0;
      viewModel.addListener(() => notified++);

      viewModel.toggleOledMode(true);
      await flush();

      expect(viewModel.isOledMode, isTrue);
      expect(rawPrefs.getBool('oledMode'), isTrue);
      expect(notified, 1);
    });

    test('toggleActionButtonAsFab átállít, értesít és elment', () async {
      var notified = 0;
      viewModel.addListener(() => notified++);

      viewModel.toggleActionButtonAsFab(true);
      await flush();

      expect(viewModel.isActionButtonAsFab, isTrue);
      expect(rawPrefs.getBool('actionButtonAsFab'), isTrue);
      expect(notified, 1);
    });

    test('a felhasználó az auth repository-ból jön', () {
      expect(viewModel.currentUser?.login, 'perpa4');

      auth.cachedUser = null;
      expect(viewModel.currentUser, isNull);
    });

    test('clearCookies nem dob', () async {
      await viewModel.clearCookies();
    });
  });

  test('dispose után a téma változása már nem értesíti a nézetmodellt',
      () async {
    await build();
    viewModel.dispose();

    // ha a listener bent maradt, ez a disposed ChangeNotifier miatt elbukna
    await theme.toggleOledMode(true);
    await theme.toggleActionButtonAsFab(true);
  });

  group('resetOnboarding', () {
    tearDown(() => viewModel.dispose());

    test('törli az onboarding jelzőt és az összes hint kulcsot', () async {
      await build(stored: {
        'hasSeenOnboarding': true,
        'hintful.calendar': '1',
        'hintful.events': '1',
        'oledMode': true,
      });
      expect(onboarding.hasSeenOnboarding.value, isTrue);

      await viewModel.resetOnboarding();

      expect(onboarding.hasSeenOnboarding.value, isFalse);
      expect(rawPrefs.getKeys(), {'oledMode'});
    });
  });
}
