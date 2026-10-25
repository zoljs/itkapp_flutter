import 'package:flutter/foundation.dart';
import 'package:itk_app/data/services/auth_service.dart';
import 'package:itk_app/utils/command.dart';
import 'package:itk_app/utils/result.dart';

typedef Credentials = ({String username, String password});

class LoginViewModel extends ChangeNotifier {
  final AuthService _authService;

  late final Command1<void, Credentials> login;

  LoginViewModel({
    required AuthService authService,
  }) : _authService = authService {
    login = Command1<void, Credentials>(_login);
  }

  factory LoginViewModel.create() => LoginViewModel(
        authService: AuthService.instance,
      );

  Future<Result<void>> _login(Credentials credentials) async {
    return await _authService.login(credentials.username, credentials.password);
  }
}
