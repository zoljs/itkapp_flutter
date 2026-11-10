import 'package:flutter/material.dart';
import 'package:itk_app/ui/core/theme/app_fonts.dart';
import 'package:itk_app/ui/core/theme/app_spacing.dart';
import 'package:itk_app/ui/core/widgets/adaptive_segmented_control.dart';
import 'package:itk_app/ui/core/widgets/app_pressable.dart';
import 'package:itk_app/ui/core/widgets/brand_appbar.dart';
import 'package:itk_app/ui/phonetics/viewmodels/phonetics_viewmodel.dart';
import 'package:itk_app/ui/phonetics/widgets/consonant_chart.dart';
import 'package:itk_app/ui/phonetics/widgets/phoneme_details.dart';
import 'package:itk_app/ui/phonetics/widgets/vowel_chart.dart';

/// Explains the sounds of Hungarian with IPA: a vowel chart and a consonant
/// chart, and the details of the tapped sound.
class PhoneticsScreen extends StatefulWidget {
  const PhoneticsScreen({super.key});

  @override
  State<PhoneticsScreen> createState() => _PhoneticsScreenState();
}

class _PhoneticsScreenState extends State<PhoneticsScreen> {
  final _viewModel = PhoneticsViewModel();

  static const _maxContentWidth = 480.0;

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final muted = TextStyle(fontSize: 13, color: scheme.onSurfaceVariant);

    return Scaffold(
      appBar: buildBrandAppBar(context: context, title: 'Magyar hangok'),
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: _maxContentWidth),
          child: ListenableBuilder(
            listenable: _viewModel,
            builder: (context, _) {
              final chart = _viewModel.chart;

              return ListView(
                padding: EdgeInsets.fromLTRB(
                  AppSpacing.screenHorizontal,
                  AppSpacing.sm,
                  AppSpacing.screenHorizontal,
                  AppSpacing.xxxl + MediaQuery.paddingOf(context).bottom,
                ),
                children: [
                  AdaptiveSegmentedControl<PhoneticsChart>(
                    values: PhoneticsChart.values,
                    selected: chart,
                    onChanged: _viewModel.setChart,
                    labelOf: (value) => value.label,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  switch (chart) {
                    PhoneticsChart.vowels => Text.rich(
                        TextSpan(
                          children: [
                            const TextSpan(
                              text: 'Függőlegesen a nyelvállás (zárt - nyílt), '
                                  'vízszintesen a képzés helye (elöl - hátul). '
                                  'A pont bal oldalán ajakréses, jobb oldalán '
                                  'ajakkerekítéses hang áll. A ',
                            ),
                            TextSpan(text: 'ː', style: ipaStyle),
                            const TextSpan(text: ' jel hosszú hangot jelöl.'),
                          ],
                        ),
                        style: muted,
                      ),
                    PhoneticsChart.consonants => Text(
                        'Az oszlop a képzés helyét, a sor a képzés módját '
                        'mutatja. Egy cellán belül balra a zöngétlen, jobbra '
                        'a zöngés hang áll.',
                        style: muted,
                      ),
                  },
                  const SizedBox(height: AppSpacing.lg),
                  AnimatedSwitcher(
                    duration: MediaQuery.disableAnimationsOf(context)
                        ? Duration.zero
                        : AppPressable.duration,
                    child: switch (chart) {
                      PhoneticsChart.vowels => VowelChart(
                          key: const ValueKey(PhoneticsChart.vowels),
                          selected: _viewModel.selected,
                          onSelect: _viewModel.select,
                        ),
                      PhoneticsChart.consonants => ConsonantChart(
                          key: const ValueKey(PhoneticsChart.consonants),
                          selected: _viewModel.selected,
                          onSelect: _viewModel.select,
                        ),
                    },
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  PhonemeDetails(phonemes: _viewModel.selected),
                  Text(
                    switch (chart) {
                      PhoneticsChart.vowels =>
                        'Fonémikus ábra a szokásos IPA-átírással '
                            '(Szende 1994).',
                      PhoneticsChart.consonants =>
                        'Fonémikus ábra a szokásos IPA-átírással '
                            '(Szende 1994). A ty és a gy hangot zárhangként '
                            'jelöljük, egyes leírások zár-réshangnak tekintik.',
                    },
                    style: muted,
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
