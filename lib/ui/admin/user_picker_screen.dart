import 'package:flutter/material.dart';
import 'package:itk_app/data/repositories/admin/admin_users_repository.dart';
import 'package:itk_app/domain/models/user_summary.dart';
import 'package:itk_app/ui/admin/viewmodels/user_picker_viewmodel.dart';
import 'package:itk_app/ui/core/screens/picker_screen.dart';
import 'package:itk_app/ui/core/widgets/adaptive_sheet.dart';
import 'package:itk_app/ui/core/widgets/picker_tile.dart';
import 'package:provider/provider.dart';
import 'package:skeletonizer/skeletonizer.dart';

class UserPickerScreen extends StatefulWidget {
  const UserPickerScreen({
    super.key,
    required this.onPicked,
    this.excludedIds = const {},
    this.scrollController,
  });

  final ValueChanged<UserSummary> onPicked;
  final Set<int> excludedIds;
  final ScrollController? scrollController;

  @override
  State<UserPickerScreen> createState() => _UserPickerScreenState();
}

class _UserPickerScreenState extends State<UserPickerScreen> {
  late final UserPickerViewModel _viewModel;

  static final _skeletonUsers = List.generate(
    10,
    (i) => UserSummary(
        userId: -i, fullName: BoneMock.name, ldapUsername: BoneMock.chars(6)),
  );

  @override
  void initState() {
    super.initState();
    _viewModel = UserPickerViewModel(
      repository: context.read<AdminUsersRepository>(),
    );
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  void _pick(UserSummary user) {
    widget.onPicked(user);
    closeSheet(context);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return PickerScreen<UserSummary>(
      viewModel: _viewModel,
      scrollController: widget.scrollController,
      title: 'Felhasználó',
      hintText: 'Felhasználó neve vagy loginja...',
      skeletonItems: _skeletonUsers,
      tileBuilder: (context, user) {
        final isExcluded = widget.excludedIds.contains(user.userId);
        return PickerTile(
          title: user.fullName,
          subtitle: isExcluded
              ? '${user.ldapUsername} · már évfolyamfelelős'
              : user.ldapUsername,
          onTap: isExcluded ? null : () => _pick(user),
          trailing: isExcluded
              ? Icon(Icons.check_rounded, color: scheme.onSurfaceVariant)
              : null,
        );
      },
      closesSheet: true,
    );
  }
}
