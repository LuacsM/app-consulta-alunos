import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:consulta_alunos/features/auth/models/user_info.dart';

class AuthStorage {
  static const _tokenKey = 'access_token';
  static const _userKey = 'info_usuario';

  Future<void> saveSession({
    required String accessToken,
    required UserInfo user,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, accessToken);
    await prefs.setString(_userKey, jsonEncode(user.toJson()));
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  Future<UserInfo?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_userKey);
    if (raw == null) return null;
    return UserInfo.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
  }
}
