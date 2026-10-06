class LdapUser {
  final int id;
  final String login;
  final String? email;
  final String name;
  final String givenName;
  final String familyName;
  final bool canModerateMidterms;

  const LdapUser({
    required this.id,
    required this.login,
    this.email,
    required this.name,
    required this.givenName,
    required this.familyName,
    this.canModerateMidterms = false,
  });

  String get firstName {
    final first = givenName.trim().split(' ').first;
    return first.isEmpty ? login : first;
  }

  factory LdapUser.fromJson(Map<String, dynamic> json) {
    return LdapUser(
      id: json['id'] as int,
      login: json['login'] as String,
      email: json['email'] as String?,
      name: json['name'] as String,
      givenName: json['givenName'] as String? ?? '',
      familyName: json['familyName'] as String? ?? '',
      canModerateMidterms: json['canModerateMidterms'] as bool? ?? false,
    );
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
    };
  }
}
