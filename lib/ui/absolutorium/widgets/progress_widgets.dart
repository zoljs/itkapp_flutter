import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:itk_app/domain/models/absolutorium.dart';
import 'package:itk_app/ui/core/theme/app_radius.dart';
import 'package:itk_app/ui/core/theme/app_spacing.dart';
import 'package:itk_app/ui/core/theme/app_themes.dart';

class CreditRing extends StatelessWidget {
  const CreditRing({
    super.key,
    required this.value,
    required this.size,
    required this.trackColor,
    required this.color,
    this.strokeWidth = 12,
    this.child,
  });

  final double value;
  final double size;
  final Color trackColor;
  final Color color;
  final double strokeWidth;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 0, end: value.clamp(0.0, 1.0)),
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeOutCubic,
        builder: (context, v, child) => SizedBox.square(
          dimension: size,
          child: CustomPaint(
            painter: _RingPainter(
              value: v,
              trackColor: trackColor,
              color: color,
              strokeWidth: strokeWidth,
            ),
            child: Center(child: child),
          ),
        ),
        child: child,
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({
    required this.value,
    required this.trackColor,
    required this.color,
    required this.strokeWidth,
  });

  final double value;
  final Color trackColor;
  final Color color;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final arcRect = rect.deflate(strokeWidth / 2);
    final track = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    final fill = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = strokeWidth;

    canvas.drawArc(arcRect, 0, math.pi * 2, false, track);
    if (value > 0) {
      canvas.drawArc(arcRect, -math.pi / 2, math.pi * 2 * value, false, fill);
    }
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.value != value ||
      old.color != color ||
      old.trackColor != trackColor ||
      old.strokeWidth != strokeWidth;
}

class CreditBar extends StatelessWidget {
  const CreditBar({
    super.key,
    required this.value,
    required this.max,
    this.complete = false,
    this.height = 8,
  });

  final int value;
  final int max;
  final bool complete;
  final double height;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final ratio =
        max <= 0 ? (complete ? 1.0 : 0.0) : (value / max).clamp(0.0, 1.0);

    return SizedBox(
      height: height,
      width: double.infinity,
      child: CustomPaint(
        painter: _BarPainter(
          ratio: ratio,
          trackColor: scheme.surfaceContainerHighest,
          color: complete ? kCompleteColor : itkPrimary,
        ),
      ),
    );
  }
}

class _BarPainter extends CustomPainter {
  _BarPainter({
    required this.ratio,
    required this.trackColor,
    required this.color,
  });

  final double ratio;
  final Color trackColor;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final radius = Radius.circular(size.height / 2);
    canvas.drawRRect(
      RRect.fromRectAndRadius(Offset.zero & size, radius),
      Paint()..color = trackColor,
    );
    if (ratio <= 0) return;
    final minWidth = math.min(size.height, size.width);
    final width = math.max(size.width * ratio, minWidth);
    canvas.drawRRect(
      RRect.fromRectAndRadius(Offset.zero & Size(width, size.height), radius),
      Paint()..color = color,
    );
  }

  @override
  bool shouldRepaint(_BarPainter old) =>
      old.ratio != ratio || old.color != color || old.trackColor != trackColor;
}

const kCompleteColor = Color(0xFF4ADE80);

class TypeBadge extends StatelessWidget {
  const TypeBadge({super.key, required this.type});

  final SubgroupType type;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final (bg, fg) = switch (type) {
      SubgroupType.mandatory => (
          scheme.primaryContainer,
          scheme.onPrimaryContainer
        ),
      SubgroupType.elective => (
          scheme.secondaryContainer,
          scheme.onSecondaryContainer
        ),
      SubgroupType.freeElective => (
          scheme.tertiaryContainer,
          scheme.onTertiaryContainer
        ),
    };
    return _Pill(label: type.label, background: bg, foreground: fg);
  }
}

class DoneBadge extends StatelessWidget {
  const DoneBadge({super.key});

  @override
  Widget build(BuildContext context) {
    const c = kCompleteColor;
    return _Pill(
      label: 'Kész',
      icon: Icons.check_rounded,
      background: c.withValues(alpha: 0.16),
      foreground: c,
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({
    required this.label,
    required this.background,
    required this.foreground,
    this.icon,
  });

  final String label;
  final Color background;
  final Color foreground;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm, vertical: AppSpacing.xxs),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: foreground),
            const SizedBox(width: AppSpacing.xxs),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: foreground,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}

class SubjectRow extends StatelessWidget {
  const SubjectRow({
    super.key,
    required this.name,
    this.code,
    required this.credits,
    this.subtitle,
    this.trailing,
    this.done = false,
    this.onTap,
  });

  final String name;

  final String? code;
  final int credits;
  final String? subtitle;
  final Widget? trailing;
  final bool done;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final muted = TextStyle(fontSize: 12, color: scheme.onSurfaceVariant);

    return InkWell(
      onTap: onTap,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 60),
        child: Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
          child: Row(
            children: [
              Icon(
                done
                    ? Icons.check_circle_rounded
                    : Icons.radio_button_unchecked_rounded,
                size: 22,
                color: done ? kCompleteColor : scheme.outline,
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: TextStyle(fontSize: 15, color: scheme.onSurface),
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      [code ?? 'saját tárgy', if (subtitle != null) subtitle!]
                          .join(' · '),
                      style: muted,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                '$credits kr',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: scheme.onSurfaceVariant,
                ),
              ),
              if (trailing != null) ...[
                const SizedBox(width: AppSpacing.xs),
                trailing!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}
