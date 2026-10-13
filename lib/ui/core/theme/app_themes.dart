import 'package:itk_app/ui/core/theme/app_radius.dart';
import 'package:itk_app/ui/core/theme/app_spacing.dart';
import 'package:flutter/material.dart';

InputDecorationThemeData buildITKAppInputDecorationTheme(ColorScheme scheme) {
  return InputDecorationThemeData(
    hintStyle: TextStyle(color: scheme.onSurfaceVariant, fontSize: 15),
    filled: true,
    fillColor: scheme.surfaceContainerHigh,
    contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm, vertical: AppSpacing.sm),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.xxxl),
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.xxxl),
      borderSide: BorderSide.none,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.xxxl),
      borderSide: BorderSide.none,
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.xxxl),
      borderSide: BorderSide(color: scheme.error, width: 2.0),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.xxxl),
      borderSide: BorderSide(color: scheme.error, width: 2.0),
    ),
  );
}

const itkPrimary = Color(0xFF00A6E7);
const itkDark = Color(0xFF0b3468);
