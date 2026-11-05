import 'package:itk_app/data/repositories/admin/admin_users_repository.dart';
import 'package:itk_app/domain/models/user_summary.dart';
import 'package:itk_app/ui/core/screens/viewmodels/picker_viewmodel.dart';

class UserPickerViewModel extends PickerViewModel<UserSummary> {
  UserPickerViewModel({required AdminUsersRepository repository})
      : super(
          fetch: repository.get,
          matches: (summary, query) =>
              summary.fullName.toLowerCase().contains(query) ||
              summary.ldapUsername.toLowerCase().contains(query),
        );
}
