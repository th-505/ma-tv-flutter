import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class ProxyService {
  static final ProxyService _instance = ProxyService._internal();
  factory ProxyService() => _instance;
  ProxyService._internal();

  String _localProxyBaseUrl = 'http://localhost:5173/api/proxy';

  void setLocalProxyBaseUrl(String url) {
    _localProxyBaseUrl = url;
  }

  /// Converts a direct stream URL to a proxied stream URL with Referer/User-Agent bypass
  String getProxiedStreamUrl(String targetUrl, {String? referer}) {
    final queryParams = <String, String>{
      'url': targetUrl,
      if (referer != null) 'referer': referer,
    };
    if (kIsWeb) {
      return getPublicFallbackProxyUrl(targetUrl);
    }
    final uri = Uri.parse('$_localProxyBaseUrl/stream').replace(queryParameters: queryParams);
    return uri.toString();
  }

  /// Public CORS fallback if running in pure static web (e.g. GitHub Pages without local backend)
  String getPublicFallbackProxyUrl(String targetUrl) {
    return 'https://api.allorigins.win/raw?url=${Uri.encodeComponent(targetUrl)}';
  }

  /// Checks if proxy server is active and reachable
  Future<bool> checkProxyHealth() async {
    try {
      final res = await http.get(Uri.parse('$_localProxyBaseUrl/ping')).timeout(const Duration(seconds: 3));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        return data['status'] == 'ok';
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  /// Direct fetch with proxy fallback
  Future<String> fetchHtmlWithProxy(String targetUrl, {Map<String, String>? headers}) async {
    // 1. Try local proxy on native/dev builds only. GitHub Pages cannot reach a user's localhost.
    if (!kIsWeb) {
      try {
        final proxyUri = Uri.parse('$_localProxyBaseUrl/scrape').replace(queryParameters: {'url': targetUrl});
        final res = await http.get(proxyUri).timeout(const Duration(seconds: 5));
        if (res.statusCode == 200) return res.body;
      } catch (_) {}
    }

    // 2. Direct fetch with headers
    try {
      final res = await http.get(
        Uri.parse(targetUrl),
        headers: {
          'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
          ...?headers,
        },
      ).timeout(const Duration(seconds: 5));
      if (res.statusCode == 200) return res.body;
    } catch (_) {}

    // 3. Fallback to public allorigins
    final fallbackRes = await http.get(Uri.parse(getPublicFallbackProxyUrl(targetUrl))).timeout(const Duration(seconds: 7));
    return fallbackRes.body;
  }
}
