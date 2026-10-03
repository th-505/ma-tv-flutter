enum DownloadStatus { pending, downloading, completed, failed, paused }

class DownloadTask {
  final String id;
  final String title;
  final String url;
  final String? posterUrl;
  final double progress; // 0.0 to 1.0
  final DownloadStatus status;
  final String? localFilePath;
  final int totalBytes;
  final int receivedBytes;

  DownloadTask({
    required this.id,
    required this.title,
    required this.url,
    this.posterUrl,
    this.progress = 0.0,
    this.status = DownloadStatus.pending,
    this.localFilePath,
    this.totalBytes = 0,
    this.receivedBytes = 0,
  });

  DownloadTask copyWith({
    double? progress,
    DownloadStatus? status,
    String? localFilePath,
    int? totalBytes,
    int? receivedBytes,
  }) {
    return DownloadTask(
      id: id,
      title: title,
      url: url,
      posterUrl: posterUrl,
      progress: progress ?? this.progress,
      status: status ?? this.status,
      localFilePath: localFilePath ?? this.localFilePath,
      totalBytes: totalBytes ?? this.totalBytes,
      receivedBytes: receivedBytes ?? this.receivedBytes,
    );
  }
}
