import 'package:itk_app/theme/app_fonts.dart';
import 'package:itk_app/theme/app_spacing.dart';
import 'package:itk_app/theme/app_theme_colors.dart';
import 'package:itk_app/theme/app_themes.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'services/api_client.dart';
import 'screens/auth_gate.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ApiClient.instance.init();
  runApp(const ITKApp());
}

final navigatorKey = GlobalKey<NavigatorState>();

const _seedColor = Color.fromARGB(255, 142, 136, 230);
//const _seedColor = Color(0xFF00A6E7);

ThemeData _buildTheme(ColorScheme scheme) {
  final TextTheme base =
      ThemeData(colorScheme: scheme, useMaterial3: true).textTheme;

  final isDark = scheme.brightness == Brightness.dark;

  return ThemeData(
    colorScheme: scheme,
    useMaterial3: true,
    extensions: [isDark ? AppThemeColors.dark : AppThemeColors.light],
    textTheme: buildITKAppTextTheme(base),
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
    final darkScheme = ColorScheme.fromSeed(
      seedColor: _seedColor,
      brightness: Brightness.dark,
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: _buildTheme(lightScheme),
      darkTheme: _buildTheme(darkScheme),
      home: const AuthGate(),
      navigatorKey: navigatorKey,
    );
  }
}
