import 'package:flutter_test/flutter_test.dart';
import 'package:matv_flutter/core/playback/provider_health_engine.dart';
import 'package:matv_flutter/core/playback/quick_play_ranking.dart';
import 'package:matv_flutter/domain/models/playback_source.dart';

void main() {
  test('quick play ranks healthier faster provider first', () {
    final a = PlaybackSource(providerId: 'a', sourceId: 'a1', url: 'https://example.com/a.m3u8');
    final b = PlaybackSource(providerId: 'b', sourceId: 'b1', url: 'https://example.com/b.m3u8');
    final perf = <String, ProviderPerformanceProfile>{
      'a': ProviderPerformanceProfile(providerId: 'a', successRateEma: .95, startupLatencyEma: 300, bufferingRateEma: .1),
      'b': ProviderPerformanceProfile(providerId: 'b', successRateEma: .55, startupLatencyEma: 1800, bufferingRateEma: 3),
    };
    final ranked = QuickPlayRanking.rank([b, a], perf);
    expect(ranked.first.source.providerId, 'a');
    expect(ranked.first.rank, 1);
  });

  test('health circuit opens after repeated failures and resets on success', () {
    final health = ProviderHealthEngine(failureThreshold: 3);
    health.recordFailure('p');
    health.recordFailure('p');
    expect(health.canAttempt('p'), isTrue);
    health.recordFailure('p');
    expect(health.canAttempt('p'), isFalse);
    health.recordSuccess('p');
    expect(health.canAttempt('p'), isTrue);
  });
}
