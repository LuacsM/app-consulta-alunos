class SyncDownloadResult {
  const SyncDownloadResult._({
    required this.requiresImport,
    this.archivePath,
    this.maxSyncUpdatedAt,
    this.generatedAt,
    this.message,
    this.total,
  });

  const SyncDownloadResult.downloaded(String archivePath)
      : this._(
          requiresImport: true,
          archivePath: archivePath,
        );

  const SyncDownloadResult.upToDate({
    String? maxSyncUpdatedAt,
    String? generatedAt,
    String? message,
    int? total,
  }) : this._(
          requiresImport: false,
          maxSyncUpdatedAt: maxSyncUpdatedAt,
          generatedAt: generatedAt,
          message: message,
          total: total,
        );

  final bool requiresImport;
  final String? archivePath;
  final String? maxSyncUpdatedAt;
  final String? generatedAt;
  final String? message;
  final int? total;
}
