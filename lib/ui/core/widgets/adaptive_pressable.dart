import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:itk_app/ui/core/theme/app_radius.dart';

class AdaptivePressable extends StatefulWidget {
  const AdaptivePressable({
    super.key,
    required this.child,
    this.onTap,
    this.borderRadius = AppRadius.xxl,
  });

  final Widget child;
  final VoidCallback? onTap;
  final double borderRadius;

  @override
  State<AdaptivePressable> createState() => _AdaptivePressableState();
}

class _AdaptivePressableState extends State<AdaptivePressable> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final isIOS = Theme.of(context).platform == TargetPlatform.iOS;
    if (isIOS) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(widget.borderRadius),
        child: GestureDetector(
          onTap: widget.onTap,
          onTapDown: (_) => setState(() => _pressed = true),
          onTapCancel: () => setState(() => _pressed = false),
          onTapUp: (_) => setState(() => _pressed = false),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 100),
            color: _pressed
                ? CupertinoColors.systemGrey5.resolveFrom(context)
                : Colors.transparent,
            child: widget.child,
          ),
        ),
      );
    }

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(widget.borderRadius),
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(widget.borderRadius),
        child: widget.child,
      ),
    );
  }
}
