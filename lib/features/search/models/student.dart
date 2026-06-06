import 'package:consulta_alunos/core/utils/formatters.dart';

class Student {
  const Student({
    required this.codAluno,
    required this.escola,
    required this.cpfAluno,
    required this.cpfResponsavel,
    required this.nomeAluno,
    required this.dtNascAluno,
    required this.nomeMaeAluno,
    required this.nomePaiAluno,
    required this.enderecoAluno,
    required this.telefone,
    this.secretaria,
    this.telefone2,
    this.codEscola,
    this.ensino,
    this.fase,
    this.turma,
    this.turno,
    this.syncUpdatedAt,
    this.syncDeletedAt,
  });

  final String codAluno;
  final String escola;
  final String cpfAluno;
  final String cpfResponsavel;
  final String nomeAluno;
  final String dtNascAluno;
  final String nomeMaeAluno;
  final String nomePaiAluno;
  final String enderecoAluno;
  final String telefone;
  final String? secretaria;
  final String? telefone2;
  final String? codEscola;
  final String? ensino;
  final String? fase;
  final String? turma;
  final String? turno;
  final String? syncUpdatedAt;
  final String? syncDeletedAt;

  String toShareText() {
    final buffer = StringBuffer()
      ..writeln('Consulta Alunos')
      ..writeln('────────────────')
      ..writeln('Nome: ${Formatters.formatName(nomeAluno)}')
      ..writeln('Código: $codAluno')
      ..writeln('Escola: $escola')
      ..writeln('CPF do aluno: ${Formatters.formatCpf(cpfAluno)}')
      ..writeln('Nascimento: $dtNascAluno')
      ..writeln('Mãe: ${Formatters.formatName(nomeMaeAluno)}');

    if (nomePaiAluno.isNotEmpty) {
      buffer.writeln('Pai: ${Formatters.formatName(nomePaiAluno)}');
    }

    buffer
      ..writeln('Telefone: ${Formatters.formatPhone(telefone)}')
      ..writeln('Endereço: $enderecoAluno')
      ..writeln('CPF responsável: ${Formatters.formatCpf(cpfResponsavel)}');

    return buffer.toString().trim();
  }

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      codAluno: json['cod_aluno'] as String? ?? '',
      secretaria: json['secretaria'] as String?,
      escola: json['escola'] as String? ?? '',
      cpfAluno: json['cpf_aluno'] as String? ?? '',
      cpfResponsavel: json['cpf_responsavel'] as String? ?? '',
      nomeAluno: json['nome_aluno'] as String? ?? '',
      dtNascAluno: json['dt_nasc_aluno'] as String? ?? '',
      nomeMaeAluno: json['nome_mae_aluno'] as String? ?? '',
      nomePaiAluno: json['nome_pai_aluno'] as String? ?? '',
      enderecoAluno: json['endereco_aluno'] as String? ?? '',
      telefone: json['telefone'] as String? ?? '',
      telefone2: json['telefone2'] as String?,
      codEscola: json['cod_escola'] as String?,
      ensino: json['ensino'] as String?,
      fase: json['fase'] as String?,
      turma: json['turma'] as String?,
      turno: json['turno'] as String?,
      syncUpdatedAt: json['sync_updated_at'] as String?,
      syncDeletedAt: json['sync_deleted_at'] as String?,
    );
  }

  factory Student.fromMap(Map<String, dynamic> map) => Student.fromJson(map);

  Map<String, dynamic> toMap() {
    return {
      'cod_aluno': codAluno,
      'secretaria': secretaria,
      'cpf_aluno': cpfAluno,
      'cpf_responsavel': cpfResponsavel,
      'nome_aluno': nomeAluno,
      'dt_nasc_aluno': dtNascAluno,
      'nome_mae_aluno': nomeMaeAluno,
      'nome_pai_aluno': nomePaiAluno,
      'telefone': telefone,
      'telefone2': telefone2,
      'endereco_aluno': enderecoAluno,
      'cod_escola': codEscola,
      'escola': escola,
      'ensino': ensino,
      'fase': fase,
      'turma': turma,
      'turno': turno,
      'sync_updated_at': syncUpdatedAt,
      'sync_deleted_at': syncDeletedAt,
    };
  }
}
