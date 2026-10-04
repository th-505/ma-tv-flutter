import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/models/live_types.dart';
import '../../core/health/live_health_engine.dart';

class LiveStreamPlayerScreen extends StatefulWidget {
  final String name;
  final List<LiveSourceModel> sources;
  const LiveStreamPlayerScreen({super.key, required this.name, required this.sources});

  @override
  State<LiveStreamPlayerScreen> createState() => _LiveStreamPlayerScreenState();
}

class _LiveStreamPlayerScreenState extends State<LiveStreamPlayerScreen> {
  VideoPlayerController? _controller;
  Object? _error;
  int _sourceIndex=0;

  @override
  void initState(){super.initState();_openFrom(0);}

  Future<void> _openFrom(int start) async {
    await _controller?.dispose();
    _controller=null;
    _error=null;
    if(mounted) setState((){});
    final ranked=LiveHealthEngine.instance.rank<LiveSourceModel>(
      widget.sources,
      (s)=>s.sourceId,
      (s)=>s.health,
      (s)=>s.quality,
    );
    for(var i=start;i<ranked.length;i++){
      final source=ranked[i];
      if(!LiveHealthEngine.instance.canTry(source.sourceId)) continue;
      final sw=Stopwatch()..start();
      try{
        final controller=VideoPlayerController.networkUrl(Uri.parse(source.url));
        await controller.initialize();
        await controller.play();
        sw.stop();
        LiveHealthEngine.instance.recordSuccess(source.sourceId,sw.elapsedMilliseconds);
        if(!mounted){await controller.dispose();return;}
        setState((){_controller=controller;_sourceIndex=widget.sources.indexWhere((s)=>s.sourceId==source.sourceId);_error=null;});
        return;
      }catch(e){
        sw.stop();
        LiveHealthEngine.instance.recordFailure(source.sourceId);
        _error=e;
      }
    }
    if(mounted) setState((){});
  }

  @override
  void dispose(){_controller?.dispose();super.dispose();}

  @override
  Widget build(BuildContext context){
    final current=widget.sources.isEmpty?null:widget.sources[_sourceIndex.clamp(0,widget.sources.length-1)];
    return Scaffold(
      backgroundColor:Colors.black,
      appBar:AppBar(
        title:Text(widget.name),
        actions:[
          if(current!=null) Padding(
            padding:const EdgeInsets.symmetric(horizontal:12),
            child:Center(child:Text('${current.quality} • ${current.providerId}',style:const TextStyle(fontSize:11))),
          ),
        ],
      ),
      body:Center(
        child:_error!=null&&_controller==null
          ?Column(mainAxisSize:MainAxisSize.min,children:[
              const Icon(Icons.error_outline,color:AppColors.gold400,size:48),
              const SizedBox(height:12),
              const Text('تعذر تشغيل جميع المصادر المتاحة',style:TextStyle(color:Colors.white)),
              const SizedBox(height:8),
              TextButton(onPressed:()=>_openFrom(0),child:const Text('إعادة المحاولة')),
            ])
          :_controller==null
            ?const CircularProgressIndicator(color:AppColors.gold400)
            :AspectRatio(
                aspectRatio:_controller!.value.aspectRatio==0?16/9:_controller!.value.aspectRatio,
                child:VideoPlayer(_controller!),
              ),
      ),
      floatingActionButton:_controller==null?null:FloatingActionButton(
        onPressed:()=>setState(()=>_controller!.value.isPlaying?_controller!.pause():_controller!.play()),
        child:Icon(_controller!.value.isPlaying?Icons.pause:Icons.play_arrow),
      ),
    );
  }
}
