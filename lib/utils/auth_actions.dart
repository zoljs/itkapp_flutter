import 'package:flutter/material.dart';
import 'package:itk_app/data/repositories/auth_repository.dart';
import 'package:itk_app/data/repositories/calendar_repository.dart';
import 'package:itk_app/data/repositories/midterms_repository.dart';
import 'package:itk_app/data/repositories/subjects_repository.dart';
import 'package:itk_app/data/repositories/sites_repository.dart';
import 'package:itk_app/ui/core/navigator_key.dart';
import 'package:itk_app/utils/context_extensions.dart';
import 'package:provider/provider.dart';

Future<void> performLogout(BuildContext context) async {
  clearAllCaches(context);
  await context.read<AuthRepository>().logout();
}

Future<void> handleSessionExpired() async {
  final navigator = navigatorKey.currentState;
  if (navigator == null) return;
  final context = navigator.context;

  navigator.context.showMessage('A munkameneted lejárt, jelentkezz be újra.');

  clearAllCaches(context);
  await context.read<AuthRepository>().logout();
}

void clearAllCaches(BuildContext context) {
  context.read<SubjectsRepository>().clearCache();
  context.read<SitesRepository>().clearCache();
  context.read<CalendarRepository>().clearCache();
  context.read<MidtermsRepository>().clearCache();
}
