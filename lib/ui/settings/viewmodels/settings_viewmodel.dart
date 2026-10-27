import 'package:flutter/foundation.dart';
import 'package:itk_app/data/repositories/auth_repository.dart';
import 'package:itk_app/data/repositories/calendar_repository.dart';
import 'package:itk_app/data/repositories/midterms_repository.dart';
import 'package:itk_app/data/repositories/sites_repository.dart';
import 'package:itk_app/data/repositories/subjects_repository.dart';
import 'package:itk_app/data/services/api_client.dart';
import 'package:itk_app/data/repositories/onboarding_repository.dart';
import 'package:itk_app/data/repositories/theme_repository.dart';
import 'package:itk_app/domain/models/user.dart';

class SettingsViewModel extends ChangeNotifier {
  final AuthRepository _authRepository;
  final ThemeRepository _themeRepository;
  final SubjectsRepository _subjectsRepository;
  final SitesRepository _sitesRepository;
  final CalendarRepository _calendarRepository;
  final MidtermsRepository _midtermsRepository;

  final ApiClient _apiClient;
  final OnboardingRepository _onboardingRepository;

  SettingsViewModel({
    required AuthRepository authRepository,
    required ThemeRepository themeRepository,
    required SubjectsRepository subjectsRepository,
    required SitesRepository sitesRepository,
    required CalendarRepository calendarRepository,
    required MidtermsRepository midtermsRepository,
    required ApiClient apiClient,
    required OnboardingRepository onboardingRepository,
  })  : _authRepository = authRepository,
        _themeRepository = themeRepository,
        _subjectsRepository = subjectsRepository,
        _sitesRepository = sitesRepository,
        _calendarRepository = calendarRepository,
        _midtermsRepository = midtermsRepository,
        _apiClient = apiClient,
        _onboardingRepository = onboardingRepository {
    _themeRepository.oledMode.addListener(notifyListeners);
    _themeRepository.actionButtonAsFab.addListener(notifyListeners);
  }

  // Getters
  bool get isOledMode => _themeRepository.oledMode.value;
  bool get isActionButtonAsFab => _themeRepository.actionButtonAsFab.value;
  LdapUser? get currentUser => _authRepository.cachedUser;

  // Methods
  void toggleOledMode(bool value) => _themeRepository.toggleOledMode(value);
  void toggleActionButtonAsFab(bool value) =>
      _themeRepository.toggleActionButtonAsFab(value);

  Future<void> clearCookies() => _apiClient.clearCookies();

  @override
  void dispose() {
    _themeRepository.oledMode.removeListener(notifyListeners);
    _themeRepository.actionButtonAsFab.removeListener(notifyListeners);
    super.dispose();
  }

  Future<void> resetOnboarding() => _onboardingRepository.resetOnboarding();

  void clearCaches() {
    _subjectsRepository.clearCache();
    _sitesRepository.clearCache();
    _calendarRepository.clearCache();
    _midtermsRepository.clearCache();
  }
}
