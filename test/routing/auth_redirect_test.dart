import 'package:flutter_test/flutter_test.dart';
import 'package:itk_app/routing/router.dart';
import 'package:itk_app/routing/routes.dart';

void main() {
  // Every combination of the two gates and the kind of location.
  final cases = <({
    bool loggedIn,
    bool seenOnboarding,
    String location,
    String? expected,
  })>[
    // Not logged in: everything except the login screen goes to login.
    (
      loggedIn: false,
      seenOnboarding: false,
      location: Routes.login,
      expected: null
    ),
    (
      loggedIn: false,
      seenOnboarding: false,
      location: Routes.home,
      expected: Routes.login
    ),
    (
      loggedIn: false,
      seenOnboarding: false,
      location: Routes.onboarding,
      expected: Routes.login
    ),
    (
      loggedIn: false,
      seenOnboarding: true,
      location: Routes.calendar,
      expected: Routes.login
    ),
    (
      loggedIn: false,
      seenOnboarding: true,
      location: Routes.filesFor('abc'),
      expected: Routes.login
    ),
    (
      loggedIn: false,
      seenOnboarding: true,
      location: Routes.login,
      expected: null
    ),

    // Logged in, onboarding not seen: everything goes to onboarding.
    (
      loggedIn: true,
      seenOnboarding: false,
      location: Routes.onboarding,
      expected: null
    ),
    (
      loggedIn: true,
      seenOnboarding: false,
      location: Routes.home,
      expected: Routes.onboarding
    ),
    (
      loggedIn: true,
      seenOnboarding: false,
      location: Routes.login,
      expected: Routes.onboarding
    ),
    (
      loggedIn: true,
      seenOnboarding: false,
      location: Routes.settings,
      expected: Routes.onboarding
    ),

    // Logged in, onboarding seen: login and onboarding go home, the rest stays.
    (
      loggedIn: true,
      seenOnboarding: true,
      location: Routes.login,
      expected: Routes.home
    ),
    (
      loggedIn: true,
      seenOnboarding: true,
      location: Routes.onboarding,
      expected: Routes.home
    ),
    (
      loggedIn: true,
      seenOnboarding: true,
      location: Routes.home,
      expected: null
    ),
    (
      loggedIn: true,
      seenOnboarding: true,
      location: Routes.calendar,
      expected: null
    ),
    (
      loggedIn: true,
      seenOnboarding: true,
      location: Routes.midterms,
      expected: null
    ),
    (
      loggedIn: true,
      seenOnboarding: true,
      location: Routes.filesFor('abc'),
      expected: null
    ),
  ];

  for (final c in cases) {
    test(
        'loggedIn: ${c.loggedIn}, onboarding seen: ${c.seenOnboarding}, '
        '${c.location} -> ${c.expected ?? 'stays'}', () {
      expect(
        authRedirect(
          loggedIn: c.loggedIn,
          seenOnboarding: c.seenOnboarding,
          location: c.location,
        ),
        c.expected,
      );
    });
  }
}
