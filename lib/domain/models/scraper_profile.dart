enum ScraperCategory { movies, anime, sports, liveTv, wrestling, global }

enum StreamProtocol { hls, mp4, dash, embed }

class ExtractedStream {
  final String url;
  final String quality;
  final StreamProtocol protocol;
  final String? serverName;
  final Map<String, String>? headers;

  ExtractedStream({
    required this.url,
    required this.quality,
    this.protocol = StreamProtocol.hls,
    this.serverName,
    this.headers,
  });
}

class ScraperProfile {
  final String id;
  final String name;
  final String baseUrl;
  final ScraperCategory category;
  final bool requiresProxy;
  final bool enabled;

  ScraperProfile({
    required this.id,
    required this.name,
    required this.baseUrl,
    required this.category,
    this.requiresProxy = false,
    this.enabled = true,
  });
}
