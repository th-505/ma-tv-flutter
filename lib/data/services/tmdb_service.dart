import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../domain/models/content_identity.dart';

class TmdbService {
  static const String _baseUrl = 'https://api.themoviedb.org/3';
  String _apiKey = 'f562845c2beca65e1028ff2e31ccaff1'; // Default public demo key or user-defined

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

  Future<List<ContentIdentity>> searchMovies(String query) async {
    if (query.trim().isEmpty) return [];
    final url = '$_baseUrl/search/movie?api_key=$_apiKey&language=ar-SA&include_adult=false&query=${Uri.encodeComponent(query)}';
    return _fetchList(url);
  }

  Future<List<ContentIdentity>> searchSeries(String query) async {
    if (query.trim().isEmpty) return [];
    final url = '$_baseUrl/search/tv?api_key=$_apiKey&language=ar-SA&include_adult=false&query=${Uri.encodeComponent(query)}';
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



  Future<List<ContentIdentity>> getUpcomingMovies({int page=1,String region='SA'}) =>
      _fetchList('$_baseUrl/movie/upcoming?api_key=$_apiKey&language=ar-SA&region=$region&page=$page');

  Future<List<ContentIdentity>> getAiringToday({int page=1}) =>
      _fetchList('$_baseUrl/tv/airing_today?api_key=$_apiKey&language=ar-SA&page=$page');

  Future<Map<String,dynamic>?> getConfiguration() =>
      _fetchObject('$_baseUrl/configuration?api_key=$_apiKey');

  Future<Map<String,dynamic>?> getCountries() =>
      _fetchObject('$_baseUrl/configuration/countries?api_key=$_apiKey&language=ar-SA');

  Future<Map<String,dynamic>?> getLanguages() =>
      _fetchObject('$_baseUrl/configuration/languages?api_key=$_apiKey');

  Future<Map<String,dynamic>?> getMovieWatchProviderCatalog({String region='SA',String language='ar-SA'}) =>
      _fetchObject('$_baseUrl/watch/providers/movie?api_key=$_apiKey&watch_region=$region&language=$language');

  Future<Map<String,dynamic>?> getTvWatchProviderCatalog({String region='SA',String language='ar-SA'}) =>
      _fetchObject('$_baseUrl/watch/providers/tv?api_key=$_apiKey&watch_region=$region&language=$language');

  Future<Map<String,dynamic>?> getWatchProviderRegions({String language='ar-SA'}) =>
      _fetchObject('$_baseUrl/watch/providers/regions?api_key=$_apiKey&language=$language');

  Future<Map<String,dynamic>?> getCollection(int collectionId) =>
      _fetchObject('$_baseUrl/collection/$collectionId?api_key=$_apiKey&language=ar-SA');

  Future<Map<String,dynamic>?> getMovieLists(int movieId,{int page=1}) =>
      _fetchObject('$_baseUrl/movie/$movieId/lists?api_key=$_apiKey&language=ar-SA&page=$page');

  Future<Map<String,dynamic>?> getTvLists(int seriesId,{int page=1}) =>
      _fetchObject('$_baseUrl/tv/$seriesId/lists?api_key=$_apiKey&language=ar-SA&page=$page');

  Future<Map<String, dynamic>?> getMovieDetails(int id,{String append='credits,videos,images,recommendations,similar,external_ids,release_dates,watch/providers'}) =>
      _fetchObject('$_baseUrl/movie/$id?api_key=$_apiKey&language=ar-SA&append_to_response=${Uri.encodeComponent(append)}');

  Future<Map<String, dynamic>?> getSeriesDetails(int id,{String append='credits,videos,images,recommendations,similar,external_ids,content_ratings,watch/providers'}) =>
      _fetchObject('$_baseUrl/tv/$id?api_key=$_apiKey&language=ar-SA&append_to_response=${Uri.encodeComponent(append)}');

  Future<Map<String, dynamic>?> getSeasonDetails(int seriesId,int season,{String append='credits,external_ids,images,videos,watch/providers'}) =>
      _fetchObject('$_baseUrl/tv/$seriesId/season/$season?api_key=$_apiKey&language=ar-SA&append_to_response=${Uri.encodeComponent(append)}');

  Future<Map<String, dynamic>?> getEpisodeDetails(int seriesId,int season,int episode,{String append='credits,external_ids,images,videos'}) =>
      _fetchObject('$_baseUrl/tv/$seriesId/season/$season/episode/$episode?api_key=$_apiKey&language=ar-SA&append_to_response=${Uri.encodeComponent(append)}');

  Future<List<ContentIdentity>> getRecommendations(int id,String mediaType,{int page=1}) =>
      _fetchList('$_baseUrl/${mediaType=='tv'?'tv':'movie'}/$id/recommendations?api_key=$_apiKey&language=ar-SA&page=$page');

  Future<List<ContentIdentity>> getSimilar(int id,String mediaType,{int page=1}) =>
      _fetchList('$_baseUrl/${mediaType=='tv'?'tv':'movie'}/$id/similar?api_key=$_apiKey&language=ar-SA&page=$page');

  Future<Map<String, dynamic>?> getWatchProviders(int id,String mediaType) =>
      _fetchObject('$_baseUrl/${mediaType=='tv'?'tv':'movie'}/$id/watch/providers?api_key=$_apiKey');

  Future<Map<String, dynamic>?> getCredits(int id,String mediaType) =>
      _fetchObject('$_baseUrl/${mediaType=='tv'?'tv':'movie'}/$id/credits?api_key=$_apiKey&language=ar-SA');

  Future<Map<String, dynamic>?> getVideos(int id,String mediaType) =>
      _fetchObject('$_baseUrl/${mediaType=='tv'?'tv':'movie'}/$id/videos?api_key=$_apiKey&language=ar-SA&include_video_language=ar,en,null');

  Future<Map<String, dynamic>?> getImages(int id,String mediaType) =>
      _fetchObject('$_baseUrl/${mediaType=='tv'?'tv':'movie'}/$id/images?api_key=$_apiKey&include_image_language=ar,en,null');

  Future<Map<String, dynamic>?> getGenres(String mediaType) =>
      _fetchObject('$_baseUrl/genre/${mediaType=='tv'?'tv':'movie'}/list?api_key=$_apiKey&language=ar-SA');

  Future<List<ContentIdentity>> discover(String mediaType,{int page=1,String sortBy='popularity.desc',String? language,String? genres,String? originCountry,double? minVote,int? year,String? watchProviders,String? watchRegion,bool? includeVideo}) {
    final params=<String,String>{'api_key':_apiKey,'language':'ar-SA','page':'$page','sort_by':sortBy,'include_adult':'false'};
    if(language!=null) params['with_original_language']=language;
    if(genres!=null) params['with_genres']=genres;
    if(originCountry!=null) params['with_origin_country']=originCountry;
    if(minVote!=null) params['vote_average.gte']='$minVote';
    if(year!=null) params[mediaType=='tv'?'first_air_date_year':'primary_release_year']='$year';
    if(watchProviders!=null) params['with_watch_providers']=watchProviders;
    if(watchRegion!=null) params['watch_region']=watchRegion;
    if(includeVideo!=null && mediaType!='tv') params['include_video']='$includeVideo';
    final uri=Uri.parse('$_baseUrl/discover/${mediaType=='tv'?'tv':'movie'}').replace(queryParameters:params);
    return _fetchList(uri.toString());
  }

  Future<Map<String, dynamic>?> findByExternalId(String externalId,{String source='imdb_id'}) =>
      _fetchObject('$_baseUrl/find/${Uri.encodeComponent(externalId)}?api_key=$_apiKey&external_source=${Uri.encodeComponent(source)}&language=ar-SA');

  Future<List<dynamic>> searchPeople(String query,{int page=1}) async {
    final data=await _fetchObject('$_baseUrl/search/person?api_key=$_apiKey&language=ar-SA&page=$page&query=${Uri.encodeComponent(query)}&include_adult=false');
    return (data?['results'] as List<dynamic>?)??const [];
  }

  Future<Map<String, dynamic>?> getPersonDetails(int id) =>
      _fetchObject('$_baseUrl/person/$id?api_key=$_apiKey&language=ar-SA&append_to_response=combined_credits,images,external_ids');

  Future<Map<String, dynamic>?> _fetchObject(String url) async {
    try {
      final res=await http.get(Uri.parse(url)).timeout(const Duration(seconds:8));
      if(res.statusCode==200) return jsonDecode(res.body) as Map<String,dynamic>;
    } catch (_) {}
    return null;
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
