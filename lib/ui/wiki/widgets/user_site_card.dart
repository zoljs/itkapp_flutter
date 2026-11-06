import 'package:itk_app/ui/core/theme/app_radius.dart';
import 'package:itk_app/ui/core/theme/app_spacing.dart';
import 'package:flutter/material.dart';

class UserSiteCard extends StatefulWidget {
  final Color color;
  final Widget child;
  final double? height;
  final VoidCallback? onTap;

  const UserSiteCard({
    super.key,
    required this.color,
    required this.child,
    this.height,
    this.onTap,
  });

  @override
  State<UserSiteCard> createState() => _UserSiteCardState();
}

class _UserSiteCardState extends State<UserSiteCard> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed != value) setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    // AnimatedScale (ticker) instead of flutter_animate: its start timer
    // stays pending in widget tests that only pump once.
    return AnimatedScale(
      scale: _pressed ? 0.95 : 1,
      duration: const Duration(milliseconds: 400),
      curve: _pressed ? Curves.easeOutBack : Curves.easeInBack,
      child: SizedBox(
      height: widget.height,
      child: Material(
        color: widget.color,
        shape: RoundedSuperellipseBorder(
          borderRadius: BorderRadius.circular(AppRadius.xxl),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onHighlightChanged: _setPressed,
          highlightColor: Colors.white38,
          onTap: widget.onTap,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.screenHorizontal),
            child: widget.child,
          ),
        ),
      ),
      ),
    );
  }
}
