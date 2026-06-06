import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

class AppDatabase {
  AppDatabase._();

  static Database? _database;

  static Future<Database> get instance async {
    _database ??= await _open();
    return _database!;
  }

  static Future<Database> _open() async {
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, 'consulta_alunos.db');

    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE alunos (
            cod_aluno TEXT PRIMARY KEY,
            secretaria TEXT,
            cpf_aluno TEXT,
            cpf_responsavel TEXT,
            nome_aluno TEXT,
            dt_nasc_aluno TEXT,
            nome_mae_aluno TEXT,
            nome_pai_aluno TEXT,
            telefone TEXT,
            telefone2 TEXT,
            endereco_aluno TEXT,
            cod_escola TEXT,
            escola TEXT,
            ensino TEXT,
            fase TEXT,
            turma TEXT,
            turno TEXT,
            sync_updated_at TEXT,
            sync_deleted_at TEXT
          )
        ''');

        await db.execute(
          'CREATE INDEX idx_alunos_nome_aluno ON alunos(nome_aluno)',
        );
        await db.execute(
          'CREATE INDEX idx_alunos_nome_mae ON alunos(nome_mae_aluno)',
        );
        await db.execute(
          'CREATE INDEX idx_alunos_nome_pai ON alunos(nome_pai_aluno)',
        );
        await db.execute(
          'CREATE INDEX idx_alunos_cpf_aluno ON alunos(cpf_aluno)',
        );
        await db.execute(
          'CREATE INDEX idx_alunos_cpf_responsavel ON alunos(cpf_responsavel)',
        );
        await db.execute(
          'CREATE INDEX idx_alunos_cod_escola ON alunos(cod_escola)',
        );
        await db.execute(
          'CREATE INDEX idx_alunos_sync_updated_at ON alunos(sync_updated_at)',
        );
      },
    );
  }
}
