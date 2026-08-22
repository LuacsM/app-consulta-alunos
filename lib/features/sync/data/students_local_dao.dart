import 'package:sqflite/sqflite.dart';
import 'package:consulta_alunos/core/database/app_database.dart';
import 'package:consulta_alunos/features/search/models/student.dart';

class StudentsLocalDao {
  StudentsLocalDao({Future<Database>? database})
      : _databaseFuture = database;

  static const maxSearchResults = 20;

  final Future<Database>? _databaseFuture;

  Future<Database> get _db => _databaseFuture ?? AppDatabase.instance;

  Future<List<Student>> searchByName(String nome) => _search(nome);

  Future<List<Student>> searchByCpf(String cpf) => _search(cpf);

  Future<List<Student>> _search(String query) async {
    final db = await _db;
    final trimmed = query.trim();
    if (trimmed.isEmpty) return [];

    final nameFilter = '%${trimmed.toUpperCase()}%';
    final digits = trimmed.replaceAll(RegExp(r'\D'), '');

    final conditions = <String>[
      'UPPER(nome_aluno) LIKE ?',
      'UPPER(nome_mae_aluno) LIKE ?',
      'UPPER(nome_pai_aluno) LIKE ?',
    ];
    final whereArgs = <Object>[nameFilter, nameFilter, nameFilter];

    if (digits.isNotEmpty) {
      final cpfFilter = '%$digits%';
      conditions.add('cpf_aluno LIKE ?');
      conditions.add('cpf_responsavel LIKE ?');
      whereArgs.addAll([cpfFilter, cpfFilter]);
    }

    final rows = await db.query(
      'alunos',
      where: conditions.join(' OR '),
      whereArgs: whereArgs,
      orderBy: 'nome_aluno ASC',
      limit: maxSearchResults,
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
