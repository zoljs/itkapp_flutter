import 'package:itk_app/theme/app_fonts.dart';
import 'package:itk_app/theme/app_theme_colors.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'services/api_client.dart';
import 'screens/auth_gate.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ApiClient.instance.init();
  runApp(const ITKApp());
}

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
    inputDecorationTheme: InputDecorationThemeData(
      hintStyle: TextStyle(color: scheme.onSurfaceVariant, fontSize: 15),
      filled: true,
      fillColor: scheme.surfaceContainerHigh,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide(color: scheme.primary, width: 2.0),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide(color: scheme.error, width: 2.0),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide(color: scheme.error, width: 1.5),
      ),
    ),
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
    );
  }
}
