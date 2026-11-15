import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

typedef OfflineEntry = ({DateTime savedAt, Object? data});

class OfflineStore {
  OfflineStore({Future<Directory> Function()? directory})
      : _directory = directory ?? _defaultDirectory;

  final Future<Directory> Function() _directory;

  static Future<Directory> _defaultDirectory() async {
    final base = await getApplicationSupportDirectory();
    return Directory('${base.path}/offline');
  }

  Future<File> _file(String key) async {
    final dir = await _directory();
    return File('${dir.path}/$key.json');
  }

  Future<void> write(String key, Object? data, {DateTime? now}) async {
    try {
      final file = await _file(key);
      await file.parent.create(recursive: true);
      await file.writeAsString(jsonEncode({
        'savedAt': (now ?? DateTime.now()).toUtc().toIso8601String(),
        'data': data,
      }));
    } on FileSystemException catch (e) {
      debugPrint('[OfflineStore] write failed: $e');
    }
  }

  Future<OfflineEntry?> read(String key) async {
    try {
      final file = await _file(key);
      if (!await file.exists()) return null;

      final json = jsonDecode(await file.readAsString());
      if (json is! Map<String, dynamic>) return null;

      final savedAt = json['savedAt'];
      if (savedAt is! String) return null;

      final parsed = DateTime.tryParse(savedAt);
      if (parsed == null) return null;

      return (savedAt: parsed.toLocal(), data: json['data']);
    } on FormatException {
      return null;
    } on FileSystemException {
      return null;
    }
  }

  Future<void> clear() async {
    final dir = await _directory();
    if (await dir.exists()) await dir.delete(recursive: true);
  }
}
