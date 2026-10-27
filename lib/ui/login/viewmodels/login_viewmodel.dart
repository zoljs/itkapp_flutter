import 'package:flutter/foundation.dart';
import 'package:itk_app/data/repositories/auth_repository.dart';
import 'package:itk_app/utils/command.dart';
import 'package:itk_app/utils/result.dart';

typedef Credentials = ({String username, String password});

class LoginViewModel extends ChangeNotifier {
  final AuthRepository _authRepository;

  late final Command1<void, Credentials> login;

  LoginViewModel({
    required AuthRepository authRepository,
  }) : _authRepository = authRepository {
    login = Command1<void, Credentials>(_login);
  }

  @override
  void dispose() {
    login.dispose();
    super.dispose();
  }

  Future<Result<void>> _login(Credentials credentials) async {
    return await _authRepository.login(credentials.username, credentials.password);
  }
}
