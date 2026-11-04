String currentSemester([DateTime? now]) {
  final d = now ?? DateTime.now();
  final y = d.year;
  final m = d.month;
  if (m >= 8) return _key(y, 1);
  if (m == 1) return _key(y - 1, 1);
  return _key(y - 1, 2);
}

DateTime currentSemesterStart([DateTime? now]) {
  final d = now ?? DateTime.now();
  final y = d.year;
  final m = d.month;
  if (m >= 8) return DateTime(y, 8, 1);
  if (m == 1) return DateTime(y - 1, 8, 1);
  return DateTime(y, 2, 1);
}

String _key(int startYear, int half) =>
    '$startYear/${((startYear + 1) % 100).toString().padLeft(2, '0')}/$half';

List<String> recentSemesters({int count = 12, DateTime? now}) {
  final current = currentSemester(now);
  final parts = current.split('/');
  var year = int.parse(parts[0]);
  var half = int.parse(parts[2]);

  final result = <String>[];
  for (var i = 0; i < count; i++) {
    result.add(_key(year, half));
    if (half == 2) {
      half = 1;
    } else {
      half = 2;
      year -= 1;
    }
  }
  return result;
}

String semesterLabel(String semester) {
  final parts = semester.split('/');
  if (parts.length != 3) return semester;
  final season = switch (parts[2]) {
    '1' => 'ősz',
    '2' => 'tavasz',
    _ => parts[2],
  };
  return '${parts[0]}/${parts[1]} $season';
}
