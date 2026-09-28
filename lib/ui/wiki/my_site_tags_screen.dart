import 'package:flutter/cupertino.dart';
import 'package:itk_app/data/services/api_client.dart';
import 'package:itk_app/ui/core/theme/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:itk_app/domain/models/subject.dart';
import 'package:itk_app/ui/core/widgets/adaptive_pressable.dart';

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

  Future<void> _loadSubjects() async {
    try {
      final response = await ApiClient.instance.dio
          .get('https://space.itk.ppke.hu/api/subjects');
      final data = response.data as List;
      final subjects = data
          .map((json) => Subject.fromJson(json as Map<String, dynamic>))
          .toList();

      if (!mounted) return;

      setState(() {
        _subjects = subjects;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Címkék'),
        backgroundColor: Colors.transparent,
        scrolledUnderElevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                scheme.surface,
                scheme.surface,
                scheme.surface.withValues(alpha: 0.0),
              ],
              stops: const [0.0, 0.55, 1.0],
            ),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(4.0),
            child: SizedBox.square(
              dimension: 48,
              child: IconButton(
                style: IconButton.styleFrom(
                    backgroundColor: Colors.black87.withValues(alpha: .3)),
                constraints: BoxConstraints.tight(
                  const Size.square(AppSpacing.minimumAndroid),
                ),
                onPressed: () => Navigator.pop(context, _selectedTags.toList()),
                icon: const Icon(
                  Icons.check,
                  color: Colors.white70,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          _loading
              ? const Center(
                  child: CircularProgressIndicator.adaptive(),
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

    return AdaptivePressable(
      borderRadius: 0,
      onTap: () => _toggleTag(subject.name),
      child: Padding(
        padding: const EdgeInsetsGeometry.symmetric(
          horizontal: AppSpacing.screenHorizontal,
          vertical: 0,
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
                      color: Theme.of(context).colorScheme.onSurface),
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
