import 'package:flutter/material.dart';
import 'package:itk_app/data/repositories/subjects_repository.dart';
import 'package:itk_app/domain/models/subject.dart';
import 'package:itk_app/ui/core/theme/app_spacing.dart';
import 'package:itk_app/ui/core/widgets/adaptive_sheet.dart';
import 'package:itk_app/ui/core/widgets/brand_appbar.dart';
import 'package:itk_app/ui/core/widgets/picker_search_field.dart';
import 'package:itk_app/ui/core/widgets/state_message.dart';
import 'package:itk_app/ui/core/screens/viewmodels/subject_picker_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:skeletonizer/skeletonizer.dart';

class SubjectPickerScreen extends StatefulWidget {
  final int? selectedId;
  final ScrollController? scrollController;

  const SubjectPickerScreen(
      {super.key, this.selectedId, this.scrollController});

  @override
  State<SubjectPickerScreen> createState() => _SubjectPickerScreenState();
}

class _SubjectPickerScreenState extends State<SubjectPickerScreen> {
  final _searchController = TextEditingController();
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
    _searchController.dispose();
    _viewModel.dispose();
    super.dispose();
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
        itemBuilder: (context, index) =>
            _buildSubjectRow(context, subjects[index]),
        separatorBuilder: (context, index) => const Divider(height: 1),
      ),
    );
  }

  Widget _buildSubjectRow(BuildContext context, Subject subject) {
    final scheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: () => Navigator.pop(context, subject),
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
              if (subject.id == widget.selectedId)
                Icon(Icons.check_rounded, color: scheme.primary),
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
        context: context,
        title: 'Tárgy',
      ),
      body: Stack(
        children: [
          Positioned.fill(
              child: ListenableBuilder(
                  listenable: Listenable.merge([_viewModel, _viewModel.load]),
                  builder: (context, _) {
                    return _buildList(context);
                  })),
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
