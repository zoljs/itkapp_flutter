import 'package:flutter/material.dart';
import 'package:itk_app/ui/core/widgets/press_feedback.dart';
import 'package:itk_app/ui/core/theme/app_radius.dart';

class BrandButton extends StatefulWidget {
  const BrandButton({
    super.key,
    required this.onTap,
    required this.child,
    required this.backgroundColor,
    this.height = 48,
  });

  final VoidCallback? onTap;
  final Widget child;
  final Color backgroundColor;
  final double? height;

  @override
  State<BrandButton> createState() => _BrandButtonState();
}

class _BrandButtonState extends State<BrandButton> {
  bool _pressed = false;

  bool get _enabled => widget.onTap != null;

  void _setPressed(bool value) {
    if (_pressed != value) setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      enabled: _enabled,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onTap,
        onTapDown: (_) => _enabled ? _setPressed(true) : null,
        onTapUp: (_) => _setPressed(false),
        onTapCancel: () => _setPressed(false),
        child: PressFeedback(
          pressed: _pressed,
          child: Container(
            height: widget.height,
            alignment: Alignment.center,
            decoration: ShapeDecoration(
              color: widget.backgroundColor,
              shape: RoundedSuperellipseBorder(
                  borderRadius: BorderRadius.circular(AppRadius.xxl)),
            ),
            child: widget.child,
          ),
        ),
      ),
    );
  }
}
