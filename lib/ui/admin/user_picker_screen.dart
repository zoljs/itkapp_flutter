import 'package:flutter/material.dart';
import 'package:itk_app/data/repositories/admin/admin_users_repository.dart';
import 'package:itk_app/domain/models/user_summary.dart';
import 'package:itk_app/ui/admin/viewmodels/user_picker_viewmodel.dart';
import 'package:itk_app/ui/core/theme/app_spacing.dart';
import 'package:itk_app/ui/core/widgets/adaptive_sheet.dart';
import 'package:itk_app/ui/core/widgets/brand_appbar.dart';
import 'package:itk_app/ui/core/widgets/picker_search_field.dart';
import 'package:itk_app/ui/core/widgets/state_message.dart';
import 'package:provider/provider.dart';

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
  final _searchController = TextEditingController();
  late final UserPickerViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = UserPickerViewModel(
      repository: context.read<AdminUsersRepository>(),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  void _pick(UserSummary user) {
    widget.onPicked(user);
    closeSheet(context);
  }

  Widget _buildList(BuildContext context) {
    if (_viewModel.load.running) {
      return const Center(child: CircularProgressIndicator.adaptive());
    }
    if (_viewModel.load.errorMessage != null) {
      return StateMessage(
        icon: Icons.cloud_off_rounded,
        message: _viewModel.load.errorMessage!,
        onRetry: _viewModel.load.execute,
      );
    }

    final users = _viewModel.filteredUsers;
    return ListView.separated(
      controller: widget.scrollController,
      padding: EdgeInsets.only(
        top: AppSpacing.sm,
        bottom: MediaQuery.paddingOf(context).bottom + 80,
      ),
      itemCount: users.length,
      itemBuilder: (context, index) => _buildUserRow(context, users[index]),
      separatorBuilder: (context, index) => const Divider(height: 1),
    );
  }

  Widget _buildUserRow(BuildContext context, UserSummary user) {
    final scheme = Theme.of(context).colorScheme;
    final isExcluded = widget.excludedIds.contains(user.userId);

    return InkWell(
      onTap: isExcluded ? null : () => _pick(user),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.screenHorizontal,
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 64.0),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.fullName,
                      style: TextStyle(
                        fontSize: 15,
                        color: isExcluded
                            ? scheme.onSurfaceVariant
                            : scheme.onSurface,
                      ),
                    ),
                    Text(
                      isExcluded
                          ? '${user.ldapUsername} · már évfolyamfelelős'
                          : user.ldapUsername,
                      style: TextStyle(
                        fontSize: 13,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              if (isExcluded)
                Icon(Icons.check_rounded, color: scheme.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: sheetBackgroundColor(context),
      appBar: buildBrandAppBar(
        context: context,
        title: 'Felhasználó',
        closesSheet: true,
      ),
      body: Stack(
        children: [
          Positioned.fill(
              child: ListenableBuilder(
                  listenable: _viewModel,
                  builder: (context, _) {
                    return _buildList(context);
                  })),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: PickerSearchField(
              searchController: _searchController,
              onChanged: (value) => _viewModel.setQuery(value),
              hintText: 'Felhasználó neve vagy loginja...',
            ),
          ),
        ],
      ),
    );
  }
}
