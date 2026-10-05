import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/tv/tv_remote_focus.dart';

class NavTabItem {
  final String label;
  final IconData icon;
  final IconData selectedIcon;

  const NavTabItem({
    required this.label,
    required this.icon,
    required this.selectedIcon,
  });
}

const List<NavTabItem> navTabs = [
  NavTabItem(label: 'الرئيسية', icon: Icons.home_outlined, selectedIcon: Icons.home),
  NavTabItem(label: 'الأفلام', icon: Icons.movie_outlined, selectedIcon: Icons.movie),
  NavTabItem(label: 'المسلسلات', icon: Icons.tv_outlined, selectedIcon: Icons.tv),
  NavTabItem(label: 'البث المباشر', icon: Icons.live_tv_outlined, selectedIcon: Icons.live_tv),
  NavTabItem(label: 'البحث', icon: Icons.search_outlined, selectedIcon: Icons.search),
  NavTabItem(label: 'الإعدادات', icon: Icons.settings_outlined, selectedIcon: Icons.settings),
];

class ResponsiveAppShell extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTabSelected;
  final Widget child;

  const ResponsiveAppShell({
    super.key,
    required this.currentIndex,
    required this.onTabSelected,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isDesktopOrTv = width >= 900;

    if (isDesktopOrTv) {
      // Desktop / TV Layout: Sidebar Rail on the Right
      return Scaffold(
        body: Row(
          children: [
            // Main Content Area
            Expanded(child: child),

            // Sidebar Rail
            Container(
              width: width >= 1280 ? 220 : 96,
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                border: Border(
                  left: BorderSide(color: Theme.of(context).dividerColor.withValues(alpha: 0.1)),
                ),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 24),
                  // Logo
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.play_circle_fill, color: AppColors.gold400, size: 24),
                      if (width >= 1280) ...[
                        const SizedBox(width: 8),
                        const Text(
                          'MA-TV',
                          style: TextStyle(
                            color: AppColors.gold400,
                            fontWeight: FontWeight.w900,
                            fontSize: 22,
                            letterSpacing: -1,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 30),
                  // Navigation Items
                  Expanded(
                    child: ListView.separated(
                      itemCount: navTabs.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final tab = navTabs[index];
                        final isSelected = currentIndex == index;
                        return TvFocusableWidget(
                          onSelect: () => onTabSelected(index),
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 10),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: isSelected ? AppColors.gold400.withValues(alpha: 0.15) : Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                              border: isSelected ? Border.all(color: AppColors.gold400.withValues(alpha: 0.3)) : null,
                            ),
                            child: width >= 1280
                                ? Row(
                                    children: [
                                      Icon(
                                        isSelected ? tab.selectedIcon : tab.icon,
                                        color: isSelected ? AppColors.gold400 : Colors.white60,
                                        size: 24,
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          tab.label,
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                            color: isSelected ? AppColors.gold400 : Colors.white60,
                                            fontFamily: 'Cairo',
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                                : Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        isSelected ? tab.selectedIcon : tab.icon,
                                        color: isSelected ? AppColors.gold400 : Colors.white60,
                                        size: 24,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        tab.label,
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                          color: isSelected ? AppColors.gold400 : Colors.white60,
                                          fontFamily: 'Cairo',
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    // Mobile / Tablet Layout: Bottom Navigation Bar
    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor.withValues(alpha: 0.95),
          border: Border(
            top: BorderSide(color: Theme.of(context).dividerColor.withValues(alpha: 0.1)),
          ),
        ),
        child: NavigationBar(
          selectedIndex: currentIndex,
          onDestinationSelected: onTabSelected,
          backgroundColor: Colors.transparent,
          indicatorColor: AppColors.gold400.withValues(alpha: 0.2),
          destinations: navTabs.map((tab) {
            return NavigationDestination(
              icon: Icon(tab.icon, color: Colors.white70),
              selectedIcon: Icon(tab.selectedIcon, color: AppColors.gold400),
              label: tab.label,
            );
          }).toList(),
        ),
      ),
    );
  }
}
