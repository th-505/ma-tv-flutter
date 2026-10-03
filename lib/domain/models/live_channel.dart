class LiveChannel {
  final String id;
  final String name;
  final String country;
  final String category;
  final String url;
  final String? logo;

  LiveChannel({
    required this.id,
    required this.name,
    required this.country,
    required this.category,
    required this.url,
    this.logo,
  });
}

class LiveMatch {
  final String id;
  final String home;
  final String away;
  final String time;
  final String tournament;
  final String url;

  LiveMatch({
    required this.id,
    required this.home,
    required this.away,
    required this.time,
    required this.tournament,
    required this.url,
  });
}
