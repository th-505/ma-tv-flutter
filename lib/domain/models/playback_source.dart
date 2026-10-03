class PlaybackSource {
  final String providerId;
  final String sourceId;
  final String url;
  final String quality;
  final String audioLanguage;
  final bool hasSubtitles;
  final String? embedUrl;
  final Map<String, String>? headers;

  PlaybackSource({
    required this.providerId,
    required this.sourceId,
    required this.url,
    this.quality = '1080p',
    this.audioLanguage = 'ar',
    this.hasSubtitles = false,
    this.embedUrl,
    this.headers,
  });
}

class RankedSource {
  final PlaybackSource source;
  final int rank;
  final int score;
  final String healthStatus; // 'READY', 'DEGRADED', 'UNAVAILABLE'
  final bool qualityVerified;

  RankedSource({
    required this.source,
    required this.rank,
    required this.score,
    this.healthStatus = 'READY',
    this.qualityVerified = true,
  });
}
