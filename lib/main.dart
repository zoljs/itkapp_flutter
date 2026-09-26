import 'package:calendar_view/calendar_view.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:itk_app/models/calendar_event.dart';
import 'package:itk_app/services/theme_service.dart';
import 'package:itk_app/theme/app_themes.dart';
import 'package:liquid_glass_widgets/liquid_glass_setup.dart';
import 'package:material_ui/material_ui.dart' hide GlobalMaterialLocalizations;
import 'package:flutter/services.dart';
import 'services/api_client.dart';
import 'screens/auth_gate.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter/foundation.dart';
import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  //debugDefaultTargetPlatformOverride = TargetPlatform.android;
  await ApiClient.instance.init();

  await LiquidGlassWidgets.initialize();
  await ThemeService.instance.loadFromDisk();
  //runApp(const ITKApp());

  initializeDateFormatting().then(
    (_) => runApp(
      LiquidGlassWidgets.wrap(
        child: const ITKApp(),
        brightnessResolver: Theme.maybeBrightnessOf,
        adaptiveQuality: true,
      ),
    ),
  );
}

final navigatorKey = GlobalKey<NavigatorState>();

const _seedColor = Color.fromARGB(255, 142, 136, 230);
//const _seedColor = Color(0xFF00A6E7);
ThemeData _buildTheme(ColorScheme scheme) {
  return ThemeData(
    colorScheme: scheme,
    useMaterial3: true,
    inputDecorationTheme: buildITKAppInputDecorationTheme(scheme),
    snackBarTheme: const SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
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
        final darkScheme = isOled
            ? baseDarkScheme.copyWith(
                surface: Colors.black,
                surfaceContainerLowest: Colors.black,
                surfaceContainerLow: const Color(0xFF0A0A0A),
                surfaceContainer: const Color(0xFF121212),
                surfaceContainerHigh: const Color(0xFF1A1A1A),
                surfaceContainerHighest: const Color(0xFF222222),
              )
            : baseDarkScheme;

        return CalendarControllerProvider(
          controller: EventController<CalendarEvent>(),
          child: MaterialApp(
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            //builder: (context, child) => AdaptiveToolbarHost(child: child!),
            builder: (context, child) => Material(
              type: MaterialType.transparency,
              child: child!,
            ),
            debugShowCheckedModeBanner: false,
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
