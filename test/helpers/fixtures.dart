import 'package:itk_app/domain/models/calendar_link.dart';
import 'package:itk_app/domain/models/event.dart';
import 'package:itk_app/domain/models/subject.dart';
import 'package:itk_app/domain/models/user.dart';
import 'package:itk_app/domain/models/user_summary.dart';

const analysis = Subject(id: 1, code: 'ITK101', name: 'Analízis I.');
const programming = Subject(id: 2, code: 'ITK202', name: 'Programozás alapjai');

Event event({
  required int id,
  Subject subject = analysis,
  String? location,
  EventType type = EventType.midterm,
  DateTime? startsAt,
}) =>
    Event(
      id: id,
      subject: subject,
      location: location,
      type: type,
      startsAt: startsAt ?? DateTime.utc(2026, 11, 10, 10),
    );

CalendarLink link({required int id, String name = 'Neptun'}) => CalendarLink(
      id: id,
      name: name,
      url: 'https://example.com/$id.ics',
      syncInterval: SyncInterval.daily,
    );

LdapUser user({bool canModerateMidterms = false}) => LdapUser(
      id: 1,
      login: 'perpa4',
      name: 'Teszt Elek',
      givenName: 'Elek',
      familyName: 'Teszt',
      canModerateMidterms: canModerateMidterms,
    );

UserSummary summary(int id, String fullName, String ldapUsername) =>
    UserSummary(userId: id, fullName: fullName, ldapUsername: ldapUsername);
