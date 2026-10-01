import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:itk_app/data/services/auth_service.dart';
import 'package:itk_app/data/services/calendar_service.dart';
import 'package:itk_app/domain/models/calendar_event.dart';
import 'package:itk_app/ui/core/theme/app_radius.dart';
import 'package:itk_app/ui/core/theme/app_spacing.dart';
import 'package:itk_app/ui/core/widgets/grouped_list.dart';
import 'package:url_launcher/url_launcher.dart';

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
    try {
      final events = await CalendarService.instance.getCalendar();
      final now = DateTime.now();
      final upcoming = events.where((e) => e.end.isAfter(now)).toList()
        ..sort((a, b) => a.start.compareTo(b.start));
      if (!mounted) return;
      setState(() {
        _nextEvent = upcoming.isEmpty ? null : upcoming.first;
        _loadingEvents = false;
      });
    } on DioException {
      if (!mounted) return;
      setState(() {
        _eventsError = 'Nem sikerült betölteni a naptárat.';
        _loadingEvents = false;
      });
    }
  }

  Future<void> _openLink(String url) async {
    final uri = Uri.tryParse(url);
    final ok = uri != null &&
        uri.hasScheme &&
        await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Nem sikerült megnyitni a linket.')));
    }
  }

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 10) return 'Jó reggelt';
    if (hour < 18) return 'Szép napot';
    return 'Szép estét';
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final login = AuthService.instance.cachedUser?.login;
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
              backgroundColor: Colors.transparent,
              title: const _FadingLogo(showWhenCollapsed: true, height: 30),
              flexibleSpace: Stack(
                fit: StackFit.expand,
                children: [
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          scheme.surface,
                          scheme.surface,
                          scheme.surface.withValues(alpha: 0.0),
                        ],
                        stops: const [0.0, 0.55, 1.0],
                      ),
                    ),
                  ),
                  FlexibleSpaceBar(
                    collapseMode: CollapseMode.pin,
                    background: Container(
                      color: scheme.primaryContainer,
                      alignment: Alignment.center,
                      child: const _FadingLogo(
                          showWhenCollapsed: false, height: 45),
                    ),
                  ),
                ],
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
                    login == null ? '$_greeting!' : '$_greeting, $login!',
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
                              builder: (_) => const Placeholder()),
                        ),
                      ),
                    ],
                  ),
                  const _SectionHeader('Gyors linkek'),
                  _QuickLinksGrid(onTap: _openLink),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNextEvent(ColorScheme scheme) {
    const nextEventHeight = 64.0;
    final muted = TextStyle(fontSize: 13, color: scheme.onSurfaceVariant);
    final Widget content;

    if (_eventsError != null) {
      content = Row(
        children: [
          Expanded(child: Text(_eventsError!, style: muted)),
          TextButton(onPressed: _loadNextEvent, child: const Text('Újra')),
        ],
      );
    } else if (_nextEvent == null) {
      content = Text('Nincs közelgő órád.', style: muted);
    } else {
      final e = _nextEvent!;
      final isToday = DateUtils.isSameDay(e.start, DateTime.now());
      final day =
          isToday ? 'Ma' : DateFormat('MMM d., EEEE', 'hu').format(e.start);
      final time =
          '${DateFormat.Hm().format(e.start)}–${DateFormat.Hm().format(e.end)}';

      content = Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                DateFormat.Hm().format(e.start),
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: scheme.primary,
                ),
              ),
              Text(day, style: muted),
            ],
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  e.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: scheme.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  [time, if (e.location?.isNotEmpty ?? false) e.location!]
                      .join(' · '),
                  style: muted,
                ),
              ],
            ),
          ),
        ],
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

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.sm),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          fontSize: 13,
          letterSpacing: 0.4,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

class _QuickLinksGrid extends StatelessWidget {
  const _QuickLinksGrid({required this.onTap});

  final ValueChanged<String> onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Material(
      color: scheme.surfaceContainerHigh,
      borderRadius: BorderRadius.circular(AppRadius.xl),
      clipBehavior: Clip.antiAlias,
      child: GridView.count(
        crossAxisCount: 4,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.all(AppSpacing.sm),
        children: [
          for (final link in _quickLinks)
            InkWell(
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
            ),
        ],
      ),
    );
  }
}
