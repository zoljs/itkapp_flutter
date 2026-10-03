import 'package:flutter/material.dart';
import 'package:itk_app/data/services/calendar_service.dart';
import 'package:itk_app/ui/auth/login_screen.dart';
import 'package:itk_app/data/services/auth_service.dart';
import 'package:itk_app/data/services/sites_service.dart';
import 'package:itk_app/ui/core/navigator_key.dart';

Future<void> performLogout(BuildContext context) async {
  await AuthService.instance.logout();
  SitesService.instance.clearCache();
  CalendarService.instance.clearCache();

  if (!context.mounted) return;

  Navigator.of(context).pushAndRemoveUntil(
    MaterialPageRoute(builder: (_) => const LoginScreen()),
    (route) => false,
  );
}

Future<void> handleSessionExpired() async {
  final navigator = navigatorKey.currentState;
  if (navigator == null) return;

  await AuthService.instance.logout();
  SitesService.instance.clearCache();
  CalendarService.instance.clearCache();

  if (!navigator.mounted) return;

  navigator.pushAndRemoveUntil(
    MaterialPageRoute(builder: (_) => const LoginScreen()),
    (_) => false,
  );

  ScaffoldMessenger.of(navigator.context).showSnackBar(
    const SnackBar(content: Text('A munkameneted lejárt, jelentkezz be újra.')),
  );
}
