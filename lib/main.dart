import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'data/repositories/progress_repository.dart';
import 'domain/models/content_identity.dart';
import 'domain/models/playback_source.dart';
import 'ui/screens/catalog_screen.dart';
import 'ui/screens/details_screen.dart';
import 'ui/screens/home_screen.dart';
import 'ui/screens/live_tv_screen.dart';
import 'ui/screens/player_screen.dart';
import 'ui/screens/search_screen.dart';
import 'ui/screens/settings_screen.dart';
import 'ui/widgets/responsive_nav.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final progress = ProgressRepository();
  await progress.init();
  runApp(
    ChangeNotifierProvider.value(
      value: progress,
      child: const MATVApp(),
    ),
  );
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
      const CatalogScreen(initialType: 'movie'),
      const CatalogScreen(initialType: 'tv'),
      const LiveTvScreen(),
      const SearchScreen(),
      const SettingsScreen(),
    ];

    return ResponsiveAppShell(
      currentIndex: _currentIndex,
      onDestinationSelected: (index) => setState(() => _currentIndex = index),
      child: IndexedStack(index: _currentIndex, children: screens),
    );
  }
}
