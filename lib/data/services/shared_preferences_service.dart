import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesService {
  SharedPreferencesService(SharedPreferences prefs) : _prefs = prefs;

  final SharedPreferences _prefs;

  // SharedPrefs reads all values into the memory on start, so get is not Future
  bool? getBool(String key) => _prefs.getBool(key);
  String? getString(String key) => _prefs.getString(key);

  Future<void> setBool(String key, bool value) async {
    await _prefs.setBool(key, value);
  }

  Future<void> setString(String key, String value) async {
    await _prefs.setString(key, value);
  }

  Future<void> remove(String key) async {
    await _prefs.remove(key);
  }
}
