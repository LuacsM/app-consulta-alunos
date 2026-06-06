import 'package:shared_preferences/shared_preferences.dart';
import 'package:consulta_alunos/features/sync/models/sync_checkpoint.dart';

class SyncStorage {
  static const _lastSyncAtKey = 'last_sync_at';
  static const _checkpointCursorUpdatedAtKey = 'sync_checkpoint_cursor_updated_at';
  static const _checkpointCursorCodAlunoKey = 'sync_checkpoint_cursor_cod_aluno';
  static const _checkpointItemsProcessedKey = 'sync_checkpoint_items_processed';
  static const _checkpointPagesProcessedKey = 'sync_checkpoint_pages_processed';
  static const _checkpointTotalExpectedKey = 'sync_checkpoint_total_expected';
  static const _checkpointServerSyncAtKey = 'sync_checkpoint_server_sync_at';

  Future<String?> getLastSyncAt() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_lastSyncAtKey);
  }

  Future<void> saveLastSyncAt(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastSyncAtKey, value);
  }

  Future<SyncCheckpoint?> getCheckpoint() async {
    final prefs = await SharedPreferences.getInstance();
    final cursorUpdatedAt = prefs.getString(_checkpointCursorUpdatedAtKey);
    final cursorCodAluno = prefs.getString(_checkpointCursorCodAlunoKey);

    if (cursorUpdatedAt == null || cursorCodAluno == null) {
      return null;
    }

    return SyncCheckpoint(
      cursorUpdatedAt: cursorUpdatedAt,
      cursorCodAluno: cursorCodAluno,
      itemsProcessed: prefs.getInt(_checkpointItemsProcessedKey) ?? 0,
      pagesProcessed: prefs.getInt(_checkpointPagesProcessedKey) ?? 0,
      totalExpected: prefs.getInt(_checkpointTotalExpectedKey),
      serverSyncAt: prefs.getString(_checkpointServerSyncAtKey),
    );
  }

  Future<void> saveCheckpoint(SyncCheckpoint checkpoint) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _checkpointCursorUpdatedAtKey,
      checkpoint.cursorUpdatedAt,
    );
    await prefs.setString(
      _checkpointCursorCodAlunoKey,
      checkpoint.cursorCodAluno,
    );
    await prefs.setInt(
      _checkpointItemsProcessedKey,
      checkpoint.itemsProcessed,
    );
    await prefs.setInt(
      _checkpointPagesProcessedKey,
      checkpoint.pagesProcessed,
    );

    if (checkpoint.totalExpected != null) {
      await prefs.setInt(
        _checkpointTotalExpectedKey,
        checkpoint.totalExpected!,
      );
    }

    if (checkpoint.serverSyncAt != null) {
      await prefs.setString(
        _checkpointServerSyncAtKey,
        checkpoint.serverSyncAt!,
      );
    }
  }

  Future<void> clearCheckpoint() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_checkpointCursorUpdatedAtKey);
    await prefs.remove(_checkpointCursorCodAlunoKey);
    await prefs.remove(_checkpointItemsProcessedKey);
    await prefs.remove(_checkpointPagesProcessedKey);
    await prefs.remove(_checkpointTotalExpectedKey);
    await prefs.remove(_checkpointServerSyncAtKey);
  }
}
