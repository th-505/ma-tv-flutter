import '../../domain/models/content_identity.dart';
import '../../domain/models/playback_source.dart';
import '../../core/playback/quick_play_ranking.dart';
import '../../core/playback/provider_health_engine.dart';

class EmbedServerConfig {
  final String id;
  final String name;
  final String moviePattern;
  final String seriesPattern;
  final String badge;
  final int priority;

  const EmbedServerConfig({
    required this.id,
    required this.name,
    required this.moviePattern,
    required this.seriesPattern,
    required this.badge,
    required this.priority,
  });
}

class ServerManager {
  static final ProviderHealthEngine health = ProviderHealthEngine();
  static final Map<String, ProviderPerformanceProfile> performance = {};

  static void recordPlayback(String providerId, {required bool success, required int latencyMs}) {
    final profile = performance.putIfAbsent(providerId, () => ProviderPerformanceProfile(providerId: providerId));
    profile.record(success: success, latencyMs: latencyMs);
    if (success) { health.recordSuccess(providerId); } else { health.recordFailure(providerId); }
  }
  static const List<EmbedServerConfig> globalServers = [
    EmbedServerConfig(
      id: 'vidsrc-su',
      name: 'VidSrc SU (سريع)',
      moviePattern: 'https://vidsrc.su/embed/movie/{id}',
      seriesPattern: 'https://vidsrc.su/embed/tv/{id}/{s}/{e}',
      badge: '1080p VIP',
      priority: 1,
    ),
    EmbedServerConfig(
      id: 'embed-su',
      name: 'Embed SU (متعدد الترجمات)',
      moviePattern: 'https://embed.su/embed/movie/{id}',
      seriesPattern: 'https://embed.su/embed/tv/{id}/{s}/{e}',
      badge: 'Auto Subs',
      priority: 2,
    ),
    EmbedServerConfig(
      id: 'vidsrc-pro',
      name: 'VidSrc PRO (فائق السرعة)',
      moviePattern: 'https://vidsrc.pro/embed/movie/{id}',
      seriesPattern: 'https://vidsrc.pro/embed/tv/{id}/{s}/{e}',
      badge: '1080p HD',
      priority: 3,
    ),
    EmbedServerConfig(
      id: 'smashystream',
      name: 'SmashyStream (بدون إعلانات)',
      moviePattern: 'https://embed.smashystream.com/playere.php?tmdb={id}',
      seriesPattern: 'https://embed.smashystream.com/playere.php?tmdb={id}&season={s}&episode={e}',
      badge: 'Ad-Free',
      priority: 4,
    ),
    EmbedServerConfig(
      id: '2embed',
      name: '2Embed (سيرفر رئيسي)',
      moviePattern: 'https://www.2embed.cc/embed/{id}',
      seriesPattern: 'https://www.2embed.cc/embedtv/{id}&s={s}&e={e}',
      badge: 'Original',
      priority: 5,
    ),
    EmbedServerConfig(
      id: 'superstream',
      name: 'SuperStream (سيرفر مستقر)',
      moviePattern: 'https://superstream.su/embed/movie/{id}',
      seriesPattern: 'https://superstream.su/embed/tv/{id}/{s}/{e}',
      badge: 'Ultra HD',
      priority: 6,
    ),
    EmbedServerConfig(
      id: 'autoembed',
      name: 'AutoEmbed Fast',
      moviePattern: 'https://player.autoembed.cc/embed/movie/{id}',
      seriesPattern: 'https://player.autoembed.cc/embed/tv/{id}/{s}/{e}',
      badge: 'Fast CDN',
      priority: 7,
    ),
    EmbedServerConfig(
      id: 'vidsrc-xyz',
      name: 'VidSrc XYZ',
      moviePattern: 'https://vidsrc.xyz/embed/movie/{id}',
      seriesPattern: 'https://vidsrc.xyz/embed/tv/{id}/{s}/{e}',
      badge: 'Multi-Res',
      priority: 8,
    ),
    EmbedServerConfig(
      id: 'multiembed',
      name: 'MultiEmbed VIP',
      moviePattern: 'https://multiembed.mov/?video_id={id}&tmdb=1',
      seriesPattern: 'https://multiembed.mov/?video_id={id}&tmdb=1&s={s}&e={e}',
      badge: 'Multi-Lang',
      priority: 9,
    ),
    EmbedServerConfig(
      id: 'vidsrc-me',
      name: 'VidSrc ME Official',
      moviePattern: 'https://vidsrc.me/embed/movie?tmdb={id}',
      seriesPattern: 'https://vidsrc.me/embed/tv?tmdb={id}&season={s}&episode={e}',
      badge: 'Official',
      priority: 10,
    ),
    EmbedServerConfig(
      id: 'movie123',
      name: 'Movie123 Global',
      moviePattern: 'https://123moviesfree.net/embed/movie/{id}',
      seriesPattern: 'https://123moviesfree.net/embed/tv/{id}/{s}/{e}',
      badge: 'HQ',
      priority: 11,
    ),
    EmbedServerConfig(
      id: 'streamwish',
      name: 'StreamWish Cloud',
      moviePattern: 'https://streamwish.to/e/{id}',
      seriesPattern: 'https://streamwish.to/e/{id}_{s}_{e}',
      badge: 'Cloud Fast',
      priority: 12,
    ),
    EmbedServerConfig(
      id: 'filelions',
      name: 'FileLions Direct',
      moviePattern: 'https://filelions.online/v/{id}',
      seriesPattern: 'https://filelions.online/v/{id}_{s}_{e}',
      badge: 'Direct Stream',
      priority: 13,
    ),
    EmbedServerConfig(
      id: 'mixdrop',
      name: 'MixDrop High Speed',
      moviePattern: 'https://mixdrop.co/e/{id}',
      seriesPattern: 'https://mixdrop.co/e/{id}_{s}_{e}',
      badge: 'High Speed',
      priority: 14,
    ),
    EmbedServerConfig(
      id: 'doodstream',
      name: 'DoodStream Mobile',
      moviePattern: 'https://dood.to/e/{id}',
      seriesPattern: 'https://dood.to/e/{id}_{s}_{e}',
      badge: 'Mobile Opt',
      priority: 15,
    ),
  ];

  static List<RankedSource> buildSources(ContentIdentity identity, {int? season, int? episode, String preferredQuality = 'auto'}) {
    final s = season ?? 1;
    final e = episode ?? 1;
    final id = identity.tmdbId.toString();

    final candidates = globalServers.where((server) => health.canAttempt(server.id)).map((server) {
      final isSeries = identity.mediaType == 'series';
      final pattern = isSeries ? server.seriesPattern : server.moviePattern;
      final url = pattern.replaceAll('{id}', id).replaceAll('{s}', s.toString()).replaceAll('{e}', e.toString());
      return PlaybackSource(
        providerId: server.id,
        sourceId: '${server.id}-$id-$s-$e',
        url: url,
        quality: '1080p',
        embedUrl: url,
        qualityConfidence: QualityConfidence.providerDeclared,
      );
    }).toList();

    final ranked=QuickPlayRanking.rank(candidates, performance);
    if(preferredQuality=='auto') return ranked;
    int distance(String quality){
      int value(String q){
        final v=q.toLowerCase();
        if(v.contains('2160')||v.contains('4k')) return 2160;
        if(v.contains('1080')) return 1080;
        if(v.contains('720')) return 720;
        if(v.contains('480')) return 480;
        if(v.contains('360')) return 360;
        return 0;
      }
      return (value(quality)-value(preferredQuality)).abs();
    }
    ranked.sort((a,b){
      final healthA=a.healthStatus.toUpperCase()=='UNHEALTHY'?1:0;
      final healthB=b.healthStatus.toUpperCase()=='UNHEALTHY'?1:0;
      final health=healthA.compareTo(healthB);
      if(health!=0)return health;
      final quality=distance(a.source.quality).compareTo(distance(b.source.quality));
      if(quality!=0)return quality;
      return b.score.compareTo(a.score);
    });
    for(var i=0;i<ranked.length;i++){ranked[i].rank=i+1;}
    return ranked;
  }
}
