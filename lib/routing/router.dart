import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:itk_app/data/repositories/onboarding_repository.dart';
import 'package:itk_app/data/repositories/wiki_files_repository.dart';
import 'package:itk_app/ui/admin/admin_roles_screen.dart';
import 'package:itk_app/ui/app_scaffold.dart';
import 'package:itk_app/ui/calendar/calendar_screen.dart';
import 'package:itk_app/ui/calendar/calendar_links_screen.dart';
import 'package:itk_app/ui/core/navigator_key.dart';
import 'package:itk_app/ui/home/home_screen.dart';
import 'package:itk_app/ui/login/login_screen.dart';
import 'package:itk_app/ui/midterms/midterms_screen.dart';
import 'package:itk_app/ui/onboarding/onboarding_screen.dart';
import 'package:itk_app/ui/videos/videos_screen.dart';
import 'package:itk_app/ui/settings/settings_screen.dart';
import 'package:itk_app/ui/wiki/my_site_screen.dart';
import 'package:itk_app/ui/wiki/viewmodels/wiki_files_viewmodel.dart';
import 'package:itk_app/ui/wiki/wiki_files_screen.dart';
import 'package:itk_app/ui/wiki/wiki_screen.dart';
import 'package:provider/provider.dart';
import '../data/repositories/auth_repository.dart';
import 'routes.dart';

GoRouter router(
  AuthRepository authRepository,
  OnboardingRepository onboardingRepository,
) =>
    GoRouter(
      initialLocation: Routes.home,
      debugLogDiagnostics: true,
      navigatorKey: navigatorKey,
      redirect: (context, state) {
        final loggedIn = authRepository.isAuthenticated;
        final seenOnboarding = onboardingRepository.hasSeenOnboarding;
        final onLogin = state.matchedLocation == Routes.login;
        final onOnboarding = state.matchedLocation == Routes.onboarding;

        // If not logged in and is on the login screen do nothing, else redirect
        if (!loggedIn) return onLogin ? null : Routes.login;

        // If has not seen onboarding and is on the onboarding screen do nothing, else redirect
        if (!seenOnboarding.value) {
          return onOnboarding ? null : Routes.onboarding;
        }

        // If logged in and seen onboarding but visits either of these screens, redirect home
        if (onOnboarding || onLogin) return Routes.home;

        return null;
      },
      refreshListenable: Listenable.merge([
        authRepository,
        onboardingRepository.hasSeenOnboarding,
      ]),

      // Paths
      routes: [
        GoRoute(
          path: Routes.login,
          builder: (context, state) {
            return const LoginScreen();
          },
        ),
        GoRoute(
          path: Routes.onboarding,
          builder: (context, state) {
            return const OnboardingScreen();
          },
        ),
        StatefulShellRoute.indexedStack(
          builder: (context, state, navigationShell) => AppScaffold(navigationShell: navigationShell),
          branches: [
            // ----------------- [HOME] -----------------
            StatefulShellBranch(routes: [
              GoRoute(
                path: Routes.home,
                builder: (context, state) => const HomeScreen(),
              ),
            ]),
            // ----------------- [CAL] -----------------
            StatefulShellBranch(routes: [
              GoRoute(
                path: Routes.calendar,
                builder: (context, state) => const CalendarScreen(),
              ),
            ]),
            // ----------------- [WIKI] -----------------
            StatefulShellBranch(routes: [
              GoRoute(
                path: Routes.wiki,
                builder: (context, state) => const WikiScreen(),
                routes: [
                  GoRoute(
                    path: 'edit',
                    pageBuilder: (context, state) => _page(state, const MySiteScreen()),
                  ),
                  GoRoute(
                    path: 'files/:user',
                    pageBuilder: (context, state) {
                      final user = state.pathParameters['user']!; // /naszy
                      final dir = state.uri.queryParameters['dir'] ?? ''; // ?key=value -> dir=semester1

                      return _page(
                        state,
                        WikiFilesScreen(
                          viewModel: WikiFilesViewModel(
                            repository: context.read<WikiFilesRepository>(),
                            user: user,
                            dir: dir,
                          ),
                        ),
                      );
                    },
                  )
                ],
              ),
            ]),
            // ----------------- [SETTINGS] -----------------
            StatefulShellBranch(routes: [
              GoRoute(
                path: Routes.settings,
                builder: (context, state) => const SettingsScreen(),
              ),
            ]),
          ],
        ),
        GoRoute(
          path: Routes.adminRoles,
          pageBuilder: (context, state) => _page(state, const AdminRolesScreen()),
        ),
        GoRoute(
          path: Routes.midterms,
          pageBuilder: (context, state) => _page(state, const MidtermsScreen()),
        ),
        GoRoute(
          path: Routes.videos,
          pageBuilder: (context, state) => _page(state, const VideosScreen()),
        ),
        GoRoute(
          path: Routes.calendarLinks,
          pageBuilder: (context, state) => _page(state, const CalendarLinksScreen()),
        ),
      ],
    );

Page<void> _page(GoRouterState state, Widget child) => MaterialPage(child: child, key: state.pageKey);
