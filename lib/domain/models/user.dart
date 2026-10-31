class LdapUser {
  final int id;
  final String login;
  final String? email;
  final String name;
  final String givenName;
  final String familyName;
  final bool canModerateMidterms;
  final bool isAdmin;

  const LdapUser({
    required this.id,
    required this.login,
    this.email,
    required this.name,
    required this.givenName,
    required this.familyName,
    this.canModerateMidterms = false,
    this.isAdmin = false,
  });

  String get firstName {
    final first = givenName.trim().split(' ').first;
    return first.isEmpty ? login : first;
  }

  factory LdapUser.fromJson(Map<String, dynamic> json) {
    final id = json['id'];
    if (id is! int) throw const FormatException('A felhasználónak hiányzik az id-je.');

    final login = json['login'];
    if (login is! String) throw const FormatException('A felhasználónak hiányzik a felhasználóneve.');

    final name = json['name'];
    if (name is! String) throw const FormatException('A felhasználónak hiányzik a neve.');

    final email = json['email'];
    if (email is! String?) throw const FormatException('Hibás email mező.');

    final givenName = json['givenName'];
    if (givenName is! String) throw const FormatException('A felhasználónak hiányzik a keresztneve.');

    final familyName = json['familyName'];
    if (familyName is! String) throw const FormatException('A felhasználónak hiányzik a vezetékneve.');

    return LdapUser(
      id: id,
      login: login,
      email: email,
      name: name,
      givenName: givenName,
      familyName: familyName,
      canModerateMidterms: _readBool(json['canModerateMidterms'], 'canModerateMidterms'),
      isAdmin: _readBool(json['isAdmin'], 'isAdmin'),
    );
  }

  static bool _readBool(Object? value, String field) {
    if (value == null) return false;
    if (value is! bool) throw FormatException('Hibás $field mező.');
    return value;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'login': login,
      'email': email,
      'name': name,
      'givenName': givenName,
      'familyName': familyName,
      'canModerateMidterms': canModerateMidterms,
      'isAdmin': isAdmin,
    };
  }

  static LdapUser parse(Object? data) {
    if (data is! Map<String, dynamic>) {
      throw const FormatException('A felhasználó nem objektum formátumú.');
    }
    return LdapUser.fromJson(data);
  }
}
