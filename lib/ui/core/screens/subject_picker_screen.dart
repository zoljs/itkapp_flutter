import 'package:flutter/material.dart';
import 'package:itk_app/data/repositories/subjects_repository.dart';
import 'package:itk_app/domain/models/subject.dart';
import 'package:itk_app/ui/core/screens/picker_screen.dart';
import 'package:itk_app/ui/core/widgets/picker_tile.dart';
import 'package:itk_app/ui/core/screens/viewmodels/subject_picker_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:skeletonizer/skeletonizer.dart';

class SubjectPickerScreen extends StatefulWidget {
  final int? selectedId;
  final ScrollController? scrollController;

  const SubjectPickerScreen({
    super.key,
    this.selectedId,
    this.scrollController,
  });

  @override
  State<SubjectPickerScreen> createState() => _SubjectPickerScreenState();
}

class _SubjectPickerScreenState extends State<SubjectPickerScreen> {
  late final SubjectPickerViewModel _viewModel;

  static final _skeletonSubjects = List.generate(
    10,
    (i) => Subject(id: -i, code: BoneMock.chars(8), name: BoneMock.words(3)),
  );

  @override
  void initState() {
    super.initState();
    _viewModel =
        SubjectPickerViewModel(repository: context.read<SubjectsRepository>());
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return PickerScreen<Subject>(
      viewModel: _viewModel,
      scrollController: widget.scrollController,
      title: 'Tárgy',
      hintText: 'Tárgy neve vagy kódja...',
      skeletonItems: _skeletonSubjects,
      tileBuilder: (context, subject) {
        return PickerTile(
          title: subject.name,
          subtitle: subject.code,
          onTap: () => Navigator.pop(context, subject),
          trailing: subject.id == widget.selectedId
              ? Icon(Icons.check_rounded, color: scheme.primary)
              : null,
        );
      },
      closesSheet: false,
    );
  }
}
