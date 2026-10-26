import 'package:flutter/foundation.dart';
import 'package:itk_app/data/repositories/auth_repository.dart';
import 'package:itk_app/data/services/api_client.dart';
import 'package:itk_app/data/services/onboarding_service.dart';
import 'package:itk_app/data/services/theme_service.dart';
import 'package:itk_app/domain/models/user.dart';
import 'package:itk_app/utils/auth_actions.dart';

class SettingsViewModel extends ChangeNotifier {
  final AuthRepository _authRepository;
  final ThemeService _themeService;
  final ApiClient _apiClient;
  final OnboardingService _onboardingService;

  SettingsViewModel({
    required AuthRepository authRepository,
    required ThemeService themeService,
    required ApiClient apiClient,
    required OnboardingService onboardingService,
  })  : _authRepository = authRepository,
        _themeService = themeService,
        _apiClient = apiClient,
        _onboardingService = onboardingService {
    _themeService.oledMode.addListener(notifyListeners);
    _themeService.actionButtonAsFab.addListener(notifyListeners);
  }

  factory SettingsViewModel.create() => SettingsViewModel(
        authRepository: AuthRepository.instance,
        themeService: ThemeService.instance,
        apiClient: ApiClient.instance,
        onboardingService: OnboardingService.instance,
      );

  // Getters
  bool get isOledMode => _themeService.oledMode.value;
  bool get isActionButtonAsFab => _themeService.actionButtonAsFab.value;
  LdapUser? get currentUser => _authRepository.cachedUser;

  // Methods
  void toggleOledMode(bool value) => _themeService.toggleOledMode(value);
  void toggleActionButtonAsFab(bool value) =>
      _themeService.toggleActionButtonAsFab(value);

  void clearCaches() => clearAllCaches();

  Future<void> clearCookies() => _apiClient.clearCookies();

  @override
  void dispose() {
    _themeService.oledMode.removeListener(notifyListeners);
    _themeService.actionButtonAsFab.removeListener(notifyListeners);
    super.dispose();
  }

  Future<void> resetOnboarding() => _onboardingService.resetOnboarding();
}
