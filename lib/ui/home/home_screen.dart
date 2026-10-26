import 'dart:async';
import 'package:itk_app/data/repositories/auth_repository.dart';
import 'package:itk_app/data/repositories/calendar_repository.dart';
import 'package:itk_app/data/repositories/wiki_files_repository.dart';
import 'package:itk_app/ui/core/theme/app_themes.dart';
import 'package:itk_app/ui/home/viewmodels/home_viewmodel.dart';
import 'package:itk_app/ui/home/widgets/event_card.dart';
import 'package:itk_app/ui/home/widgets/home_screen_app_bar.dart';
import 'package:itk_app/ui/home/widgets/quick_links_grid.dart';
import 'package:itk_app/ui/midterms/midterms_screen.dart';
import 'package:itk_app/ui/online_videos/online_videos.dart';
import 'package:itk_app/ui/wiki/viewmodels/wiki_files_viewmodel.dart';
import 'package:itk_app/ui/wiki/wiki_files_screen.dart';
import 'package:itk_app/utils/open_link.dart';
import 'package:provider/provider.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:itk_app/domain/models/calendar_event.dart';
import 'package:itk_app/ui/core/theme/app_spacing.dart';
import 'package:itk_app/ui/core/widgets/grouped_list.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final HomeViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = HomeViewModel(
      authRepository: context.read<AuthRepository>(),
      calendarRepository: context.read<CalendarRepository>(),
    );
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    await _viewModel.load.execute(true);
    if (!mounted) return;
  }

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 10) return 'Jó reggelt';
    if (hour < 18) return 'Szép napot';
    return 'Jó estét';
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final firstName = _viewModel.firstName ?? 'diák';
    final today = DateFormat('MMMM d., EEEE', 'hu').format(DateTime.now());

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          slivers: [
            const HomeScreenAppBar(),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenHorizontal,
                AppSpacing.xxl,
                AppSpacing.screenHorizontal,
                AppSpacing.bottomNavClearance,
              ),
              sliver: SliverList.list(
                children: [
                  Text(
                    '$_greeting, $firstName!',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(today, style: TextStyle(color: scheme.onSurfaceVariant)),
                  const SizedBox(height: AppSpacing.xxl),
                  SettingsGroup(
                    header: 'Következő óra',
                    children: [
                      ListenableBuilder(
                          listenable:
                              Listenable.merge([_viewModel.load, _viewModel]),
                          builder: (context, _) {
                            return _buildNextEvent(scheme);
                          })
                    ],
                  ),
                  SettingsGroup(
                    header: 'Számonkérések',
                    children: [
                      SettingsTile(
                        icon: Icons.event_note_rounded,
                        iconColor: scheme.error,
                        title: 'ZH időpontok',
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const MidtermsScreen()),
                        ),
                      ),
                      SettingsTile(
                        icon: Icons.event_available_rounded,
                        iconColor: scheme.primary,
                        title: 'Perpa',
                        onTap: () {
                          final repository =
                              context.read<WikiFilesRepository>();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => WikiFilesScreen(
                                viewModel: WikiFilesViewModel(
                                    repository: repository, dir: ''),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  SettingsGroup(
                    header: 'Gyors linkek',
                    children: [
                      QuickLinksGrid(onTap: (url) => openLink(context, url)),
                      SettingsTile(
                        icon: Icons.video_chat_outlined,
                        iconColor: itkPrimary,
                        title: 'Online Videók',
                        onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const OnlineVideos())),
                      )
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNextEvent(ColorScheme scheme) {
    final muted = TextStyle(fontSize: 13, color: scheme.onSurfaceVariant);
    final Widget content;

    if (_viewModel.load.errorMessage != null) {
      content = Row(
        children: [
          Expanded(child: Text(_viewModel.load.errorMessage!, style: muted)),
          TextButton(onPressed: _refresh, child: const Text('Újra')),
        ],
      );
    } else if (!_viewModel.load.running && _viewModel.nextEvent == null) {
      content = Text('Nincs közelgő órád.', style: muted);
    } else {
      // While loading, show mock data
      final e = _viewModel.nextEvent ??
          CalendarEvent(
            title: BoneMock.words(3),
            start: DateTime.now(),
            end: DateTime.now(),
          );

      // Datetime stuff
      final isToday = DateUtils.isSameDay(e.start, DateTime.now());
      final day =
          isToday ? 'Ma' : DateFormat('MMM d., EEEE', 'hu').format(e.start);
      final time =
          '${DateFormat.Hm().format(e.start)}–${DateFormat.Hm().format(e.end)}';

      content = Skeletonizer(
        enabled: _viewModel.load.running,
        child:
            EventCard(e: e, scheme: scheme, day: day, muted: muted, time: time),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: content,
    );
  }
}
