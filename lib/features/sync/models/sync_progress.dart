enum SyncPhase { preparing, downloading, importing }

class SyncProgress {
  const SyncProgress({
    required this.phase,
    this.itemsProcessed = 0,
    this.total,
    this.downloadProgress,
  });

  final SyncPhase phase;
  final int itemsProcessed;
  final int? total;
  final double? downloadProgress;

  double? get importProgressFraction {
    if (total == null || total! <= 0) return null;
    return (itemsProcessed / total!).clamp(0.0, 1.0);
  }

  double? get overallProgressFraction {
    return switch (phase) {
      SyncPhase.preparing => null,
      SyncPhase.downloading => downloadProgress,
      SyncPhase.importing => importProgressFraction,
    };
  }

  bool get isIndeterminate =>
      phase == SyncPhase.preparing ||
      (phase == SyncPhase.downloading && downloadProgress == null);
}
