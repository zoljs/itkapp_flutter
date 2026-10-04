class UserSite {
  final int? userId;
  final String name;
  final String url;
  final List<String> tags;

  const UserSite({
    this.userId,
    required this.name,
    required this.url,
    required this.tags,
  });

  factory UserSite.fromJson(Map<String, dynamic> json) {
    return UserSite(
      userId: json['userId'] as int?,
      name: json['name'] as String,
      url: json['url'] as String,
      tags: (json['tags'] as List).map((e) => e.toString()).toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'url': url,
        'tags': tags,
      };
}
