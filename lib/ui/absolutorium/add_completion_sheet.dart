import 'package:flutter/material.dart';
import 'package:itk_app/data/repositories/absolutorium_repository.dart';
import 'package:itk_app/domain/models/absolutorium.dart';
import 'package:itk_app/ui/absolutorium/semester_picker_screen.dart';
import 'package:itk_app/ui/absolutorium/subject_search_screen.dart';
import 'package:itk_app/ui/absolutorium/viewmodels/add_completion_viewmodel.dart';
import 'package:itk_app/ui/absolutorium/widgets/grade_chip.dart';
import 'package:itk_app/ui/core/theme/app_spacing.dart';
import 'package:itk_app/ui/core/widgets/adaptive_sheet.dart';
import 'package:itk_app/ui/core/widgets/brand_appbar.dart';
import 'package:itk_app/ui/core/widgets/grouped_list.dart';
import 'package:itk_app/utils/context_extensions.dart';
import 'package:itk_app/utils/semester.dart';
import 'package:provider/provider.dart';

class AddCompletionSheet extends StatefulWidget {
  const AddCompletionSheet(
      {super.key, this.scrollController, this.initialSubject});

  final ScrollController? scrollController;
  final MissingSubject? initialSubject;

  @override
  State<AddCompletionSheet> createState() => _AddCompletionSheetState();
}

class _AddCompletionSheetState extends State<AddCompletionSheet> {
  final _nameController = TextEditingController();
  final _codeController = TextEditingController();
  late final AddCompletionViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = AddCompletionViewModel(
      repository: context.read<AbsolutoriumRepository>(),
      initialSubject: widget.initialSubject,
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  Future<void> _pickSubject() async {
    final picked = await Navigator.push<SubjectSearchResult>(
      context,
      MaterialPageRoute(
        builder: (_) => SubjectSearchScreen(
          selectedId: _viewModel.subject?.id,
          scrollController: widget.scrollController,
        ),
      ),
    );
    switch (picked) {
      case PickedSubject(:final subject):
        _viewModel.setSubject(subject);
      case AddAsCustom(:final name):
        _nameController.text = name;
        _viewModel.switchToCustomWithName(name);
      case null:
        break;
    }
  }

  Future<void> _pickSemester() async {
    final picked = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (_) => SemesterPickerScreen(
          selected: _viewModel.semester,
          scrollController: widget.scrollController,
        ),
      ),
    );
    if (picked != null) _viewModel.setSemester(picked);
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

  Widget _buildModeSwitch() {
    return SegmentedButton<bool>(
      showSelectedIcon: false,
      segments: const [
        ButtonSegment(
            value: false,
            icon: Icon(Icons.menu_book_rounded),
            label: Text('Tantervi tárgy')),
        ButtonSegment(
            value: true,
            icon: Icon(Icons.edit_note_rounded),
            label: Text('Saját tárgy')),
      ],
      selected: {_viewModel.custom},
      onSelectionChanged: (s) => _viewModel.setCustom(s.first),
    );
  }

  Widget _buildCurriculumSubject() {
    final subject = _viewModel.subject;
    return SettingsGroup(
      header: 'Tárgy',
      footer: subject == null
          ? 'Csak a saját tantervedben szereplő tárgyak között keresünk.'
          : '${subject.code} · ${subject.credits} kredit',
      children: [
        SettingsTile(
            title: subject?.name ?? 'Tárgy kiválasztása', onTap: _pickSubject),
      ],
    );
  }

  Widget _buildCustomSubject() {
    final scheme = Theme.of(context).colorScheme;
    const fieldDecoration = InputDecoration(
      border: InputBorder.none,
      enabledBorder: InputBorder.none,
      focusedBorder: InputBorder.none,
      filled: false,
      counterText: '',
    );

    return SettingsGroup(
      header: 'Saját tárgy',
      footer: 'Tantervben nem szereplő tárgy (pl. más karon felvett). '
          'Szabadon választhatóként számít bele az abszolutóriumba.',
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: TextField(
            controller: _nameController,
            maxLength: 120,
            textCapitalization: TextCapitalization.sentences,
            textInputAction: TextInputAction.next,
            onChanged: _viewModel.setCustomName,
            decoration: fieldDecoration.copyWith(hintText: 'Tárgy neve'),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: TextField(
            controller: _codeController,
            maxLength: 40,
            textCapitalization: TextCapitalization.characters,
            textInputAction: TextInputAction.done,
            onChanged: _viewModel.setCustomCode,
            decoration:
                fieldDecoration.copyWith(hintText: 'Tárgykód (nem kötelező)'),
          ),
        ),
        SettingsTile(
          title: 'Kredit',
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                tooltip: 'Kevesebb',
                icon: const Icon(Icons.remove_rounded),
                onPressed: _viewModel.customCredits > 0
                    ? () => _viewModel.changeCustomCredits(-1)
                    : null,
              ),
              SizedBox(
                width: 32,
                child: Text(
                  '${_viewModel.customCredits}',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: scheme.onSurface),
                ),
              ),
              IconButton(
                tooltip: 'Több',
                icon: const Icon(Icons.add_rounded),
                onPressed: _viewModel.customCredits <
                        AddCompletionViewModel.maxCustomCredits
                    ? () => _viewModel.changeCustomCredits(1)
                    : null,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildForm(BuildContext context) {
    return SingleChildScrollView(
      controller: widget.scrollController,
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, AppSpacing.xxxl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (!_viewModel.lockedToCurriculum) ...[
            _buildModeSwitch(),
            const SizedBox(height: AppSpacing.xxl),
          ],
          if (_viewModel.custom)
            _buildCustomSubject()
          else
            _buildCurriculumSubject(),
          SettingsGroup(
            header: 'Félév',
            children: [
              SettingsTile(
                  title: 'Félév',
                  value: semesterLabel(_viewModel.semester),
                  onTap: _pickSemester),
            ],
          ),
          SettingsGroup(
            header: 'Eredmény',
            footer:
                'Elégtelen (1) jegy nem számít bele a kreditekbe, de rögzítheted a nyilvántartásodhoz.',
            children: [
              Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: [
                    for (final g in _viewModel.gradeOptions)
                      GradeChip(
                          grade: g,
                          selected: g == _viewModel.grade,
                          onTap: () => _viewModel.setGrade(g)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([_viewModel, _viewModel.save]),
      builder: (context, _) => Scaffold(
        backgroundColor: sheetBackgroundColor(context),
        appBar: buildBrandAppBar(
          context: context,
          title: 'Teljesítés felvétele',
          closesSheet: true,
          onAction: _submit,
          actionEnabled: _viewModel.canSave && !_viewModel.save.running,
        ),
        body: _buildForm(context),
      ),
    );
  }
}

// class _GradeChip extends StatelessWidget {
//   const _GradeChip({required this.grade, required this.selected, required this.onTap});

//   final int? grade;
//   final bool selected;
//   final VoidCallback onTap;

//   @override
//   Widget build(BuildContext context) {
//     final scheme = Theme.of(context).colorScheme;
//     final isWide = grade == null;
//     final shape = RoundedSuperellipseBorder(borderRadius: BorderRadius.circular(AppRadius.lg));

//     return Semantics(
//       button: true,
//       selected: selected,
//       label: grade == null ? 'Aláírás' : 'Jegy: $grade',
//       child: Material(
//         color: selected ? itkPrimary : scheme.surfaceContainerHighest,
//         shape: shape,
//         child: InkWell(
//           customBorder: shape,
//           onTap: onTap,
//           child: SizedBox(
//             height: 48,
//             width: isWide ? 96 : 48,
//             child: Center(
//               child: Text(
//                 gradeLabel(grade),
//                 style: TextStyle(
//                   fontSize: isWide ? 14 : 18,
//                   fontWeight: FontWeight.w700,
//                   color: selected ? itkDark : scheme.onSurface,
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
