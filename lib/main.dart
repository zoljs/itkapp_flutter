import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:itk_app/data/repositories/admin/admin_roles_repository.dart';
import 'package:itk_app/data/repositories/admin/admin_users_repository.dart';
import 'package:itk_app/data/repositories/auth_repository.dart';
import 'package:itk_app/data/repositories/calendar_repository.dart';
import 'package:itk_app/data/repositories/midterms_repository.dart';
import 'package:itk_app/data/repositories/onboarding_repository.dart';
import 'package:itk_app/data/repositories/sites_repository.dart';
import 'package:itk_app/data/repositories/subjects_repository.dart';
import 'package:itk_app/data/repositories/theme_repository.dart';
import 'package:itk_app/data/repositories/wiki_files_repository.dart';
import 'package:itk_app/ui/core/navigator_key.dart';
import 'package:itk_app/ui/core/theme/app_fonts.dart';
import 'package:itk_app/ui/core/theme/app_radius.dart';
import 'package:itk_app/ui/core/theme/app_themes.dart';
import 'package:flutter/services.dart';
import 'package:itk_app/utils/auth_actions.dart';
import 'package:provider/provider.dart';
import 'data/services/api_client.dart';
import 'ui/login/auth_gate.dart';
import 'package:intl/date_symbol_data_local.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final apiClient = ApiClient.instance;
  final themeRepository = ThemeRepository.instance;
  final onboardingRepository = OnboardingRepository.instance;

  await apiClient.init();
  apiClient.onUnauthorized = handleSessionExpired;
  await themeRepository.loadFromDisk();
  await onboardingRepository.loadFromDisk();

  initializeDateFormatting().then(
    (_) => runApp(
      MultiProvider(
        providers: [
          Provider.value(value: apiClient),
          Provider.value(value: themeRepository),
          Provider.value(value: onboardingRepository),
          ChangeNotifierProvider.value(value: AuthRepository.instance),
          Provider.value(value: CalendarRepository.instance),
          Provider.value(value: MidtermsRepository.instance),
          Provider.value(value: SitesRepository.instance),
          Provider.value(value: SubjectsRepository.instance),
          Provider.value(value: WikiFilesRepository.instance),
          Provider.value(value: AdminRolesRepository.instance),
          Provider.value(value: AdminUsersRepository.instance),
        ],
        child: const ITKApp(),
      ),
    ),
  );
}

const _seedColor = itkDark;

ColorScheme _darkSchemeFor(ColorScheme base, {required bool isOled}) {
  if (!isOled) return base;
  return base.copyWith(
    surface: Colors.black,
    surfaceContainerLowest: Colors.black,
    surfaceContainerLow: const Color(0xFF0A0A0A),
    surfaceContainer: const Color(0xFF121212),
    surfaceContainerHigh: const Color(0xFF1A1A1A),
    surfaceContainerHighest: const Color(0xFF222222),
  );
}

ThemeData _buildTheme(ColorScheme scheme) {
  final TextTheme base =
      ThemeData(colorScheme: scheme, useMaterial3: true).textTheme;
  final cupertinoText = const CupertinoThemeData().textTheme;

  return ThemeData(
    colorScheme: scheme,
    useMaterial3: true,
    splashFactory: defaultTargetPlatform == TargetPlatform.iOS
        ? NoSplash.splashFactory
        : null,
    textTheme: buildITKAppTextTheme(base),
    cupertinoOverrideTheme: CupertinoThemeData(
      textTheme: cupertinoText.copyWith(
        textStyle: cupertinoText.textStyle.merge(flexRegular),
        actionTextStyle: cupertinoText.actionTextStyle.merge(flexRegular),
        navTitleTextStyle: cupertinoText.navTitleTextStyle.merge(flexRounded),
        navLargeTitleTextStyle:
            cupertinoText.navLargeTitleTextStyle.merge(flexRounded),
        pickerTextStyle: cupertinoText.pickerTextStyle.merge(flexRegular),
        dateTimePickerTextStyle:
            cupertinoText.dateTimePickerTextStyle.merge(flexRegular),
      ),
    ),
    inputDecorationTheme: buildITKAppInputDecorationTheme(scheme),
    snackBarTheme: const SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(AppRadius.lg)),
      ),
    ),
  );
}

class ITKApp extends StatelessWidget {
  const ITKApp({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    final baseDarkScheme = ColorScheme.fromSeed(
      seedColor: _seedColor,
      brightness: Brightness.dark,
    );

    return ValueListenableBuilder<bool>(
      valueListenable: ThemeRepository.instance.oledMode,
      builder: (context, isOled, child) {
        final darkScheme = _darkSchemeFor(baseDarkScheme, isOled: isOled);

        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'ITK App',
          themeMode: ThemeMode.dark,
          darkTheme: _buildTheme(darkScheme),
          home: const AuthGate(),
          navigatorKey: navigatorKey,
        );
      },
    );
  }
}
