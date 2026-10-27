import 'package:flutter/material.dart';
import 'package:itk_app/ui/core/theme/app_radius.dart';
import 'package:itk_app/ui/core/theme/app_spacing.dart';

class SettingsGroup extends StatelessWidget {
  const SettingsGroup(
      {super.key, this.header, this.footer, required this.children});

  final String? header;
  final String? footer;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final muted = TextStyle(fontSize: 13, color: scheme.onSurfaceVariant);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xxl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (header != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.sm),
              child: Text(header!, style: muted.copyWith(letterSpacing: 0.4)),
            ),
          ClipRSuperellipse(
            borderRadius: BorderRadius.circular(AppRadius.xxl),
            child: Material(
              color: scheme.surfaceContainerHigh,
              child: Column(
                children: [
                  for (var i = 0; i < children.length; i++) ...[
                    if (i > 0)
                      Divider(
                        height: 1,
                        indent: 60,
                        color: scheme.outlineVariant.withValues(alpha: 0.5),
                      ),
                    children[i],
                  ],
                ],
              ),
            ),
          ),
          if (footer != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg, AppSpacing.sm, AppSpacing.lg, 0),
              child: Text(footer!, style: muted),
            ),
        ],
      ),
    );
  }
}

class SettingsTile extends StatelessWidget {
  const SettingsTile({
    super.key,
    this.icon,
    this.iconColor,
    required this.title,
    this.value,
    this.trailing,
    this.onTap,
    this.external = false,
  });

  final IconData? icon;
  final Color? iconColor;
  final String title;
  final String? value;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool external;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 52),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Row(
            children: [
              if (icon != null) ...[
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: iconColor,
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: Icon(icon, size: 18, color: Colors.white),
                ),
                const SizedBox(width: AppSpacing.md + 2),
              ],
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(fontSize: 15, color: scheme.onSurface),
                ),
              ),
              if (value != null)
                Flexible(
                  fit: FlexFit.tight,
                  child: Text(
                    value!,
                    textAlign: TextAlign.end,
                    overflow: TextOverflow.ellipsis,
                    style:
                        TextStyle(fontSize: 15, color: scheme.onSurfaceVariant),
                  ),
                ),
              if (trailing != null) trailing!,
              if (onTap != null && trailing == null) ...[
                const SizedBox(width: AppSpacing.xs),
                Icon(
                  external
                      ? Icons.open_in_new_rounded
                      : Icons.chevron_right_rounded,
                  size: external ? 18 : 22,
                  color: scheme.outline,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
