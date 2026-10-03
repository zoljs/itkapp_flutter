import 'package:flutter/cupertino.dart';
import 'package:itk_app/data/services/subjects_service.dart';
import 'package:itk_app/ui/core/theme/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:itk_app/domain/models/subject.dart';
import 'package:itk_app/ui/core/widgets/ack_appbar.dart';
import 'package:itk_app/ui/core/widgets/state_message.dart';
import 'package:itk_app/utils/result.dart';

class MySiteTagsScreen extends StatefulWidget {
  final List<String> currentTags;
  const MySiteTagsScreen({super.key, required this.currentTags});

  @override
  State<MySiteTagsScreen> createState() => _MySiteTagsScreenState();
}

class _MySiteTagsScreenState extends State<MySiteTagsScreen> {
  // [REMEMBER FOR FUTURE] if catches error it wont get initialized so 'late' wont work lol
  List<Subject> _subjects = [];
  bool _loading = true;

  final _searchController = TextEditingController();
  late final Set<String> _selectedTags;

  List<Subject> get _filteredSubjects {
    final query = _searchController.text.trim().toLowerCase();

    return _subjects.where((s) {
      final matchesSearch =
          query.isEmpty || s.name.toLowerCase().contains(query);

      return matchesSearch;
    }).toList();
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

  String? _error;

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

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: buildAckAppBar(
        context: context,
        scheme: scheme,
        title: const Text('Címkék'),
        onPressed: () => Navigator.pop(context, _selectedTags.toList()),
      ),
      body: Stack(
        children: [
          _loading
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : _error != null
                  ? StateMessage(
                      icon: Icons.cloud_off_rounded,
                      message: _error!,
                      onRetry: _loadSubjects,
                    )
                  : ListView.separated(
                      padding: EdgeInsets.only(
                        bottom: MediaQuery.paddingOf(context).bottom + 80,
                        top: kToolbarHeight + MediaQuery.paddingOf(context).top,
                      ),
                      itemCount: _filteredSubjects.length,
                      itemBuilder: (context, index) {
                        final subject = _filteredSubjects[index];
                        final selected = _selectedTags.contains(subject.name);

                        return _buildSubjectrow(
                          context,
                          subject,
                          selected,
                        );
                      },
                      separatorBuilder: (context, index) => const Divider(
                        height: 1,
                      ),
                    ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.screenHorizontal,
                AppSpacing.screenHorizontal,
                AppSpacing.screenHorizontal,
                MediaQuery.paddingOf(context).bottom +
                    AppSpacing.screenHorizontal,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    scheme.surface.withValues(alpha: 0.0),
                    scheme.surface,
                  ],
                  stops: const [0.0, 0.4],
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      onChanged: (_) => setState(() {}),
                      decoration:
                          const InputDecoration(hint: Text("Tantárgy neve...")),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubjectrow(
      BuildContext context, Subject subject, bool selected) {
    final scheme = Theme.of(context).colorScheme;
    final isIOS = Theme.of(context).platform == TargetPlatform.iOS;

    return InkWell(
      onTap: () => _toggleTag(subject.name),
      child: Padding(
        padding: const EdgeInsetsGeometry.symmetric(
          horizontal: AppSpacing.screenHorizontal,
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 64.0),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  subject.name,
                  style: TextStyle(
                    fontSize: 14,
                    color: scheme.onSurface,
                  ),
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
}
