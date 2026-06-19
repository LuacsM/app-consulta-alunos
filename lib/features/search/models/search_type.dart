import 'package:flutter/material.dart';

enum SearchType {
  name,
  cpf;

  String get label => switch (this) {
        SearchType.name => 'Nome',
        SearchType.cpf => 'CPF',
      };

  IconData get icon => switch (this) {
        SearchType.name => Icons.person_outline,
        SearchType.cpf => Icons.badge_outlined,
      };

  String get inputLabel => switch (this) {
        SearchType.name => 'Nome do aluno ou responsável',
        SearchType.cpf => 'CPF do aluno ou responsável',
      };

  String get placeholder => switch (this) {
        SearchType.name => 'Digite o nome completo',
        SearchType.cpf => '000.000.000-00',
      };

  TextInputType get keyboardType => switch (this) {
        SearchType.name => TextInputType.name,
        SearchType.cpf => TextInputType.number,
      };
}
