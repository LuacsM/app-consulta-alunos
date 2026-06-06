import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:consulta_alunos/features/auth/data/auth_repository.dart';
import 'package:consulta_alunos/features/auth/views/login_view.dart';
import 'package:consulta_alunos/features/search/data/students_repository.dart';
import 'package:consulta_alunos/features/sync/services/aluno_sync_service.dart';

void main() {
  testWidgets('exibe tela de login', (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider(create: (_) => AuthRepository()),
          Provider(create: (_) => AlunoSyncService()),
          ProxyProvider<AuthRepository, StudentsRepository>(
            update: (_, auth, previous) =>
                previous ?? StudentsRepository(authRepository: auth),
          ),
        ],
        child: const MaterialApp(home: LoginView()),
      ),
    );
    await tester.pump();

    expect(find.text('Entrar'), findsOneWidget);
    expect(find.text('E-mail institucional'), findsOneWidget);
  });
}
