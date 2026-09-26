import 'package:itk_app/theme/glass_settings.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'package:material_ui/material_ui.dart';

class AdaptiveIconButton extends StatelessWidget {
  const AdaptiveIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.dimension = 40,
    this.iconSize = 20,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final double dimension;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    final isIOS = Theme.of(context).platform == TargetPlatform.iOS;
    final scheme = Theme.of(context).colorScheme;

    if (isIOS) {
      return GlassIconButton(
        icon: Icon(
          icon,
          size: iconSize,
        ),
        onPressed: onPressed,
        size: dimension,
        useOwnLayer: true,
        settings: kAppGlassSettings,
        quality: kAppGlassQuality,
      );
    }

    return SizedBox.square(
      dimension: dimension,
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(
          icon,
          size: iconSize,
        ),
        style: IconButton.styleFrom(
          backgroundColor: scheme.surfaceContainer,
          foregroundColor: scheme.onSurface,
          shape: const CircleBorder(),
          padding: EdgeInsets.zero,
        ),
      ),
    );
  }
}
