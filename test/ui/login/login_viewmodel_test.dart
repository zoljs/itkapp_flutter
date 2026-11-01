import 'package:flutter_test/flutter_test.dart';
import 'package:itk_app/ui/login/viewmodels/login_viewmodel.dart';
import 'package:itk_app/utils/result.dart';

import '../../helpers/fake_repositories.dart';

void main() {
  test('a megadott adatokkal jelentkeztet be', () async {
    final auth = FakeAuthRepository();
    final viewModel = LoginViewModel(authRepository: auth);

    await viewModel.login.execute((username: 'perpa4', password: 'titok'));

    expect(auth.logins.single, ('perpa4', 'titok'));
    expect(viewModel.login.completed, isTrue);
    viewModel.dispose();
  });

  test('a hibás jelszó üzenete átjön', () async {
    final auth = FakeAuthRepository()..loginResult = const Err('Hibás felhasználónév vagy jelszó!');
    final viewModel = LoginViewModel(authRepository: auth);

    await viewModel.login.execute((username: 'perpa4', password: 'rossz'));

    expect(viewModel.login.errorMessage, 'Hibás felhasználónév vagy jelszó!');
    viewModel.dispose();
  });
}
