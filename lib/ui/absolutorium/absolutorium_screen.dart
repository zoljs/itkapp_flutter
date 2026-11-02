import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:itk_app/data/repositories/absolutorium_repository.dart';
import 'package:itk_app/data/repositories/theme_repository.dart';
import 'package:itk_app/domain/models/absolutorium.dart';
import 'package:itk_app/routing/routes.dart';
import 'package:itk_app/ui/absolutorium/add_completion_sheet.dart';
import 'package:itk_app/ui/absolutorium/curriculum_sheet.dart';
import 'package:itk_app/ui/absolutorium/viewmodels/absolutorium_viewmodel.dart';
import 'package:itk_app/ui/absolutorium/widgets/completion_dismissible.dart';
import 'package:itk_app/ui/absolutorium/widgets/progress_widgets.dart';
import 'package:itk_app/ui/absolutorium/widgets/summary_widgets.dart';
import 'package:itk_app/ui/absolutorium/diploma_sheet.dart';
import 'package:itk_app/ui/absolutorium/widgets/averages_widgets.dart';
import 'package:itk_app/ui/core/theme/app_spacing.dart';
import 'package:itk_app/ui/core/theme/app_themes.dart';
import 'package:itk_app/ui/core/widgets/adaptive_sheet.dart';
import 'package:itk_app/ui/core/widgets/app_spinner.dart';
import 'package:itk_app/ui/core/widgets/brand_appbar.dart';
import 'package:itk_app/ui/core/widgets/circles_painter.dart';
import 'package:itk_app/ui/core/widgets/grouped_list.dart';
import 'package:itk_app/ui/core/widgets/state_message.dart';
import 'package:itk_app/utils/context_extensions.dart';
import 'package:provider/provider.dart';

class AbsolutoriumScreen extends StatefulWidget {
  const AbsolutoriumScreen({super.key});

  @override
  State<AbsolutoriumScreen> createState() => _AbsolutoriumScreenState();
}

class _AbsolutoriumScreenState extends State<AbsolutoriumScreen> {
  late final AbsolutoriumViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = AbsolutoriumViewModel(repository: context.read<AbsolutoriumRepository>());
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  Future<void> _openCurriculum() async {
    final p = _viewModel.progress;
    await showAdaptiveSheet<void>(
      context: context,
      builder: (context, controller) => CurriculumSheet(
        scrollController: controller,
        initialCurriculumId: p?.curriculum.id,
        initialSpecializationId: p?.chosenSpecializationId,
      ),
    );
  }

  Future<void> _openDiploma() async {
    await showAdaptiveSheet<void>(
      context: context,
      builder: (context, controller) => DiplomaSheet(scrollController: controller),
    );
  }

  Future<void> _openAdd() async {
    await showAdaptiveSheet<void>(
      context: context,
      builder: (context, controller) => AddCompletionSheet(scrollController: controller),
    );
  }

  Future<void> _delete(int completionId) async {
    await _viewModel.delete.execute(completionId);
    if (!mounted) return;
    if (_viewModel.delete.errorMessage case final message?) context.showMessage(message);
  }

  Widget _buildHeader(BuildContext context, {required bool asFab}) {
    final scheme = Theme.of(context).colorScheme;
    final p = _viewModel.progress;

    return SliverAppBar(
      pinned: true,
      stretch: true,
      expandedHeight: p != null ? 280 : 180,
      collapsedHeight: AppSpacing.toolbarHeight,
      backgroundColor: scheme.surface,
      scrolledUnderElevation: 0,
      title: const Text('Abszolutórium'),
      leading: buildBrandLeading(context),
      leadingWidth: AppSpacing.minimumAndroid + 2 * AppSpacing.sm,
      actionsPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
      actions: [
        if (p != null && !asFab) buildBrandAction(actionIcon: Icons.add_rounded, label: 'Teljesítés felvétele', onAction: _openAdd),
      ],
      flexibleSpace: FlexibleSpaceBar(
        stretchModes: const [StretchMode.zoomBackground],
        background: RepaintBoundary(
          child: Stack(
            fit: StackFit.expand,
            children: [
              ColoredBox(color: scheme.primaryContainer),
              CustomPaint(
                painter: CirclesPainter([
                  scheme.secondary.withValues(alpha: 0.55),
                  itkDark.withValues(alpha: 0.44),
                  itkPrimary.withValues(alpha: 0.66),
                ]),
              ),
              if (p != null)
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.xl,
                      AppSpacing.toolbarHeight,
                      AppSpacing.xl,
                      AppSpacing.xl,
                    ),
                    child: Align(alignment: Alignment.bottomLeft, child: HeaderSummary(progress: p)),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildContent(BuildContext context) {
    final p = _viewModel.progress;

    if (_viewModel.initialLoading) {
      return const [
        SliverFillRemaining(hasScrollBody: false, child: Center(child: AppSpinner())),
      ];
    }
    if (p == null && _viewModel.load.errorMessage != null) {
      return [
        SliverFillRemaining(
          hasScrollBody: false,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xxl),
            child: StateMessage(
              icon: Icons.cloud_off_rounded,
              message: _viewModel.load.errorMessage!,
              onRetry: () => _viewModel.load.execute(true),
            ),
          ),
        ),
      ];
    }
    if (p == null) {
      return [
        SliverFillRemaining(hasScrollBody: false, child: NoCurriculumView(onChoose: _openCurriculum)),
      ];
    }

    final scheme = Theme.of(context).colorScheme;
    final uncategorized = _viewModel.uncategorized;

    return [
      SliverPadding(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.screenHorizontal,
          AppSpacing.lg,
          AppSpacing.screenHorizontal,
          MediaQuery.paddingOf(context).bottom + 120,
        ),
        sliver: SliverList.list(
          children: [
            if (p.isComplete)
              const InfoBanner(
                icon: Icons.celebration_rounded,
                color: kCompleteColor,
                title: 'Minden feltétel teljesítve!',
                message: 'A felvitt adatok alapján megvan az abszolutórium.',
              )
            else if (p.needsSpecialization)
              InfoBanner(
                icon: Icons.alt_route_rounded,
                color: scheme.tertiary,
                title: 'Válassz specializációt',
                message: 'Amíg nincs kiválasztva, a specializáció tárgyai nem számítanak bele.',
                onTap: _openCurriculum,
              ),
            TypeTotalsRow(byType: p.byType),
            const SizedBox(height: AppSpacing.xxl),
            AveragesCard(
              averages: _viewModel.averages,
              diploma: _viewModel.diploma,
              onOpenDiploma: _openDiploma,
              onOpenCompletions: () => context.push(Routes.absolutoriumCompletions),
            ),
            SettingsGroup(
              header: 'Mintatanterv csoportok',
              children: [
                for (final g in p.groups) GroupTile(group: g, onTap: () => context.push(Routes.absolutoriumGroupFor(g.id))),
              ],
            ),
            if (uncategorized.isNotEmpty)
              SettingsGroup(
                header: 'Nem besorolt tárgyak',
                footer: 'Ezek a teljesítések egyik tárgycsoportba sem illeszthetők, de a kreditösszegbe '
                    'beleszámítanak. Törléshez húzd balra a sort.',
                children: [
                  for (final c in uncategorized)
                    CompletionDismissible(
                      completionId: c.completionId,
                      name: c.name,
                      semester: c.semester,
                      onDelete: _delete,
                      child: SubjectRow(
                        name: c.name,
                        code: c.code,
                        credits: c.credits,
                        done: true,
                        subtitle: gradeLabel(c.grade),
                      ),
                    ),
                ],
              ),
            SettingsGroup(
              header: 'Nyilvántartás',
              children: [
                SettingsTile(
                  icon: Icons.fact_check_rounded,
                  iconColor: itkPrimary,
                  title: 'Összes teljesítés',
                  onTap: () => context.push(Routes.absolutoriumCompletions),
                ),
                SettingsTile(
                  icon: Icons.school_rounded,
                  iconColor: scheme.tertiary,
                  title: 'Tanterv',
                  value: [p.curriculum.code, if (p.chosenSpecialization != null) p.chosenSpecialization!.name].join(' · '),
                  onTap: _openCurriculum,
                ),
              ],
            ),
          ],
        ),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: context.watch<ThemeRepository>().actionButtonAsFab,
      builder: (context, asFab, _) => ListenableBuilder(
        listenable: Listenable.merge([_viewModel, _viewModel.load]),
        builder: (context, _) => Scaffold(
          body: RefreshIndicator.adaptive(
            onRefresh: () => _viewModel.load.execute(true),
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
              slivers: [
                _buildHeader(context, asFab: asFab),
                ..._buildContent(context),
              ],
            ),
          ),
          floatingActionButton: _viewModel.progress != null && asFab ? buildBrandFab(icon: Icons.add_rounded, semanticLabel: 'Teljesítés felvétele', onPressed: _openAdd) : null,
        ),
      ),
    );
  }
}
