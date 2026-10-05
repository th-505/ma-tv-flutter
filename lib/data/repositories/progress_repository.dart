import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/models/content_identity.dart';

class ProgressRepository extends ChangeNotifier {
  static const _keyHistory='matv_watch_history', _keyFavorites='matv_favorites', _keyFavChannels='matv_fav_channels', _keyTheme='matv_theme';
  SharedPreferences? _prefs;
  List<ContentIdentity> _favorites=[];
  List<String> _favChannelIds=[];
  ThemeMode _themeMode=ThemeMode.dark;
  String _preferredQuality='auto';
  bool _autoplay=true;
  bool _resumePlayback=true;
  bool _liveFailover=true;
  double _defaultPlaybackSpeed=1.0;
  List<ContentIdentity> get favorites=>List.unmodifiable(_favorites);
  List<String> get favChannelIds=>List.unmodifiable(_favChannelIds);
  ThemeMode get themeMode=>_themeMode;
  String get preferredQuality=>_preferredQuality;
  bool get autoplay=>_autoplay;
  bool get resumePlayback=>_resumePlayback;
  bool get liveFailover=>_liveFailover;
  double get defaultPlaybackSpeed=>_defaultPlaybackSpeed;

  Future<void> init() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      _loadFavorites();
      _loadFavChannels();
      _loadTheme();
      _loadPlaybackSettings();
    } catch (_) {
      _prefs = null;
      _favorites = [];
      _favChannelIds = [];
      _themeMode = ThemeMode.dark;
      notifyListeners();
    }
  }
  Future<void> _ensureInit() async { if(_prefs==null) await init(); }
  void _loadTheme(){ final v=_prefs?.getString(_keyTheme)??'dark'; _themeMode=v=='light'?ThemeMode.light:v=='system'?ThemeMode.system:ThemeMode.dark; notifyListeners(); }
  Future<bool> isDarkMode() async { await _ensureInit(); return _themeMode!=ThemeMode.light; }
  Future<void> setDarkMode(bool dark)=>setTheme(dark?'dark':'light');
  Future<void> setTheme(String value) async { await _ensureInit(); await _prefs!.setString(_keyTheme,value); _loadTheme(); }
  void _loadPlaybackSettings(){
    _preferredQuality=_prefs?.getString('matv_preferred_quality')??'auto';
    _autoplay=_prefs?.getBool('matv_autoplay')??true;
    _resumePlayback=_prefs?.getBool('matv_resume_playback')??true;
    _liveFailover=_prefs?.getBool('matv_live_failover')??true;
    _defaultPlaybackSpeed=_prefs?.getDouble('matv_playback_speed')??1.0;
    notifyListeners();
  }
  Future<void> setPreferredQuality(String v) async {await _ensureInit();_preferredQuality=v;await _prefs!.setString('matv_preferred_quality',v);notifyListeners();}
  Future<void> setAutoplay(bool v) async {await _ensureInit();_autoplay=v;await _prefs!.setBool('matv_autoplay',v);notifyListeners();}
  Future<void> setResumePlayback(bool v) async {await _ensureInit();_resumePlayback=v;await _prefs!.setBool('matv_resume_playback',v);notifyListeners();}
  Future<void> setLiveFailover(bool v) async {await _ensureInit();_liveFailover=v;await _prefs!.setBool('matv_live_failover',v);notifyListeners();}
  Future<void> setDefaultPlaybackSpeed(double v) async {await _ensureInit();_defaultPlaybackSpeed=v;await _prefs!.setDouble('matv_playback_speed',v);notifyListeners();}
  Future<List<ContentIdentity>> getFavorites() async { await _ensureInit(); return List.unmodifiable(_favorites); }
  Future<List<String>> getWatchHistory() async { await _ensureInit(); return _prefs!.getStringList(_keyHistory)??const[]; }
  Future<void> clearAllHistory() async { await _ensureInit(); final keys=_prefs!.getKeys().where((k)=>k==_keyHistory||k.startsWith('progress_')||k.startsWith('duration_')).toList(); for(final k in keys){await _prefs!.remove(k);} notifyListeners(); }

  void _loadFavorites(){
    final raw=_prefs?.getStringList(_keyFavorites)??[];
    final parsed=<ContentIdentity>[];
    for(final item in raw){
      try {
        final decoded=jsonDecode(item);
        if(decoded is Map<String,dynamic>) parsed.add(ContentIdentity.fromJson(decoded));
      } catch (_) {}
    }
    _favorites=parsed;
    notifyListeners();
  }
  bool isFavorite(int id)=>_favorites.any((f)=>f.tmdbId==id);
  Future<void> toggleFavorite(ContentIdentity identity) async { await _ensureInit(); if(isFavorite(identity.tmdbId)){_favorites.removeWhere((f)=>f.tmdbId==identity.tmdbId);}else{_favorites.add(identity);} final raw=_favorites.map((f)=>jsonEncode({'id':f.tmdbId,'media_type':f.mediaType,'title':f.canonical.title,'overview':f.canonical.overview,'poster_path':f.canonical.posterPath,'backdrop_path':f.canonical.backdropPath,'vote_average':f.canonical.voteAverage})).toList(); await _prefs!.setStringList(_keyFavorites,raw); notifyListeners(); }
  void _loadFavChannels(){_favChannelIds=_prefs?.getStringList(_keyFavChannels)??[]; notifyListeners();}
  bool isFavChannel(String id)=>_favChannelIds.contains(id);
  Future<void> toggleFavChannel(String id) async { await _ensureInit(); _favChannelIds.contains(id)?_favChannelIds.remove(id):_favChannelIds.add(id); await _prefs!.setStringList(_keyFavChannels,_favChannelIds); notifyListeners(); }
  Future<void> saveProgress(int id,double positionSeconds,double durationSeconds) async {
    await _ensureInit();
    await _prefs!.setDouble('progress_$id',positionSeconds);
    await _prefs!.setDouble('duration_$id',durationSeconds);
    final history=_prefs!.getStringList(_keyHistory)??<String>[];
    history.remove('$id');
    history.insert(0,'$id');
    if(history.length>50) history.removeRange(50,history.length);
    await _prefs!.setStringList(_keyHistory,history);
    notifyListeners();
  }
  double getProgress(int id)=>_prefs?.getDouble('progress_$id')??0;
  double getDuration(int id)=>_prefs?.getDouble('duration_$id')??0;
  double getProgressRatio(int id){final d=getDuration(id);return d<=0?0:(getProgress(id)/d).clamp(0.0,1.0);}
  Future<void> removeProgress(int id) async {await _ensureInit();await _prefs!.remove('progress_$id');await _prefs!.remove('duration_$id');final h=_prefs!.getStringList(_keyHistory)??<String>[];h.remove('$id');await _prefs!.setStringList(_keyHistory,h);notifyListeners();}
}
