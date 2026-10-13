import 'package:flutter/material.dart';
import 'package:itk_app/data/services/admin/roles_service.dart';
import 'package:itk_app/data/services/theme_service.dart';
import 'package:itk_app/domain/models/user_summary.dart';
import 'package:itk_app/ui/admin/user_picker_screen.dart';
import 'package:itk_app/ui/core/theme/app_spacing.dart';
import 'package:itk_app/ui/core/widgets/adaptive_sheet.dart';
import 'package:itk_app/ui/core/widgets/brand_appbar.dart';
import 'package:itk_app/ui/core/widgets/confirm_dialog.dart';
import 'package:itk_app/ui/core/widgets/grouped_list.dart';
import 'package:itk_app/ui/core/widgets/state_message.dart';
import 'package:itk_app/utils/context_extensions.dart';
import 'package:itk_app/utils/result.dart';

class AdminRolesScreen extends StatefulWidget {
  const AdminRolesScreen({super.key});

  @override
  State<AdminRolesScreen> createState() => _AdminRolesScreenState();
}

class _AdminRolesScreenState extends State<AdminRolesScreen> {
  List<UserSummary> _holders = const [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _error = null;
      if (_holders.isEmpty) _loading = true;
    });

    final result = await AdminRolesService.instance.getRoleHolders();
    if (!mounted) return;

    switch (result) {
      case Ok(:final value):
        setState(() {
          _holders = value;
          _loading = false;
        });
      case Err(:final message):
        setState(() {
          _error = message;
          _loading = false;
        });
    }
  }

  Future<void> _openUserPicker() async {
    UserSummary? picked;
    await showAdaptiveSheet<void>(
      context: context,
      builder: (context, controller) => UserPickerScreen(
        scrollController: controller,
        excludedIds: {for (final u in _holders) u.userId},
        onPicked: (user) => picked = user,
      ),
    );

    final user = picked;
    if (user == null || !mounted) return;

    final result =
        await AdminRolesService.instance.assignCohortRep(user.userId);
    if (!mounted) return;

    switch (result) {
      case Ok():
        context.showMessage('${user.fullName} évfolyamfelelős lett.');
        _load();
      case Err(:final message):
        context.showMessage(message);
    }
  }

  Future<bool> _confirmAndRevoke(UserSummary user) async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Rang visszavonása',
      message: '${user.fullName} többé nem lesz évfolyamfelelős.',
      confirmLabel: 'Visszavonás',
      isDestructive: true,
    );
    if (confirmed != true) return false;

    final result = await AdminRolesService.instance.revokeRole(user.userId);
    if (!mounted) return false;

    switch (result) {
      case Ok():
        return true;
      case Err(:final message):
        context.showMessage(message);
        return false;
    }
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
      confirmDismiss: (_) => _confirmAndRevoke(user),
      onDismissed: (_) => setState(() {
        _holders = _holders.where((u) => u.userId != user.userId).toList();
      }),
      child: SettingsTile(
        title: user.fullName,
        value: user.ldapUsername,
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator.adaptive());
    }
    if (_error != null) {
      return Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: StateMessage(
          icon: Icons.cloud_off_rounded,
          message: _error!,
          onRetry: _load,
        ),
      );
    }
    if (_holders.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(AppSpacing.xxl),
        child: StateMessage(
          icon: Icons.group_off_rounded,
          message: 'Még nincs évfolyamfelelős.',
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _load,
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
            footer:
                'Az évfolyamfelelősök bármely ZH-t felvehetik és törölhetik. '
                'Balra húzva visszavonhatod a rangot.',
            children: [for (final u in _holders) _buildRow(u)],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: ThemeService.instance.actionButtonAsFab,
      builder: (context, asFab, _) => Scaffold(
        appBar: buildBrandAppBar(
          context: context,
          title: 'Jogosultságok',
          actionIcon: Icons.add_rounded,
          actionLabel: 'Kinevezés',
          onAction: asFab ? null : _openUserPicker,
        ),
        body: _buildBody(context),
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
