class LdapUser {
  final int id;
  final String login;
  final String? email;
  final String name;

  const LdapUser({
    required this.id,
    required this.login,
    this.email,
    required this.name,
  });

  factory LdapUser.fromJson(Map<String, dynamic> json) {
    return LdapUser(
      id: json['id'] as int,
      login: json['login'] as String,
      email: json['email'] as String?,
      name: json['name'] as String,
    );
  }
}
