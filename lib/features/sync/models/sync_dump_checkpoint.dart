enum SyncDumpPhase { downloading, importing }

class SyncDumpCheckpoint {
  const SyncDumpCheckpoint({
    required this.phase,
    required this.archivePath,
    required this.linesProcessed,
    this.totalExpected,
    this.generatedAt,
  });

  final SyncDumpPhase phase;
  final String archivePath;
  final int linesProcessed;
  final int? totalExpected;
  final String? generatedAt;

  bool get isValid => archivePath.isNotEmpty;

  double? get progressFraction {
    if (totalExpected == null || totalExpected! <= 0) return null;
    return (linesProcessed / totalExpected!).clamp(0.0, 1.0);
  }
}
