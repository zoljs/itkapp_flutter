class CalendarLinks {
  const CalendarLinks({
    this.neptunUrl,
    this.moodleUrl,
    this.neptunLastSyncedAt,
    this.moodleLastSyncedAt,
  });

  final String? neptunUrl;
  final String? moodleUrl;
  final DateTime? neptunLastSyncedAt;
  final DateTime? moodleLastSyncedAt;

  factory CalendarLinks.fromJson(Map<String, dynamic> json) {
    return CalendarLinks(
      neptunUrl: _readUrl(json['neptunLink'], 'neptunLink'),
      moodleUrl: _readUrl(json['moodleLink'], 'moodleLink'),
      neptunLastSyncedAt: _readDate(json['neptunLastSyncedAt'], 'neptunLastSyncedAt'),
      moodleLastSyncedAt: _readDate(json['moodleLastSyncedAt'], 'moodleLastSyncedAt'),
    );
  }

  // PUT expects plain url strings, not the {url, syncInterval} objects GET returns
  Map<String, dynamic> toJson() => {
        'neptunLink': neptunUrl,
        'moodleLink': moodleUrl,
      };

  // null -->> not set; {url: String} -->> the url; anything else -->> FormatException
  static String? _readUrl(Object? value, String field) {
    if (value == null) return null;
    if (value is! Map<String, dynamic>) {
      throw FormatException('Hibás $field: nem objektum.');
    }
    final url = value['url'];
    if (url is! String) {
      throw FormatException('Hibás $field: hiányzik az url.');
    }
    return url;
  }

  /// null -->> never synced; ISO string -->> DateTime; anything else -->> FormatException
  static DateTime? _readDate(Object? value, String field) {
    if (value == null) return null;
    if (value is! String) {
      throw FormatException('Hibás $field: nem szöveg.');
    }
    final date = DateTime.tryParse(value);
    if (date == null) {
      throw FormatException('Hibás $field: rossz dátum formátum.');
    }
    return date;
  }
}
