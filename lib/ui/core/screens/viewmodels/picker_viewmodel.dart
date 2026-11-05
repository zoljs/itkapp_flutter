import 'dart:async';
import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:itk_app/utils/command.dart';
import 'package:itk_app/utils/result.dart';

class PickerViewModel<T> extends ChangeNotifier {
  PickerViewModel({
    required this.matches,
    required this.fetch,
  }) {
    load = Command0<void>(_load)..addListener(notifyListeners);
    unawaited(load.execute());
  }

  final Future<Result<List<T>>> Function() fetch;
  final bool Function(T item, String query) matches;

  @override
  void dispose() {
    load.dispose();
    super.dispose();
  }

  // State
  List<T> _items = [];
  late final Command0<void> load;
  String _query = '';

  // Getters
  UnmodifiableListView<T> get items => UnmodifiableListView(_items);

  String get query => _query;
  void setQuery(String value) {
    _query = value;
    notifyListeners();
  }

  List<T> get filteredItems {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return items;
    return _items.where((item) => matches(item, q)).toList();
  }

  // Methods
  Future<Result<void>> _load() async {
    final result = await fetch();

    if (result case Ok(:final value)) {
      _items = value;
      notifyListeners();
    }
    return result;
  }
}
