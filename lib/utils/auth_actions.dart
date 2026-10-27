import 'package:flutter/material.dart';
import 'package:itk_app/data/repositories/auth_repository.dart';
import 'package:itk_app/data/repositories/calendar_repository.dart';
import 'package:itk_app/data/repositories/subjects_repository.dart';
import 'package:itk_app/ui/login/login_screen.dart';
import 'package:itk_app/data/repositories/sites_repository.dart';
import 'package:itk_app/ui/core/navigator_key.dart';
import 'package:itk_app/utils/context_extensions.dart';
import 'package:provider/provider.dart';

Future<void> performLogout(BuildContext context) async {
  context.read<SubjectsRepository>().clearCache();
  context.read<SitesRepository>().clearCache();
  context.read<CalendarRepository>().clearCache();
  await context.read<AuthRepository>().logout();

  if (!context.mounted) return;

  Navigator.of(context).pushAndRemoveUntil(
    MaterialPageRoute(builder: (_) => const LoginScreen()),
    (route) => false,
  );
}

Future<void> handleSessionExpired() async {
  final navigator = navigatorKey.currentState;
  if (navigator == null) return;
  final context = navigator.context;

  navigator.context.showMessage('A munkameneted lejárt, jelentkezz be újra.');

  context.read<SubjectsRepository>().clearCache();
  context.read<SitesRepository>().clearCache();
  context.read<CalendarRepository>().clearCache();
  await context.read<AuthRepository>().logout();
}
