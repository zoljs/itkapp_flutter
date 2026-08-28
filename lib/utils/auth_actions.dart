import 'package:material_ui/material_ui.dart';
import 'package:itk_app/screens/login_screen.dart';
import 'package:itk_app/services/auth_service.dart';
import 'package:itk_app/services/sites_service.dart';

Future<void> performLogout(BuildContext context) async {
  await AuthService.instance.logout();
  SitesService.instance.clearCache();

  if (!context.mounted) return;

  Navigator.of(context).pushAndRemoveUntil(
    MaterialPageRoute(builder: (_) => const LoginScreen()),
    (route) => false,
  );
}
