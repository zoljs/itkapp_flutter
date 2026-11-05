import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:itk_app/ui/core/theme/app_spacing.dart';
import 'package:itk_app/ui/core/theme/app_themes.dart';
import 'package:itk_app/ui/core/widgets/circles_painter.dart';
import 'package:itk_app/ui/events/widgets/weekstrip.dart';

class EventsHeaderBackground extends StatelessWidget {
  const EventsHeaderBackground({
    super.key,
    required this.bottomInset,
  });

  String get _todayLabel {
    final n = DateTime.now();
    return '${toBeginningOfSentenceCase(DateFormat('EEEE', 'hu').format(n))}, ${DateFormat('MMM d.', 'hu').format(n)}';
  }

  final double bottomInset;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Stack(
      fit: StackFit.expand,
      children: [
        Padding(
          padding: EdgeInsets.only(bottom: bottomInset),
          child: ColoredBox(color: scheme.primaryContainer),
        ),
        Padding(
          padding: EdgeInsets.only(bottom: bottomInset),
          child: ClipRect(
            child: CustomPaint(
              painter: CirclesPainter([
                scheme.secondary.withValues(alpha: 0.55),
                itkDark.withValues(alpha: 0.44),
                itkPrimary.withValues(alpha: 0.66),
              ]),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(
            AppSpacing.lg,
            0,
            AppSpacing.lg,
            bottomInset + AppSpacing.screenHorizontal,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _todayLabel,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: scheme.onPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              const WeekStrip(),
            ],
          ),
        ),
      ],
    );
  }
}
