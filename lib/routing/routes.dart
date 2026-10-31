abstract final class Routes {
  static const login = '/login';
  static const onboarding = '/onboarding';
  static const home = '/';
  static const calendar = '/calendar';
  static const calendarLinks = '/calendar/links';
  static const wiki = '/wiki';
  static const wikiEdit = '/wiki/edit';
  static const wikiFiles = '/wiki/files';
  static const settings = '/settings';
  static const adminRoles = '/admin/roles';
  static const midterms = '/midterms';
  static const consultations = '/consultations';
  static const videos = '/videos';
  static const absolutorium = '/absolutorium';
  static const absolutoriumCompletions = '/absolutorium/completions';
  static const absolutoriumGroups = '/absolutorium/groups';

  static String wikiFilesFor(String user) => '$wikiFiles/$user';

  static String absolutoriumGroupFor(int groupId) =>
      '$absolutoriumGroups/$groupId';
}
