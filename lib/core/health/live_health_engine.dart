class LiveSourceHealthSnapshot {
  final int successes;
  final int failures;
  final int consecutiveFailures;
  final double latencyEmaMs;
  final DateTime? lastFailure;
  const LiveSourceHealthSnapshot({
    this.successes=0,
    this.failures=0,
    this.consecutiveFailures=0,
    this.latencyEmaMs=0,
    this.lastFailure,
  });

  double get successRate {
    final total=successes+failures;
    return total==0?1:successes/total;
  }

  String get status {
    if(consecutiveFailures>=3) return 'UNHEALTHY';
    if(consecutiveFailures>0||successRate<0.75) return 'DEGRADED';
    return 'HEALTHY';
  }
}

class LiveHealthEngine {
  LiveHealthEngine._();
  static final instance=LiveHealthEngine._();
  final Map<String,LiveSourceHealthSnapshot> _states={};

  LiveSourceHealthSnapshot state(String sourceId)=>_states[sourceId]??const LiveSourceHealthSnapshot();

  void recordSuccess(String sourceId,int latencyMs){
    final s=state(sourceId);
    final ema=s.latencyEmaMs==0?latencyMs.toDouble():(s.latencyEmaMs*.7+latencyMs*.3);
    _states[sourceId]=LiveSourceHealthSnapshot(
      successes:s.successes+1,
      failures:s.failures,
      consecutiveFailures:0,
      latencyEmaMs:ema,
      lastFailure:s.lastFailure,
    );
  }

  void recordFailure(String sourceId){
    final s=state(sourceId);
    _states[sourceId]=LiveSourceHealthSnapshot(
      successes:s.successes,
      failures:s.failures+1,
      consecutiveFailures:s.consecutiveFailures+1,
      latencyEmaMs:s.latencyEmaMs,
      lastFailure:DateTime.now(),
    );
  }

  bool canTry(String sourceId){
    final s=state(sourceId);
    if(s.consecutiveFailures<3) return true;
    final last=s.lastFailure;
    return last==null||DateTime.now().difference(last)>const Duration(seconds:30);
  }

  List<T> rank<T>(List<T> items,String Function(T) sourceId,String Function(T) declaredHealth,String Function(T) quality){
    final out=List<T>.from(items);
    int q(String value){
      final v=value.toLowerCase();
      if(v.contains('4k')||v.contains('2160')) return 4;
      if(v.contains('1080')) return 3;
      if(v.contains('720')) return 2;
      if(v.contains('480')) return 1;
      return 0;
    }
    int h(String value)=>value=='HEALTHY'?0:value=='DEGRADED'?1:2;
    out.sort((a,b){
      final sa=state(sourceId(a));
      final sb=state(sourceId(b));
      final ha=sa.successes+sa.failures==0?declaredHealth(a).toUpperCase():sa.status;
      final hb=sb.successes+sb.failures==0?declaredHealth(b).toUpperCase():sb.status;
      final byHealth=h(ha).compareTo(h(hb));
      if(byHealth!=0)return byHealth;
      final byRate=sb.successRate.compareTo(sa.successRate);
      if(byRate!=0)return byRate;
      final byQuality=q(quality(b)).compareTo(q(quality(a)));
      if(byQuality!=0)return byQuality;
      return sa.latencyEmaMs.compareTo(sb.latencyEmaMs);
    });
    return out;
  }
}
