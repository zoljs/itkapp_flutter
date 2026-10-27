import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:itk_app/data/repositories/wiki_files_repository.dart';
import 'package:itk_app/data/services/users_client.dart';
import 'package:itk_app/domain/models/wiki_file.dart';
import 'package:itk_app/utils/command.dart';
import 'package:itk_app/utils/result.dart';

class WikiFilesViewModel extends ChangeNotifier {
  WikiFilesViewModel({
    required WikiFilesRepository repository,
    required String dir,
    required String user,
  })  : _repository = repository,
        _dir = dir,
        _user = user {
    load = Command0<void>(_load)..execute();
  }

  final WikiFilesRepository _repository;
  final String _dir;
  final String _user;

  // State
  List<WikiFile> _items = [];
  late final Command0<void> load;

  // Getters
  String get user => _user;
  String get siteUrl => '${UsersClient.baseUrl}/~$_user';

  @override
  void dispose() {
    load.dispose();
    super.dispose();
  }

  // Getters
  UnmodifiableListView<WikiFile> get items => UnmodifiableListView(_items);
  String get title => _dir.isEmpty ? 'Fájlok' : _dir.split('/').last;
  String fileUrl(String name) =>
      Uri.encodeFull('$siteUrl/files/${childPath(name)}');

  String childPath(String name) => _dir.isEmpty ? name : '$_dir/$name';

  // Methods
  Future<Result<void>> _load() async {
    final result = await _repository.listDir(_dir, _user);

    if (result case Ok(:final value)) {
      _items = value;
      notifyListeners();
    }
    return result;
  }
}
