import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:itk_app/screens/app_scaffold.dart';
import 'package:itk_app/theme/app_spacing.dart';
import 'package:itk_app/widgets/field_label.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show SystemUiOverlayStyle, TextInput;
import '../services/auth_service.dart';

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
      // is what triggers the native "save password?" prompt.
      TextInput.finishAutofillContext();
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const AppScaffold()),
      );
    } else {
      setState(() => _error = result.errorMessage);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(_error!)));
    }
  }

  Widget _buildDualCardHeader() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(40),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: 0,
            right: 64,
            top: 0,
            child: Container(
              height: 150,
              decoration: BoxDecoration(
                color: const Color(0xFFD6E4FB),
                borderRadius: BorderRadius.circular(20),
              ),
              alignment: Alignment.center,
              child: Image.asset(
                'assets/icons/itkapp-small.png',
                height: 64,
                errorBuilder: (_, __, ___) => Icon(
                  Icons.school_outlined,
                  size: 56,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
          ),
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: 148,
              height: 100,
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: const Color(0xFFF7D9E4),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Icon(Icons.flutter_dash_outlined,
                      color: Colors.black, size: 22),
                  SizedBox(height: 10),
                  Text(
                    'Made with Flutter and ❤️',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                      height: 1.25,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(40),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg, vertical: AppSpacing.xxxl),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const Text(
                'Üdvözlünk újra',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  height: 1.15,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Jelentkezz be az Shibboleth azonosítóddal a naptárad és értesítéseid eléréséhez.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 32),
              AutofillGroup(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const FieldLabel('Felhasználónév'),
                    TextFormField(
                      controller: _usernameController,
                      decoration: const InputDecoration(hintText: 'pl. naszy'),
                      style: const TextStyle(color: Colors.black87),
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.username],
                    ),
                    const SizedBox(height: 18),
                    const FieldLabel('Jelszó'),
                    TextFormField(
                      controller: _passwordController,
                      decoration: InputDecoration(
                        hintText: 'Add meg a jelszavad',
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: Colors.black87,
                            size: 20,
                          ),
                          onPressed: () {
                            setState(
                                () => _obscurePassword = !_obscurePassword);
                          },
                        ),
                      ),
                      style: const TextStyle(color: Colors.black87),
                      obscureText: _obscurePassword,
                      textInputAction: TextInputAction.done,
                      autofillHints: const [AutofillHints.password],
                      onFieldSubmitted: (_) => _submit(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              SizedBox(
                height: 56,
                child: AdaptiveButton.child(
                  style: AdaptiveButtonStyle.filled,
                  useSmoothRectangleBorder: false,
                  minSize: const Size(double.infinity, 52),
                  enabled: !_loading,
                  onPressed: _loading ? null : _submit,
                  child: _loading
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator.adaptive(),
                        )
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Bejelentkezés',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final padding = MediaQuery.paddingOf(context);

    final availableHeight = size.height - padding.top - padding.bottom;
    const spacing = 14.0;
    final usableHeight = availableHeight - spacing;

    final topCardHeight =
        (usableHeight * (7 / 20)).clamp(150.0, double.infinity);
    final bottomCardHeight =
        (usableHeight * (13 / 20)).clamp(400.0, double.infinity);

    final ambientScheme = Theme.of(context).colorScheme;
    final forcedLightScheme = ColorScheme.fromSeed(
      seedColor: ambientScheme.primary,
      brightness: Brightness.light,
    );

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Theme(
        data: Theme.of(context).copyWith(
          colorScheme: forcedLightScheme,
          inputDecorationTheme: Theme.of(context).inputDecorationTheme.copyWith(
                fillColor: forcedLightScheme.surfaceContainerHigh,
                hintStyle: TextStyle(
                    color: forcedLightScheme.onSurfaceVariant, fontSize: 15),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide:
                      BorderSide(color: forcedLightScheme.primary, width: 2),
                ),
              ),
        ),
        child: Scaffold(
          backgroundColor: Colors.black,
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(
                    height: topCardHeight,
                    child: _buildDualCardHeader(),
                  ),
                  const SizedBox(height: spacing),
                  SizedBox(
                    height: bottomCardHeight,
                    child: _buildFormCard(),
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
