import 'package:flutter/material.dart';
import 'package:itk_app/ui/core/theme/app_spacing.dart';
import 'package:itk_app/ui/core/widgets/state_message.dart';

class SliverStateMessage extends StatelessWidget {
  const SliverStateMessage({
    super.key,
    required this.icon,
    required this.message,
    this.onRetry,
  });

  final IconData icon;
  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return SliverFillRemaining(
      hasScrollBody: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.xxl,
          AppSpacing.xxl,
          AppSpacing.xxl,
          MediaQuery.paddingOf(context).bottom + AppSpacing.lg,
        ),
        child: StateMessage(
          icon: icon,
          message: message,
          onRetry: onRetry,
        ),
      ),
    );
  }
}
