import 'package:flutter/material.dart';
import 'package:consulta_alunos/core/theme/app_colors.dart';
import 'package:consulta_alunos/features/search/views/search_view.dart';
import 'package:consulta_alunos/features/settings/views/settings_view.dart';
import 'package:consulta_alunos/shared/widgets/app_tab_bar.dart';
import 'package:consulta_alunos/shared/widgets/dismiss_keyboard.dart';
import 'package:consulta_alunos/shared/widgets/wavy_top_navbar.dart';

class MainShellView extends StatefulWidget {
  const MainShellView({super.key});

  @override
  State<MainShellView> createState() => _MainShellViewState();
}

class _MainShellViewState extends State<MainShellView> {
  int _currentTab = 0;

  static const _tabs = [
    AppTabItem(
      label: 'Busca',
      icon: Icons.search_outlined,
      activeIcon: Icons.search,
    ),
    AppTabItem(
      label: 'Ajustes',
      icon: Icons.settings_outlined,
      activeIcon: Icons.settings,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      resizeToAvoidBottomInset: true,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const WavyTopNavbar(),
          Expanded(
            child: IndexedStack(
              index: _currentTab,
              children: const [
                SearchView(),
                SettingsView(),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: AppTabBar(
        items: _tabs,
        currentIndex: _currentTab,
        onTap: (index) => DismissKeyboard.run(() {
              setState(() => _currentTab = index);
            }),
      ),
    );
  }
}
