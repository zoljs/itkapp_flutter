import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeService {
  ThemeService.internal();
  static final ThemeService instance = ThemeService.internal();

  final ValueNotifier<bool> amoledMode = ValueNotifier(false);

  Future<void> _saveToDisk(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('amoledMode', value);
  }

  Future<void> loadFromDisk() async {
    final prefs = await SharedPreferences.getInstance();
    amoledMode.value = prefs.getBool('amoledMode') ?? false;
  }

  Future<void> toggleAmoledMode(bool value) async {
    amoledMode.value = value;
  }
}
