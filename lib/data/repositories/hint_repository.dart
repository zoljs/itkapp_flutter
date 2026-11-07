import 'dart:async';

import 'package:hintful/hintful.dart';
import 'package:itk_app/data/services/shared_preferences_service.dart';

class HintRepository {
  HintRepository({required SharedPreferencesService prefs}) : _prefs = prefs;
  static const _prefix = 'hintful.';

  final SharedPreferencesService _prefs;

  static String _storageKey(String tourId) => 'hintful.$tourId';

  void configureStore() {
    Hintful.configure(
      store: CallbackHintStore(
        read: (key) => _prefs.getString(_storageKey(key)),
        write: (key, version) =>
            unawaited(_prefs.setString(_storageKey(key), version)),
      ),
    );
  }

  Future<void> reset(String tourId) => _prefs.remove(_storageKey(tourId));

  Future<void> resetAll() async {
    for (final key in _prefs.keys.where((k) => k.startsWith(_prefix))) {
      await _prefs.remove(key);
    }
  }
}
