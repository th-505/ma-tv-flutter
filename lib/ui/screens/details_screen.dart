import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../domain/models/content_identity.dart';
import '../../domain/models/playback_source.dart';
import '../../data/services/tmdb_service.dart';
import '../../data/scrapers/server_manager.dart';
import '../../data/repositories/progress_repository.dart';
import '../../core/theme/app_theme.dart';
import '../widgets/custom_badge.dart';
import '../../core/tv/tv_remote_focus.dart';

class DetailsScreen extends StatefulWidget {
  final ContentIdentity content;
  final VoidCallback onBack;
  final void Function(ContentIdentity, PlaybackSource, List<RankedSource>, EpisodeIdentity?) onPlay;

  const DetailsScreen({
    super.key,
    required this.content,
    required this.onBack,
    required this.onPlay,
  });

  @override
  State<DetailsScreen> createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> {
  final TmdbService _tmdb = TmdbService();
  int _selectedSeason = 1;
  EpisodeIdentity? _selectedEpisode;
  List<EpisodeIdentity> _episodes = [];
  bool _loadingEpisodes = false;
  bool _loadingDetails = true;
  Map<String, dynamic>? _details;
  List<ContentIdentity> _recommendations = [];
  List<ContentIdentity> _similar = [];

  @override
  void initState() {
    super.initState();
    _loadDetails();
    if (widget.content.mediaType == 'series') {
      _loadSeason(_selectedSeason);
    }
  }

  Future<void> _loadDetails() async {
    final isSeries = widget.content.mediaType == 'series';
    final results = await Future.wait<dynamic>([
      isSeries ? _tmdb.getSeriesDetails(widget.content.tmdbId) : _tmdb.getMovieDetails(widget.content.tmdbId),
      _tmdb.getRecommendations(widget.content.tmdbId, isSeries ? 'tv' : 'movie'),
      _tmdb.getSimilar(widget.content.tmdbId, isSeries ? 'tv' : 'movie'),
    ]);
    if (!mounted) return;
    setState(() {
      _details = results[0] as Map<String, dynamic>?;
      _recommendations = results[1] as List<ContentIdentity>;
      _similar = results[2] as List<ContentIdentity>;
      _loadingDetails = false;
    });
  }

  Future<void> _loadSeason(int season) async {
    setState(() => _loadingEpisodes = true);
    final eps = await _tmdb.getSeasonEpisodes(widget.content.tmdbId, season);
    if (mounted) {
      setState(() {
        _episodes = eps;
        _selectedEpisode = eps.isNotEmpty ? eps.first : null;
        _loadingEpisodes = false;
      });
    }
  }

  void _handleQuickPlay() {
    final sources = ServerManager.buildSources(
      widget.content,
      season: _selectedSeason,
      episode: _selectedEpisode?.episodeNumber ?? 1,
    );
    if (sources.isNotEmpty) {
      widget.onPlay(widget.content, sources.first.source, sources, _selectedEpisode);
    }
  }

  void _showSourcePicker() {
    final sources = ServerManager.buildSources(
      widget.content,
      season: _selectedSeason,
      episode: _selectedEpisode?.episodeNumber ?? 1,
    );

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.darkElevated,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'اختر سيرفر المشاهدة (${sources.length} سيرفر متاح)',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Cairo',
                  color: AppColors.gold400,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.separated(
                  itemCount: sources.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, idx) {
                    final rs = sources[idx];
                    final serverConfig = ServerManager.globalServers[idx];
                    return ListTile(
                      tileColor: Colors.white.withOpacity(0.04),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      title: Text(
                        serverConfig.name,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Cairo', fontSize: 13),
                      ),
                      trailing: CustomBadge(
                        isGold: idx < 3,
                        child: Text(serverConfig.badge),
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        widget.onPlay(widget.content, rs.source, sources, _selectedEpisode);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _shareContent() {
    final title = widget.content.canonical.title;
    Share.share('شاهد $title بجودة عالية على MA-TV Cinematic Gold');
  }

  @override
  Widget build(BuildContext context) {
    final progress = context.watch<ProgressRepository>();
    final isFav = progress.isFavorite(widget.content.tmdbId);
    final c = widget.content;
    final backdrop = c.canonical.backdropPath != null
        ? 'https://image.tmdb.org/t/p/original${c.canonical.backdropPath}'
        : null;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Collapsible Backdrop App Bar
          SliverAppBar(
            expandedHeight: 320,
            pinned: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: widget.onBack,
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  if (backdrop != null)
                    Image.network(backdrop, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const SizedBox())
                  else
                    Container(color: AppColors.darkElevated),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Theme.of(context).scaffoldBackgroundColor,
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Content Details Body
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title & Metadata
                  Text(
                    c.canonical.title,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      fontFamily: 'Cairo',
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      if (c.canonical.voteAverage != null)
                        CustomBadge(
                          isGold: true,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.star, size: 12, color: AppColors.gold400),
                              const SizedBox(width: 4),
                              Text(c.canonical.voteAverage!.toStringAsFixed(1)),
                            ],
                          ),
                        ),
                      if (c.canonical.releaseDate != null)
                        CustomBadge(child: Text(c.canonical.releaseDate!.split('-').first)),
                      ...c.canonical.genres.map((g) => CustomBadge(child: Text(g))),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Overview
                  if (c.canonical.overview.isNotEmpty)
                    Text(
                      c.canonical.overview,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.8),
                        fontFamily: 'Cairo',
                        height: 1.6,
                      ),
                    ),
                  const SizedBox(height: 24),

                  // Action Buttons
                  Row(
                    children: [
                      // Quick Play Button
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _handleQuickPlay,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.gold400,
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                          ),
                          icon: const Icon(Icons.play_arrow, size: 22),
                          label: const Text(
                            'تشغيل سريع',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, fontFamily: 'Cairo'),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),

                      // Server Picker
                      OutlinedButton.icon(
                        onPressed: _showSourcePicker,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: BorderSide(color: Colors.white.withOpacity(0.2)),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        ),
                        icon: const Icon(Icons.layers_outlined, size: 20),
                        label: const Text('السيرفرات', style: TextStyle(fontFamily: 'Cairo')),
                      ),
                      const SizedBox(width: 10),

                      // Favorite Button
                      IconButton.filledTonal(
                        onPressed: () => progress.toggleFavorite(c),
                        icon: Icon(
                          isFav ? Icons.favorite : Icons.favorite_border,
                          color: isFav ? AppColors.gold400 : Colors.white70,
                        ),
                      ),
                      const SizedBox(width: 6),

                      // Share Button
                      IconButton.filledTonal(
                        onPressed: _shareContent,
                        icon: const Icon(Icons.share_outlined, color: Colors.white70),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Series Episodes Section
                  if (c.mediaType == 'series') ...[
                    const Text(
                      'الحلقات والمواسم',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Cairo'),
                    ),
                    const SizedBox(height: 16),
                    if (_loadingEpisodes)
                      const Center(child: CircularProgressIndicator(color: AppColors.gold400))
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _episodes.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (context, idx) {
                          final ep = _episodes[idx];
                          final isCurrent = _selectedEpisode?.episodeNumber == ep.episodeNumber;
                          return ListTile(
                            tileColor: isCurrent ? AppColors.gold400.withOpacity(0.12) : AppColors.darkElevated,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                              side: BorderSide(color: isCurrent ? AppColors.gold400 : Colors.transparent),
                            ),
                            title: Text(
                              ep.title,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: isCurrent ? AppColors.gold400 : Colors.white,
                                fontFamily: 'Cairo',
                              ),
                            ),
                            subtitle: ep.overview.isNotEmpty
                                ? Text(ep.overview, maxLines: 1, overflow: TextOverflow.ellipsis)
                                : null,
                            trailing: IconButton(
                              icon: const Icon(Icons.play_circle_fill, color: AppColors.gold400, size: 28),
                              onPressed: () {
                                setState(() => _selectedEpisode = ep);
                                _handleQuickPlay();
                              },
                            ),
                          );
                        },
                      ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
