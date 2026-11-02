import 'dart:async';
import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:itk_app/data/repositories/absolutorium_repository.dart';
import 'package:itk_app/domain/models/absolutorium.dart';
import 'package:itk_app/utils/command.dart';
import 'package:itk_app/utils/result.dart';

class SubjectSearchViewModel extends ChangeNotifier {
  SubjectSearchViewModel({required AbsolutoriumRepository repository}) : _repository = repository {
    search = Command1<void, String>(_search);
  }

  static const minQueryLength = 2;
  static const _debounce = Duration(milliseconds: 300);

  final AbsolutoriumRepository _repository;
  late final Command1<void, String> search;

  @override
  void dispose() {
    _timer?.cancel();
    search.dispose();
    super.dispose();
  }

  String _query = '';
  List<CurriculumSubject> _hits = [];
  Timer? _timer;
  int _requestId = 0;

  String get query => _query.trim();

  UnmodifiableListView<CurriculumSubject> get hits => UnmodifiableListView(_hits);

  bool get queryTooShort => query.length < minQueryLength;

  void setQuery(String value) {
    _query = value;
    _timer?.cancel();
    if (queryTooShort) {
      _requestId++;
      _hits = [];
    } else {
      _timer = Timer(_debounce, () => unawaited(_runLatest()));
    }
    notifyListeners();
  }

  Future<void> _runLatest() async {
    final q = query;
    await search.execute(q);
    if (query != q && !queryTooShort && !search.running) await _runLatest();
  }

  Future<Result<void>> _search(String q) async {
    final id = ++_requestId;
    final result = await _repository.searchSubjects(q);
    if (id != _requestId) return const Ok(null);

    if (result case Ok(:final value)) {
      _hits = value;
      notifyListeners();
    }
    return result;
  }
}
