import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:itk_app/data/services/subjects_service.dart';
import 'package:itk_app/domain/models/subject.dart';
import 'package:itk_app/ui/core/theme/app_spacing.dart';
import 'package:itk_app/ui/core/widgets/adaptive_sheet.dart';
import 'package:itk_app/ui/core/widgets/brand_appbar.dart';
import 'package:itk_app/ui/core/widgets/state_message.dart';
import 'package:itk_app/utils/result.dart';

class MySiteTagsScreen extends StatefulWidget {
  final List<String> currentTags;
  final ValueChanged<List<String>> onSave;
  final ScrollController? scrollController;

  const MySiteTagsScreen({
    super.key,
    required this.currentTags,
    required this.onSave,
    this.scrollController,
  });

  @override
  State<MySiteTagsScreen> createState() => _MySiteTagsScreenState();
}

class _MySiteTagsScreenState extends State<MySiteTagsScreen> {
  final _searchController = TextEditingController();
  late final Set<String> _selectedTags;

  List<Subject> _subjects = [];
  bool _loading = true;
  String? _error;

  List<Subject> get _filteredSubjects {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) return _subjects;
    return _subjects
        .where((s) => s.name.toLowerCase().contains(query))
        .toList();
  }

  @override
  void initState() {
    super.initState();
    _selectedTags = Set<String>.from(widget.currentTags);
    _loadSubjects();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _toggleTag(String tag) {
    setState(() {
      if (_selectedTags.contains(tag)) {
        _selectedTags.remove(tag);
      } else {
        _selectedTags.add(tag);
      }
    });
  }

  void _save() {
    widget.onSave(_selectedTags.toList());
    closeSheet(context);
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
        top: kToolbarHeight + MediaQuery.paddingOf(context).top,
        bottom: MediaQuery.paddingOf(context).bottom + 80,
      ),
      itemCount: subjects.length,
      itemBuilder: (context, index) {
        final subject = subjects[index];
        return _buildSubjectRow(
          context,
          subject,
          _selectedTags.contains(subject.name),
        );
      },
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
          hintText: 'Tantárgy neve...',
          prefixIcon: Icon(Icons.search_rounded),
        ),
      ),
    );
  }

  Widget _buildSubjectRow(
      BuildContext context, Subject subject, bool selected) {
    final scheme = Theme.of(context).colorScheme;
    final isIOS = Theme.of(context).platform == TargetPlatform.iOS;

    return InkWell(
      onTap: () => _toggleTag(subject.name),
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
                  onChanged: (_) => _toggleTag(subject.name),
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
      extendBodyBehindAppBar: true,
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
