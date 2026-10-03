class SubtitleTrack {
  final String id;
  final String language;
  final String label;
  final String url;
  final String format; // 'vtt' or 'srt'

  SubtitleTrack({
    required this.id,
    required this.language,
    required this.label,
    required this.url,
    this.format = 'vtt',
  });

  factory SubtitleTrack.fromJson(Map<String, dynamic> json) {
    return SubtitleTrack(
      id: json['id'] ?? '',
      language: json['language'] ?? 'ar',
      label: json['label'] ?? 'العربية',
      url: json['url'] ?? '',
      format: json['format'] ?? 'vtt',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'language': language,
    'label': label,
    'url': url,
    'format': format,
  };
}

class SubtitleSettings {
  final String language;
  final double offsetSeconds;
  final String fontSize; // 'small', 'medium', 'large', 'xlarge'

  SubtitleSettings({
    this.language = 'ar',
    this.offsetSeconds = 0.0,
    this.fontSize = 'medium',
  });
}
