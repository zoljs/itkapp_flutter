import 'package:flutter/material.dart';
import 'package:itk_app/data/repositories/auth_repository.dart';
import 'package:itk_app/data/repositories/calendar_repository.dart';
import 'package:itk_app/data/repositories/subjects_repository.dart';
import 'package:itk_app/ui/login/login_screen.dart';
import 'package:itk_app/data/repositories/sites_repository.dart';
import 'package:itk_app/ui/core/navigator_key.dart';
import 'package:itk_app/utils/context_extensions.dart';

Future<void> performLogout(BuildContext context) async {
  await AuthRepository.instance.logout();
  SubjectsRepository.instance.clearCache();
  SitesRepository.instance.clearCache();
  CalendarRepository.instance.clearCache();

  if (!context.mounted) return;

  Navigator.of(context).pushAndRemoveUntil(
    MaterialPageRoute(builder: (_) => const LoginScreen()),
    (route) => false,
  );
}

Future<void> handleSessionExpired() async {
  final navigator = navigatorKey.currentState;
  if (navigator == null) return;

  await AuthRepository.instance.logout();
  SitesRepository.instance.clearCache();
  CalendarRepository.instance.clearCache();

  if (!navigator.mounted) return;

  navigator.pushAndRemoveUntil(
    MaterialPageRoute(builder: (_) => const LoginScreen()),
    (_) => false,
  );

  navigator.context.showMessage('A munkameneted lejárt, jelentkezz be újra.');
}

void clearAllCaches() {
  SubjectsRepository.instance.clearCache();
  SitesRepository.instance.clearCache();
  CalendarRepository.instance.clearCache();
}
