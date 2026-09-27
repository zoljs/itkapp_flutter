import 'package:calendar_view/calendar_view.dart';
import 'package:flutter/material.dart';
import 'package:itk_app/models/calendar_event.dart';
import 'package:itk_app/services/theme_service.dart';
import 'package:itk_app/theme/app_fonts.dart';
import 'package:itk_app/theme/app_radius.dart';
import 'package:itk_app/theme/app_themes.dart';
import 'package:flutter/services.dart';
import 'services/api_client.dart';
import 'screens/auth_gate.dart';
import 'package:intl/date_symbol_data_local.dart';

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
  final TextTheme base =
      ThemeData(colorScheme: scheme, useMaterial3: true).textTheme;

  return ThemeData(
    colorScheme: scheme,
    useMaterial3: true,
    textTheme: buildITKAppTextTheme(base),
    inputDecorationTheme: buildITKAppInputDecorationTheme(scheme),
    snackBarTheme: const SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(AppRadius.lg)),
      ),
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
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'ITK App',
            themeMode: ThemeMode.system,
            theme: _buildTheme(lightScheme),
            darkTheme: _buildTheme(darkScheme),
            home: const AuthGate(),
            navigatorKey: navigatorKey,
          ),
        );
      },
    );
  }
}
