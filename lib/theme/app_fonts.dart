import 'package:flutter/material.dart';

TextStyle get flexRegular => const TextStyle(
      fontFamily: 'GoogleSansFlex',
      fontVariations: [FontVariation('wght', 400)],
    );

TextStyle get flexRounded => const TextStyle(
      fontFamily: 'GoogleSansFlex',
      fontVariations: [
        FontVariation('wght', 600),
        FontVariation('ROND', 100),
      ],
    );

TextStyle get topBarTitleStyle => const TextStyle(
      fontFamily: 'GoogleSansFlex',
      fontVariations: [
        FontVariation('wght', 900),
        FontVariation('wdth', 112.5),
        FontVariation('ROND', 35),
      ],
    );

// TextTheme buildITKAppTextTheme(TextTheme base, {required bool isIOS}) {
//   return base.copyWith(
//     displayLarge: base.displayLarge?.merge(flexRounded),
//     displayMedium: base.displayMedium?.merge(flexRounded),
//     displaySmall: base.displaySmall?.merge(flexRounded),
//     headlineLarge: base.headlineLarge?.merge(flexRounded),
//     headlineMedium: base.headlineMedium?.merge(flexRounded),
//     headlineSmall: base.headlineSmall?.merge(flexRounded),
//     titleLarge: base.titleLarge?.merge(flexRegular),
//     titleMedium: base.titleMedium?.merge(flexRounded),
//     titleSmall: base.titleSmall?.merge(flexRounded),
//     bodyLarge: base.bodyLarge?.merge(flexRounded),
//     bodyMedium: base.bodyMedium?.merge(flexRegular),
//     bodySmall: base.bodySmall?.merge(flexRegular),
//     labelLarge: base.labelLarge?.merge(flexRounded),
//     labelMedium: base.labelMedium?.merge(flexRounded),
//     labelSmall: base.labelSmall?.merge(flexRounded),
//   );
// }
