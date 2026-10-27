import 'package:flutter/material.dart';
import 'package:itk_app/data/repositories/admin/admin_roles_repository.dart';
import 'package:itk_app/data/repositories/theme_repository.dart';
import 'package:itk_app/domain/models/user_summary.dart';
import 'package:itk_app/ui/admin/user_picker_screen.dart';
import 'package:itk_app/ui/admin/viewmodels/admin_roles_viewmodel.dart';
import 'package:itk_app/ui/core/theme/app_spacing.dart';
import 'package:itk_app/ui/core/widgets/adaptive_sheet.dart';
import 'package:itk_app/ui/core/widgets/brand_appbar.dart';
import 'package:itk_app/ui/core/widgets/confirm_dialog.dart';
import 'package:itk_app/ui/core/widgets/grouped_list.dart';
import 'package:itk_app/ui/core/widgets/state_message.dart';
import 'package:itk_app/utils/context_extensions.dart';
import 'package:provider/provider.dart';

class AdminRolesScreen extends StatefulWidget {
  const AdminRolesScreen({super.key});

  @override
  State<AdminRolesScreen> createState() => _AdminRolesScreenState();
}

class _AdminRolesScreenState extends State<AdminRolesScreen> {
  late final AdminRolesViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = AdminRolesViewModel(
      repository: context.read<AdminRolesRepository>(),
    );
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  Future<void> _openUserPicker() async {
    UserSummary? picked;
    await showAdaptiveSheet<void>(
      context: context,
      builder: (context, controller) => UserPickerScreen(
        scrollController: controller,
        excludedIds: {for (final u in _viewModel.roleHolders) u.userId},
        onPicked: (user) => picked = user,
      ),
    );

    final user = picked;
    if (user == null || !mounted) return;

    await _viewModel.assign.execute(user.userId);
    if (!mounted) return;

    final error = _viewModel.assign.errorMessage;
    context.showMessage(error ?? '${user.fullName} évfolyamfelelős lett.');
  }

  Widget _buildRow(UserSummary user) {
    final scheme = Theme.of(context).colorScheme;

    return Dismissible(
      key: ValueKey(user.userId),
      direction: DismissDirection.endToStart,
      background: Container(
        color: scheme.error,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        child: Icon(Icons.person_remove_rounded, color: scheme.onError),
      ),
      confirmDismiss: (_) async =>
          await showConfirmDialog(
            context,
            title: 'Rang visszavonása',
            message: '${user.fullName} többé nem lesz évfolyamfelelős.',
            confirmLabel: 'Visszavonás',
            isDestructive: true,
          ) ==
          true,
      onDismissed: (_) async {
        await _viewModel.revoke.execute(user.userId);
        if (!mounted) return;
        final error = _viewModel.revoke.errorMessage;
        if (error != null) context.showMessage(error);
      },
      child: SettingsTile(
        title: user.fullName,
        value: user.ldapUsername,
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (_viewModel.initialLoading) {
      return const Center(child: CircularProgressIndicator.adaptive());
    }
    if (_viewModel.load.errorMessage != null) {
      return Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: StateMessage(
          icon: Icons.cloud_off_rounded,
          message: _viewModel.load.errorMessage!,
          onRetry: _viewModel.load.execute,
        ),
      );
    }
    if (_viewModel.roleHolders.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(AppSpacing.xxl),
        child: StateMessage(
          icon: Icons.group_off_rounded,
          message: 'Még nincs évfolyamfelelős.',
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _viewModel.load.execute,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        padding: EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.lg,
          AppSpacing.lg,
          MediaQuery.paddingOf(context).bottom + AppSpacing.xxl,
        ),
        children: [
          SettingsGroup(
            header: 'Évfolyamfelelősök',
            footer: 'Az évfolyamfelelősök bármely ZH-t felvehetik és törölhetik. '
                'Balra húzva visszavonhatod a rangot.',
            children: [for (final u in _viewModel.roleHolders) _buildRow(u)],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: context.watch<ThemeRepository>().actionButtonAsFab,
      builder: (context, asFab, _) => Scaffold(
        appBar: buildBrandAppBar(
          context: context,
          title: 'Jogosultságok',
          actionIcon: Icons.add_rounded,
          actionLabel: 'Kinevezés',
          onAction: asFab ? null : _openUserPicker,
        ),
        body: ListenableBuilder(
          listenable: Listenable.merge([_viewModel, _viewModel.load]),
          builder: (context, _) => _buildBody(context),
        ),
        floatingActionButton: asFab
            ? buildBrandFab(
                icon: Icons.add_rounded,
                semanticLabel: "Új jogosultság felvétele",
                onPressed: _openUserPicker,
              )
            : null,
      ),
    );
  }
}
