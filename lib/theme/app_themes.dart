import 'package:itk_app/theme/app_spacing.dart';
import 'package:material_ui/material_ui.dart';

InputDecorationThemeData buildITKAppInputDecorationTheme(ColorScheme scheme) {
  return InputDecorationThemeData(
    hintStyle: TextStyle(color: scheme.onSurfaceVariant, fontSize: 15),
    filled: true,
    fillColor: scheme.surfaceContainerHigh,
    contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg, vertical: AppSpacing.lg),
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
  );
}

const itkPrimary = Color(0xFF00A6E7);
