import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:itk_app/data/repositories/admin/admin_roles_repository.dart';
import 'package:itk_app/data/repositories/admin/admin_users_repository.dart';
import 'package:itk_app/data/repositories/auth_repository.dart';
import 'package:itk_app/data/repositories/calendar_repository.dart';
import 'package:itk_app/data/repositories/midterms_repository.dart';
import 'package:itk_app/data/repositories/onboarding_repository.dart';
import 'package:itk_app/data/repositories/sites_repository.dart';
import 'package:itk_app/data/repositories/subjects_repository.dart';
import 'package:itk_app/data/repositories/theme_repository.dart';
import 'package:itk_app/data/repositories/videos_repository.dart';
import 'package:itk_app/data/repositories/wiki_files_repository.dart';
import 'package:itk_app/data/services/shared_preferences_service.dart';
import 'package:itk_app/data/services/users_client.dart';
import 'package:itk_app/routing/router.dart';
import 'package:itk_app/ui/core/theme/app_fonts.dart';
import 'package:itk_app/ui/core/theme/app_radius.dart';
import 'package:itk_app/ui/core/theme/app_themes.dart';
import 'package:flutter/services.dart';
import 'package:itk_app/utils/auth_actions.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'data/services/api_client.dart';
import 'package:intl/date_symbol_data_local.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final apiClient = await ApiClient.create();
  final prefs = SharedPreferencesService(await SharedPreferences.getInstance());

  final themeRepository = ThemeRepository(prefs: prefs);
  final onboardingRepository = OnboardingRepository(prefs: prefs);
  final authRepository = AuthRepository(apiClient: apiClient, prefs: prefs);
  unawaited(authRepository.refreshUser());
  apiClient.onUnauthorized = handleSessionExpired;

  final appRouter = router(authRepository, onboardingRepository);

  initializeDateFormatting().then(
    (_) => runApp(
      MultiProvider(
        providers: [
          Provider.value(value: apiClient),
          Provider.value(value: prefs),
          Provider.value(value: themeRepository),
          Provider.value(value: onboardingRepository),
          ChangeNotifierProvider.value(value: authRepository),
          Provider(create: (context) => CalendarRepository(apiClient: context.read<ApiClient>())),
          Provider(create: (context) => MidtermsRepository(apiClient: context.read<ApiClient>())),
          Provider(
            create: (context) => SitesRepository(apiClient: context.read<ApiClient>()),
          ),
          Provider(create: (context) => SubjectsRepository(apiClient: context.read<ApiClient>())),
          Provider(create: (_) => UsersClient()),
          Provider(create: (context) => WikiFilesRepository(usersClient: context.read<UsersClient>())),
          Provider(create: (context) => AdminRolesRepository(apiClient: context.read<ApiClient>())),
          Provider(create: (context) => AdminUsersRepository(apiClient: context.read<ApiClient>())),
          Provider(create: (context) => VideosRepository(apiClient: context.read<ApiClient>())),
        ],
        child: ITKApp(appRouter: appRouter),
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
  final TextTheme base = ThemeData(colorScheme: scheme, useMaterial3: true).textTheme;
  final cupertinoText = const CupertinoThemeData().textTheme;

  return ThemeData(
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: ZoomPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
      },
    ),
    colorScheme: scheme,
    useMaterial3: true,
    splashFactory: defaultTargetPlatform == TargetPlatform.iOS ? NoSplash.splashFactory : null,
    textTheme: buildITKAppTextTheme(base),
    cupertinoOverrideTheme: CupertinoThemeData(
      textTheme: cupertinoText.copyWith(
        textStyle: cupertinoText.textStyle.merge(flexRegular),
        actionTextStyle: cupertinoText.actionTextStyle.merge(flexRegular),
        navTitleTextStyle: cupertinoText.navTitleTextStyle.merge(flexRounded),
        navLargeTitleTextStyle: cupertinoText.navLargeTitleTextStyle.merge(flexRounded),
        pickerTextStyle: cupertinoText.pickerTextStyle.merge(flexRegular),
        dateTimePickerTextStyle: cupertinoText.dateTimePickerTextStyle.merge(flexRegular),
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
  const ITKApp({super.key, required this.appRouter});

  final GoRouter appRouter;

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
      valueListenable: context.watch<ThemeRepository>().oledMode,
      builder: (context, isOled, child) {
        final darkScheme = _darkSchemeFor(baseDarkScheme, isOled: isOled);

        return MaterialApp.router(
          debugShowCheckedModeBanner: false,
          title: 'ITK App',
          themeMode: ThemeMode.dark,
          darkTheme: _buildTheme(darkScheme),
          routerConfig: appRouter,
        );
      },
    );
  }
}
