import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:itk_app/ui/core/theme/app_radius.dart';
import 'package:itk_app/ui/core/theme/app_spacing.dart';

class BrandIconButton extends StatefulWidget {
  const BrandIconButton({
    super.key,
    required this.icon,
    required this.semanticLabel,
    this.onPressed,
    this.backgroundColor,
    this.iconColor,
  });

  final VoidCallback? onPressed;
  final String semanticLabel;
  final IconData icon;
  final Color? backgroundColor;
  final Color? iconColor;

  @override
  State<BrandIconButton> createState() => _BrandIconButtonState();
}

class _BrandIconButtonState extends State<BrandIconButton> {
  bool _pressed = false;

  bool get _enabled => widget.onPressed != null;

  void _setPressed(bool value) {
    if (_pressed != value) setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Semantics(
      button: true,
      enabled: _enabled,
      label: widget.semanticLabel,
      child: Listener(
        onPointerDown: (_) => _enabled ? _setPressed(true) : null,
        onPointerUp: (_) => _setPressed(false),
        onPointerCancel: (_) => _setPressed(false),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: widget.onPressed,
          child: Container(
            height: AppSpacing.minimumAndroid,
            width: AppSpacing.minimumAndroid,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: widget.backgroundColor,
              borderRadius: BorderRadius.circular(AppRadius.xxxl),
            ),
            child: Icon(
              widget.icon,
              size: 24,
              color: widget.iconColor ?? scheme.onSurface,
              semanticLabel: widget.semanticLabel,
            ),
          )
              .animate(target: _pressed ? 1 : 0)
              .scaleXY(end: 0.9, duration: 100.ms)
              .tint(color: Colors.black, end: 0.15, duration: 100.ms),
        ),
      ),
    );
  }
}
