import 'package:shared_preferences/shared_preferences.dart';

class SyncStorage {
  static const _lastSyncAtKey = 'last_sync_at';

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
}
