import 'package:flutter_test/flutter_test.dart';
import 'package:itk_app/data/repositories/theme_repository.dart';
import 'package:itk_app/data/services/shared_preferences_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late SharedPreferences rawPrefs;

  Future<ThemeRepository> build({Map<String, Object> stored = const {}}) async {
    SharedPreferences.setMockInitialValues(stored);
    rawPrefs = await SharedPreferences.getInstance();
    return ThemeRepository(prefs: SharedPreferencesService(rawPrefs));
  }

  test('alapértelmezés: OLED és FAB kikapcsolva', () async {
    final repository = await build();

    expect(repository.oledMode.value, isFalse);
    expect(repository.actionButtonAsFab.value, isFalse);
  });

  test('a mentett értékek induláskor beolvasódnak', () async {
    final repository =
        await build(stored: {'oledMode': true, 'actionButtonAsFab': true});

    expect(repository.oledMode.value, isTrue);
    expect(repository.actionButtonAsFab.value, isTrue);
  });

  test('toggleOledMode átállítja, értesít és elment', () async {
    final repository = await build();
    var notified = 0;
    repository.oledMode.addListener(() => notified++);

    await repository.toggleOledMode(true);

    expect(repository.oledMode.value, isTrue);
    expect(rawPrefs.getBool('oledMode'), isTrue);
    expect(notified, 1);
    expect(repository.actionButtonAsFab.value, isFalse);
  });

  test('toggleActionButtonAsFab átállítja és elment, az OLED-et nem bántja',
      () async {
    final repository = await build();

    await repository.toggleActionButtonAsFab(true);

    expect(repository.actionButtonAsFab.value, isTrue);
    expect(rawPrefs.getBool('actionButtonAsFab'), isTrue);
    expect(repository.oledMode.value, isFalse);

    await repository.toggleActionButtonAsFab(false);
    expect(rawPrefs.getBool('actionButtonAsFab'), isFalse);
  });
}
