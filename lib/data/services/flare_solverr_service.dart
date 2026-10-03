import 'dart:convert';
import 'package:http/http.dart' as http;

class FlareSolverrService {
  static final FlareSolverrService _instance = FlareSolverrService._internal();
  factory FlareSolverrService() => _instance;
  FlareSolverrService._internal();

  String _apiUrl = 'http://localhost:8191/v1';
  final Map<String, Map<String, dynamic>> _cache = {};

  String get apiUrl => _apiUrl;

  void setApiUrl(String url) {
    if (url.isNotEmpty) _apiUrl = url;
  }

  /// Checks if FlareSolverr microservice is active
  Future<bool> checkHealth() async {
    try {
      final res = await http.get(Uri.parse(_apiUrl)).timeout(const Duration(seconds: 3));
      return res.statusCode == 200 || res.statusCode == 405;
    } catch (_) {
      return false;
    }
  }

  /// Solves Cloudflare challenge for the given target URL
  Future<String?> resolveChallenge(String targetUrl) async {
    final domain = Uri.parse(targetUrl).host;
    final now = DateTime.now().millisecondsSinceEpoch;

    // Check 30-min cache
    if (_cache.containsKey(domain)) {
      final cached = _cache[domain]!;
      if (now - (cached['timestamp'] as int) < 30 * 60 * 1000) {
        return cached['html'] as String;
      }
    }

    try {
      final payload = {
        'cmd': 'request.get',
        'url': targetUrl,
        'maxTimeout': 60000,
      };

      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      ).timeout(const Duration(seconds: 40));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'ok' && data['solution'] != null) {
          final html = data['solution']['response'] as String;
          _cache[domain] = {
            'html': html,
            'timestamp': now,
            'cookies': data['solution']['cookies'],
            'userAgent': data['solution']['userAgent'],
          };
          return html;
        }
      }
    } catch (_) {}
    return null;
  }
}
