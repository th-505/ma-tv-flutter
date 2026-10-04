import 'package:flutter/material.dart';
import '../../data/services/tmdb_service.dart';
import '../../domain/models/content_identity.dart';
import '../widgets/poster_card.dart';
import '../../core/theme/app_theme.dart';

class CatalogScreen extends StatefulWidget {
  final String mediaType; // "movie" or "series"
  final ValueChanged<ContentIdentity> onSelectContent;

  const CatalogScreen({
    super.key,
    required this.mediaType,
    required this.onSelectContent,
  });

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  final TmdbService _tmdb = TmdbService();
  bool _loading = true;
  List<ContentIdentity> _items = [];
  String _selectedFilter = 'trending';

  final List<Map<String, String>> _filters = [
    {'id': 'trending', 'label': 'الرائج الآن'},
    {'id': 'popular', 'label': 'الأكثر شعبية'},
    {'id': 'top_rated', 'label': 'الأعلى تقييماً'},
    {'id': 'current', 'label': 'يعرض الآن'},
    {'id': 'arabic', 'label': 'عربي'},
    {'id': 'turkish', 'label': 'تركي'},
    {'id': 'korean', 'label': 'كوري'},
  ];

  @override
  void initState() {
    super.initState();
    _fetchCategory(_selectedFilter);
  }

  Future<void> _fetchCategory(String filter) async {
    setState(() {
      _selectedFilter = filter;
      _loading = true;
    });

    List<ContentIdentity> res = [];
    final isMovie = widget.mediaType == 'movie';

    switch (filter) {
      case 'trending':
        res = await _tmdb.getTrending(type: isMovie ? 'movie' : 'tv');
        break;
      case 'popular':
        res = isMovie ? await _tmdb.getPopularMovies() : await _tmdb.getPopularSeries();
        break;
      case 'top_rated':
        res = isMovie ? await _tmdb.getTopRatedMovies() : await _tmdb.getTopRatedSeries();
        break;
      case 'current':
        res = isMovie ? await _tmdb.getNowPlayingMovies() : await _tmdb.getOnTheAirSeries();
        break;
      case 'arabic':
        res = await _tmdb.getByLanguage('ar', type: isMovie ? 'movie' : 'tv');
        break;
      case 'turkish':
        res = await _tmdb.getByLanguage('tr', type: isMovie ? 'movie' : 'tv');
        break;
      case 'korean':
        res = await _tmdb.getByLanguage('ko', type: isMovie ? 'movie' : 'tv');
        break;
    }

    if (mounted) {
      setState(() {
        _items = res;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.mediaType == 'movie' ? 'كتالوج الأفلام' : 'كتالوج المسلسلات';

    return Scaffold(
      appBar: AppBar(
        title: Text(title, style: const TextStyle(fontFamily: 'Cairo')),
      ),
      body: Column(
        children: [
          // Filter Chips
          SizedBox(
            height: 50,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              scrollDirection: Axis.horizontal,
              itemCount: _filters.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final f = _filters[index];
                final isSelected = _selectedFilter == f['id'];
                return ChoiceChip(
                  label: Text(f['label']!),
                  selected: isSelected,
                  selectedColor: AppColors.gold400,
                  backgroundColor: AppColors.darkElevated,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.black : Colors.white70,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    fontFamily: 'Cairo',
                    fontSize: 12,
                  ),
                  onSelected: (_) => _fetchCategory(f['id']!),
                );
              },
            ),
          ),

          // Content Grid
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator(color: AppColors.gold400))
                : _items.isEmpty
                    ? const Center(
                        child: Text(
                          'لا يوجد محتوى متاح حالياً',
                          style: TextStyle(fontFamily: 'Cairo', color: Colors.white60),
                        ),
                      )
                    : GridView.builder(
                        padding: const EdgeInsets.all(16),
                        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 160,
                          childAspectRatio: 0.65,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                        itemCount: _items.length,
                        itemBuilder: (context, index) {
                          final item = _items[index];
                          return PosterCard(
                            identity: item,
                            onTap: () => widget.onSelectContent(item),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
