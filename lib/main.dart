import 'package:flutter/foundation.dart';
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
      child: kIsWeb ? const WebBootProbe() : const MATVApp(),
    ),
  );
}


class WebBootProbe extends StatelessWidget {
  const WebBootProbe({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: const Color(0xFF0A0A0B),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.check_circle_outline, color: Color(0xFFD4AF37), size: 72),
              SizedBox(height: 20),
              Text('MA-TV WEB OK', style: TextStyle(color: Color(0xFFD4AF37), fontSize: 28, fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              Text('Flutter engine started successfully', style: TextStyle(color: Colors.white70, fontSize: 14)),
            ],
          ),
        ),
      ),
    );
  }
}

class MATVApp extends StatelessWidget {
  const MATVApp({super.key});

  @override
  Widget build(BuildContext context) {
    final progress = context.watch<ProgressRepository>();
    return MaterialApp(
      title: 'MA-TV | منصة الترفيه المتكاملة',
      debugShowCheckedModeBanner: false,
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
    final screens = <Widget>[
      HomeScreen(
        onSelectContent: _openDetails,
        onNavigateTab: (index) {
          if (mounted) setState(() => _currentIndex = index);
        },
      ),
      CatalogScreen(mediaType: 'movie', onSelectContent: _openDetails),
      CatalogScreen(mediaType: 'series', onSelectContent: _openDetails),
      LiveTvScreen(onPlayLive: _openLivePlayer),
      SearchScreen(onSelectContent: _openDetails),
      const SettingsScreen(),
    ];

    return ResponsiveAppShell(
      currentIndex: _currentIndex,
      onTabSelected: (index) => setState(() => _currentIndex = index),
      child: IndexedStack(index: _currentIndex, children: screens),
    );
  }
}
