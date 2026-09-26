import 'package:calendar_view/calendar_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:itk_app/models/calendar_event.dart';
import 'package:itk_app/services/theme_service.dart';
import 'package:itk_app/theme/app_themes.dart';
import 'package:flutter/services.dart';
import 'services/api_client.dart';
import 'screens/auth_gate.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ApiClient.instance.init();

  await ThemeService.instance.loadFromDisk();

  initializeDateFormatting().then(
    (_) => runApp(
      const ITKApp(),
    ),
  );
}

final navigatorKey = GlobalKey<NavigatorState>();

const _seedColor = Color.fromARGB(255, 142, 136, 230);
//const _seedColor = Color(0xFF00A6E7);

ColorScheme _darkSchemeFor(ColorScheme base, {required bool isOled}) {
  if (!isOled) return base;
  return base.copyWith(
    surface: Colors.black,
    surfaceContainerLowest: Colors.black,
    surfaceContainerLow: const Color(0xFF0A0A0A),
    surfaceContainer: const Color(0xFF121212),
    surfaceContainerHigh: const Color(0xFF1A1A1A),
    surfaceContainerHighest: const Color(0xFF222222),
  );
}

ThemeData _buildTheme(ColorScheme scheme) {
  return ThemeData(
    colorScheme: scheme,
    useMaterial3: true,
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
      ),
    ),
    inputDecorationTheme: buildITKAppInputDecorationTheme(scheme),
    snackBarTheme: const SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
    ),
  );
}

CupertinoThemeData _buildCupertinoTheme(ColorScheme scheme) {
  return CupertinoThemeData(
    brightness: scheme.brightness,
    primaryColor: scheme.primary,
    primaryContrastingColor: scheme.onPrimary,
    scaffoldBackgroundColor: scheme.surface,
    barBackgroundColor: scheme.surfaceContainer.withValues(alpha: 0.9),
    textTheme: CupertinoTextThemeData(
      textStyle: TextStyle(color: scheme.onSurface),
      navTitleTextStyle: TextStyle(
        color: scheme.onSurface,
        fontWeight: FontWeight.w600,
        fontSize: 17,
      ),
      primaryColor: scheme.primary,
    ),
  );
}

class ITKApp extends StatelessWidget {
  const ITKApp({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    final lightScheme = ColorScheme.fromSeed(seedColor: _seedColor);
    final baseDarkScheme = ColorScheme.fromSeed(
      seedColor: _seedColor,
      brightness: Brightness.dark,
    );

    return ValueListenableBuilder<bool>(
      valueListenable: ThemeService.instance.oledMode,
      builder: (context, isOled, child) {
        final darkScheme = _darkSchemeFor(baseDarkScheme, isOled: isOled);

        return CalendarControllerProvider(
          controller: EventController<CalendarEvent>(),
          child: AdaptiveApp(
            title: 'ITK App',
            themeMode: ThemeMode.system,
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            materialLightTheme: _buildTheme(lightScheme),
            materialDarkTheme: _buildTheme(darkScheme),
            cupertinoLightTheme: _buildCupertinoTheme(lightScheme),
            cupertinoDarkTheme: _buildCupertinoTheme(darkScheme),
            home: const AuthGate(),

            // CupertinoApp does NOT place a material theme ancestor for all screens
            // without a builder all material widgets would default to standard colorscheme under ios
            builder: (context, child) {
              final brightness = MediaQuery.platformBrightnessOf(context);
              final effectiveScheme =
                  brightness == Brightness.dark ? darkScheme : lightScheme;
              return Theme(
                data: _buildTheme(effectiveScheme),
                child: Material(
                  type: MaterialType.transparency,
                  child: child!,
                ),
              );
            },
          ),
        );
      },
    );
  }
}
