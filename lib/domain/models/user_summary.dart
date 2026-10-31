class UserSummary {
  final int userId;
  final String fullName;
  final String ldapUsername;

  const UserSummary({
    required this.userId,
    required this.fullName,
    required this.ldapUsername,
  });

  factory UserSummary.fromJson(Map<String, dynamic> json) {
    final userId = json['userId'];
    if (userId is! int) {
      throw const FormatException('Egy felhasználónak hiányzik az id-je.');
    }

    final fullName = json['fullName'];
    if (fullName is! String || fullName.trim().isEmpty) {
      throw const FormatException('Egy felhasználónak hiányzik a neve.');
    }

    final ldapUsername = json['ldapUsername'];
    if (ldapUsername is! String || ldapUsername.trim().isEmpty) {
      throw const FormatException('Egy felhasználónak hiányzik a felhasználóneve.');
    }

    return UserSummary(userId: userId, fullName: fullName, ldapUsername: ldapUsername);
  }

  static List<UserSummary> parseList(Object? data) {
    if (data is! List) {
      throw const FormatException('A felhasználó lista nem lista formátumú.');
    }

    final List<UserSummary> users = [];
    for (final entry in data) {
      if (entry is! Map<String, dynamic>) {
        throw const FormatException('Egy felhasználó nem objektum formátumú.');
      }
      users.add(UserSummary.fromJson(entry));
    }
    return List.unmodifiable(users);
  }
}
