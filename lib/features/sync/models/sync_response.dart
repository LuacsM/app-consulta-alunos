import 'package:consulta_alunos/features/search/models/student.dart';

class SyncResponse {
  const SyncResponse({
    required this.total,
    required this.size,
    required this.hasNext,
    required this.items,
    this.nextCursorUpdatedAt,
    this.nextCursorCodAluno,
    this.serverSyncAt,
  });

  final int total;
  final int size;
  final bool hasNext;
  final String? nextCursorUpdatedAt;
  final String? nextCursorCodAluno;
  final String? serverSyncAt;
  final List<Student> items;

  factory SyncResponse.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'] as List<dynamic>? ?? [];
    return SyncResponse(
      total: json['total'] as int? ?? rawItems.length,
      size: json['size'] as int? ?? rawItems.length,
      hasNext: json['has_next'] as bool? ?? false,
      nextCursorUpdatedAt: json['next_cursor_updated_at'] as String?,
      nextCursorCodAluno: json['next_cursor_cod_aluno'] as String?,
      serverSyncAt: json['server_sync_at'] as String?,
      items: rawItems
          .map((item) => Student.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}
