import 'package:flutter/material.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:provider/provider.dart';
import 'package:consulta_alunos/core/theme/app_theme.dart';
import 'package:consulta_alunos/features/auth/data/auth_repository.dart';
import 'package:consulta_alunos/features/splash/splash_view.dart';
import 'package:consulta_alunos/features/search/data/students_repository.dart';
import 'package:consulta_alunos/features/sync/services/aluno_sync_service.dart';
import 'package:consulta_alunos/features/sync/services/sync_session_controller.dart';

class ConsultaAlunosApp extends StatelessWidget {
  const ConsultaAlunosApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider(create: (_) => AuthRepository()),
        ProxyProvider<AuthRepository, AlunoSyncService>(
          update: (_, auth, previous) =>
              previous ?? AlunoSyncService(authRepository: auth),
        ),
        ProxyProvider<AuthRepository, StudentsRepository>(
          update: (_, auth, previous) =>
              previous ?? StudentsRepository(authRepository: auth),
        ),
        ChangeNotifierProxyProvider<AlunoSyncService, SyncSessionController>(
          create: (context) =>
              SyncSessionController(context.read<AlunoSyncService>()),
          update: (_, syncService, previous) =>
              previous ?? SyncSessionController(syncService),
        ),
      ],
      child: MaterialApp(
        title: 'Consulta Alunos',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        builder: (context, child) {
          return WithForegroundTask(
            child: child ?? const SizedBox.shrink(),
          );
        },
        home: const SplashView(),
      ),
    );
  }
}
