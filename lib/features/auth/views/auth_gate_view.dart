import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:consulta_alunos/core/theme/app_theme.dart';
import 'package:provider/provider.dart';
import 'package:consulta_alunos/core/theme/app_colors.dart';
import 'package:consulta_alunos/features/auth/data/auth_repository.dart';
import 'package:consulta_alunos/features/auth/models/session_check_result.dart';
import 'package:consulta_alunos/features/auth/views/login_view.dart';
import 'package:consulta_alunos/features/shell/main_shell_view.dart';

class AuthGateView extends StatefulWidget {
  const AuthGateView({super.key, this.initialSession});

  final SessionCheckResult? initialSession;

  @override
  State<AuthGateView> createState() => _AuthGateViewState();
}

class _AuthGateViewState extends State<AuthGateView> {
  late final Future<SessionCheckResult> _sessionCheck;

  @override
  void initState() {
    super.initState();
    _sessionCheck = widget.initialSession != null
        ? Future.value(widget.initialSession)
        : context.read<AuthRepository>().checkSession();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<SessionCheckResult>(
      future: _sessionCheck,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const AnnotatedRegion<SystemUiOverlayStyle>(
            value: AppTheme.lightScreenOverlay,
            child: Scaffold(
              body: Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
            ),
          );
        }

        final result = snapshot.data ?? SessionCheckResult.unauthenticated();
        if (result.isAuthenticated) {
          return const MainShellView();
        }

        return LoginView(showOfflineOption: result.showOfflineOption);
      },
    );
  }
}
