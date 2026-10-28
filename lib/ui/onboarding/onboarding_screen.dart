import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:itk_app/data/repositories/onboarding_repository.dart';
import 'package:itk_app/data/repositories/theme_repository.dart';
import 'package:itk_app/ui/core/theme/app_spacing.dart';
import 'package:itk_app/ui/core/theme/app_themes.dart';
import 'package:itk_app/ui/core/widgets/brand_button.dart';
import 'package:itk_app/ui/core/widgets/grouped_list.dart';
import 'package:itk_app/ui/onboarding/widgets/wiki_illustration.dart';
import 'package:itk_app/ui/onboarding/widgets/timetable_illustration.dart';
import 'package:itk_app/ui/onboarding/widgets/welcome_illustration.dart';
import 'package:provider/provider.dart';

class _OnboardingPage {
  final String title;
  final String body;
  final Widget illustration;

  const _OnboardingPage({
    required this.title,
    required this.body,
    required this.illustration,
  });
}

const _pages = <_OnboardingPage>[
  _OnboardingPage(
    illustration: WelcomeIllustration(),
    title: 'Üdv az ITK Appban!',
    body: 'Órarend, ZH-időpontok és a hallgatói wiki egy helyen.',
  ),
  _OnboardingPage(
    illustration: TimetableIllustration(),
    title: 'Naptár és ZH-k',
    body: 'Kövesd az óráidat és a közelgő számonkéréseket.',
  ),
  _OnboardingPage(
    illustration: WikiIllustration(),
    title: 'Hallgatói wiki',
    body: 'Böngészd a hallgatók oldalait, és oszd meg a sajátodat.',
  ),
];

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _page = 0;
  bool get _isLastPage => _page == 3;

  Future<void> _finish() async {
    await context.read<OnboardingRepository>().markSeenOnboarding();
    if (!mounted) return;
  }

  void _next() {
    if (_isLastPage) {
      unawaited(_finish());
    } else {
      _controller.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: _finish,
                child: const Text('Kihagyom'),
              ),
            ),
            Expanded(
              child: PageView(
                controller: _controller,
                onPageChanged: (i) => setState(() => _page = i),
                children: [
                  _buildInfoPage(_pages[0], context),
                  _buildInfoPage(_pages[1], context),
                  _buildInfoPage(_pages[2], context),
                  _buildSettingPage(context),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(4, (i) {
                final active = i == _page;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: active ? 20 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: active ? scheme.primary : scheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              }),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.xxl),
              child: SizedBox(
                width: double.infinity,
                child: BrandButton(
                  onTap: _next,
                  backgroundColor: itkPrimary,
                  child: Text(
                    _isLastPage ? 'Kezdjük!' : 'Tovább',
                    style: const TextStyle(
                      color: itkDark,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoPage(_OnboardingPage page, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xxl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          page.illustration,
          const SizedBox(height: AppSpacing.xxl),
          Text(
            page.title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            page.body,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }

  Widget _buildSettingPage(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final themeRepository = context.watch<ThemeRepository>();

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xxl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Hol legyen a gomb?',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: AppSpacing.lg),
          ValueListenableBuilder<bool>(
            valueListenable: context.watch<ThemeRepository>().actionButtonAsFab,
            builder: (context, asFab, _) {
              return Container(
                  height: 350,
                  width: 200,
                  padding: const EdgeInsets.all(AppSpacing.xs),
                  decoration: BoxDecoration(
                    color: scheme.surfaceContainer,
                    borderRadius: BorderRadius.circular(AppSpacing.xxl),
                    border: Border.all(color: scheme.outlineVariant, width: AppSpacing.sm),
                  ),
                  child: AnimatedAlign(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    alignment: Alignment(1, asFab ? 1 : -1),
                    child: Icon(
                      Icons.add_rounded,
                      size: AppSpacing.minimumIOS,
                      color: scheme.tertiary,
                    ).animate(target: asFab ? 0 : 1).scale(
                          begin: const Offset(1, 1),
                          end: const Offset(0.6, 0.6),
                          duration: 250.ms,
                          curve: Curves.easeOut,
                        ),
                  ));
            },
          ),
          const SizedBox(height: AppSpacing.lg),
          SettingsGroup(
            footer: 'Az új elem hozzáadása gomb a képernyő alján jelenik meg, egy kézzel könnyebben elérhető.',
            children: [
              SettingsTile(
                icon: Icons.add_rounded,
                iconColor: scheme.tertiary,
                title: 'Akció gombok lent',
                onTap: () => themeRepository.toggleActionButtonAsFab(!themeRepository.actionButtonAsFab.value),
                trailing: ValueListenableBuilder<bool>(
                  valueListenable: themeRepository.actionButtonAsFab,
                  builder: (context, asFab, _) => Switch.adaptive(
                    activeTrackColor: itkPrimary,
                    value: asFab,
                    onChanged: themeRepository.toggleActionButtonAsFab,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
