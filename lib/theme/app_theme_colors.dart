import 'package:material_ui/material_ui.dart';

class AppThemeColors extends ThemeExtension<AppThemeColors> {
  final Color textDark;
  final Color textGray;
  final Color itkPrimary;

  const AppThemeColors(
      {required this.textDark,
      required this.textGray,
      required this.itkPrimary});

  static const light = AppThemeColors(
    textDark: Color(0xFF111111),
    textGray: Color(0xFF6B6B70),
    itkPrimary: Color(0xFF00A6E7),
  );

  // Current ones are the same, later ones might not be
  static const dark = AppThemeColors(
    textDark: Color(0xFF111111),
    textGray: Color(0xFF6B6B70),
    itkPrimary: Color(0xFF00A6E7),
  );

  @override
  AppThemeColors copyWith({
    Color? textDark,
    Color? textGray,
    Color? itkPrimary,
  }) {
    return AppThemeColors(
      textDark: textDark ?? this.textDark,
      textGray: textGray ?? this.textGray,
      itkPrimary: itkPrimary ?? this.itkPrimary,
    );
  }

  @override
  ThemeExtension<AppThemeColors> lerp(
      covariant ThemeExtension<AppThemeColors>? other, double t) {
    if (other is! AppThemeColors) return this;
    return AppThemeColors(
      textDark: Color.lerp(textDark, other.textDark, t)!,
      textGray: Color.lerp(textGray, other.textGray, t)!,
      itkPrimary: Color.lerp(itkPrimary, other.itkPrimary, t)!,
    );
  }
}
