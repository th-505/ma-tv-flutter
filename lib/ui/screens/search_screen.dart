import 'package:flutter/material.dart';
import '../../data/services/tmdb_service.dart';
import '../../domain/models/content_identity.dart';
import '../widgets/poster_card.dart';
import '../../core/theme/app_theme.dart';

class SearchScreen extends StatefulWidget {
  final ValueChanged<ContentIdentity> onSelectContent;

  const SearchScreen({
    super.key,
    required this.onSelectContent,
  });

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TmdbService _tmdb = TmdbService();
  final TextEditingController _searchCtrl = TextEditingController();
  List<ContentIdentity> _results = [];
  bool _searching = false;
  String _scope = 'all';

  void _onSearchChanged(String query) async {
    if (query.trim().isEmpty) {
      setState(() => _results = []);
      return;
    }

    setState(() => _searching = true);
    var res = await _tmdb.search(query);
    if (_scope != 'all') {
      res = res.where((item) => _scope == 'tv' ? item.mediaType == 'series' : item.mediaType == 'movie').toList();
    }
    if (mounted) {
      setState(() {
        _results = res;
        _searching = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchCtrl,
          autofocus: true,
          onChanged: _onSearchChanged,
          decoration: InputDecoration(
            hintText: 'ابحث عن فيلم أو مسلسل بالاسم...',
            hintStyle: const TextStyle(color: Colors.white54, fontFamily: 'Cairo'),
            border: InputBorder.none,
            suffixIcon: _searchCtrl.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear, color: Colors.white60),
                    onPressed: () {
                      _searchCtrl.clear();
                      _onSearchChanged('');
                    },
                  )
                : null,
          ),
          style: const TextStyle(color: Colors.white, fontFamily: 'Cairo'),
        ),
      ),
      body: Column(
        children: [
          SizedBox(
            height: 52,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              children: [
                for (final item in const [('all','الكل'),('movie','أفلام'),('tv','مسلسلات')])
                  Padding(
                    padding: const EdgeInsetsDirectional.only(end: 8),
                    child: ChoiceChip(
                      label: Text(item.$2),
                      selected: _scope == item.$1,
                      onSelected: (_) {
                        setState(() => _scope = item.$1);
                        _onSearchChanged(_searchCtrl.text);
                      },
                    ),
                  ),
              ],
            ),
          ),
          Expanded(child: _searching
          ? const Center(child: CircularProgressIndicator(color: AppColors.gold400))
          : _results.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.search, size: 60, color: Colors.white.withOpacity(0.2)),
                      const SizedBox(height: 12),
                      const Text(
                        'ابدأ بكتابة اسم العمل للبحث السريع',
                        style: TextStyle(fontFamily: 'Cairo', color: Colors.white54),
                      ),
                    ],
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
                  itemCount: _results.length,
                  itemBuilder: (context, idx) {
                    final item = _results[idx];
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
