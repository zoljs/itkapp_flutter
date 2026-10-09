import 'package:flutter/material.dart';
import 'package:itk_app/data/services/subjects_service.dart';
import 'package:itk_app/domain/models/subject.dart';
import 'package:itk_app/ui/core/theme/app_spacing.dart';
import 'package:itk_app/ui/core/widgets/adaptive_sheet.dart';
import 'package:itk_app/ui/core/widgets/brand_appbar.dart';
import 'package:itk_app/ui/core/widgets/state_message.dart';
import 'package:itk_app/utils/result.dart';

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

  List<Subject> _subjects = [];
  bool _loading = true;
  String? _error;

  List<Subject> get _filteredSubjects {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) return _subjects;
    return _subjects
        .where((s) =>
            s.name.toLowerCase().contains(query) ||
            s.code.toLowerCase().contains(query))
        .toList();
  }

  @override
  void initState() {
    super.initState();
    _loadSubjects();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadSubjects() async {
    setState(() {
      _error = null;
      _loading = true;
    });

    final result = await SubjectsService.instance.getSubjects();
    if (!mounted) return;

    switch (result) {
      case Ok(:final value):
        setState(() {
          _subjects = value;
          _loading = false;
        });
      case Err(:final message):
        setState(() {
          _error = message;
          _loading = false;
        });
    }
  }

  Widget _buildList(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator.adaptive());
    }
    if (_error != null) {
      return StateMessage(
        icon: Icons.cloud_off_rounded,
        message: _error!,
        onRetry: _loadSubjects,
      );
    }

    final subjects = _filteredSubjects;
    return ListView.separated(
      controller: widget.scrollController,
      padding: EdgeInsets.only(
        bottom: MediaQuery.paddingOf(context).bottom + 80,
      ),
      itemCount: subjects.length,
      itemBuilder: (context, index) =>
          _buildSubjectRow(context, subjects[index]),
      separatorBuilder: (context, index) => const Divider(height: 1),
    );
  }

  Widget _buildSearch(BuildContext context) {
    final bg = sheetBackgroundColor(context);

    return Container(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.screenHorizontal,
        AppSpacing.screenHorizontal,
        AppSpacing.screenHorizontal,
        MediaQuery.paddingOf(context).bottom + AppSpacing.screenHorizontal,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [bg.withValues(alpha: 0.0), bg],
          stops: const [0.0, 0.4],
        ),
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (_) => setState(() {}),
        textInputAction: TextInputAction.search,
        decoration: const InputDecoration(
          hintText: 'Tárgy neve vagy kódja...',
          prefixIcon: Icon(Icons.search_rounded),
        ),
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
          Positioned.fill(child: _buildList(context)),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _buildSearch(context),
          ),
        ],
      ),
    );
  }
}
