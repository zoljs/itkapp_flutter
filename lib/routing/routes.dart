abstract final class Routes {
  static const login = '/login';
  static const onboarding = '/onboarding';
  static const home = '/';
  static const calendar = '/calendar';
  static const wiki = '/wiki';
  static const wikiEdit = '/wiki/edit';
  static const wikiFiles = '/wiki/files';
  static const settings = '/settings';
  static const adminRoles = '/admin/roles';
  static const midterms = '/midterms';
  static const onlineVideos = '/onlinevideos';

  static String wikiFilesFor(String user) => '$wikiFiles/$user';
}
