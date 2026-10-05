import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/repositories/progress_repository.dart';
import 'package:video_player/video_player.dart';
import '../../domain/models/content_identity.dart';
import '../../domain/models/playback_source.dart';
import '../../data/services/proxy_service.dart';
import '../../data/scrapers/server_manager.dart';
import '../../core/theme/app_theme.dart';

class PlayerScreen extends StatefulWidget {
  final ContentIdentity identity;
  final PlaybackSource source;
  final List<RankedSource> allSources;
  final EpisodeIdentity? episode;
  final VoidCallback onBack;

  const PlayerScreen({
    super.key,
    required this.identity,
    required this.source,
    required this.allSources,
    this.episode,
    required this.onBack,
  });

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  late PlaybackSource _currentSource;
  late int _currentServerIdx;
  VideoPlayerController? _controller;
  bool _isLoading = true;
  bool _hasError = false;
  bool _useProxy = false;
  double _playbackSpeed = 1.0;
  bool _restoredProgress = false;
  int _playerRequestSerial = 0;
  late ProgressRepository _progressRepository;

  final List<double> _speeds = [0.75, 1.0, 1.25, 1.5, 2.0];

  @override
  void initState() {
    super.initState();
    _progressRepository=context.read<ProgressRepository>();
    _playbackSpeed=_progressRepository.defaultPlaybackSpeed;
    _currentSource = widget.source;
    _currentServerIdx = widget.allSources.indexWhere((s) => s.source.sourceId == widget.source.sourceId);
    if (_currentServerIdx < 0) _currentServerIdx = 0;
    _initPlayer(_currentSource.url);
  }

  bool _isDirectMediaUrl(String url) {
    final u = url.toLowerCase().split('?').first;
    return u.endsWith('.m3u8') || u.endsWith('.mp4') || u.endsWith('.webm') || u.endsWith('.mov');
  }

  Future<void> _initPlayer(String streamUrl) async {
    final serial = ++_playerRequestSerial;
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    await _controller?.dispose();
    _controller = null;

    if (!_isDirectMediaUrl(streamUrl)) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
        });
      }
      return;
    }

    final effectiveUrl = _useProxy ? ProxyService().getProxiedStreamUrl(streamUrl) : streamUrl;

    final stopwatch = Stopwatch()..start();
    try {
      final controller = VideoPlayerController.networkUrl(
        Uri.parse(effectiveUrl),
        videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
      );

      _controller = controller;
      await controller.initialize().timeout(const Duration(seconds: 12));
      if (!mounted || serial != _playerRequestSerial) {
        await controller.dispose();
        return;
      }
      await controller.setPlaybackSpeed(_playbackSpeed);
      if (!_restoredProgress && mounted && _progressRepository.resumePlayback) {
        final saved = _progressRepository.getProgress(widget.identity.tmdbId);
        if (saved > 5 && saved < controller.value.duration.inSeconds - 15) {
          await controller.seekTo(Duration(seconds: saved.round()));
        }
        _restoredProgress = true;
      }
      if(_progressRepository.autoplay) await controller.play();
      stopwatch.stop();
      ServerManager.recordPlayback(_currentSource.providerId, success: true, latencyMs: stopwatch.elapsedMilliseconds);

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      stopwatch.stop();
      if (serial != _playerRequestSerial) return;
      ServerManager.recordPlayback(_currentSource.providerId, success: false, latencyMs: stopwatch.elapsedMilliseconds);
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
        });
      }
    }
  }

  void _switchServer(int idx) {
    if (idx >= 0 && idx < widget.allSources.length) {
      setState(() {
        _currentServerIdx = idx;
        _currentSource = widget.allSources[idx].source;
        _useProxy = false;
      });
      _initPlayer(_currentSource.url);
    }
  }

  void _retryWithProxy() {
    setState(() => _useProxy = true);
    _initPlayer(_currentSource.url);
  }

  void _cycleSpeed() {
    final nextIdx = (_speeds.indexOf(_playbackSpeed) + 1) % _speeds.length;
    final nextSpeed = _speeds[nextIdx];
    setState(() => _playbackSpeed = nextSpeed);
    _controller?.setPlaybackSpeed(nextSpeed);
  }

  void _showServerSwitcher() {
    if (widget.allSources.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('لا توجد سيرفرات متاحة حالياً')),
      );
      return;
    }
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.darkElevated,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return SafeArea(
          child: SizedBox(
            height: MediaQuery.sizeOf(context).height * 0.72,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
            children: [
              const Text(
                'قائمة السيرفرات العالمية',
                style: TextStyle(color: AppColors.gold400, fontWeight: FontWeight.bold, fontSize: 16, fontFamily: 'Cairo'),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.separated(
                  itemCount: widget.allSources.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, idx) {
                    final rs = widget.allSources[idx];
                    final isCurrent = idx == _currentServerIdx;
                    final pingColor = idx < 5 ? Colors.green : (idx < 15 ? Colors.amber : Colors.grey);
                    final pingLabel = idx < 5 ? 'سريع جداً' : (idx < 15 ? 'مستقر' : 'احتياطي');

                    return ListTile(
                      tileColor: isCurrent ? AppColors.gold400.withValues(alpha: 0.15) : Colors.white.withValues(alpha: 0.04),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      title: Text(
                        rs.source.providerId,
                        style: TextStyle(fontWeight: FontWeight.bold, color: isCurrent ? AppColors.gold400 : Colors.white),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(shape: BoxShape.circle, color: pingColor),
                          ),
                          const SizedBox(width: 6),
                          Text(pingLabel, style: TextStyle(color: pingColor, fontSize: 11, fontFamily: 'Cairo')),
                        ],
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        _switchServer(idx);
                      },
                    );
                  },
                ),
              ),
            ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _playerRequestSerial++;
    final controller=_controller;
    if(controller!=null&&controller.value.isInitialized){
      final p=controller.value.position.inMilliseconds/1000;
      final d=controller.value.duration.inMilliseconds/1000;
      _progressRepository.saveProgress(widget.identity.tmdbId,p,d);
    }
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.episode != null
        ? '${widget.identity.canonical.title} - ${widget.episode!.title}'
        : widget.identity.canonical.title;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Video Player Core
          Center(
            child: _controller != null && _controller!.value.isInitialized
                ? AspectRatio(
                    aspectRatio: _controller!.value.aspectRatio,
                    child: VideoPlayer(_controller!),
                  )
                : const SizedBox(),
          ),

          // Loading Indicator
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(color: AppColors.gold400),
            ),

          // Rescue / Error Overlay
          if (_hasError)
            Container(
              color: Colors.black87,
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.warning_amber_rounded, color: AppColors.warning, size: 54),
                  const SizedBox(height: 16),
                  const Text(
                    'تعذر تشغيل هذا المصدر',
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Cairo'),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'هذا المصدر ليس رابط فيديو مباشرًا أو تعذر تشغيله. اختر مصدرًا مباشرًا صالحًا أو جرّب مصدرًا آخر.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white70, fontSize: 13, fontFamily: 'Cairo'),
                  ),
                  const SizedBox(height: 24),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      ElevatedButton.icon(
                        onPressed: _retryWithProxy,
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.gold400, foregroundColor: Colors.black),
                        icon: const Icon(Icons.flash_on),
                        label: const Text('تشغيل عبر البروكسي (Proxy Relay)', style: TextStyle(fontFamily: 'Cairo')),
                      ),
                      OutlinedButton.icon(
                        onPressed: widget.allSources.isEmpty ? null : () => _switchServer((_currentServerIdx + 1) % widget.allSources.length),
                        style: OutlinedButton.styleFrom(foregroundColor: Colors.white),
                        icon: const Icon(Icons.skip_next),
                        label: const Text('السيرفر التالي', style: TextStyle(fontFamily: 'Cairo')),
                      ),
                    ],
                  ),
                ],
              ),
            ),

          // Controls Overlay
          if (!_hasError)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.black87, Colors.transparent],
                  ),
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: widget.onBack,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'Cairo'),
                      ),
                    ),
                    // Speed Control
                    TextButton(
                      onPressed: _cycleSpeed,
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.white12,
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      ),
                      child: Text(
                        '${_playbackSpeed}x',
                        style: const TextStyle(color: AppColors.gold400, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Server Switcher Button
                    IconButton(
                      icon: const Icon(Icons.layers_outlined, color: Colors.white),
                      onPressed: _showServerSwitcher,
                      tooltip: 'تبديل السيرفر',
                    ),
                  ],
                ),
              ),
            ),

          // Bottom Player Bar
          if (!_hasError && _controller != null && _controller!.value.isInitialized)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [Colors.black87, Colors.transparent],
                  ),
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        _controller!.value.isPlaying ? Icons.pause : Icons.play_arrow,
                        color: Colors.white,
                        size: 30,
                      ),
                      onPressed: () {
                        setState(() {
                          _controller!.value.isPlaying ? _controller!.pause() : _controller!.play();
                        });
                      },
                    ),
                    const SizedBox(width: 8),
                    // Scrubber
                    Expanded(
                      child: VideoProgressIndicator(
                        _controller!,
                        allowScrubbing: true,
                        colors: const VideoProgressColors(
                          playedColor: AppColors.gold400,
                          bufferedColor: Colors.white24,
                          backgroundColor: Colors.white10,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ValueListenableBuilder<VideoPlayerValue>(
                      valueListenable:_controller!,
                      builder:(context,value,_){
                        String fmt(Duration d){
                          final h=d.inHours;
                          final m=d.inMinutes.remainder(60).toString().padLeft(2,'0');
                          final s=d.inSeconds.remainder(60).toString().padLeft(2,'0');
                          return h>0?'$h:$m:$s':'$m:$s';
                        }
                        return Text('${fmt(value.position)} / ${fmt(value.duration)}',style:const TextStyle(color:Colors.white70,fontSize:11));
                      },
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.fullscreen, color: Colors.white),
                      onPressed: () {
                        // Fullscreen handled by platform or landscape orientation
                      },
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
