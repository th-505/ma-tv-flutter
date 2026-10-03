import '../../domain/models/playback_source.dart';

class QuickPlayRanking {
  static int _quality(String q) => const {'4K':4,'1080p':3,'720p':2,'480p':1,'360p':0}[q] ?? 0;

  static List<RankedSource> rank(
    List<PlaybackSource> sources,
    Map<String, ProviderPerformanceProfile> performance, {
    String preferredAudioLanguage = 'ar',
    bool preferSubtitles = true,
  }) {
    final ranked = sources.map((source) {
      final p = performance[source.providerId];
      final qualityScore = _quality(source.quality) * 25.0;
      final stability = (p?.successRateEma ?? .5) * 100;
      final latency = p == null ? 50.0 : (100 - p.startupLatencyEma / 20).clamp(0, 100).toDouble();
      final buffering = p == null ? 80.0 : (100 - p.bufferingRateEma * 10).clamp(0, 100).toDouble();
      final audio = source.audioLanguage == preferredAudioLanguage ? 100.0 : 50.0;
      final subtitles = preferSubtitles && source.hasSubtitles ? 100.0 : 50.0;
      final verified = switch (source.qualityConfidence) {
        QualityConfidence.trackVerified => 100.0,
        QualityConfidence.manifestVerified => 85.0,
        QualityConfidence.providerDeclared => 60.0,
        QualityConfidence.unverified => 30.0,
      };
      final score = qualityScore*.2 + verified*.2 + stability*.2 + latency*.1 + buffering*.1 + audio*.1 + subtitles*.1;
      final health = p == null ? 'UNKNOWN' : p.successRateEma > .85 ? 'HEALTHY' : p.successRateEma > .5 ? 'DEGRADED' : 'UNHEALTHY';
      return RankedSource(source: source, rank: 0, score: score.round(), healthStatus: health,
        qualityVerified: source.qualityConfidence == QualityConfidence.trackVerified || source.qualityConfidence == QualityConfidence.manifestVerified,
        latencyMs: p?.startupLatencyEma.round());
    }).toList()..sort((a,b)=>b.score.compareTo(a.score));
    for (var i=0;i<ranked.length;i++) ranked[i].rank=i+1;
    return ranked;
  }
}
