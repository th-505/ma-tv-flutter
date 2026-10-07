import '../../domain/models/timeline_alignment.dart';
class TimelineAlignmentEngine {
  const TimelineAlignmentEngine();
  AlignmentResult fromDurations(double sourceDuration,double targetDuration) {
    if(sourceDuration<=0||targetDuration<=0) return const AlignmentResult(offsetSeconds:0,confidence:0,method:AlignmentMethod.durationComparison);
    final delta=(targetDuration-sourceDuration).abs();
    final confidence=(1-(delta/sourceDuration)).clamp(0.0,1.0);
    return AlignmentResult(offsetSeconds:0,confidence:confidence,method:AlignmentMethod.durationComparison);
  }
  double alignedPosition(double sourcePosition,AlignmentResult alignment) =>
      (sourcePosition+alignment.offsetSeconds).clamp(0,double.infinity);
}
