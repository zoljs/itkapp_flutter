import 'package:itk_app/data/repositories/auth_repository.dart';
import 'package:itk_app/data/repositories/onboarding_repository.dart';
import 'package:itk_app/ui/app_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:itk_app/ui/onboarding/onboarding_screen.dart';
import 'login_screen.dart';

/// Shown on app start. Calls GET /api/auth/me to see if a valid session
/// cookie already exists (from a previous app run) and routes straight
/// to Home if so, otherwise to the login form.
class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  final _authRepository = AuthRepository.instance;

  @override
  void initState() {
    super.initState();
    _checkSession();
  }

  Future<void> _checkSession() async {
    final user = await _authRepository.getSessionUser();
    if (!mounted) return;

    final Widget next;
    if (user == null) {
      next = const LoginScreen();
    } else if (!OnboardingRepository.instance.hasSeenOnboarding.value) {
      next = const OnboardingScreen();
    } else {
      next = const AppScaffold();
    }

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => next,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
