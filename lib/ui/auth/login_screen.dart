import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:itk_app/ui/app_scaffold.dart';
import 'package:itk_app/ui/core/theme/app_radius.dart';
import 'package:itk_app/ui/core/theme/app_spacing.dart';
import 'package:itk_app/ui/core/theme/app_themes.dart';
import 'package:itk_app/ui/core/widgets/brand_button.dart';
import '../../data/services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService.instance;

  bool _loading = false;
  bool _obscurePassword = true;
  String? _error;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    final result = await _authService.login(
      _usernameController.text.trim(),
      _passwordController.text,
    );

    if (!mounted) return;
    setState(() => _loading = false);

    if (result.success) {
      TextInput.finishAutofillContext();
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const AppScaffold()),
      );
    } else {
      setState(() => _error = result.errorMessage);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor:
              Theme.of(context).colorScheme.surfaceContainerHighest,
          content: Text(
            _error!,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        ),
      );
    }
  }

  InputDecoration _buildInputDecoration({
    required BuildContext context,
    required String hintText,
    required IconData prefixIcon,
    Widget? suffixIcon,
  }) {
    final scheme = Theme.of(context).colorScheme;

    return InputDecoration(
      hintText: hintText,
      prefixIcon: Icon(prefixIcon, size: 22, color: scheme.primary),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: scheme.surfaceContainerHigh,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: 18,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        borderSide: BorderSide(color: scheme.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        borderSide: BorderSide(color: scheme.error, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        borderSide: BorderSide(color: scheme.error, width: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: scheme.surface,
      body: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: const Alignment(0, -0.8),
            radius: 1.2,
            colors: [
              itkPrimary.withValues(alpha: 0.12),
              scheme.surface,
            ],
            stops: const [0.0, 0.6],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.xl,
                vertical: AppSpacing.xxl,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: itkPrimary.withValues(alpha: 0.2),
                          blurRadius: 24,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Image.asset(
                      'assets/icons/itkapp-small.png',
                      height: 84,
                      errorBuilder: (_, __, ___) => Icon(
                        Icons.school_rounded,
                        size: 72,
                        color: scheme.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxxl),
                  Text(
                    'Üdvözlünk újra',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: scheme.onSurface,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                    child: Text(
                      'Jelentkezz be a Shibboleth azonosítóddal a naptárad és többi feature eléréséhez.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        color: scheme.onSurfaceVariant,
                        height: 1.4,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxxxl),
                  Form(
                    key: _formKey,
                    child: AutofillGroup(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          TextFormField(
                            controller: _usernameController,
                            style: TextStyle(
                              color: scheme.onSurface,
                              fontWeight: FontWeight.w500,
                            ),
                            textInputAction: TextInputAction.next,
                            autofillHints: const [AutofillHints.username],
                            autocorrect: false,
                            enableSuggestions: false,
                            keyboardType: TextInputType.visiblePassword,
                            decoration: _buildInputDecoration(
                              context: context,
                              hintText: 'Felhasználónév (pl. naszy)',
                              prefixIcon: Icons.person_outline_rounded,
                            ),
                            validator: (value) =>
                                (value == null || value.trim().isEmpty)
                                    ? 'Kérlek, add meg a felhasználóneved.'
                                    : null,
                          ),
                          const SizedBox(height: AppSpacing.xxl),
                          TextFormField(
                            controller: _passwordController,
                            style: TextStyle(
                              color: scheme.onSurface,
                              fontWeight: FontWeight.w500,
                            ),
                            obscureText: _obscurePassword,
                            textInputAction: TextInputAction.done,
                            autofillHints: const [AutofillHints.password],
                            onFieldSubmitted: (_) => _submit(),
                            decoration: _buildInputDecoration(
                              context: context,
                              hintText: 'Jelszó',
                              prefixIcon: Icons.lock_outline_rounded,
                              suffixIcon: Padding(
                                padding: const EdgeInsets.only(right: 4.0),
                                child: IconButton(
                                  icon: Icon(
                                    _obscurePassword
                                        ? Icons.visibility_off_outlined
                                        : Icons.visibility_outlined,
                                    color: scheme.outline,
                                    size: 22,
                                  ),
                                  onPressed: () {
                                    setState(() =>
                                        _obscurePassword = !_obscurePassword);
                                  },
                                ),
                              ),
                            ),
                            validator: (value) =>
                                (value == null || value.isEmpty)
                                    ? 'Kérlek, add meg a jelszavad.'
                                    : null,
                          ),
                          const SizedBox(height: AppSpacing.xxxl),
                          BrandButton(
                            height: 56,
                            onTap: _loading ? null : _submit,
                            backgroundColor: itkPrimary,
                            child: Center(
                              child: _loading
                                  ? SizedBox(
                                      height: 24,
                                      width: 24,
                                      child: CircularProgressIndicator(
                                        valueColor: AlwaysStoppedAnimation(
                                            scheme.onPrimary),
                                        strokeWidth: 3,
                                      ),
                                    )
                                  : const Text(
                                      'Bejelentkezés',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 0.2,
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
