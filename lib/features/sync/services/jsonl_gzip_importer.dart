import 'dart:convert';
import 'dart:io';

import 'package:consulta_alunos/features/search/models/student.dart';
import 'package:consulta_alunos/features/sync/data/students_local_dao.dart';

class JsonlMetadata {
  const JsonlMetadata({
    required this.generatedAt,
    required this.total,
  });

  final String generatedAt;
  final int total;

  factory JsonlMetadata.fromJson(Map<String, dynamic> json) {
    return JsonlMetadata(
      generatedAt: json['generated_at'] as String? ?? '',
      total: json['total'] as int? ?? 0,
    );
  }
}

typedef ImportProgressCallback = void Function({
  required int itemsProcessed,
  required int total,
  required String generatedAt,
});

class JsonlGzipImporter {
  JsonlGzipImporter({StudentsLocalDao? localDao})
      : _localDao = localDao ?? StudentsLocalDao();

  final StudentsLocalDao _localDao;
  static const _batchSize = 500;

  Future<JsonlImportResult> importFile({
    required String archivePath,
    int skipAlunoLines = 0,
    ImportProgressCallback? onProgress,
  }) async {
    final file = File(archivePath);
    if (!await file.exists()) {
      throw const FormatException('Arquivo de sincronização não encontrado.');
    }

    JsonlMetadata? metadata;
    var itemsProcessed = skipAlunoLines;
    var skipped = 0;
    final batch = <Student>[];

    final stream = file
        .openRead()
        .transform(gzip.decoder)
        .transform(utf8.decoder)
        .transform(const LineSplitter());

    await for (final line in stream) {
      if (line.trim().isEmpty) continue;

      final decoded = jsonDecode(line) as Map<String, dynamic>;
      final type = decoded['type'] as String?;

      if (type == 'metadata') {
        metadata = JsonlMetadata.fromJson(decoded);
        continue;
      }

      if (type != 'aluno') continue;

      if (skipped < skipAlunoLines) {
        skipped++;
        continue;
      }

      final data = decoded['data'] as Map<String, dynamic>?;
      if (data == null) continue;

      batch.add(Student.fromJson(data));

      if (batch.length >= _batchSize) {
        await _localDao.applySyncBatch(batch);
        itemsProcessed += batch.length;
        batch.clear();

        if (metadata != null) {
          onProgress?.call(
            itemsProcessed: itemsProcessed,
            total: metadata.total,
            generatedAt: metadata.generatedAt,
          );
        }
      }
    }

    if (batch.isNotEmpty) {
      await _localDao.applySyncBatch(batch);
      itemsProcessed += batch.length;
      if (metadata != null) {
        onProgress?.call(
          itemsProcessed: itemsProcessed,
          total: metadata.total,
          generatedAt: metadata.generatedAt,
        );
      }
    }

    if (metadata == null) {
      throw const FormatException(
        'Arquivo inválido: linha de metadata não encontrada.',
      );
    }

    return JsonlImportResult(
      metadata: metadata,
      itemsProcessed: itemsProcessed,
    );
  }
}

class JsonlImportResult {
  const JsonlImportResult({
    required this.metadata,
    required this.itemsProcessed,
  });

  final JsonlMetadata metadata;
  final int itemsProcessed;
}
