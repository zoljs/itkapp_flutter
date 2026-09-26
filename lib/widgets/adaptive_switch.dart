import 'package:itk_app/theme/glass_settings.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'package:material_ui/material_ui.dart';

class AdaptiveSwitch extends StatefulWidget {
  const AdaptiveSwitch({
    super.key,
    this.value = false,
    required this.onChanged,
  });

  final void Function(bool value) onChanged;
  final bool value;

  @override
  State<AdaptiveSwitch> createState() => _AdaptiveSwitchState();
}

class _AdaptiveSwitchState extends State<AdaptiveSwitch> {
  @override
  Widget build(BuildContext context) {
    final isIOS = Theme.of(context).platform == TargetPlatform.iOS;
    final scheme = Theme.of(context).colorScheme;

    if (isIOS) {
      return GlassSwitch(
        settings: kAppGlassSettings,
        quality: kAppGlassQuality,
        value: widget.value,
        onChanged: widget.onChanged,
        activeColor: scheme.primary,
      );
    }

    return Switch(
      value: widget.value,
      onChanged: widget.onChanged,
    );
  }
}
