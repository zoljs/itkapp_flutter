import 'package:itk_app/models/user.dart';
import 'package:itk_app/services/auth_service.dart';
import 'package:itk_app/theme/app_fonts.dart';
import 'package:itk_app/utils/auth_actions.dart';
import 'package:itk_app/widgets/field_label.dart';
import 'package:itk_app/widgets/section_card.dart';
import 'package:material_ui/material_ui.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _authService = AuthService.instance;
  LdapUser? _currentUser;

  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadCurrentUser() async {
    final user = await _authService.getSessionUser();
    if (!mounted) return;
    setState(() => _currentUser = user);
  }

  @override
  Widget build(BuildContext context) {
    // Full size is 320: 260 + 60 preferredSize height
    const collapsedHeight = 60.0;
    const expandedHeight = 260.0;
    const preferredSizeHeight = 60.0;
    const fullHeight = expandedHeight + preferredSizeHeight;
    const halfHeight = fullHeight / 2;
    const separatorOffset = 20.0;
    const cardAlignY = (separatorOffset + 0) / 100.0;
    const separatorHeight = halfHeight + separatorOffset;

    return Scaffold(
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: expandedHeight,
                collapsedHeight: collapsedHeight,
                floating: true,
                pinned: true,
                scrolledUnderElevation: 0,
                // backgroundColor: Colors.amber, //test
                backgroundColor: Theme.of(context).colorScheme.surface,
                actionsPadding: const EdgeInsets.symmetric(horizontal: 16),
                actions: [
                  SizedBox(
                    width: 40,
                    height: 40,
                    child: IconButton(
                      onPressed: () => performLogout(context),
                      icon: Icon(Icons.logout_rounded,
                          color: Theme.of(context).colorScheme.onSurface,
                          size: 20),
                      style: IconButton.styleFrom(
                        backgroundColor:
                            Theme.of(context).colorScheme.surfaceContainer,
                        shape: const CircleBorder(),
                        padding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  collapseMode: CollapseMode.pin,
                  title: Text(
                    'Beállítások',
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.merge(topBarTitleStyle),
                  ),
                  centerTitle: true,
                  background: Stack(
                    children: [
                      Align(
                        alignment: Alignment.topCenter,
                        child: Container(
                          height: separatorHeight,
                          color: Theme.of(context).colorScheme.primaryContainer,
                        ),
                      ),
                      Align(
                        // Push by 20px
                        alignment: const Alignment(0, cardAlignY),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: CircleAvatar(
                            backgroundColor:
                                Theme.of(context).colorScheme.surface,
                            radius: 55,
                            child: CircleAvatar(
                              backgroundColor:
                                  Theme.of(context).colorScheme.primary,
                              radius: 45,
                              child: Text(
                                '${_currentUser?.login[0].toUpperCase()}',
                                style: const TextStyle(
                                    fontSize: 28, fontWeight: FontWeight.w900),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 140),
                sliver: SliverFillRemaining(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SectionCard(
                        title: 'Profil',
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const FieldLabel('Név'),
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Theme.of(context)
                                    .colorScheme
                                    .surfaceContainerHigh,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.warning_amber_rounded,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .primary),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '${_currentUser?.login}',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 14,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onSurface,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Ez a bejelentkezett fiókodhoz van rögzítve, nem módosítható.',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onSurfaceVariant,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      SectionCard(
                        title: 'WIKI Oldal',
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const FieldLabel('Név'),
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Theme.of(context)
                                    .colorScheme
                                    .surfaceContainerHigh,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.warning_amber_rounded,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .primary),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '${_currentUser?.login}',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 14,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onSurface,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Ez a bejelentkezett fiókodhoz van rögzítve, nem módosítható.',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onSurfaceVariant,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
