import 'package:shared_preferences/shared_preferences.dart';
import 'package:consulta_alunos/features/sync/models/sync_dump_checkpoint.dart';

class SyncStorage {
  static const _lastSyncAtKey = 'last_sync_at';
  static const _checkpointPhaseKey = 'sync_dump_phase';
  static const _checkpointArchivePathKey = 'sync_dump_archive_path';
  static const _checkpointLinesProcessedKey = 'sync_dump_lines_processed';
  static const _checkpointTotalExpectedKey = 'sync_dump_total_expected';
  static const _checkpointGeneratedAtKey = 'sync_dump_generated_at';

  Future<String?> getLastSyncAt() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_lastSyncAtKey);
  }

  Future<void> saveLastSyncAt(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastSyncAtKey, value);
  }

  Future<void> clearLastSyncAt() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_lastSyncAtKey);
  }

  Future<SyncDumpCheckpoint?> getCheckpoint() async {
    final prefs = await SharedPreferences.getInstance();
    final phaseName = prefs.getString(_checkpointPhaseKey);
    final archivePath = prefs.getString(_checkpointArchivePathKey);

    if (phaseName == null || archivePath == null || archivePath.isEmpty) {
      return null;
    }

    final phase = SyncDumpPhase.values.asNameMap()[phaseName];
    if (phase == null) return null;

    return SyncDumpCheckpoint(
      phase: phase,
      archivePath: archivePath,
      linesProcessed: prefs.getInt(_checkpointLinesProcessedKey) ?? 0,
      totalExpected: prefs.getInt(_checkpointTotalExpectedKey),
      generatedAt: prefs.getString(_checkpointGeneratedAtKey),
    );
  }

  Future<void> saveCheckpoint(SyncDumpCheckpoint checkpoint) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_checkpointPhaseKey, checkpoint.phase.name);
    await prefs.setString(_checkpointArchivePathKey, checkpoint.archivePath);
    await prefs.setInt(
      _checkpointLinesProcessedKey,
      checkpoint.linesProcessed,
    );

    if (checkpoint.totalExpected != null) {
      await prefs.setInt(
        _checkpointTotalExpectedKey,
        checkpoint.totalExpected!,
      );
    }

    if (checkpoint.generatedAt != null) {
      await prefs.setString(
        _checkpointGeneratedAtKey,
        checkpoint.generatedAt!,
      );
    }
  }

  Future<void> clearCheckpoint() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_checkpointPhaseKey);
    await prefs.remove(_checkpointArchivePathKey);
    await prefs.remove(_checkpointLinesProcessedKey);
    await prefs.remove(_checkpointTotalExpectedKey);
    await prefs.remove(_checkpointGeneratedAtKey);
  }
}
