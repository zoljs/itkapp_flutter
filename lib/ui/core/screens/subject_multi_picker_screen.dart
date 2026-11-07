import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:itk_app/data/repositories/subjects_repository.dart';
import 'package:itk_app/domain/models/subject.dart';
import 'package:itk_app/ui/core/screens/picker_screen.dart';
import 'package:itk_app/ui/core/widgets/adaptive_sheet.dart';
import 'package:itk_app/ui/core/widgets/picker_tile.dart';
import 'package:itk_app/ui/core/screens/viewmodels/subject_multi_picker_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:skeletonizer/skeletonizer.dart';

class SubjectMultiPickerScreen extends StatefulWidget {
  final List<String> currentTags;
  final ValueChanged<List<String>> onSave;
  final ScrollController? scrollController;

  const SubjectMultiPickerScreen({
    super.key,
    required this.currentTags,
    required this.onSave,
    this.scrollController,
  });

  @override
  State<SubjectMultiPickerScreen> createState() =>
      _SubjectMultiPickerScreenState();
}

class _SubjectMultiPickerScreenState extends State<SubjectMultiPickerScreen> {
  late final SubjectMultiPickerViewModel _viewModel;

  static final _skeletonSubjects = List.generate(
    10,
    (i) => Subject(id: -i, code: BoneMock.chars(8), name: BoneMock.words(3)),
  );

  @override
  void initState() {
    super.initState();
    _viewModel = SubjectMultiPickerViewModel(
        repository: context.read<SubjectsRepository>(),
        initialSubjects: widget.currentTags);
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  void _save() {
    widget.onSave(_viewModel.selectedSubjects.toList());
    closeSheet(context);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return PickerScreen<Subject>(
      viewModel: _viewModel,
      scrollController: widget.scrollController,
      title: 'Címkék',
      hintText: 'Tárgy neve vagy kódja...',
      onAction: _save,
      skeletonItems: _skeletonSubjects,
      tileBuilder: (context, subject) {
        final selected = _viewModel.selectedSubjects.contains(subject.name);
        return PickerTile(
          title: subject.name,
          subtitle: subject.code,
          onTap: () => _viewModel.toggleSubject(subject.name),
          trailing: Icon(
            selected
                ? CupertinoIcons.checkmark_circle_fill
                : CupertinoIcons.circle,
            color: selected ? scheme.primary : scheme.outline,
            size: 24,
          ),
        );
      },
      closesSheet: true,
    );
  }
}
