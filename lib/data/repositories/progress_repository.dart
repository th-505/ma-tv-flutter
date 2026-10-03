import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/models/content_identity.dart';

class ProgressRepository extends ChangeNotifier {
  static const String _keyHistory = 'matv_watch_history';
  static const String _keyFavorites = 'matv_favorites';
  static const String _keyFavChannels = 'matv_fav_channels';
  static const String _keyTheme = 'matv_theme';

  SharedPreferences? _prefs;
  List<ContentIdentity> _favorites = [];
  List<String> _favChannelIds = [];
  ThemeMode _themeMode = ThemeMode.dark;

  List<ContentIdentity> get favorites => _favorites;
  List<String> get favChannelIds => _favChannelIds;
  ThemeMode get themeMode => _themeMode;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _loadFavorites();
    _loadFavChannels();
    _loadTheme();
  }

  void _loadTheme() {
    final themeStr = _prefs?.getString(_keyTheme) ?? 'dark';
    if (themeStr == 'light') {
      _themeMode = ThemeMode.light;
    } else if (themeStr == 'system') {
      _themeMode = ThemeMode.system;
    } else {
      _themeMode = ThemeMode.dark;
    }
    notifyListeners();
  }

  Future<bool> isDarkMode() async {\n    if (_prefs == null) await init();\n    return _themeMode != ThemeMode.light;\n  }\n\n  Future<void> setDarkMode(bool dark) async {\n    await setTheme(dark ? 'dark' : 'light');\n  }\n\n  Future<List<ContentIdentity>> getFavorites() async {\n    if (_prefs == null) await init();\n    return List.unmodifiable(_favorites);\n  }\n\n  Future<List<String>> getWatchHistory() async {\n    if (_prefs == null) await init();\n    return _prefs?.getStringList(_keyHistory) ?? const [];\n  }\n\n  Future<void> clearAllHistory() async {\n    if (_prefs == null) await init();\n    final keys = _prefs?.getKeys().where((k) => k == _keyHistory || k.startsWith('progress_')).toList() ?? const <String>[];\n    for (final key in keys) { await _prefs?.remove(key); }\n    notifyListeners();\n  }\n\n  Future<void> setTheme(String themeStr) async {
    await _prefs?.setString(_keyTheme, themeStr);
    _loadTheme();
  }

  void _loadFavorites() {
    final raw = _prefs?.getStringList(_keyFavorites) ?? [];
    _favorites = raw.map((item) {
      final json = jsonDecode(item);
      return ContentIdentity.fromJson(json);
    }).toList();
    notifyListeners();
  }

  bool isFavorite(int tmdbId) {
    return _favorites.any((f) => f.tmdbId == tmdbId);
  }

  Future<void> toggleFavorite(ContentIdentity identity) async {
    if (isFavorite(identity.tmdbId)) {
      _favorites.removeWhere((f) => f.tmdbId == identity.tmdbId);
    } else {
      _favorites.add(identity);
    }
    final raw = _favorites.map((f) => jsonEncode({
      'id': f.tmdbId,
      'media_type': f.mediaType,
      'title': f.canonical.title,
      'overview': f.canonical.overview,
      'poster_path': f.canonical.posterPath,
      'backdrop_path': f.canonical.backdropPath,
      'vote_average': f.canonical.voteAverage,
    })).toList();
    await _prefs?.setStringList(_keyFavorites, raw);
    notifyListeners();
  }

  void _loadFavChannels() {
    _favChannelIds = _prefs?.getStringList(_keyFavChannels) ?? [];
    notifyListeners();
  }

  bool isFavChannel(String channelId) {
    return _favChannelIds.contains(channelId);
  }

  Future<void> toggleFavChannel(String channelId) async {
    if (_favChannelIds.contains(channelId)) {
      _favChannelIds.remove(channelId);
    } else {
      _favChannelIds.add(channelId);
    }
    await _prefs?.setStringList(_keyFavChannels, _favChannelIds);
    notifyListeners();
  }

  Future<void> saveProgress(int contentId, double positionSeconds, double durationSeconds) async {
    final key = 'progress_$contentId';
    await _prefs?.setDouble(key, positionSeconds);
  }

  double getProgress(int contentId) {
    return _prefs?.getDouble('progress_$contentId') ?? 0.0;
  }
}
