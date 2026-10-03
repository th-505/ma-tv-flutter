import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'data/repositories/progress_repository.dart';
import 'ui/widgets/responsive_nav.dart';
import 'ui/screens/home_screen.dart';
import 'ui/screens/catalog_screen.dart';
import 'ui/screens/live_tv_screen.dart';
import 'ui/screens/search_screen.dart';
import 'ui/screens/settings_screen.dart';

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

  @override
  void initState() {
    super.initState();
    _loadThemePreference();
  }

  Future<void> _loadThemePreference() async {
    final dark = await _repo.isDarkMode();
    if (mounted) {
      setState(() => _isDark = dark);
    }
  }

  void _toggleTheme() async {
    final newDark = !_isDark;
    setState(() => _isDark = newDark);
    await _repo.setDarkMode(newDark);
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
    final screens = <Widget>[
      HomeScreen(
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
      onDestinationSelected: (index) {
        setState(() => _currentIndex = index);
      },
      child: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
    );
  }
}
