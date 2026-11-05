import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:itk_app/data/repositories/subjects_repository.dart';
import 'package:itk_app/domain/models/subject.dart';
import 'package:itk_app/ui/core/theme/app_spacing.dart';
import 'package:itk_app/ui/core/widgets/adaptive_sheet.dart';
import 'package:itk_app/ui/core/widgets/brand_appbar.dart';
import 'package:itk_app/ui/core/widgets/picker_search_field.dart';
import 'package:itk_app/ui/core/widgets/state_message.dart';
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
  final _searchController = TextEditingController();
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
    _searchController.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  void _save() {
    widget.onSave(_viewModel.selectedSubjects.toList());
    closeSheet(context);
  }

  Widget _buildList(BuildContext context) {
    final loading = _viewModel.load.running;
    final subjects = loading ? _skeletonSubjects : _viewModel.filteredSubjects;

    if (_viewModel.load.errorMessage != null) {
      return StateMessage(
        icon: Icons.cloud_off_rounded,
        message: _viewModel.load.errorMessage!,
        onRetry: _viewModel.load.execute,
      );
    }

    return Skeletonizer(
      enabled: loading,
      child: ListView.separated(
        controller: widget.scrollController,
        padding: EdgeInsets.only(
          bottom: MediaQuery.paddingOf(context).bottom + 80,
        ),
        itemCount: subjects.length,
        itemBuilder: (context, index) {
          final subject = subjects[index];
          return _buildSubjectRow(
            context,
            subjects[index],
            _viewModel.selectedSubjects.contains(subject.name),
          );
        },
        separatorBuilder: (context, index) => const Divider(height: 1),
      ),
    );
  }

  Widget _buildSubjectRow(
      BuildContext context, Subject subject, bool selected) {
    final scheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: () => _viewModel.toggleSubject(subject.name),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.screenHorizontal,
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 64.0),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      subject.name,
                      style: TextStyle(fontSize: 15, color: scheme.onSurface),
                    ),
                    Text(
                      subject.code,
                      style: TextStyle(
                        fontSize: 13,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                selected
                    ? CupertinoIcons.checkmark_circle_fill
                    : CupertinoIcons.circle,
                color: selected ? scheme.primary : scheme.outline,
                size: 24,
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: sheetBackgroundColor(context),
      appBar: buildBrandAppBar(
        closesSheet: true,
        context: context,
        title: 'Címkék',
        actionIcon: Icons.check,
        onAction: _save,
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: ListenableBuilder(
              listenable: _viewModel,
              builder: (context, _) {
                return _buildList(context);
              },
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: PickerSearchField(
              searchController: _searchController,
              onChanged: (value) => _viewModel.setQuery(value),
              hintText: 'Tárgy neve vagy kódja...',
            ),
          ),
        ],
      ),
    );
  }
}
