class OnlineVideo {
  final int id;
  final String semester;
  final String semesterLabel;
  final String subject;
  final String title;
  final String? uploader;
  final String url;
  final String? youtubeId;
  final String? thumbnailUrl;

  const OnlineVideo({
    required this.id,
    required this.semester,
    required this.semesterLabel,
    required this.subject,
    required this.title,
    required this.url,
    this.uploader,
    this.youtubeId,
    this.thumbnailUrl,
  });

  factory OnlineVideo.fromJson(Map<String, dynamic> json) {
    return OnlineVideo(
      id: json['id'] as int,
      semester: json['semester'] as String,
      semesterLabel: (json['semesterLabel'] as String?) ?? json['semester'] as String,
      subject: json['subject'] as String,
      title: json['title'] as String,
      uploader: json['uploader'] as String?,
      url: json['url'] as String,
      youtubeId: json['youtubeId'] as String?,
      thumbnailUrl: json['thumbnailUrl'] as String?,
    );
  }
}

class VideoPage {
  final int total;
  final int offset;
  final List<OnlineVideo> items;

  const VideoPage({required this.total, required this.offset, required this.items});

  bool get hasMore => offset + items.length < total;

  factory VideoPage.fromJson(Map<String, dynamic> json) {
    return VideoPage(
      total: json['total'] as int,
      offset: json['offset'] as int,
      items: (json['items'] as List).map((e) => OnlineVideo.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }
}

class SemesterFacet {
  final String key;
  final String label;
  final int count;

  const SemesterFacet({required this.key, required this.label, required this.count});

  factory SemesterFacet.fromJson(Map<String, dynamic> json) => SemesterFacet(
        key: json['key'] as String,
        label: json['label'] as String,
        count: json['count'] as int,
      );
}

class SubjectFacet {
  final String name;
  final int count;

  const SubjectFacet({required this.name, required this.count});

  factory SubjectFacet.fromJson(Map<String, dynamic> json) => SubjectFacet(
        name: json['name'] as String,
        count: json['count'] as int,
      );
}

class VideoFilters {
  final List<SemesterFacet> semesters;
  final List<SubjectFacet> subjects;

  const VideoFilters({required this.semesters, required this.subjects});

  static const empty = VideoFilters(semesters: [], subjects: []);

  factory VideoFilters.fromJson(Map<String, dynamic> json) => VideoFilters(
        semesters: (json['semesters'] as List).map((e) => SemesterFacet.fromJson(e as Map<String, dynamic>)).toList(),
        subjects: (json['subjects'] as List).map((e) => SubjectFacet.fromJson(e as Map<String, dynamic>)).toList(),
      );
}
