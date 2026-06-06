import 'package:flutter/material.dart';

/// Fecha o teclado ao tocar fora dos campos ou em botões de ação.
class DismissKeyboard extends StatelessWidget {
  const DismissKeyboard({super.key, required this.child});

  final Widget child;

  static void unfocus() => FocusManager.instance.primaryFocus?.unfocus();

  static VoidCallback? wrap(VoidCallback? callback) {
    if (callback == null) return null;
    return () {
      unfocus();
      callback();
    };
  }

  static void run(VoidCallback callback) {
    unfocus();
    callback();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: unfocus,
      behavior: HitTestBehavior.translucent,
      child: child,
    );
  }
}
