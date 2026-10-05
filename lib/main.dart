import 'dart:ui' show PointerDeviceKind;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'data/repositories/progress_repository.dart';
import 'domain/models/content_identity.dart';
import 'domain/models/playback_source.dart';
import 'domain/models/live_types.dart';
import 'ui/screens/catalog_screen.dart';
import 'ui/screens/details_screen.dart';
import 'ui/screens/home_screen.dart';
import 'ui/screens/live_tv_screen.dart';
import 'ui/screens/live_stream_player_screen.dart';
import 'ui/screens/player_screen.dart';
import 'ui/screens/search_screen.dart';
import 'ui/screens/settings_screen.dart';
import 'ui/widgets/responsive_nav.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    ChangeNotifierProvider(
      create: (_) {
        final progress = ProgressRepository();
        progress.init();
        return progress;
      },
      child: const MATVApp(),
    ),
  );
}


class MATVScrollBehavior extends MaterialScrollBehavior {
  const MATVScrollBehavior();

  @override
  Set<PointerDeviceKind> get dragDevices => const {
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
    PointerDeviceKind.trackpad,
    PointerDeviceKind.stylus,
    PointerDeviceKind.unknown,
  };
}

class MATVApp extends StatelessWidget {
  const MATVApp({super.key});

  @override
  Widget build(BuildContext context) {
    final progress = context.watch<ProgressRepository>();
    return MaterialApp(
      title: 'MA-TV | منصة الترفيه المتكاملة',
      debugShowCheckedModeBanner: false,
      scrollBehavior: const MATVScrollBehavior(),
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: progress.themeMode,
      locale: const Locale('ar', 'SA'),
      supportedLocales: const [Locale('ar', 'SA'), Locale('en', 'US')],
      home: const MainNavigationShell(),
    );
  }
}

class MainNavigationShell extends StatefulWidget {
  const MainNavigationShell({super.key});

  @override
  State<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends State<MainNavigationShell> {
  int _currentIndex = 0;
  final Map<int, Widget> _screenCache = {};

  Widget _screenFor(int index) {
    return _screenCache.putIfAbsent(index, () {
      switch (index) {
        case 0:
          return HomeScreen(
            onSelectContent: _openDetails,
            onNavigateTab: (nextIndex) {
              if (mounted) setState(() => _currentIndex = nextIndex);
            },
          );
        case 1:
          return CatalogScreen(mediaType: 'movie', onSelectContent: _openDetails);
        case 2:
          return CatalogScreen(mediaType: 'series', onSelectContent: _openDetails);
        case 3:
          return LiveTvScreen(onPlayLive: _openLivePlayer);
        case 4:
          return SearchScreen(onSelectContent: _openDetails);
        default:
          return const SettingsScreen();
      }
    });
  }

  void _openDetails(ContentIdentity content) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => DetailsScreen(
          content: content,
          onBack: () => Navigator.of(context).pop(),
          onPlay: _openPlayer,
        ),
      ),
    );
  }

  void _openLivePlayer(String name, List<LiveSourceModel> sources) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => LiveStreamPlayerScreen(name: name, sources: sources)),
    );
  }

  void _openPlayer(
    ContentIdentity identity,
    PlaybackSource source,
    List<RankedSource> allSources,
    EpisodeIdentity? episode,
  ) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PlayerScreen(
          identity: identity,
          source: source,
          allSources: allSources,
          episode: episode,
          onBack: () => Navigator.of(context).pop(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveAppShell(
      currentIndex: _currentIndex,
      onTabSelected: (index) => setState(() => _currentIndex = index),
      child: _screenFor(_currentIndex),
    );
  }
}
