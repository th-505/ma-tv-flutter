import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../domain/models/scraper_profile.dart';

class ConsumetService {
  static final ConsumetService _instance = ConsumetService._internal();
  factory ConsumetService() => _instance;
  ConsumetService._internal();

  final List<String> _endpoints = [
    'https://consumet.beebank.dev',
    'https://api.consumet.org',
    'https://consumet-api.up.railway.app',
  ];

  String _activeEndpoint = 'https://consumet.beebank.dev';

  String get activeEndpoint => _activeEndpoint;

  void setActiveEndpoint(String url) {
    if (url.isNotEmpty) _activeEndpoint = url;
  }

  Future<bool> checkHealth() async {
    for (final ep in _endpoints) {
      try {
        final res = await http.get(Uri.parse(ep)).timeout(const Duration(seconds: 4));
        if (res.statusCode == 200) {
          _activeEndpoint = ep;
          return true;
        }
      } catch (_) {}
    }
    return false;
  }

  /// Search anime and extract stream via Gogoanime or Zoro
  Future<List<ExtractedStream>> fetchAnimeStream(String query, int episode) async {
    try {
      final searchUrl = '$_activeEndpoint/anime/gogoanime/$query';
      final searchRes = await http.get(Uri.parse(searchUrl)).timeout(const Duration(seconds: 7));
      if (searchRes.statusCode == 200) {
        final data = jsonDecode(searchRes.body);
        final results = data['results'] as List<dynamic>?;
        if (results != null && results.isNotEmpty) {
          final animeId = results[0]['id'];
          final epId = '$animeId-episode-$episode';
          final streamUrl = '$_activeEndpoint/anime/gogoanime/watch/$epId';
          final streamRes = await http.get(Uri.parse(streamUrl)).timeout(const Duration(seconds: 7));
          if (streamRes.statusCode == 200) {
            final streamData = jsonDecode(streamRes.body);
            final sources = streamData['sources'] as List<dynamic>?;
            if (sources != null) {
              return sources.map((s) {
                return ExtractedStream(
                  url: s['url'] ?? '',
                  quality: s['quality'] ?? 'default',
                  protocol: StreamProtocol.hls,
                  serverName: 'GogoAnime CDN',
                );
              }).toList();
            }
          }
        }
      }
    } catch (_) {}
    return [];
  }
}
