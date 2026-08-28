import 'package:itk_app/theme/app_colors.dart';
import 'package:itk_app/theme/app_fonts.dart';
import 'package:itk_app/utils/auth_actions.dart';
import 'package:material_ui/material_ui.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _scrollController = ScrollController();

  double _collapseProgress = 0.0;
  static const _collapseRange = 130.0;

  void _onScroll() {
    final progress =
        (_scrollController.offset / _collapseRange).clamp(0.0, 1.0);
    if (progress != _collapseProgress) {
      setState(() => _collapseProgress = progress);
    }
  }

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const collapsedHeight = 60.0;
    const expandedHeight = 240.0;

    return Scaffold(
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverAppBar(
            expandedHeight: expandedHeight,
            collapsedHeight: collapsedHeight,
            floating: true,
            pinned: true,
            scrolledUnderElevation: 0,
            backgroundColor: Theme.of(context).colorScheme.surface,
            actionsPadding: const EdgeInsets.all(8),
            actions: [
              IconButton(
                onPressed: () => performLogout(context),
                icon: Icon(Icons.logout_rounded,
                    color: Theme.of(context).colorScheme.onSurface, size: 20),
                style: IconButton.styleFrom(
                  backgroundColor:
                      Theme.of(context).colorScheme.surfaceContainer,
                  shape: const CircleBorder(),
                  padding: const EdgeInsets.all(10),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.pin,
              centerTitle: true,
              title: Text(
                'Beállítások',
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.merge(topBarTitleStyle),
              ),
              background: Stack(
                children: [
                  Align(
                    alignment: Alignment.topCenter,
                    child: Container(
                      height: expandedHeight - collapsedHeight,
                      color: Theme.of(context).colorScheme.primaryContainer,
                    ),
                  ),
                  Align(
                    alignment: const Alignment(0, 0.3),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: ShapeDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        shape: const CircleBorder(),
                      ),
                      child: CircleAvatar(
                        radius: 22,
                        backgroundColor: Colors.white.withValues(alpha: 0.25),
                        child: const Text(
                          '?',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            color: kTextDark,
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
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
            sliver: SliverList.separated(
              itemCount: 16,
              itemBuilder: (context, index) => Container(
                height: 56,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(16),
                ),
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text('Beállítás ${index + 1}'), // placeholder
              ),
              separatorBuilder: (context, index) => const SizedBox(height: 10),
            ),
          ),
        ],
      ),
    );
  }
}
