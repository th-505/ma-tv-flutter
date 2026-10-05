import 'dart:async';
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
  bool _searchFailed = false;
  String _scope = 'all';
  Timer? _debounce;
  int _requestSerial = 0;

  void _onSearchChanged(String query) {
    _debounce?.cancel();
    if (mounted) setState(() {});
    final normalized = query.trim();
    if (normalized.isEmpty) {
      _requestSerial++;
      setState(() {
        _results = [];
        _searching = false;
        _searchFailed = false;
      });
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 350), () => _runSearch(normalized));
  }

  Future<void> _runSearch(String query) async {
    final serial = ++_requestSerial;
    setState(() {
      _searching = true;
      _searchFailed = false;
    });
    try {
      final res = switch (_scope) {
        'movie' => await _tmdb.searchMovies(query),
        'tv' => await _tmdb.searchSeries(query),
        _ => await _tmdb.search(query),
      };
      if (!mounted || serial != _requestSerial) return;
      setState(() {
        _results = res;
        _searching = false;
      });
    } catch (_) {
      if (!mounted || serial != _requestSerial) return;
      setState(() {
        _results = [];
        _searching = false;
        _searchFailed = true;
      });
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchCtrl.dispose();
    super.dispose();
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
          textInputAction: TextInputAction.search,
          onSubmitted: (value) {
            _debounce?.cancel();
            final query = value.trim();
            if (query.isNotEmpty) _runSearch(query);
          },
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
          : _searchFailed
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.cloud_off, size: 54, color: AppColors.gold400),
                      const SizedBox(height: 12),
                      const Text('تعذر تنفيذ البحث', style: TextStyle(fontFamily: 'Cairo', color: Colors.white70)),
                      const SizedBox(height: 10),
                      OutlinedButton.icon(
                        onPressed: () => _runSearch(_searchCtrl.text.trim()),
                        icon: const Icon(Icons.refresh),
                        label: const Text('إعادة المحاولة'),
                      ),
                    ],
                  ),
                )
              : _results.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.search, size: 60, color: Colors.white.withValues(alpha: 0.2)),
                      const SizedBox(height: 12),
                      Text(
                        _searchCtrl.text.trim().isEmpty ? 'ابدأ بكتابة اسم العمل للبحث السريع' : 'لا توجد نتائج مطابقة',
                        style: const TextStyle(fontFamily: 'Cairo', color: Colors.white54),
                      ),
                    ],
                  ),
                )
              : GridView.builder(
                  keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                  physics: const ClampingScrollPhysics(),
                  padding: EdgeInsets.fromLTRB(16, 16, 16, 72 + MediaQuery.paddingOf(context).bottom),
                  gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: MediaQuery.sizeOf(context).width >= 900 ? 190 : 160,
                    childAspectRatio: 0.65,
                    crossAxisSpacing: MediaQuery.sizeOf(context).width >= 900 ? 18 : 12,
                    mainAxisSpacing: MediaQuery.sizeOf(context).width >= 900 ? 18 : 12,
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
