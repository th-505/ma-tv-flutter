import 'package:flutter/material.dart';
import '../../data/services/tmdb_service.dart';
import '../../domain/models/content_identity.dart';
import '../widgets/hero_banner.dart';
import '../widgets/content_rail.dart';
import '../widgets/poster_card.dart';
import '../../core/theme/app_theme.dart';

class HomeScreen extends StatefulWidget {
  final ValueChanged<ContentIdentity> onSelectContent;
  final ValueChanged<int> onNavigateTab;

  const HomeScreen({
    super.key,
    required this.onSelectContent,
    required this.onNavigateTab,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TmdbService _tmdb = TmdbService();
  bool _loading = true;
  bool _loadFailed = false;
  int _loadSerial = 0;

  List<ContentIdentity> _trendingMovies = [];
  List<ContentIdentity> _trendingSeries = [];
  List<ContentIdentity> _topRated = [];
  List<ContentIdentity> _nowPlaying = [];
  List<ContentIdentity> _onTheAir = [];
  List<ContentIdentity> _arabicContent = [];
  List<ContentIdentity> _turkishContent = [];
  List<ContentIdentity> _koreanContent = [];
  List<ContentIdentity> _animeContent = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final serial = ++_loadSerial;
    setState(() {
      _loading = true;
      _loadFailed = false;
    });
    try {
      final results = await Future.wait([
        _tmdb.getTrending(type: 'movie'),
        _tmdb.getTrending(type: 'tv'),
        _tmdb.getTopRatedMovies(),
        _tmdb.getNowPlayingMovies(),
        _tmdb.getOnTheAirSeries(),
        _tmdb.getByLanguage('ar', type: 'movie'),
        _tmdb.getByLanguage('tr', type: 'tv'),
        _tmdb.getByLanguage('ko', type: 'tv'),
        _tmdb.getAnime(),
      ]);

      if (mounted && serial == _loadSerial) {
        setState(() {
          _trendingMovies = results[0];
          _trendingSeries = results[1];
          _topRated = results[2];
          _nowPlaying = results[3];
          _onTheAir = results[4];
          _arabicContent = results[5];
          _turkishContent = results[6];
          _koreanContent = results[7];
          _animeContent = results[8];
          _loadFailed = results.every((items) => items.isEmpty);
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted && serial == _loadSerial) {
        setState(() {
          _loading = false;
          _loadFailed = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.gold400),
      );
    }

    if (_loadFailed) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off, color: AppColors.gold400, size: 48),
            const SizedBox(height: 16),
            const Text(
              'تعذر تحميل محتوى TMDB',
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _loadData,
              icon: const Icon(Icons.refresh),
              label: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      );
    }

    final heroItem = _trendingMovies.isNotEmpty ? _trendingMovies.first : (_trendingSeries.isNotEmpty ? _trendingSeries.first : null);

    return RefreshIndicator(
      onRefresh: _loadData,
      notificationPredicate: (notification) => notification.depth == 0,
      color: AppColors.gold400,
      backgroundColor: AppColors.darkElevated,
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 56),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1600),
            child: Column(
          children: [
            // Hero Section
            if (heroItem != null)
              HeroBanner(
                content: heroItem,
                onPlay: () => widget.onSelectContent(heroItem),
                onDetails: () => widget.onSelectContent(heroItem),
              ),

            // Trending Movies Rail
            ContentRail(
              title: 'أفلام رائجة',
              onSeeAll: () => widget.onNavigateTab(1), // Movies Tab
              children: _trendingMovies.map((item) {
                return PosterCard(
                  identity: item,
                  onTap: () => widget.onSelectContent(item),
                );
              }).toList(),
            ),

            // Trending Series Rail
            ContentRail(
              title: 'مسلسلات رائجة',
              onSeeAll: () => widget.onNavigateTab(2), // Series Tab
              children: _trendingSeries.map((item) {
                return PosterCard(
                  identity: item,
                  onTap: () => widget.onSelectContent(item),
                );
              }).toList(),
            ),

            ContentRail(
              title: 'يعرض الآن',
              onSeeAll: () => widget.onNavigateTab(1),
              children: _nowPlaying.map((item) => PosterCard(identity: item, onTap: () => widget.onSelectContent(item))).toList(),
            ),
            ContentRail(
              title: 'مسلسلات على الهواء',
              onSeeAll: () => widget.onNavigateTab(2),
              children: _onTheAir.map((item) => PosterCard(identity: item, onTap: () => widget.onSelectContent(item))).toList(),
            ),

            // Top Rated Movies
            ContentRail(
              title: 'الأعلى تقييماً',
              onSeeAll: () => widget.onNavigateTab(1),
              children: _topRated.map((item) {
                return PosterCard(
                  identity: item,
                  onTap: () => widget.onSelectContent(item),
                );
              }).toList(),
            ),

            // Arabic Content
            ContentRail(
              title: 'سينما عربية',
              onSeeAll: () => widget.onNavigateTab(1),
              children: _arabicContent.map((item) {
                return PosterCard(
                  identity: item,
                  onTap: () => widget.onSelectContent(item),
                );
              }).toList(),
            ),

            // Turkish Drama
            ContentRail(
              title: 'مسلسلات تركية',
              onSeeAll: () => widget.onNavigateTab(2),
              children: _turkishContent.map((item) {
                return PosterCard(
                  identity: item,
                  onTap: () => widget.onSelectContent(item),
                );
              }).toList(),
            ),

            // Korean Drama
            ContentRail(
              title: 'دراما كورية',
              onSeeAll: () => widget.onNavigateTab(2),
              children: _koreanContent.map((item) {
                return PosterCard(
                  identity: item,
                  onTap: () => widget.onSelectContent(item),
                );
              }).toList(),
            ),

            // Anime
            ContentRail(
              title: 'أنمي مترجم',
              onSeeAll: () => widget.onNavigateTab(2),
              children: _animeContent.map((item) {
                return PosterCard(
                  identity: item,
                  onTap: () => widget.onSelectContent(item),
                );
              }).toList(),
            ),
          ],
            ),
          ),
        ),
      ),
    );
  }
}
