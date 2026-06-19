import 'dart:convert';

abstract final class ApiResponseParser {
  static Map<String, dynamic> decodeObject(String body) {
    if (body.isEmpty) return {};
    final decoded = jsonDecode(body);
    if (decoded is Map<String, dynamic>) return decoded;
    return {};
  }

  static List<dynamic> decodeList(String body) {
    if (body.isEmpty) return [];
    final decoded = jsonDecode(body);
    if (decoded is List) return decoded;
    return [];
  }

  static Map<String, dynamic> decodeObjectFrom(dynamic data) {
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);
    if (data is String) return decodeObject(data);
    return {};
  }

  static List<dynamic> decodeListFrom(dynamic data) {
    if (data is List) return data;
    if (data is String) return decodeList(data);
    return [];
  }

  /// Aceita resposta em lista ou objeto único de aluno.
  static List<dynamic> decodeStudentListFrom(dynamic data) {
    final asList = decodeListFrom(data);
    if (asList.isNotEmpty) return asList;

    final object = decodeObjectFrom(data);
    if (object.containsKey('cod_aluno')) return [object];
    return [];
  }

  static String? extractDetail(Map<String, dynamic> body) {
    final detail = body['detail'];
    if (detail is String) return detail;
    if (detail is List && detail.isNotEmpty) {
      final first = detail.first;
      if (first is Map && first['msg'] is String) return first['msg'] as String;
    }
    return null;
  }
}
