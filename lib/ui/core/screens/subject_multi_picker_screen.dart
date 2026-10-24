import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:itk_app/domain/models/subject.dart';
import 'package:itk_app/ui/core/theme/app_spacing.dart';
import 'package:itk_app/ui/core/widgets/adaptive_sheet.dart';
import 'package:itk_app/ui/core/widgets/brand_appbar.dart';
import 'package:itk_app/ui/core/widgets/picker_search_field.dart';
import 'package:itk_app/ui/core/widgets/state_message.dart';
import 'package:itk_app/ui/core/screens/viewmodels/subject_multi_picker_viewmodel.dart';

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
  late final _viewModel =
      SubjectMultiPickerViewModel.create(widget.currentTags);

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _save() {
    widget.onSave(_viewModel.selectedSubjects.toList());
    closeSheet(context);
  }

  Widget _buildList(BuildContext context) {
    if (_viewModel.load.running) {
      return const Center(child: CircularProgressIndicator.adaptive());
    }
    if (_viewModel.load.errorMessage != null) {
      return StateMessage(
        icon: Icons.cloud_off_rounded,
        message: _viewModel.load.errorMessage!,
        onRetry: _viewModel.load.execute,
      );
    }

    final subjects = _viewModel.filteredSubjects;
    return ListView.separated(
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
    );
  }

  Widget _buildSubjectRow(
      BuildContext context, Subject subject, bool selected) {
    final scheme = Theme.of(context).colorScheme;
    final isIOS = Theme.of(context).platform == TargetPlatform.iOS;

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
                child: Text(
                  subject.name,
                  style: TextStyle(fontSize: 15, color: scheme.onSurface),
                ),
              ),
              if (isIOS)
                Icon(
                  selected
                      ? CupertinoIcons.checkmark_circle_fill
                      : CupertinoIcons.circle,
                  color: selected ? scheme.primary : scheme.outline,
                  size: 24,
                )
              else
                Checkbox(
                  value: selected,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.compact,
                  onChanged: (_) => _viewModel.toggleSubject(subject.name),
                ),
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
