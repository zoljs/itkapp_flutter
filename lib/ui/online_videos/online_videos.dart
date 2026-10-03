import 'package:flutter/material.dart';

import 'package:itk_app/ui/core/theme/app_fonts.dart';
import 'package:itk_app/ui/core/theme/app_radius.dart';
import 'package:itk_app/ui/core/theme/app_spacing.dart';

class VideoCategory {
  const VideoCategory(this.label, this.icon);

  final String label;
  final IconData icon;
}

const _categories = [
  VideoCategory('Mind', Icons.apps_rounded),
  VideoCategory('Előadások', Icons.co_present_rounded),
  VideoCategory('Gyakorlatok', Icons.edit_note_rounded),
  VideoCategory('Konzultációk', Icons.forum_rounded),
  VideoCategory('Egyéb', Icons.more_horiz_rounded),
];

class OnlineVideos extends StatefulWidget {
  const OnlineVideos({super.key, this.title = 'Online videók'});

  final String title;

  @override
  State<OnlineVideos> createState() => _OnlineVideosState();
}

class _OnlineVideosState extends State<OnlineVideos> {
  @override
  Widget build(BuildContext context) {
    const categoryBarHeight = 56.0;
    int selected = 0;
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      backgroundColor: scheme.primaryContainer,
      body: SafeArea(
          bottom: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screenHorizontal,
                  1,
                  AppSpacing.screenHorizontal,
                  18,
                ),
                child: Text(widget.title,
                    style: textTheme.headlineSmall?.merge(topBarTitleStyle)),
              ),
              Expanded(
                  child: ColoredBox(
                      color: scheme.surface,
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: _CategoryContent(
                              category: _categories[selected],
                              topPadding: categoryBarHeight,
                            ),
                          ),
                          Positioned(
                            top: 0,
                            left: 0,
                            right: 0,
                            child: _CategoryBar(
                              height: categoryBarHeight,
                              selected: selected,
                              onSelected: (i) => setState(() => selected = i),
                            ),
                          )
                        ],
                      )))
            ],
          )),
    );
  }
}

class _CategoryBar extends StatelessWidget {
  const _CategoryBar({
    required this.height,
    required this.selected,
    required this.onSelected,
  });

  static const _fadeHeight = 16.0;

  final double height;
  final int selected;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final total = height + _fadeHeight;

    return Container(
      height: total,
      // Solid behind the chips, fading out below them so scrolled
      // content slides softly under the bar.
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [scheme.surface, scheme.surface.withValues(alpha: 0)],
          stops: [height / total, 1],
        ),
      ),
      alignment: Alignment.topCenter,
      child: SizedBox(
        height: height,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.screenHorizontal,
            vertical: 8,
          ),
          itemCount: _categories.length,
          separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
          itemBuilder: (context, i) {
            final category = _categories[i];
            final isSelected = i == selected;
            final fg = isSelected
                ? scheme.onPrimaryContainer
                : scheme.onSurfaceVariant;

            return ChoiceChip(
              avatar: Icon(category.icon, size: 18, color: fg),
              label: Text(category.label),
              selected: isSelected,
              showCheckmark: false,
              onSelected: (_) => onSelected(i),
              selectedColor: scheme.primaryContainer,
              backgroundColor: scheme.surfaceContainerHigh,
              side: BorderSide.none,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.lg),
              ),
              labelStyle: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: fg,
              ),
            );
          },
        ),
      ),
    );
  }
}

class _CategoryContent extends StatelessWidget {
  const _CategoryContent({required this.category, required this.topPadding});

  final VideoCategory category;
  final double topPadding;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.screenHorizontal,
        topPadding,
        AppSpacing.screenHorizontal,
        0,
      ),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: Center(
          key: ValueKey(category.label),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                category.icon,
                size: 56,
                color: scheme.onSurfaceVariant.withValues(alpha: 0.6),
              ),
              const SizedBox(height: 16),
              Text(
                category.label,
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: scheme.onSurface,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Ebben a kategóriában még nincsenek videók.',
                textAlign: TextAlign.center,
                style: textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
