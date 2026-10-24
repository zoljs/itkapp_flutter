import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:itk_app/data/services/wiki_files_service.dart';
import 'package:itk_app/domain/models/wiki_file.dart';
import 'package:itk_app/utils/command.dart';
import 'package:itk_app/utils/result.dart';

class WikiFilesViewModel extends ChangeNotifier {
  WikiFilesViewModel({
    required WikiFilesService service,
    required String dir,
  })  : _service = service,
        _dir = dir {
    load = Command0<void>(_load)..execute();
  }

  factory WikiFilesViewModel.forDir(String dir) => WikiFilesViewModel(
        service: WikiFilesService.instance,
        dir: dir,
      );

  final WikiFilesService _service;
  final String _dir;

  // State
  List<WikiFile> _items = [];
  late final Command0<void> load;

  // Getters
  UnmodifiableListView<WikiFile> get items => UnmodifiableListView(_items);
  String get title => _dir.isEmpty ? 'Fájlok' : _dir.split('/').last;
  String childPath(String name) => _dir.isEmpty ? name : '$_dir/$name';

  // Methods
  Future<Result<void>> _load() async {
    final result = await _service.listDir(_dir);

    switch (result) {
      case Ok(:final value):
        _items = value;
        notifyListeners();
        return const Ok(null);
      case Err(:final message):
        return Err(message);
    }
  }
}
