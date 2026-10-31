abstract final class Routes {
  static const login = '/login';
  static const onboarding = '/onboarding';
  static const home = '/';
  static const calendar = '/calendar';
  static const calendarV2Links = '/calendar/v2/links';
  static const wiki = '/wiki';
  static const wikiEdit = '/wiki/edit';
  static const wikiFiles = '/wiki/files';
  static const settings = '/settings';
  static const adminRoles = '/admin/roles';
  static const midterms = '/midterms';
  static const videos = '/videos';

  static String wikiFilesFor(String user) => '$wikiFiles/$user';
}
