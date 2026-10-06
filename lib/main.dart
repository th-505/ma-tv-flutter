import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'data/repositories/progress_repository.dart';
import 'ui/widgets/responsive_nav.dart';
import 'ui/screens/home_screen.dart';
import 'ui/screens/catalog_screen.dart';
import 'ui/screens/live_tv_screen.dart';
import 'ui/screens/search_screen.dart';
import 'ui/screens/settings_screen.dart';
import 'ui/screens/details_screen.dart';
import 'ui/screens/player_screen.dart';
import 'domain/models/content_identity.dart';
import 'domain/models/playback_source.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MATVApp());
}

/// Global Application Root
class MATVApp extends StatefulWidget {
  const MATVApp({super.key});

  @override
  State<MATVApp> createState() => _MATVAppState();
}

class _MATVAppState extends State<MATVApp> {
  final ProgressRepository _repo = ProgressRepository();
  bool _isDark = true;
  ContentIdentity? _selectedContent;
  PlaybackSource? _playbackSource;
  List<RankedSource> _playbackSources = const [];
  EpisodeIdentity? _selectedEpisode;

  @override
  void initState() {
    super.initState();
    _loadThemePreference();
  }

  Future<void> _loadThemePreference() async {
    await _repo.init();
    if (mounted) {
      setState(() => _isDark = _repo.themeMode != ThemeMode.light);
    }
  }

  void _toggleTheme() async {
    final newDark = !_isDark;
    setState(() => _isDark = newDark);
    await _repo.setTheme(newDark ? 'dark' : 'light');
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MA-TV | منصة الترفيه المتكاملة',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: _isDark ? ThemeMode.dark : ThemeMode.light,
      // Arabic RTL localization settings
      locale: const Locale('ar', 'SA'),
      supportedLocales: const [
        Locale('ar', 'SA'),
        Locale('en', 'US'),
      ],
      home: MainNavigationShell(
        isDark: _isDark,
        onToggleTheme: _toggleTheme,
      ),
    );
  }
}

/// Main Navigation Coordinator Shell
class MainNavigationShell extends StatefulWidget {
  final bool isDark;
  final VoidCallback onToggleTheme;

  const MainNavigationShell({
    super.key,
    required this.isDark,
    required this.onToggleTheme,
  });

  @override
  State<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends State<MainNavigationShell> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    if (_playbackSource != null && _selectedContent != null) {
      return PlayerScreen(
        identity: _selectedContent!,
        source: _playbackSource!,
        allSources: _playbackSources,
        episode: _selectedEpisode,
        onBack: () => setState(() {
          _playbackSource = null;
          _playbackSources = const [];
          _selectedEpisode = null;
        }),
      );
    }

    if (_selectedContent != null) {
      return DetailsScreen(
        content: _selectedContent!,
        onBack: () => setState(() => _selectedContent = null),
        onPlay: (content, source, sources, episode) => setState(() {
          _selectedContent = content;
          _playbackSource = source;
          _playbackSources = sources;
          _selectedEpisode = episode;
        }),
      );
    }

    final screens = <Widget>[
      HomeScreen(
        onSelectContent: (content) => setState(() => _selectedContent = content),
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
      onTabSelected: (index) {
        setState(() => _currentIndex = index);
      },
      child: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
    );
  }
}
