import 'package:flutter/material.dart';
import 'package:itk_app/domain/models/site_color.dart';
import 'package:itk_app/ui/core/theme/app_themes.dart';

/// UI side of [SiteColor]: the model only knows the key, the theme knows the color.
extension SiteColorX on SiteColor {
  Color get color => switch (this) {
        SiteColor.itk => itkPrimary,
        SiteColor.purple => const Color(0xFF7E57C2),
        SiteColor.red => const Color(0xFFEF5350),
        SiteColor.orange => const Color(0xFFFF9800),
        SiteColor.amber => const Color(0xFFFFCA28),
        SiteColor.green => const Color(0xFF66BB6A),
        SiteColor.mint => const Color(0xFFCAE1CB),
      };
}
