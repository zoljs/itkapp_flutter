import 'package:flutter/material.dart';
import 'package:itk_app/data/repositories/absolutorium_repository.dart';
import 'package:itk_app/ui/absolutorium/viewmodels/curriculum_viewmodel.dart';
import 'package:itk_app/ui/core/theme/app_spacing.dart';
import 'package:itk_app/ui/core/widgets/adaptive_sheet.dart';
import 'package:itk_app/ui/core/widgets/app_spinner.dart';
import 'package:itk_app/ui/core/widgets/brand_appbar.dart';
import 'package:itk_app/ui/core/widgets/grouped_list.dart';
import 'package:itk_app/ui/core/widgets/state_message.dart';
import 'package:itk_app/utils/context_extensions.dart';
import 'package:provider/provider.dart';

class CurriculumSheet extends StatefulWidget {
  const CurriculumSheet({
    super.key,
    this.scrollController,
    this.initialCurriculumId,
    this.initialSpecializationId,
  });

  final ScrollController? scrollController;
  final int? initialCurriculumId;
  final int? initialSpecializationId;

  @override
  State<CurriculumSheet> createState() => _CurriculumSheetState();
}

class _CurriculumSheetState extends State<CurriculumSheet> {
  late final CurriculumViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = CurriculumViewModel(
      repository: context.read<AbsolutoriumRepository>(),
      initialCurriculumId: widget.initialCurriculumId,
      initialSpecializationId: widget.initialSpecializationId,
    );
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    await _viewModel.save.execute();
    if (!mounted) return;

    if (_viewModel.save.completed) {
      closeSheet(context);
    } else if (_viewModel.save.errorMessage case final message?) {
      context.showMessage(message);
    }
  }

  Widget _check(bool selected) {
    final scheme = Theme.of(context).colorScheme;
    return SizedBox(
      width: 24,
      child: selected ? Icon(Icons.check_rounded, color: scheme.primary) : const SizedBox.shrink(),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (_viewModel.load.running) {
      return const Center(child: AppSpinner());
    }
    if (_viewModel.load.errorMessage case final message?) {
      return StateMessage(icon: Icons.cloud_off_rounded, message: message, onRetry: _viewModel.load.execute);
    }
    if (_viewModel.curricula.isEmpty) {
      return const StateMessage(
        icon: Icons.school_outlined,
        message: 'Még nincs feltöltött tanterv.\nSzólj egy adminnak!',
      );
    }

    final selected = _viewModel.selected;

    return ListView(
      controller: widget.scrollController,
      padding: EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg,
        MediaQuery.paddingOf(context).bottom + AppSpacing.xxxl,
      ),
      children: [
        for (final entry in _viewModel.byMajor.entries)
          SettingsGroup(
            header: entry.key,
            children: [
              for (final c in entry.value)
                SettingsTile(
                  title: c.name,
                  value: '${c.totalCreditsRequired} kr',
                  trailing: _check(c.id == _viewModel.curriculumId),
                  onTap: () => _viewModel.selectCurriculum(c.id),
                ),
            ],
          ),
        if (selected != null && selected.specializations.isNotEmpty)
          SettingsGroup(
            header: 'Specializáció',
            footer: 'Később is megadhatod. Amíg nincs kiválasztva, az abszolutórium nem lehet teljes.',
            children: [
              SettingsTile(
                title: 'Még nem választottam',
                trailing: _check(_viewModel.specializationId == null),
                onTap: () => _viewModel.selectSpecialization(null),
              ),
              for (final s in selected.specializations)
                SettingsTile(
                  title: s.name,
                  trailing: _check(s.id == _viewModel.specializationId),
                  onTap: () => _viewModel.selectSpecialization(s.id),
                ),
            ],
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([_viewModel, _viewModel.load, _viewModel.save]),
      builder: (context, _) => Scaffold(
        backgroundColor: sheetBackgroundColor(context),
        appBar: buildBrandAppBar(
          context: context,
          title: 'Tanterv',
          closesSheet: true,
          onAction: _submit,
          actionEnabled: _viewModel.canSave && !_viewModel.save.running,
        ),
        body: _buildBody(context),
      ),
    );
  }
}
