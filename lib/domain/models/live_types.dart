class LiveChannelModel {
 final String channelId,name,country; final String? logo,category; final List<LiveSourceModel> sources;
 const LiveChannelModel({required this.channelId,required this.name,this.logo,required this.country,this.category,required this.sources});
}
class LiveSourceModel {
 final String providerId,sourceId,url,quality,health; final List<String>? audioTracks;
 const LiveSourceModel({required this.providerId,required this.sourceId,required this.url,required this.quality,this.audioTracks,required this.health});
}
enum LiveHealthStatus { healthy, degraded, unhealthy }
class LiveHealthState { final String channelId,sourceId; final LiveHealthStatus status; final DateTime lastChecked; final int? latencyMs; const LiveHealthState({required this.channelId,required this.sourceId,required this.status,required this.lastChecked,this.latencyMs}); }
class MatchEvent { final String matchId,homeTeam,awayTeam,time,tournament; final List<String> channels; final String? logoHome,logoAway; const MatchEvent({required this.matchId,required this.homeTeam,required this.awayTeam,required this.time,required this.tournament,required this.channels,this.logoHome,this.logoAway}); }

extension LiveChannelSelection on LiveChannelModel {
  List<LiveSourceModel> get playableSources {
    final items = List<LiveSourceModel>.from(sources);
    int rank(String health) {
      switch (health.toUpperCase()) {
        case 'HEALTHY': return 0;
        case 'DEGRADED': return 1;
        default: return 2;
      }
    }
    items.sort((a,b) {
      final byHealth=rank(a.health).compareTo(rank(b.health));
      if(byHealth!=0) return byHealth;
      int quality(String q) {
        final v=q.toLowerCase();
        if(v.contains('4k')||v.contains('2160')) return 4;
        if(v.contains('1080')) return 3;
        if(v.contains('720')) return 2;
        if(v.contains('480')) return 1;
        return 0;
      }
      return quality(b.quality).compareTo(quality(a.quality));
    });
    return items;
  }

  LiveSourceModel? get bestSource {
    final candidates=playableSources.where((s)=>s.health.toUpperCase()!='UNHEALTHY').toList();
    return candidates.isEmpty?null:candidates.first;
  }
}
