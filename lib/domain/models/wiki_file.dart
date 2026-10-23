class WikiFile {
  final String name;
  final bool isDir;

  WikiFile({
    required this.name,
    required this.isDir,
  });

  factory WikiFile.fromJson(Map<String, dynamic> json) {
    final name = json['name'];
    if (name is! String || name.trim().isEmpty) {
      throw const FormatException('A fájlnév üres.');
    }

    final type = json['type'];
    if (type is! String || type != 'dir' && type != 'file') {
      throw const FormatException('A fájltípus nem megfelelő.');
    }

    return WikiFile(name: name, isDir: type == 'dir');
  }
}
