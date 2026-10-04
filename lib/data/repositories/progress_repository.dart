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
  List<ContentIdentity> get favorites=>List.unmodifiable(_favorites);
  List<String> get favChannelIds=>List.unmodifiable(_favChannelIds);
  ThemeMode get themeMode=>_themeMode;

  Future<void> init() async { _prefs=await SharedPreferences.getInstance(); _loadFavorites(); _loadFavChannels(); _loadTheme(); }
  Future<void> _ensureInit() async { if(_prefs==null) await init(); }
  void _loadTheme(){ final v=_prefs?.getString(_keyTheme)??'dark'; _themeMode=v=='light'?ThemeMode.light:v=='system'?ThemeMode.system:ThemeMode.dark; notifyListeners(); }
  Future<bool> isDarkMode() async { await _ensureInit(); return _themeMode!=ThemeMode.light; }
  Future<void> setDarkMode(bool dark)=>setTheme(dark?'dark':'light');
  Future<void> setTheme(String value) async { await _ensureInit(); await _prefs!.setString(_keyTheme,value); _loadTheme(); }
  Future<List<ContentIdentity>> getFavorites() async { await _ensureInit(); return List.unmodifiable(_favorites); }
  Future<List<String>> getWatchHistory() async { await _ensureInit(); return _prefs!.getStringList(_keyHistory)??const[]; }
  Future<void> clearAllHistory() async { await _ensureInit(); final keys=_prefs!.getKeys().where((k)=>k==_keyHistory||k.startsWith('progress_')||k.startsWith('duration_')).toList(); for(final k in keys){await _prefs!.remove(k);} notifyListeners(); }

  void _loadFavorites(){ final raw=_prefs?.getStringList(_keyFavorites)??[]; _favorites=raw.map((x)=>ContentIdentity.fromJson(jsonDecode(x))).toList(); notifyListeners(); }
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
