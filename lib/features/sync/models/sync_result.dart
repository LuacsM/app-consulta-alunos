class SyncResult {
  const SyncResult({
    required this.pagesProcessed,
    required this.itemsProcessed,
    required this.completedFully,
    this.serverSyncAt,
    this.totalExpected,
    this.resumedFromCheckpoint = false,
    this.sessionPagesProcessed = 0,
    this.sessionItemsProcessed = 0,
  });

  final int pagesProcessed;
  final int itemsProcessed;
  final bool completedFully;
  final String? serverSyncAt;
  final int? totalExpected;
  final bool resumedFromCheckpoint;
  final int sessionPagesProcessed;
  final int sessionItemsProcessed;
}

class SyncProgress {
  const SyncProgress({
    required this.pagesProcessed,
    required this.itemsProcessed,
    this.total,
  });

  final int pagesProcessed;
  final int itemsProcessed;
  final int? total;

  double? get progressFraction {
    if (total == null || total! <= 0) return null;
    return (itemsProcessed / total!).clamp(0.0, 1.0);
  }
}
