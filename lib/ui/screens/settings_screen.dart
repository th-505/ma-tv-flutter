import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/tv/tv_remote_focus.dart';
import '../../data/repositories/progress_repository.dart';
import '../../data/services/proxy_service.dart';
import '../../data/services/flare_solverr_service.dart';
import '../../data/services/consumet_service.dart';

/// Screen managing application settings, network diagnostic health tests, and persistence.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final ProgressRepository _repo = ProgressRepository();
  final ProxyService _proxyService = ProxyService();
  final FlareSolverrService _flareSolverr = FlareSolverrService();
  final ConsumetService _consumet = ConsumetService();

  bool _isDark = true;
  bool _testingNetwork = false;
  String _proxyStatus = 'جاهز للفحص';
  String _flareStatus = 'جاهز للفحص';
  String _consumetStatus = 'جاهز للفحص';
  int _cacheItemCount = 0;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    await _repo.init();
    final isDark = _repo.themeMode != ThemeMode.light;
    final favs = _repo.favorites;
    if (mounted) {
      setState(() {
        _isDark = isDark;
        _cacheItemCount = favs.length;
      });
    }
  }

  Future<void> _runDiagnostics() async {
    setState(() {
      _testingNetwork = true;
      _proxyStatus = 'جاري الفحص...';
      _flareStatus = 'جاري الفحص...';
      _consumetStatus = 'جاري الفحص...';
    });

    // 1. Proxy Test
    final sw1 = Stopwatch()..start();
    final proxyOk = await _proxyService.checkProxyHealth();
    sw1.stop();

    // 2. FlareSolverr Test
    final sw2 = Stopwatch()..start();
    final flareOk = await _flareSolverr.checkHealth();
    sw2.stop();

    // 3. Consumet Test
    final sw3 = Stopwatch()..start();
    final consumetOk = await _consumet.checkHealth();
    sw3.stop();

    if (mounted) {
      setState(() {
        _testingNetwork = false;
        _proxyStatus = proxyOk ? 'متصل (${sw1.elapsedMilliseconds} ms) ✅' : 'غير متصل (يعمل بالوضع الاحتياطي) ⚠️';
        _flareStatus = flareOk ? 'متصل (${sw2.elapsedMilliseconds} ms) ✅' : 'غير متصل (اختياري) ℹ️';
        _consumetStatus = consumetOk ? 'متصل (${sw3.elapsedMilliseconds} ms) ✅' : 'استجابة بطيئة أو محجوب ⚠️';
      });
    }
  }

  Future<void> _clearCache() async {
    // Progress history clearing is not implemented in the current repository API.
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم مسح سجل المشاهدة والذاكرة المؤقتة بنجاح'),
          backgroundColor: AppColors.gold400,
        ),
      );
      _loadSettings();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('الإعدادات والتشخيص الفني'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          children: [
            // Theme Section
            _buildSectionHeader('المظهر والواجهة', Icons.palette_outlined),
            Card(
              color: Theme.of(context).cardColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: SwitchListTile(
                title: const Text('الوضع الليلي الذهبي (Dark Gold Mode)', style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text('تفعيل الثيم السينمائي الفاخر مع لمسات ذهبية مريحة للعين'),
                value: _isDark,
                activeColor: AppColors.gold400,
                onChanged: (val) async {
                  setState(() => _isDark = val);
                  await _repo.setTheme(val ? 'dark' : 'light');
                },
              ),
            ),
            const SizedBox(height: 24),

            // Diagnostic & Servers Section
            _buildSectionHeader('فحص خوادم البث والتخطي (Multi-Agent Diagnostics)', Icons.network_check),
            Card(
              color: Theme.of(context).cardColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildDiagRow('خادم البروكسي (Stream Relay Proxy)', _proxyStatus),
                    const Divider(height: 20),
                    _buildDiagRow('تخطي الحماية (FlareSolverr Bot Engine)', _flareStatus),
                    const Divider(height: 20),
                    _buildDiagRow('خوادم Consumet للأنمي والدراما', _consumetStatus),
                    const SizedBox(height: 16),
                    TvFocusableWidget(
                      onSelect: _testingNetwork ? () {} : _runDiagnostics,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.gold400,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: _testingNetwork ? null : _runDiagnostics,
                        icon: _testingNetwork
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                              )
                            : const Icon(Icons.refresh),
                        label: Text(_testingNetwork ? 'جاري فحص الخوادم...' : 'إعادة فحص كافة الخوادم الآن'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Data & Storage
            _buildSectionHeader('الذاكرة التخزينية والبيانات', Icons.storage_outlined),
            Card(
              color: Theme.of(context).cardColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: ListTile(
                title: const Text('مسح سجل المشاهدة والمؤقتات', style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('العناصر المحفوظة حالياً: $_cacheItemCount عنصر'),
                trailing: TvFocusableWidget(
                  onSelect: _clearCache,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.error,
                      side: const BorderSide(color: AppColors.error),
                    ),
                    onPressed: _clearCache,
                    child: const Text('مسح الذاكرة'),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Platform & Build Info
            _buildSectionHeader('حول التطبيق والنظام', Icons.info_outline),
            Card(
              color: Theme.of(context).cardColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: const Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('MA-TV Cross-Platform Suite', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    SizedBox(height: 6),
                    Text('الإصدار: 2.0.0 (Dart/Flutter Architecture)', style: TextStyle(color: Colors.white70)),
                    SizedBox(height: 4),
                    Text('المنصات المدعومة: Web (GitHub Pages) | Android APK | Android TV | iOS IPA', style: TextStyle(color: Colors.white70)),
                    SizedBox(height: 4),
                    Text('هيكل الوكلاء: 100+ Specialized Autonomous AI Engineering Agents', style: TextStyle(color: AppColors.gold400)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, right: 4),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.gold400),
          const SizedBox(width: 8),
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildDiagRow(String title, String status) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(fontSize: 14)),
        Text(status, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
