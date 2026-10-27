import 'package:itk_app/data/repositories/sites_repository.dart';
import 'package:itk_app/domain/models/user_site.dart';
import 'package:itk_app/utils/result.dart';

class FakeSitesService implements SitesRepository {
  Result<List<UserSite>> sitesResult = const Ok([]);
  Result<UserSite?> mySiteResult = const Ok(null);

  @override
  List<UserSite> get cached => const [];

  @override
  void clearCache() {}

  @override
  Future<Result<List<UserSite>>> getAllSites(
          {bool forceReload = false}) async =>
      sitesResult;

  @override
  Future<Result<UserSite?>> getMySite() async => mySiteResult;

  @override
  Future<Result<UserSite>> saveMySite(
          List<String> tags, bool isPublic, bool isPhpEnabled) =>
      throw UnimplementedError();

  @override
  Future<Result<void>> deleteMySite() => throw UnimplementedError();
}
