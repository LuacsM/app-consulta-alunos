import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:consulta_alunos/core/theme/app_theme.dart';
import 'package:consulta_alunos/features/auth/data/auth_repository.dart';
import 'package:consulta_alunos/features/auth/views/auth_gate_view.dart';
import 'package:consulta_alunos/features/search/data/students_repository.dart';
import 'package:consulta_alunos/features/sync/services/aluno_sync_service.dart';

class ConsultaAlunosApp extends StatelessWidget {
  const ConsultaAlunosApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider(create: (_) => AuthRepository()),
        Provider(create: (_) => AlunoSyncService()),
        ProxyProvider<AuthRepository, StudentsRepository>(
          update: (_, auth, previous) =>
              previous ?? StudentsRepository(authRepository: auth),
        ),
      ],
      child: MaterialApp(
        title: 'Consulta Alunos',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        home: const AuthGateView(),
      ),
    );
  }
}
