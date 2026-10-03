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
