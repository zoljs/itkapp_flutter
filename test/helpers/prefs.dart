import 'package:itk_app/data/repositories/theme_repository.dart';
import 'package:itk_app/data/services/shared_preferences_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A real [ThemeRepository] on in-memory SharedPreferences.
Future<ThemeRepository> makeThemeRepository({
  bool actionButtonAsFab = false,
  bool oledMode = false,
}) async {
  SharedPreferences.setMockInitialValues({
    'actionButtonAsFab': actionButtonAsFab,
    'oledMode': oledMode,
  });
  final prefs = await SharedPreferences.getInstance();
  return ThemeRepository(prefs: SharedPreferencesService(prefs));
}
