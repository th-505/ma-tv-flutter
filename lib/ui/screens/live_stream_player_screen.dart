import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../../core/theme/app_theme.dart';

class LiveStreamPlayerScreen extends StatefulWidget {
  final String name;
  final String url;
  const LiveStreamPlayerScreen({super.key, required this.name, required this.url});

  @override
  State<LiveStreamPlayerScreen> createState() => _LiveStreamPlayerScreenState();
}

class _LiveStreamPlayerScreenState extends State<LiveStreamPlayerScreen> {
  VideoPlayerController? _controller;
  Object? _error;

  @override
  void initState() {
    super.initState();
    _open();
  }

  Future<void> _open() async {
    try {
      final controller = VideoPlayerController.networkUrl(Uri.parse(widget.url));
      await controller.initialize();
      await controller.play();
      if (!mounted) { await controller.dispose(); return; }
      setState(() => _controller = controller);
    } catch (e) {
      if (mounted) setState(() => _error = e);
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(title: Text(widget.name)),
      body: Center(
        child: _error != null
            ? Column(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.error_outline, color: AppColors.gold400, size: 48),
                const SizedBox(height: 12),
                const Text('تعذر تشغيل البث', style: TextStyle(color: Colors.white)),
                TextButton(onPressed: () { setState(() => _error = null); _open(); }, child: const Text('إعادة المحاولة')),
              ])
            : _controller == null
                ? const CircularProgressIndicator(color: AppColors.gold400)
                : AspectRatio(
                    aspectRatio: _controller!.value.aspectRatio == 0 ? 16 / 9 : _controller!.value.aspectRatio,
                    child: VideoPlayer(_controller!),
                  ),
      ),
      floatingActionButton: _controller == null ? null : FloatingActionButton(
        onPressed: () => setState(() => _controller!.value.isPlaying ? _controller!.pause() : _controller!.play()),
        child: Icon(_controller!.value.isPlaying ? Icons.pause : Icons.play_arrow),
      ),
    );
  }
}
