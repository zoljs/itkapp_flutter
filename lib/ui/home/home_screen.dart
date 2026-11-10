import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:hintful/hintful.dart';
import 'package:itk_app/app_tours.dart';
import 'package:itk_app/data/repositories/absolutorium_repository.dart';
import 'package:itk_app/data/repositories/auth_repository.dart';
import 'package:itk_app/data/repositories/calendar_repository.dart';
import 'package:itk_app/routing/routes.dart';
import 'package:itk_app/ui/core/theme/app_themes.dart';
import 'package:itk_app/ui/core/widgets/platform_appbar.dart';
import 'package:itk_app/ui/core/widgets/settings_avatar_button.dart';
import 'package:itk_app/ui/home/viewmodels/home_viewmodel.dart';
import 'package:itk_app/ui/home/widgets/next_class_card.dart';
import 'package:itk_app/ui/home/widgets/quick_links_grid.dart';
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
  final _hintController = HintController(scopePrefix: 'home-');
  late final HomeViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = HomeViewModel(
      authRepository: context.read<AuthRepository>(),
      calendarRepository: context.read<CalendarRepository>(),
      absolutoriumRepository: context.read<AbsolutoriumRepository>(),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(_hintController.tryShowTour(
        AppTours.home(),
        mark: HintMarkPolicy.onAnyExit,
      ));
    });
  }

  @override
  void dispose() {
    _viewModel.dispose();
    _hintController.skip(); // no-op when idle
    _hintController.dispose();
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
    final isIOS = Theme.of(context).platform == TargetPlatform.iOS;

    final customScrollView = CustomScrollView(
      slivers: [
        ShrinkingSliverAppBar(
          flexibleSpaceBarTitle:
              Image.asset('assets/icons/itkapp-small.png', height: 30),
          hasBackButton: false,
          expandedHeight: 130,
          divider: 0,
          actions: [
            HintTarget(
              focusShape: FocusShape.circle,
              id: 'home-avatar',
              child: SettingsAvatarButton(
                onAvatarTap: () => context.push(Routes.settings),
                login: _viewModel.login,
              ),
            ),
          ],
        ),
        if (isIOS)
          CupertinoSliverRefreshControl(
            onRefresh: () async {
              await _viewModel.load.execute(true);
            },
          ),
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
                      listenable: _viewModel,
                      builder: (context, _) {
                        return _buildNextEvent(scheme);
                      })
                ],
              ),
              SettingsGroup(
                header: 'Időpontok',
                children: [
                  SettingsTile(
                    icon: Icons.event_note_rounded,
                    iconColor: scheme.error,
                    title: 'Zárthelyi dolgozatok',
                    onTap: () => context.push(Routes.midterms),
                  ),
                  SettingsTile(
                    icon: Icons.event_note_rounded,
                    iconColor: scheme.error,
                    title: 'Konzultációk',
                    onTap: () => context.push(Routes.consultations),
                  ),
                ],
              ),
              SettingsGroup(
                header: 'Tanulmányok',
                children: [
                  ListenableBuilder(
                    listenable: _viewModel,
                    builder: (context, _) => SettingsTile(
                      icon: Icons.school_rounded,
                      iconColor: itkPrimary,
                      title: 'Abszolutórium',
                      value: _viewModel.absolutoriumSummary,
                      onTap: () => context.push(Routes.absolutorium),
                    ),
                  ),
                  SettingsTile(
                    icon: Icons.record_voice_over_rounded,
                    iconColor: itkPrimary,
                    title: 'Magyar hangok (IPA)',
                    onTap: () => context.push(Routes.phonetics),
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
                    onTap: () => context.push(Routes.videos),
                  )
                ],
              ),
            ],
          ),
        ),
      ],
    );

    // Body
    return Scaffold(
      body: isIOS
          ? customScrollView
          : RefreshIndicator(
              onRefresh: _refresh,
              edgeOffset: MediaQuery.paddingOf(context).top,
              child: customScrollView,
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
      final e = _viewModel.nextEvent ??
          CalendarEvent(
            title: BoneMock.words(3),
            start: DateTime.now(),
            end: DateTime.now(),
          );

      final isToday = DateUtils.isSameDay(e.start, DateTime.now());
      final day =
          isToday ? 'Ma' : DateFormat('MMM d., EEEE', 'hu').format(e.start);
      final time =
          '${DateFormat.Hm().format(e.start)}–${DateFormat.Hm().format(e.end)}';

      content = Skeletonizer(
        enabled: _viewModel.load.running,
        child: NextClassCard(
            e: e, scheme: scheme, day: day, muted: muted, time: time),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: content,
    );
  }
}
