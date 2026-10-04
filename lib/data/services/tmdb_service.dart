import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../domain/models/content_identity.dart';

class TmdbService {
  static const String _baseUrl = 'https://api.themoviedb.org/3';
  String _apiKey = 'f89b2518e3a2b72bf4da2880c102a0a3'; // Default public demo key or user-defined

  void setApiKey(String key) {
    if (key.isNotEmpty) _apiKey = key;
  }

  String getPosterUrl(String? path) {
    if (path == null || path.isEmpty) return 'https://via.placeholder.com/300x450/1A1A1E/D4AF37?text=MA-TV';
    return 'https://image.tmdb.org/t/p/w500$path';
  }

  String getBackdropUrl(String? path) {
    if (path == null || path.isEmpty) return 'https://via.placeholder.com/1280x720/1A1A1E/D4AF37?text=MA-TV';
    return 'https://image.tmdb.org/t/p/original$path';
  }

  Future<List<ContentIdentity>> getTrending({String type = 'all'}) async {
    final url = '$_baseUrl/trending/$type/week?api_key=$_apiKey&language=ar-SA';
    return _fetchList(url);
  }

  Future<List<ContentIdentity>> getTopRatedMovies() async {
    final url = '$_baseUrl/movie/top_rated?api_key=$_apiKey&language=ar-SA';
    return _fetchList(url);
  }

  Future<List<ContentIdentity>> getPopularMovies({int page = 1}) async {
    final url = '$_baseUrl/movie/popular?api_key=$_apiKey&language=ar-SA&page=$page';
    return _fetchList(url);
  }

  Future<List<ContentIdentity>> getTopRatedSeries({int page = 1}) async {
    final url = '$_baseUrl/tv/top_rated?api_key=$_apiKey&language=ar-SA&page=$page';
    return _fetchList(url);
  }

  Future<List<ContentIdentity>> getNowPlayingMovies({int page = 1}) async {
    final url = '$_baseUrl/movie/now_playing?api_key=$_apiKey&language=ar-SA&page=$page';
    return _fetchList(url);
  }

  Future<List<ContentIdentity>> getOnTheAirSeries({int page = 1}) async {
    final url = '$_baseUrl/tv/on_the_air?api_key=$_apiKey&language=ar-SA&page=$page';
    return _fetchList(url);
  }

  Future<List<ContentIdentity>> getPopularSeries() async {
    final url = '$_baseUrl/tv/popular?api_key=$_apiKey&language=ar-SA';
    return _fetchList(url);
  }

  Future<List<ContentIdentity>> getByLanguage(String lang, {String type = 'movie'}) async {
    final url = '$_baseUrl/discover/$type?api_key=$_apiKey&language=ar-SA&with_original_language=$lang&sort_by=popularity.desc';
    return _fetchList(url);
  }

  Future<List<ContentIdentity>> getAnime() async {
    final url = '$_baseUrl/discover/tv?api_key=$_apiKey&language=ar-SA&with_genres=16&sort_by=popularity.desc';
    return _fetchList(url);
  }

  Future<List<ContentIdentity>> search(String query) async {
    if (query.trim().isEmpty) return [];
    final url = '$_baseUrl/search/multi?api_key=$_apiKey&language=ar-SA&query=${Uri.encodeComponent(query)}';
    return _fetchList(url);
  }

  Future<List<EpisodeIdentity>> getSeasonEpisodes(int seriesId, int seasonNumber) async {
    final url = '$_baseUrl/tv/$seriesId/season/$seasonNumber?api_key=$_apiKey&language=ar-SA';
    try {
      final res = await http.get(Uri.parse(url));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final eps = data['episodes'] as List<dynamic>?;
        if (eps != null) {
          return eps.map((e) => EpisodeIdentity.fromJson(e)).toList();
        }
      }
    } catch (_) {}
    return [];
  }

  Future<List<ContentIdentity>> _fetchList(String url) async {
    try {
      final res = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 8));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final results = data['results'] as List<dynamic>?;
        if (results != null) {
          return results.map((item) => ContentIdentity.fromJson(item)).toList();
        }
      }
    } catch (_) {}
    return [];
  }
}
