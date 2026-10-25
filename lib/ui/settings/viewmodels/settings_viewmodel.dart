import 'package:flutter/foundation.dart';
import 'package:itk_app/data/services/api_client.dart';
import 'package:itk_app/data/services/auth_service.dart';
import 'package:itk_app/data/services/theme_service.dart';
import 'package:itk_app/domain/models/user.dart';
import 'package:itk_app/utils/auth_actions.dart';

class SettingsViewModel extends ChangeNotifier {
  final AuthService _authService;
  final ThemeService _themeService;
  final ApiClient _apiClient;

  SettingsViewModel({
    required AuthService authService,
    required ThemeService themeService,
    required ApiClient apiClient,
  })  : _authService = authService,
        _themeService = themeService,
        _apiClient = apiClient {
    _themeService.oledMode.addListener(notifyListeners);
    _themeService.actionButtonAsFab.addListener(notifyListeners);
  }

  factory SettingsViewModel.create() => SettingsViewModel(
        authService: AuthService.instance,
        themeService: ThemeService.instance,
        apiClient: ApiClient.instance,
      );

  // Getters
  bool get isOledMode => _themeService.oledMode.value;
  bool get isActionButtonAsFab => _themeService.actionButtonAsFab.value;
  LdapUser? get currentUser => _authService.cachedUser;

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
}
