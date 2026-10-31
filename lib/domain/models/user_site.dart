class UserSite {
  //final int? userId;
  final String? login;
  final String name;
  final String url;
  final List<String> tags;
  final bool claimed;
  final bool isPublic;
  final bool isPhpEnabled;

  const UserSite({
    this.login,
    required this.name,
    required this.url,
    required this.tags,
    this.claimed = false,
    this.isPublic = true,
    this.isPhpEnabled = false,
  });

  factory UserSite.fromJson(Map<String, dynamic> json) {
    final name = json['name'];
    if (name is! String || name.trim().isEmpty) {
      throw const FormatException('Egy oldalnak hiányzik a neve.');
    }

    final login = json['login'];
    if (login != null && login is! String) {
      throw FormatException('$name oldalának hiányzik az azonosítója.');
    }

    final url = json['url'];
    if (url is! String || url.trim().isEmpty) {
      throw FormatException('$name oldalának hiányzik az URL-je.');
    }

    final tags = json['tags'];
    if (tags is! List) {
      throw FormatException('$name oldalának hiányoznak a címkéi.');
    }
    if (tags.any((tag) => tag is! String || tag.trim().isEmpty)) {
      throw FormatException('$name oldalának címkéi között van egy hibás elem.');
    }
    final tagsList = tags.map((tag) => tag.toString()).toList();

    final claimed = _readBool(json['claimed'], 'claimed');
    final isPublic = _readBool(json['isPublic'], 'isPublic');
    final isPhpEnabled = _readBool(json['isPhpEnabled'], 'isPhpEnabled');

    return UserSite(
      login: login,
      name: name,
      url: url,
      tags: tagsList,
      claimed: claimed,
      isPublic: isPublic,
      isPhpEnabled: isPhpEnabled,
    );
  }

  static bool _readBool(Object? value, String field) {
    if (value == null) return false;
    if (value is! bool) throw FormatException('Hibás $field mező.');
    return value;
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'url': url,
        'tags': tags,
        'isPublic': isPublic,
        'isPhpEnabled': isPhpEnabled,
      };

  static UserSite parse(Object? data) {
    if (data is! Map<String, dynamic>) {
      throw const FormatException('Egy oldal nem objektum formátumú.');
    }
    return UserSite.fromJson(data);
  }

  static List<UserSite> parseList(Object? data) {
    if (data is! List) {
      throw const FormatException('Az oldal lista nem lista formátumú.');
    }
    return List.unmodifiable(data.map(parse));
  }
}
