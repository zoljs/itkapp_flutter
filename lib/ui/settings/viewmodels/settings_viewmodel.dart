import 'package:flutter/foundation.dart';
import 'package:itk_app/data/repositories/auth_repository.dart';
import 'package:itk_app/data/services/api_client.dart';
import 'package:itk_app/data/repositories/onboarding_repository.dart';
import 'package:itk_app/data/repositories/theme_repository.dart';
import 'package:itk_app/domain/models/user.dart';
import 'package:itk_app/utils/auth_actions.dart';

class SettingsViewModel extends ChangeNotifier {
  final AuthRepository _authRepository;
  final ThemeRepository _themeRepository;
  final ApiClient _apiClient;
  final OnboardingRepository _onboardingRepository;

  SettingsViewModel({
    required AuthRepository authRepository,
    required ThemeRepository themeRepository,
    required ApiClient apiClient,
    required OnboardingRepository onboardingRepository,
  })  : _authRepository = authRepository,
        _themeRepository = themeRepository,
        _apiClient = apiClient,
        _onboardingRepository = onboardingRepository {
    _themeRepository.oledMode.addListener(notifyListeners);
    _themeRepository.actionButtonAsFab.addListener(notifyListeners);
  }

  factory SettingsViewModel.create() => SettingsViewModel(
        authRepository: AuthRepository.instance,
        themeRepository: ThemeRepository.instance,
        apiClient: ApiClient.instance,
        onboardingRepository: OnboardingRepository.instance,
      );

  // Getters
  bool get isOledMode => _themeRepository.oledMode.value;
  bool get isActionButtonAsFab => _themeRepository.actionButtonAsFab.value;
  LdapUser? get currentUser => _authRepository.cachedUser;

  // Methods
  void toggleOledMode(bool value) => _themeRepository.toggleOledMode(value);
  void toggleActionButtonAsFab(bool value) =>
      _themeRepository.toggleActionButtonAsFab(value);

  void clearCaches() => clearAllCaches();

  Future<void> clearCookies() => _apiClient.clearCookies();

  @override
  void dispose() {
    _themeRepository.oledMode.removeListener(notifyListeners);
    _themeRepository.actionButtonAsFab.removeListener(notifyListeners);
    super.dispose();
  }

  Future<void> resetOnboarding() => _onboardingRepository.resetOnboarding();
}
