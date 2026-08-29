import 'package:itk_app/services/auth_service.dart';
import 'package:itk_app/theme/app_fonts.dart';
import 'package:itk_app/utils/auth_actions.dart';
import 'package:material_ui/material_ui.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _authService = AuthService.instance;

  final _searchController = TextEditingController();
  int? _currentUserId = AuthService.instance.cachedUser?.id;

  Future<void> _loadCurrentUser() async {
    final user = await _authService.getSessionUser();
    if (!mounted) return;
    setState(() => _currentUserId = user?.id);
  }

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
                              child: Text('$_currentUserId'),
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
                sliver: SliverList.separated(
                  itemCount: 20,
                  itemBuilder: (context, index) => const SizedBox(
                    height: 150,
                    child: Card(
                      color: Colors.white,
                      child: Text('test'),
                    ),
                  ),
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 10),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
