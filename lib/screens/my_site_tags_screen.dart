import 'package:dio/dio.dart';
import 'package:material_ui/material_ui.dart';
import 'package:itk_app/models/subject.dart';

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
      final response =
          await Dio().get('https://space.itk.ppke.hu/api/subjects');
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
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        title: const Text('Címkék'),
      ),
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.separated(
                      itemCount: _filteredSubjects.length,
                      itemBuilder: (context, index) {
                        final subject = _filteredSubjects[index];
                        final selected = _selectedTags.contains(subject.name);

                        return CheckboxListTile(
                          value: selected,
                          onChanged: (_) => (_toggleTag(subject.name)),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 0),
                          title: Text(
                            subject.name,
                            style: TextStyle(
                                fontSize: 14,
                                color: Theme.of(context).colorScheme.onSurface),
                          ),
                        );
                      },
                      separatorBuilder: (context, index) => const Divider(
                        height: 1,
                      ),
                    ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
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
                  const SizedBox(width: 8),
                  IconButton(
                      onPressed: () =>
                          Navigator.pop(context, _selectedTags.toList()),
                      icon: const Icon(Icons.save_rounded))
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
