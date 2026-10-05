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
  bool _loadFailed = false;
  int _requestSerial = 0;
  List<ContentIdentity> _items = [];
  String _selectedFilter = 'trending';
  String? _language;
  double? _minVote;
  int? _year;
  String _sortBy = 'popularity.desc';

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

  Future<void> _applyDiscover() async {
    final serial = ++_requestSerial;
    setState(() {
      _loading = true;
      _loadFailed = false;
    });
    final res = await _tmdb.discover(
      widget.mediaType == 'movie' ? 'movie' : 'tv',
      language: _language,
      minVote: _minVote,
      year: _year,
      sortBy: widget.mediaType == 'series' && _sortBy == 'primary_release_date.desc' ? 'first_air_date.desc' : _sortBy,
    );
    if (!mounted || serial != _requestSerial) return;
    setState(() {
      _selectedFilter = 'discover';
      _items = res;
      _loadFailed = res.isEmpty;
      _loading = false;
    });
  }

  Future<void> _fetchCategory(String filter) async {
    final serial = ++_requestSerial;
    setState(() {
      _selectedFilter = filter;
      _loading = true;
      _loadFailed = false;
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

    if (mounted && serial == _requestSerial) {
      setState(() {
        _items = res;
        _loadFailed = res.isEmpty;
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

          ExpansionTile(
            title: const Text('تصفية متقدمة من TMDB', style: TextStyle(fontFamily:'Cairo',fontWeight:FontWeight.bold)),
            childrenPadding: const EdgeInsets.fromLTRB(16,0,16,12),
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  DropdownButton<String?>(
                    value: _language,
                    hint: const Text('اللغة'),
                    items: const [
                      DropdownMenuItem(value:null,child:Text('كل اللغات')),
                      DropdownMenuItem(value:'ar',child:Text('العربية')),
                      DropdownMenuItem(value:'en',child:Text('الإنجليزية')),
                      DropdownMenuItem(value:'tr',child:Text('التركية')),
                      DropdownMenuItem(value:'ko',child:Text('الكورية')),
                      DropdownMenuItem(value:'ja',child:Text('اليابانية')),
                      DropdownMenuItem(value:'hi',child:Text('الهندية')),
                    ],
                    onChanged:(v)=>setState(()=>_language=v),
                  ),
                  DropdownButton<double?>(
                    value:_minVote,
                    hint:const Text('التقييم'),
                    items:const [
                      DropdownMenuItem(value:null,child:Text('أي تقييم')),
                      DropdownMenuItem(value:6,child:Text('6+')),
                      DropdownMenuItem(value:7,child:Text('7+')),
                      DropdownMenuItem(value:8,child:Text('8+')),
                    ],
                    onChanged:(v)=>setState(()=>_minVote=v),
                  ),
                  DropdownButton<String>(
                    value:_sortBy,
                    items:const [
                      DropdownMenuItem(value:'popularity.desc',child:Text('الأكثر شعبية')),
                      DropdownMenuItem(value:'vote_average.desc',child:Text('الأعلى تقييماً')),
                      DropdownMenuItem(value:'primary_release_date.desc',child:Text('الأحدث')),
                    ],
                    onChanged:(v)=>setState(()=>_sortBy=v??'popularity.desc'),
                  ),
                  SizedBox(
                    width:110,
                    child:TextField(
                      keyboardType:TextInputType.number,
                      decoration:const InputDecoration(labelText:'السنة',isDense:true),
                      onChanged:(v)=>_year=int.tryParse(v),
                    ),
                  ),
                  FilledButton.icon(
                    onPressed:_applyDiscover,
                    icon:const Icon(Icons.tune),
                    label:const Text('تطبيق'),
                  ),
                ],
              ),
            ],
          ),

          // Content Grid
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator(color: AppColors.gold400))
                : _loadFailed
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.cloud_off, color: AppColors.gold400, size: 46),
                            const SizedBox(height: 12),
                            const Text('تعذر تحميل هذا القسم', style: TextStyle(fontFamily: 'Cairo', color: Colors.white70)),
                            const SizedBox(height: 10),
                            OutlinedButton.icon(
                              onPressed: () => _selectedFilter == 'discover' ? _applyDiscover() : _fetchCategory(_selectedFilter),
                              icon: const Icon(Icons.refresh),
                              label: const Text('إعادة المحاولة'),
                            ),
                          ],
                        ),
                      )
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
