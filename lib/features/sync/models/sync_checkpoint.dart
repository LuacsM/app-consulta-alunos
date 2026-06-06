class SyncCheckpoint {
  const SyncCheckpoint({
    required this.cursorUpdatedAt,
    required this.cursorCodAluno,
    required this.itemsProcessed,
    required this.pagesProcessed,
    this.totalExpected,
    this.serverSyncAt,
  });

  final String cursorUpdatedAt;
  final String cursorCodAluno;
  final int itemsProcessed;
  final int pagesProcessed;
  final int? totalExpected;
  final String? serverSyncAt;

  bool get isValid =>
      cursorUpdatedAt.isNotEmpty && cursorCodAluno.isNotEmpty;

  double? get progressFraction {
    if (totalExpected == null || totalExpected! <= 0) return null;
    return (itemsProcessed / totalExpected!).clamp(0.0, 1.0);
  }
}
