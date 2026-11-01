import 'package:flutter/foundation.dart';
import 'package:itk_app/data/repositories/absolutorium_repository.dart';
import 'package:itk_app/data/repositories/admin/admin_roles_repository.dart';
import 'package:itk_app/data/repositories/admin/admin_users_repository.dart';
import 'package:itk_app/data/repositories/auth_repository.dart';
import 'package:itk_app/data/repositories/calendar_links_repository.dart';
import 'package:itk_app/data/repositories/calendar_repository.dart';
import 'package:itk_app/data/repositories/event_repository.dart';
import 'package:itk_app/data/repositories/sites_repository.dart';
import 'package:itk_app/data/repositories/subjects_repository.dart';
import 'package:itk_app/data/repositories/wiki_files_repository.dart';
import 'package:itk_app/domain/models/absolutorium.dart';
import 'package:itk_app/domain/models/calendar_event.dart';
import 'package:itk_app/domain/models/calendar_link.dart';
import 'package:itk_app/domain/models/event.dart';
import 'package:itk_app/domain/models/subject.dart';
import 'package:itk_app/domain/models/user.dart';
import 'package:itk_app/domain/models/user_site.dart';
import 'package:itk_app/domain/models/user_summary.dart';
import 'package:itk_app/domain/models/wiki_file.dart';
import 'package:itk_app/utils/result.dart';

// The fakes implement only what the view models use. Anything else goes to
// noSuchMethod and throws, so a test never silently relies on missing behaviour.

class FakeAuthRepository extends ChangeNotifier implements AuthRepository {
  @override
  LdapUser? cachedUser;

  Result<void> loginResult = const Ok(null);
  final logins = <(String, String)>[];

  @override
  bool get isAuthenticated => cachedUser != null;

  @override
  Future<Result<void>> login(String username, String password) async {
    logins.add((username, password));
    return loginResult;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeEventRepository implements EventRepository {
  Result<List<Event>> getResult = const Ok([]);
  Result<void> addResult = const Ok(null);
  Result<void> deleteResult = const Ok(null);

  final getCalls = <({Set<EventType> types, bool forceReload})>[];
  final deletedIds = <int>[];
  ({int subjectId, DateTime startsAt, String? location, EventType type})? lastAdd;

  @override
  Future<Result<List<Event>>> get({required Set<EventType> types, bool forceReload = false}) async {
    getCalls.add((types: types, forceReload: forceReload));
    return getResult;
  }

  @override
  Future<Result<void>> add({
    required int subjectId,
    required DateTime startsAt,
    String? location,
    required EventType type,
  }) async {
    lastAdd = (subjectId: subjectId, startsAt: startsAt, location: location, type: type);
    return addResult;
  }

  @override
  Future<Result<void>> delete({required int id}) async {
    deletedIds.add(id);
    return deleteResult;
  }

  @override
  void clearCache() {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeCalendarLinksRepository implements CalendarLinksRepository {
  Result<List<CalendarLink>> getResult = const Ok([]);
  Result<void> addResult = const Ok(null);
  Result<void> deleteResult = const Ok(null);

  int getCount = 0;
  final deletedIds = <int>[];
  ({String name, String url, SyncInterval syncInterval})? lastAdd;

  @override
  Future<Result<List<CalendarLink>>> get() async {
    getCount++;
    return getResult;
  }

  @override
  Future<Result<void>> add({
    required String name,
    required String url,
    required SyncInterval syncInterval,
  }) async {
    lastAdd = (name: name, url: url, syncInterval: syncInterval);
    return addResult;
  }

  @override
  Future<Result<void>> delete({required int id}) async {
    deletedIds.add(id);
    return deleteResult;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeCalendarRepository implements CalendarRepository {
  Result<List<CalendarEvent>> getResult = const Ok([]);
  int clearCount = 0;

  @override
  Future<Result<List<CalendarEvent>>> get({bool forceReload = false}) async => getResult;

  @override
  void clearCache() => clearCount++;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeAbsolutoriumRepository implements AbsolutoriumRepository {
  final _progress = ValueNotifier<AbsolutoriumProgress?>(null);

  @override
  ValueListenable<AbsolutoriumProgress?> get progress => _progress;

  @override
  Future<Result<AbsolutoriumProgress?>> getProgress({
    bool forceReload = false,
    Duration maxAge = const Duration(minutes: 2),
  }) async =>
      const Ok(null);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeSubjectsRepository implements SubjectsRepository {
  Result<List<Subject>> getResult = const Ok([]);

  @override
  Future<Result<List<Subject>>> get({bool forceReload = false}) async => getResult;

  @override
  void clearCache() {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeWikiFilesRepository implements WikiFilesRepository {
  Result<List<WikiFile>> listResult = const Ok([]);
  final calls = <(String dir, String user)>[];

  @override
  Future<Result<List<WikiFile>>> listDir(String dir, String user) async {
    calls.add((dir, user));
    return listResult;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeSitesRepository implements SitesRepository {
  Result<UserSite?> getResult = const Ok(null);
  ({List<String> tags, bool isPublic, bool isPhpEnabled})? lastSave;

  @override
  Future<Result<UserSite?>> get() async => getResult;

  @override
  Future<Result<UserSite>> save(List<String> tags, bool isPublic, bool isPhpEnabled) async {
    lastSave = (tags: tags, isPublic: isPublic, isPhpEnabled: isPhpEnabled);
    return Ok(UserSite(name: 'Teszt', url: 'https://example.com', tags: tags));
  }

  @override
  Future<Result<void>> delete() async => const Ok(null);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeAdminRolesRepository implements AdminRolesRepository {
  Result<List<UserSummary>> getResult = const Ok([]);
  Result<void> assignResult = const Ok(null);
  Result<void> revokeResult = const Ok(null);
  int getCount = 0;

  @override
  Future<Result<List<UserSummary>>> getRoleHolders() async {
    getCount++;
    return getResult;
  }

  @override
  Future<Result<void>> assignCohortRep(int userId) async => assignResult;

  @override
  Future<Result<void>> revokeRole(int userId) async => revokeResult;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeAdminUsersRepository implements AdminUsersRepository {
  Result<List<UserSummary>> getResult = const Ok([]);

  @override
  Future<Result<List<UserSummary>>> get() async => getResult;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
