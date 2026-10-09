import 'dart:async';
import 'package:itk_app/ui/core/theme/app_themes.dart';
import 'package:itk_app/ui/home/widgets/event_card.dart';
import 'package:itk_app/ui/midterms/midterms_screen.dart';
import 'package:itk_app/ui/online_videos/online_videos.dart';
import 'package:itk_app/ui/settings/settings_screen.dart';
import 'package:itk_app/utils/open_link.dart';
import 'package:itk_app/utils/result.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:itk_app/data/services/auth_service.dart';
import 'package:itk_app/data/services/calendar_service.dart';
import 'package:itk_app/domain/models/calendar_event.dart';
import 'package:itk_app/ui/core/theme/app_radius.dart';
import 'package:itk_app/ui/core/theme/app_spacing.dart';
import 'package:itk_app/ui/core/widgets/grouped_list.dart';

class QuickLink {
  const QuickLink(this.label, this.url, this.iconAsset);

  final String label;
  final String url;
  final String iconAsset;
}

const _quickLinks = [
  QuickLink('Neptun', 'https://neptun3.ppke.hu/hallgato_uj/login',
      'assets/icons/neptun.png'),
  QuickLink(
      'ITK Space', 'https://space.itk.ppke.hu', 'assets/icons/itk-small.png'),
  QuickLink('T.O.', '', 'assets/icons/sharepoint.png'),
  QuickLink('Oktatók', '', 'assets/icons/ppke.png'),
];

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  CalendarEvent? _nextEvent;
  bool _loadingEvents = true;
  String? _eventsError;

  @override
  void initState() {
    super.initState();
    _loadNextEvent();
  }

  Future<void> _loadNextEvent() async {
    setState(() {
      _loadingEvents = true;
      _eventsError = null;
    });
    //await Completer<void>().future;
    final result = await CalendarService.instance.getCalendar();
    if (!mounted) return;

    switch (result) {
      case Ok(:final value):
        final now = DateTime.now();
        final upcoming = value.where((e) => e.end.isAfter(now)).toList()
          ..sort((a, b) => a.start.compareTo(b.start));
        setState(() {
          _nextEvent = upcoming.firstOrNull;
          _loadingEvents = false;
        });
      case Err(:final message):
        setState(() {
          _eventsError = message;
          _loadingEvents = false;
        });
    }
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
    final firstName = AuthService.instance.cachedUser?.firstName;
    final today = DateFormat('MMMM d., EEEE', 'hu').format(DateTime.now());

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _loadNextEvent,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          slivers: [
            SliverAppBar(
              stretch: true,
              stretchTriggerOffset: 100.0,
              pinned: true,
              expandedHeight: 150,
              collapsedHeight: 60,
              scrolledUnderElevation: 0,
              backgroundColor: scheme.surface,
              title: const _FadingLogo(showWhenCollapsed: true, height: 30),
              flexibleSpace: FlexibleSpaceBar(
                collapseMode: CollapseMode.pin,
                background: Container(
                  color: scheme.primaryContainer,
                  alignment: Alignment.center,
                  child:
                      const _FadingLogo(showWhenCollapsed: false, height: 45),
                ),
              ),
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
                    children: [_buildNextEvent(scheme)],
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
                    ],
                  ),
                  SettingsGroup(
                    header: 'Gyors linkek',
                    children: [
                      _QuickLinksGrid(onTap: (url) => openLink(context, url)),
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

    if (_eventsError != null) {
      content = Row(
        children: [
          Expanded(child: Text(_eventsError!, style: muted)),
          TextButton(onPressed: _loadNextEvent, child: const Text('Újra')),
        ],
      );
    } else if (!_loadingEvents && _nextEvent == null) {
      content = Text('Nincs közelgő órád.', style: muted);
    } else {
      // While loading, show mock data
      final e = _nextEvent ??
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
        enabled: _loadingEvents,
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

class _FadingLogo extends StatelessWidget {
  const _FadingLogo({required this.showWhenCollapsed, required this.height});

  final bool showWhenCollapsed;
  final double height;

  @override
  Widget build(BuildContext context) {
    final settings =
        context.dependOnInheritedWidgetOfExactType<FlexibleSpaceBarSettings>();

    var expanded = 1.0;
    if (settings != null) {
      final delta = settings.maxExtent - settings.minExtent;
      expanded = ((settings.currentExtent - settings.minExtent) / delta)
          .clamp(0.0, 1.0);
    }
    final opacity = showWhenCollapsed
        ? 1.0 - expanded
        : ((expanded - 0.6) / 0.4).clamp(0.0, 1.0);

    return Opacity(
      opacity: opacity,
      child: Image.asset('assets/icons/itkapp-small.png', height: height),
    );
  }
}

class _QuickLinksGrid extends StatelessWidget {
  const _QuickLinksGrid({required this.onTap});

  final ValueChanged<String> onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return GridView.count(
      crossAxisCount: 4,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(AppSpacing.sm),
      children: [
        for (final link in _quickLinks)
          QuickLinkTile(onTap: onTap, link: link, scheme: scheme),
      ],
    );
  }
}

class QuickLinkTile extends StatelessWidget {
  const QuickLinkTile({
    super.key,
    required this.onTap,
    required this.link,
    required this.scheme,
  });

  final ValueChanged<String> onTap;
  final QuickLink link;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(AppRadius.lg),
      onTap: () => onTap(link.url),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            link.iconAsset,
            height: 32,
            errorBuilder: (_, __, ___) => Icon(
              Icons.link_rounded,
              size: 32,
              color: scheme.primary,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            link.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 12, color: scheme.onSurface),
          ),
        ],
      ),
    );
  }
}
