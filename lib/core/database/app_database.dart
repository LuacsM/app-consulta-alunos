import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

class AppDatabase {
  AppDatabase._();

  static Database? _database;
  static const _dbVersion = 2;

  static Future<Database> get instance async {
    _database ??= await _open();
    return _database!;
  }

  static Future<Database> _open() async {
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, 'consulta_alunos.db');

    return openDatabase(
      path,
      version: _dbVersion,
      onCreate: (db, version) async {
        await _createSchema(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await _migrateToV2(db);
        }
      },
    );
  }

  static Future<void> _createSchema(Database db) async {
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
        sync_updated_at TEXT,
        sync_deleted_at TEXT
      )
    ''');

    await _createIndexes(db);
  }

  static Future<void> _createIndexes(Database db) async {
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
  }

  /// Remove colunas ensino, fase, turma e turno (não retornadas mais pela API).
  static Future<void> _migrateToV2(Database db) async {
    await db.execute('''
      CREATE TABLE alunos_new (
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
        sync_updated_at TEXT,
        sync_deleted_at TEXT
      )
    ''');

    await db.execute('''
      INSERT INTO alunos_new (
        cod_aluno,
        secretaria,
        cpf_aluno,
        cpf_responsavel,
        nome_aluno,
        dt_nasc_aluno,
        nome_mae_aluno,
        nome_pai_aluno,
        telefone,
        telefone2,
        endereco_aluno,
        cod_escola,
        escola,
        sync_updated_at,
        sync_deleted_at
      )
      SELECT
        cod_aluno,
        secretaria,
        cpf_aluno,
        cpf_responsavel,
        nome_aluno,
        dt_nasc_aluno,
        nome_mae_aluno,
        nome_pai_aluno,
        telefone,
        telefone2,
        endereco_aluno,
        cod_escola,
        escola,
        sync_updated_at,
        sync_deleted_at
      FROM alunos
    ''');

    await db.execute('DROP TABLE alunos');
    await db.execute('ALTER TABLE alunos_new RENAME TO alunos');
    await _createIndexes(db);
  }
}
