import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:itk_app/data/services/wiki_files_service.dart';
import 'package:itk_app/domain/models/wiki_file.dart';
import 'package:itk_app/utils/result.dart';

class WikiFilesViewModel extends ChangeNotifier {
  WikiFilesViewModel({
    required WikiFilesService service,
    required String dir,
  })  : _service = service,
        _dir = dir;

  factory WikiFilesViewModel.forDir(String dir) => WikiFilesViewModel(
        service: WikiFilesService.instance,
        dir: dir,
      );

  final WikiFilesService _service;
  final String _dir;

  // State
  List<WikiFile> _items = [];
  bool _loading = true;
  String? _error;

  // Getters
  UnmodifiableListView<WikiFile> get items => UnmodifiableListView(_items);
  bool get loading => _loading;
  String? get error => _error;
  String get title => _dir.isEmpty ? 'Fájlok' : _dir.split('/').last;
  String childPath(String name) => _dir.isEmpty ? name : '$_dir/$name';

  // Methods
  Future<void> load() async {
    _loading = true;
    _error = null;
    notifyListeners();

    final result = await _service.listDir(_dir);

    switch (result) {
      case Ok(:final value):
        _items = value;
        _loading = false;
      case Err(:final message):
        _error = message;
        _loading = false;
    }
    notifyListeners();
  }
}
