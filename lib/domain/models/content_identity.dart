class CanonicalData {
  final String title;
  final String overview;
  final String? posterPath;
  final String? backdropPath;
  final String? releaseDate;
  final double? voteAverage;
  final int? runtime;
  final List<String> genres;

  CanonicalData({
    required this.title,
    required this.overview,
    this.posterPath,
    this.backdropPath,
    this.releaseDate,
    this.voteAverage,
    this.runtime,
    this.genres = const [],
  });

  factory CanonicalData.fromJson(Map<String, dynamic> json) {
    return CanonicalData(
      title: json['title'] ?? json['name'] ?? '',
      overview: json['overview'] ?? '',
      posterPath: json['poster_path'],
      backdropPath: json['backdrop_path'],
      releaseDate: json['release_date'] ?? json['first_air_date'],
      voteAverage: (json['vote_average'] as num?)?.toDouble(),
      runtime: json['runtime'] as int?,
      genres: (json['genres'] as List<dynamic>?)
              ?.map((g) => g['name']?.toString() ?? '')
              .toList() ??
          [],
    );
  }
}

class EpisodeIdentity {
  final int seasonNumber;
  final int episodeNumber;
  final String title;
  final String overview;
  final String? stillPath;

  EpisodeIdentity({
    required this.seasonNumber,
    required this.episodeNumber,
    required this.title,
    required this.overview,
    this.stillPath,
  });

  factory EpisodeIdentity.fromJson(Map<String, dynamic> json) {
    return EpisodeIdentity(
      seasonNumber: json['season_number'] ?? 1,
      episodeNumber: json['episode_number'] ?? 1,
      title: json['name'] ?? 'الحلقة ${json['episode_number'] ?? 1}',
      overview: json['overview'] ?? '',
      stillPath: json['still_path'],
    );
  }
}

class ContentIdentity {
  final int tmdbId;
  final String mediaType; // "movie" or "series"
  final CanonicalData canonical;
  final String? imdbId;

  ContentIdentity({
    required this.tmdbId,
    required this.mediaType,
    required this.canonical,
    this.imdbId,
  });

  factory ContentIdentity.fromJson(Map<String, dynamic> json) {
    final rawMediaType = json['media_type']?.toString();
    final normalizedMediaType = rawMediaType == 'tv'
        ? 'series'
        : (rawMediaType == 'movie'
            ? 'movie'
            : (json['first_air_date'] != null ? 'series' : 'movie'));
    return ContentIdentity(
      tmdbId: json['id'] ?? 0,
      mediaType: normalizedMediaType,
      canonical: CanonicalData.fromJson(json),
      imdbId: json['imdb_id'],
    );
  }
}
