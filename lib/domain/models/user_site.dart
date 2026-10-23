class UserSite {
  //final int? userId;
  final String? login;
  final String name;
  final String url;
  final List<String> tags;
  final bool claimed;

  const UserSite({
    this.login,
    required this.name,
    required this.url,
    required this.tags,
    this.claimed = false,
  });

  factory UserSite.fromJson(Map<String, dynamic> json) {
    return UserSite(
      login: json['login'] as String?,
      name: json['name'] as String,
      url: json['url'] as String,
      tags: (json['tags'] as List).map((e) => e.toString()).toList(),
      claimed: json['claimed'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'url': url,
        'tags': tags,
      };
}
