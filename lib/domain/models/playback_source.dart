enum QualityConfidence { unverified, providerDeclared, manifestVerified, trackVerified }

enum PlaybackSourceKind { directMedia, embedPage }

class PlaybackSource {
  final String providerId;
  final String sourceId;
  final String url;
  final String quality;
  final String audioLanguage;
  final bool hasSubtitles;
  final String? embedUrl;
  final Map<String, String>? headers;
  final QualityConfidence qualityConfidence;
  final PlaybackSourceKind kind;

  PlaybackSource({
    required this.providerId,
    required this.sourceId,
    required this.url,
    this.quality = '1080p',
    this.audioLanguage = 'ar',
    this.hasSubtitles = false,
    this.embedUrl,
    this.headers,
    this.qualityConfidence = QualityConfidence.providerDeclared,
    this.kind = PlaybackSourceKind.directMedia,
  });
}

class RankedSource {
  final PlaybackSource source;
  int rank;
  final int score;
  final String healthStatus;
  final bool qualityVerified;
  final int? latencyMs;

  RankedSource({
    required this.source,
    required this.rank,
    required this.score,
    this.healthStatus = 'UNKNOWN',
    this.qualityVerified = false,
    this.latencyMs,
  });
}

class ProviderPerformanceProfile {
  final String providerId;
  double successRateEma;
  double startupLatencyEma;
  double bufferingRateEma;

  ProviderPerformanceProfile({
    required this.providerId,
    this.successRateEma = .8,
    this.startupLatencyEma = 1000,
    this.bufferingRateEma = 1,
  });

  void record({required bool success, required int latencyMs, double bufferingRate = 0}) {
    const a = .3;
    successRateEma = successRateEma * (1 - a) + (success ? 1 : 0) * a;
    startupLatencyEma = startupLatencyEma * (1 - a) + latencyMs * a;
    bufferingRateEma = bufferingRateEma * (1 - a) + bufferingRate * a;
  }
}
