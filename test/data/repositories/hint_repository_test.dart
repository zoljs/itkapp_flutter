import 'package:flutter_test/flutter_test.dart';
import 'package:itk_app/data/repositories/hint_repository.dart';
import 'package:itk_app/data/services/shared_preferences_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late SharedPreferences rawPrefs;
  late HintRepository repository;

  Future<void> build(Map<String, Object> stored) async {
    SharedPreferences.setMockInitialValues(stored);
    rawPrefs = await SharedPreferences.getInstance();
    repository = HintRepository(prefs: SharedPreferencesService(rawPrefs));
  }

  test('reset csak az adott tour kulcsát törli', () async {
    await build({'hintful.calendar': '1', 'hintful.events': '1'});

    await repository.reset('calendar');

    expect(rawPrefs.containsKey('hintful.calendar'), isFalse);
    expect(rawPrefs.getString('hintful.events'), '1');
  });

  test('resetAll minden hintful. kulcsot töröl, a többit nem', () async {
    await build({
      'hintful.calendar': '1',
      'hintful.events': '2',
      'oledMode': true,
      'hasSeenOnboarding': true,
    });

    await repository.resetAll();

    expect(rawPrefs.getKeys(), {'oledMode', 'hasSeenOnboarding'});
  });

  test('resetAll üres tárolón sem dob', () async {
    await build({});

    await repository.resetAll();

    expect(rawPrefs.getKeys(), isEmpty);
  });
}
