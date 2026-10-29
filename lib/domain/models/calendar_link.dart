enum SyncInterval {
  hourly('1h', 'Óránként'),
  sixHours('6h', '6 óránként'),
  daily('1d', 'Naponta');

  final String wire;
  final String label;

  const SyncInterval(this.wire, this.label);

  static SyncInterval fromWire(Object? wire) {
    for (final interval in values) {
      if (interval.wire == wire) return interval;
    }
    throw FormatException('Ismeretlen frissítési időköz: $wire');
  }
}

class CalendarLink {
  final int id;
  final String name;
  final String url;
  final SyncInterval syncInterval;
  final DateTime? lastSyncedAt;
  final String? lastError;

  const CalendarLink({
    required this.id,
    required this.name,
    required this.url,
    required this.syncInterval,
    this.lastSyncedAt,
    this.lastError,
  });

  factory CalendarLink.fromJson(Map<String, dynamic> json) {
    final id = json['id'];
    if (id is! int) {
      throw const FormatException('Egy naptárnak hiányzik az id-je.');
    }

    final name = json['name'];
    if (name is! String) {
      throw const FormatException('Egy naptárnak hibás a neve.');
    }

    final url = json['url'];
    if (url is! String) {
      throw const FormatException('Egy naptárnak hibás az url-je.');
    }

    final rawLastSyncedAt = json['lastSyncedAt'];
    if (rawLastSyncedAt is! String?) {
      throw const FormatException('Egy naptárnak hibás az utolsó frissítési ideje.');
    }
    final lastSyncedAt = rawLastSyncedAt != null ? DateTime.tryParse(rawLastSyncedAt) : null;
    if (rawLastSyncedAt != null && lastSyncedAt == null) {
      throw const FormatException('Egy naptárnak hibás az utolsó frissítési ideje.');
    }

    final lastError = json['lastError'];
    if (lastError is! String?) {
      throw const FormatException('Egy naptár hiba hibás formátumú.');
    }

    return CalendarLink(
      id: id,
      name: name,
      url: url,
      syncInterval: SyncInterval.fromWire(json['syncInterval']),
      lastSyncedAt: lastSyncedAt,
      lastError: lastError,
    );
  }

  static CalendarLink parse(Object? data) {
    if (data is! Map<String, dynamic>) {
      throw const FormatException('Hibás naptár formátum.');
    }
    return CalendarLink.fromJson(data);
  }

  static List<CalendarLink> parseList(Object? data) {
    if (data is! List) {
      throw const FormatException('A naptár lista nem lista formátumú.');
    }

    final links = <CalendarLink>[];
    for (final entry in data) {
      links.add(parse(entry));
    }
    return List.unmodifiable(links);
  }
}
