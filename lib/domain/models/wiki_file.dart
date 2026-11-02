class WikiFile {
  final String name;
  final bool isDir;

  WikiFile({
    required this.name,
    required this.isDir,
  });

  /// The PHP script runs on a server we do not control, so a huge listing is rejected.
  static const maxFiles = 1000;
  static final _controlChars = RegExp(r'[\x00-\x1F\x7F]');

  factory WikiFile.fromJson(Map<String, dynamic> json) {
    final name = json['name'];
    if (name is! String || name.trim().isEmpty) {
      throw const FormatException('A fájlnév üres.');
    }
    if (name.contains('/') || name.contains('\\')) {
      throw const FormatException('Egy fájlnév nem tartalmazhat "/" vagy "\\" karaktereket.');
    }
    if (name == '.' || name == '..') {
      throw const FormatException('Egy fájlnév nem lehet ".." vagy "." karaktersorozat.');
    }
    if (name.length > 255) {
      throw const FormatException('Egy fájlnév túl hosszú.');
    }
    if (_controlChars.hasMatch(name)) {
      throw const FormatException('Egy fájlnév nem tartalmazhat vezérlőkaraktereket.');
    }

    final type = json['type'];
    if (type is! String || type != 'dir' && type != 'file') {
      throw const FormatException('A fájltípus nem megfelelő.');
    }

    return WikiFile(name: name, isDir: type == 'dir');
  }

  static WikiFile parse(Object? data) {
    if (data is! Map<String, dynamic>) {
      throw const FormatException('A fájl nem objektum formátumú.');
    }
    return WikiFile.fromJson(data);
  }

  static List<WikiFile> parseList(Object? data) {
    if (data is! List) {
      throw const FormatException('A fájllista nem lista formátumú.');
    }
    if (data.length > maxFiles) {
      throw const FormatException('A mappában túl sok fájl van.');
    }
    return List.unmodifiable(data.map(parse));
  }
}
