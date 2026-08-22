import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:consulta_alunos/core/theme/app_theme.dart';
import 'package:consulta_alunos/shared/widgets/detin_footer.dart';
import 'package:consulta_alunos/features/auth/data/auth_repository.dart';
import 'package:consulta_alunos/features/auth/views/auth_gate_view.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  static const _minDuration = Duration(milliseconds: 2200);

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  @override
  void initState() {
    super.initState();
    _openApp();
  }

  Future<void> _openApp() async {
    final navigator = Navigator.of(context);
    final sessionFuture = context.read<AuthRepository>().checkSession();
    await Future.wait([
      sessionFuture,
      Future<void>.delayed(SplashView._minDuration),
    ]);

    if (!mounted) return;

    final session = await sessionFuture;
    navigator.pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => AuthGateView(initialSession: session),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: AppTheme.lightScreenOverlay,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image(
                image: AssetImage('assets/images/logo_curumim_splash.png'),
                width: 220,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 32),
              const DetinFooter(bottomPadding: 0),
            ],
          ),
        ),
      ),
    );
  }
}
