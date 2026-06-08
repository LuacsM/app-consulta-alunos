class SyncResult {
  const SyncResult({
    required this.itemsProcessed,
    required this.completedFully,
    this.totalExpected,
    this.generatedAt,
    this.resumedFromCheckpoint = false,
    this.incremental = false,
  });

  final int itemsProcessed;
  final bool completedFully;
  final int? totalExpected;
  final String? generatedAt;
  final bool resumedFromCheckpoint;
  final bool incremental;
}
