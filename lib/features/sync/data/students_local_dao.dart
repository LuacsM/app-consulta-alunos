import 'package:sqflite/sqflite.dart';
import 'package:consulta_alunos/core/database/app_database.dart';
import 'package:consulta_alunos/features/search/models/student.dart';

class StudentsLocalDao {
  StudentsLocalDao({Future<Database>? database})
      : _databaseFuture = database;

  final Future<Database>? _databaseFuture;

  Future<Database> get _db => _databaseFuture ?? AppDatabase.instance;

  Future<List<Student>> searchByName(String nome) async {
    final db = await _db;
    final filtro = '%${nome.toUpperCase()}%';

    final rows = await db.query(
      'alunos',
      where: '''
        UPPER(nome_aluno) LIKE ?
        OR UPPER(nome_mae_aluno) LIKE ?
        OR UPPER(nome_pai_aluno) LIKE ?
      ''',
      whereArgs: [filtro, filtro, filtro],
      orderBy: 'nome_aluno ASC',
    );

    return rows.map(Student.fromMap).toList();
  }

  Future<List<Student>> searchByCpf(String cpf) async {
    final db = await _db;
    final digits = cpf.replaceAll(RegExp(r'\D'), '');

    final rows = await db.query(
      'alunos',
      where: 'cpf_aluno = ? OR cpf_responsavel = ?',
      whereArgs: [digits, digits],
      orderBy: 'nome_aluno ASC',
    );

    return rows.map(Student.fromMap).toList();
  }

  Future<void> applySyncBatch(List<Student> items) async {
    if (items.isEmpty) return;

    final db = await _db;
    final batch = db.batch();

    for (final student in items) {
      if (student.syncDeletedAt != null && student.syncDeletedAt!.isNotEmpty) {
        batch.delete(
          'alunos',
          where: 'cod_aluno = ?',
          whereArgs: [student.codAluno],
        );
      } else {
        batch.insert(
          'alunos',
          student.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    }

    await batch.commit(noResult: true);
  }

  Future<void> upsertStudents(List<Student> students) async {
    if (students.isEmpty) return;

    final db = await _db;
    final batch = db.batch();

    for (final student in students) {
      batch.insert(
        'alunos',
        student.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    await batch.commit(noResult: true);
  }

  Future<int> countStudents() async {
    final db = await _db;
    final result = await db.rawQuery('SELECT COUNT(*) as total FROM alunos');
    return Sqflite.firstIntValue(result) ?? 0;
  }
}
