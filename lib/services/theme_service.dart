import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeService {
  ThemeService.internal();
  static final ThemeService instance = ThemeService.internal();

  final ValueNotifier<bool> oledMode = ValueNotifier(false);

  Future<void> _saveToDisk(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('oledMode', value);
  }

  Future<void> loadFromDisk() async {
    final prefs = await SharedPreferences.getInstance();
    oledMode.value = prefs.getBool('oledMode') ?? false;
  }

  Future<void> toggleOledMode(bool value) async {
    oledMode.value = value;
    _saveToDisk(value);
  }
}
