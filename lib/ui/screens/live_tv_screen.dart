import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/models/live_channel.dart';
import '../../domain/models/live_types.dart';
import '../../data/repositories/progress_repository.dart';
import '../../core/theme/app_theme.dart';
import '../widgets/custom_badge.dart';
import '../../core/tv/tv_remote_focus.dart';

class LiveTvScreen extends StatefulWidget {
  final void Function(String name, List<LiveSourceModel> sources) onPlayLive;

  const LiveTvScreen({
    super.key,
    required this.onPlayLive,
  });

  @override
  State<LiveTvScreen> createState() => _LiveTvScreenState();
}

class _LiveTvScreenState extends State<LiveTvScreen> {
  String _selectedCountry = 'all';
  String _selectedCategory = 'all';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  final List<Map<String, String>> _countries = [
    {'code': 'all', 'name': 'الكل', 'flag': '🌐'},
    {'code': 'sa', 'name': 'السعودية', 'flag': '🇸🇦'},
    {'code': 'eg', 'name': 'مصر', 'flag': '🇪🇬'},
    {'code': 'ae', 'name': 'الإمارات', 'flag': '🇦🇪'},
    {'code': 'qa', 'name': 'قطر', 'flag': '🇶🇦'},
    {'code': 'kw', 'name': 'الكويت', 'flag': '🇰🇼'},
    {'code': 'ma', 'name': 'المغرب', 'flag': '🇲🇦'},
    {'code': 'int', 'name': 'عالمي', 'flag': '🌍'},
  ];

  final List<Map<String, String>> _categories = [
    {'id': 'all', 'label': 'الكل'},
    {'id': 'favorites', 'label': '⭐ المفضلة'},
    {'id': 'news', 'label': 'أخبار'},
    {'id': 'sports', 'label': 'رياضة'},
    {'id': 'entertainment', 'label': 'ترفيه'},
    {'id': 'religious', 'label': 'إسلامية'},
    {'id': 'documentary', 'label': 'وثائقي'},
  ];

  final List<LiveChannel> _channels = [
    // News & Satellite
    LiveChannel(id: 'sa-alarabiya', name: 'قناة العربية', country: 'sa', category: 'news', url: 'https://live.alarabiya.net/alarabiapublish/alarabiya.smil/playlist.m3u8'),
    LiveChannel(id: 'sa-alhadath', name: 'قناة الحدث', country: 'sa', category: 'news', url: 'https://live.alarabiya.net/alarabiapublish/alhadath.smil/playlist.m3u8'),
    LiveChannel(id: 'qa-aljazeera', name: 'الجزيرة الإخبارية', country: 'qa', category: 'news', url: 'https://live-hls-web-aje.getaj.net/AJE/01.m3u8'),
    LiveChannel(id: 'int-france24', name: 'فرانس 24 عربي', country: 'int', category: 'news', url: 'https://stream.france24.com/hls/live/2037768/F24_AR_HI/master.m3u8'),
    LiveChannel(id: 'int-bbc', name: 'بي بي سي عربي', country: 'int', category: 'news', url: 'https://stream.ecable.tv/bbc-arabic/index.m3u8'),

    // Sports
    LiveChannel(id: 'qa-alkass-1', name: 'الكأس 1 HD', country: 'qa', category: 'sports', url: 'https://live.alkassdigital.net/alkass/one/index.m3u8'),
    LiveChannel(id: 'qa-alkass-2', name: 'الكأس 2 HD', country: 'qa', category: 'sports', url: 'https://live.alkassdigital.net/alkass/two/index.m3u8'),
    LiveChannel(id: 'ae-adsports', name: 'أبوظبي الرياضية 1', country: 'ae', category: 'sports', url: 'https://admdn1.cdn.mangomolo.com/adsports1/smil:adsports1.smil/playlist.m3u8'),
    LiveChannel(id: 'ae-dubaisports', name: 'دبي الرياضية 1', country: 'ae', category: 'sports', url: 'https://dmitv.cdn.mangomolo.com/dubaisports/smil:dubaisports.smil/playlist.m3u8'),
    LiveChannel(id: 'ma-arryadia', name: 'الرياضية المغربية TNT', country: 'ma', category: 'sports', url: 'https://arryadia-live.snrt.ma/live/hls/arryadia.m3u8'),

    // Entertainment & Religious
    LiveChannel(id: 'sa-quran', name: 'القرآن الكريم (مكة مباشر)', country: 'sa', category: 'religious', url: 'https://shd-hls-ksa-med.erc.cdn.ooredoo.mobi/ksa/smil:quran.smil/playlist.m3u8'),
    LiveChannel(id: 'sa-sunnah', name: 'السنة النبوية (المدينة مباشر)', country: 'sa', category: 'religious', url: 'https://shd-hls-ksa-med.erc.cdn.ooredoo.mobi/ksa/smil:sunnah.smil/playlist.m3u8'),
    LiveChannel(id: 'ae-dubaitv', name: 'تلفزيون دبي', country: 'ae', category: 'entertainment', url: 'https://dmitv.cdn.mangomolo.com/dubaitv/smil:dubaitv.smil/playlist.m3u8'),
  ];

  LiveChannelModel _asModel(LiveChannel c) => LiveChannelModel(
    channelId:c.id,
    name:c.name,
    logo:c.logo,
    country:c.country,
    category:c.category,
    sources:[
      LiveSourceModel(
        providerId:'official-live',
        sourceId:'${c.id}-primary',
        url:c.url,
        quality:'auto',
        health:'HEALTHY',
      ),
    ],
  );

  void _playBest(LiveChannel channel) {
    final source=_asModel(channel).bestSource;
    if(source!=null) widget.onPlayLive(channel.name,_asModel(channel).playableSources);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final progress = context.watch<ProgressRepository>();

    final filtered = _channels.where((c) {
      if (_selectedCategory == 'favorites') {
        if (!progress.isFavChannel(c.id)) return false;
      } else if (_selectedCategory != 'all' && c.category != _selectedCategory) {
        return false;
      }
      if (_selectedCountry != 'all' && c.country != _selectedCountry) return false;
      if (_searchQuery.trim().isNotEmpty) {
        final q = _searchQuery.toLowerCase().trim();
        return c.name.toLowerCase().contains(q);
      }
      return true;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('البث المباشر والقنوات', style: TextStyle(fontFamily: 'Cairo')),
      ),
      body: Column(
        children: [
          // Search Input
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: TextField(
              controller: _searchController,
              onChanged: (v) => setState(() => _searchQuery = v),
              decoration: InputDecoration(
                hintText: 'ابحث عن قناة...',
                prefixIcon: const Icon(Icons.search, color: Colors.white60),
                suffixIcon: _searchQuery.isEmpty ? null : IconButton(
                  tooltip: 'مسح البحث',
                  icon: const Icon(Icons.close, color: Colors.white60),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _searchQuery = '');
                  },
                ),
                filled: true,
                fillColor: AppColors.darkElevated,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
              ),
            ),
          ),

          // Country Filter Carousel
          SizedBox(
            height: 48,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemCount: _countries.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, idx) {
                final c = _countries[idx];
                final isSelected = _selectedCountry == c['code'];
                return ChoiceChip(
                  label: Text('${c['flag']} ${c['name']}'),
                  selected: isSelected,
                  selectedColor: AppColors.gold400,
                  backgroundColor: AppColors.darkElevated,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.black : Colors.white70,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    fontFamily: 'Cairo',
                  ),
                  onSelected: (_) => setState(() => _selectedCountry = c['code']!),
                );
              },
            ),
          ),
          const SizedBox(height: 8),

          // Category Filter Chips
          SizedBox(
            height: 42,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemCount: _categories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, idx) {
                final cat = _categories[idx];
                final isSelected = _selectedCategory == cat['id'];
                return FilterChip(
                  label: Text(cat['label']!),
                  selected: isSelected,
                  selectedColor: AppColors.gold400.withValues(alpha: 0.2),
                  checkmarkColor: AppColors.gold400,
                  backgroundColor: Colors.transparent,
                  labelStyle: TextStyle(
                    color: isSelected ? AppColors.gold400 : Colors.white60,
                    fontFamily: 'Cairo',
                    fontSize: 12,
                  ),
                  onSelected: (_) => setState(() => _selectedCategory = cat['id']!),
                );
              },
            ),
          ),
          const SizedBox(height: 12),

          // Channels Grid
          Expanded(
            child: filtered.isEmpty
                ? const Center(
                    child: Text('لا توجد قنوات تطابق الفلتر الحالي', style: TextStyle(fontFamily: 'Cairo', color: Colors.white60)),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: MediaQuery.sizeOf(context).width >= 900 ? 280 : 220,
                      childAspectRatio: MediaQuery.sizeOf(context).width >= 900 ? 1.65 : 1.4,
                      crossAxisSpacing: MediaQuery.sizeOf(context).width >= 900 ? 18 : 12,
                      mainAxisSpacing: MediaQuery.sizeOf(context).width >= 900 ? 18 : 12,
                    ),
                    itemCount: filtered.length,
                    itemBuilder: (context, idx) {
                      final ch = filtered[idx];
                      final isFav = progress.isFavChannel(ch.id);
                      final liveModel = _asModel(ch);
                      final best = liveModel.bestSource;

                      return TvFocusableWidget(
                        onSelect: () => _playBest(ch),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.darkElevated,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.white10),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  IconButton(
                                    icon: Icon(
                                      isFav ? Icons.star : Icons.star_border,
                                      color: isFav ? AppColors.gold400 : Colors.white38,
                                      size: 20,
                                    ),
                                    onPressed: () => progress.toggleFavChannel(ch.id),
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                  ),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      if(best!=null) CustomBadge(child: Text(best.quality.toUpperCase())),
                                      const SizedBox(width:6),
                                      CustomBadge(isGold: best!=null, child: Text(best==null?'غير متاح':'مباشر')),
                                    ],
                                  ),
                                ],
                              ),
                              Text(
                                ch.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, fontFamily: 'Cairo'),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  if(best!=null) ...[
                                    Container(width:7,height:7,decoration:const BoxDecoration(shape:BoxShape.circle,color:AppColors.success)),
                                    const SizedBox(width:6),
                                    Text(best.health,style:const TextStyle(fontSize:9,color:Colors.white54)),
                                    const SizedBox(width:8),
                                  ],
                                  Icon(best==null?Icons.block:Icons.play_circle_fill, color:best==null?Colors.white24:AppColors.gold400, size:22),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

extension ListFilter<T> on List<T> {
  Iterable<T> filter(bool Function(T) test) sync* {
    for (var element in this) {
      if (test(element)) yield element;
    }
  }
}
