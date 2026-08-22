class SyncResult {
  const SyncResult({
    required this.itemsProcessed,
    required this.completedFully,
    this.totalExpected,
    this.generatedAt,
    this.changedCount,
    this.upToDateMessage,
    this.resumedFromCheckpoint = false,
    this.incremental = false,
  });

  final int itemsProcessed;
  final bool completedFully;
  final int? totalExpected;
  final String? generatedAt;
  final int? changedCount;
  final String? upToDateMessage;
  final bool resumedFromCheckpoint;
  final bool incremental;
}
