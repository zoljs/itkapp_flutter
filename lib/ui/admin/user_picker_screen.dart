import 'package:flutter/material.dart';
import 'package:itk_app/data/services/admin/users_service.dart';
import 'package:itk_app/domain/models/user_summary.dart';
import 'package:itk_app/ui/core/theme/app_spacing.dart';
import 'package:itk_app/ui/core/widgets/adaptive_sheet.dart';
import 'package:itk_app/ui/core/widgets/brand_appbar.dart';
import 'package:itk_app/ui/core/widgets/state_message.dart';
import 'package:itk_app/utils/result.dart';

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

  List<UserSummary> _users = const [];
  bool _loading = true;
  String? _error;

  List<UserSummary> get _filteredUsers {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) return _users;
    return _users
        .where((u) =>
            u.fullName.toLowerCase().contains(query) ||
            u.ldapUsername.toLowerCase().contains(query))
        .toList();
  }

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadUsers() async {
    setState(() {
      _error = null;
      _loading = true;
    });

    final result = await AdminUsersService.instance.getUsers();
    if (!mounted) return;

    switch (result) {
      case Ok(:final value):
        setState(() {
          _users = value;
          _loading = false;
        });
      case Err(:final message):
        setState(() {
          _error = message;
          _loading = false;
        });
    }
  }

  void _pick(UserSummary user) {
    widget.onPicked(user);
    closeSheet(context);
  }

  Widget _buildList(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator.adaptive());
    }
    if (_error != null) {
      return StateMessage(
        icon: Icons.cloud_off_rounded,
        message: _error!,
        onRetry: _loadUsers,
      );
    }

    final users = _filteredUsers;
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

  Widget _buildSearch(BuildContext context) {
    final bg = sheetBackgroundColor(context);

    return Container(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.screenHorizontal,
        AppSpacing.screenHorizontal,
        AppSpacing.screenHorizontal,
        MediaQuery.paddingOf(context).bottom + AppSpacing.screenHorizontal,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [bg.withValues(alpha: 0.0), bg],
          stops: const [0.0, 0.4],
        ),
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (_) => setState(() {}),
        textInputAction: TextInputAction.search,
        decoration: const InputDecoration(
          hintText: 'Név vagy felhasználónév...',
          prefixIcon: Icon(Icons.search_rounded),
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
          Positioned.fill(child: _buildList(context)),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _buildSearch(context),
          ),
        ],
      ),
    );
  }
}
