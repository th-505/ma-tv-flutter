import '../../domain/models/scraper_profile.dart';
import '../services/proxy_service.dart';
import '../services/flare_solverr_service.dart';
import '../services/consumet_service.dart';

class DirectStreamScraper {
  static final DirectStreamScraper _instance = DirectStreamScraper._internal();
  factory DirectStreamScraper() => _instance;
  DirectStreamScraper._internal();

  final ProxyService _proxyService = ProxyService();
  final FlareSolverrService _flareService = FlareSolverrService();
  final ConsumetService _consumetService = ConsumetService();

  /// Multi-Engine Cascading Stream Extraction
  Future<List<ExtractedStream>> scrapeStream({
    required String portalId,
    required String title,
    String? mediaType,
    int? season,
    int? episode,
  }) async {
    // Tier 1: Consumet Engine (for Anime & Asian Drama)
    if (portalId == 'hianime' || portalId == 'gogoanime' || portalId == 'dramacool') {
      final streams = await _consumetService.fetchAnimeStream(title, episode ?? 1);
      if (streams.isNotEmpty) return streams;
    }

    // Tier 2: Dedicated Arabic Site Routers via Proxy Relay
    final directStream = await _resolveArabicPortal(portalId, title, season, episode);
    if (directStream != null) return [directStream];

    // Tier 3: Cloudflare Protected Portals via FlareSolverr
    if (portalId == 'faselhd' || portalId == 'arabseed' || portalId == 'wecima') {
      final targetUrl = 'https://$portalId.com/watch/$title';
      final html = await _flareService.resolveChallenge(targetUrl);
      if (html != null && html.contains('.m3u8')) {
        final regex = RegExp(r'''https?://[^\\s\"'<>]+\\.m3u8[^\\s\"'<>]*''');
        final match = regex.firstMatch(html);
        if (match != null) {
          final streamUrl = match.group(0)!;
          return [
            ExtractedStream(
              url: _proxyService.getProxiedStreamUrl(streamUrl),
              quality: '1080p',
              protocol: StreamProtocol.hls,
              serverName: '$portalId (مباشر)',
            ),
          ];
        }
      }
    }

    return [];
  }

  Future<ExtractedStream?> _resolveArabicPortal(String portalId, String title, int? season, int? episode) async {
    final slug = title.toLowerCase().replaceAll(' ', '-');
    String url = '';

    switch (portalId) {
      case 'akwam':
        url = 'https://stream.akwam.link/video/$slug/1080p.mp4';
        break;
      case 'faselhd':
        url = 'https://stream.faselhd.club/hls/$slug/master.m3u8';
        break;
      case 'arabseed':
        url = 'https://stream.arabseed.show/hls/$slug/master.m3u8';
        break;
      case 'wecima':
        url = 'https://v.wecima.show/watch/$slug/master.mp4';
        break;
      case 'egydead':
        url = 'https://stream.egydead.live/hls/$slug/index.m3u8';
        break;
      default:
        return null;
    }

    // Wrap via proxy relay to bypass CORS & Header checks
    final proxiedUrl = _proxyService.getProxiedStreamUrl(url, referer: 'https://$portalId.com/');
    return ExtractedStream(
      url: proxiedUrl,
      quality: '1080p',
      protocol: url.endsWith('.mp4') ? StreamProtocol.mp4 : StreamProtocol.hls,
      serverName: portalId,
    );
  }
}
