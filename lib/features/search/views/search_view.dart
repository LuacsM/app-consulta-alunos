import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:consulta_alunos/features/search/data/students_repository.dart';
import 'package:consulta_alunos/features/search/models/search_content_state.dart';
import 'package:consulta_alunos/features/search/models/search_type.dart';
import 'package:consulta_alunos/core/utils/cpf_input_formatter.dart';
import 'package:consulta_alunos/features/search/view_models/search_view_model.dart';
import 'package:consulta_alunos/shared/widgets/dismiss_keyboard.dart';
import 'package:consulta_alunos/shared/widgets/empty_state_card.dart';
import 'package:consulta_alunos/shared/widgets/info_card.dart';
import 'package:consulta_alunos/shared/widgets/input_field.dart';
import 'package:consulta_alunos/shared/widgets/primary_button.dart';
import 'package:consulta_alunos/shared/widgets/segmented_toggle.dart';
import 'package:consulta_alunos/shared/widgets/student_accordion_card.dart';
import 'package:consulta_alunos/shared/widgets/student_results_skeleton.dart';
import 'package:consulta_alunos/shared/widgets/welcome_header.dart';

class SearchView extends StatelessWidget {
  const SearchView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => SearchViewModel(context.read<StudentsRepository>()),
      child: const _SearchBody(),
    );
  }
}

class _SearchBody extends StatelessWidget {
  const _SearchBody();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<SearchViewModel>();
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return DismissKeyboard(
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(20, 8, 20, 16 + bottomInset),
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const WelcomeHeader(
            title: 'Vamos consultar? 👋',
            subtitle: 'Encontre informações de alunos rapidamente.',
          ),
          const SizedBox(height: 24),
          SegmentedToggle<SearchType>(
            selected: vm.searchType,
            onChanged: vm.setSearchType,
            options: SearchType.values
                .map(
                  (type) => SegmentedOption(
                    value: type,
                    label: type.label,
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 20),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            switchInCurve: Curves.easeInOutCubic,
            switchOutCurve: Curves.easeInOutCubic,
            transitionBuilder: (child, animation) {
              final offsetAnimation = Tween<Offset>(
                begin: const Offset(0, 0.06),
                end: Offset.zero,
              ).animate(animation);

              return FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: offsetAnimation,
                  child: child,
                ),
              );
            },
            child: InputField(
              key: ValueKey(vm.searchType),
              label: vm.searchType.inputLabel,
              controller: vm.queryController,
              hint: vm.searchType.placeholder,
              leadingIcon: vm.searchType.icon,
              keyboardType: vm.searchType.keyboardType,
              textInputAction: TextInputAction.search,
              inputFormatters: vm.searchType == SearchType.cpf
                  ? const [CpfInputFormatter()]
                  : null,
              onChanged: (_) => vm.onQueryChanged(),
              onSubmitted: (_) => vm.search(),
            ),
          ),
          const SizedBox(height: 16),
          PrimaryButton(
            label: vm.isSearching ? 'Consultando...' : 'Consultar',
            icon: Icons.search,
            onPressed:
                vm.canSearch && !vm.isSearching ? vm.search : null,
          ),
          const SizedBox(height: 24),
          _buildContentArea(vm),
          if (vm.contentState != SearchContentState.loading &&
              vm.contentState != SearchContentState.results) ...[
            const SizedBox(height: 20),
            const InfoCard(
              title: 'Dica de busca',
              message:
                  'Buscas por CPF costumam ser mais precisas em casos de homônimos (nomes iguais).',
            ),
          ],
        ],
        ),
      ),
    );
  }

  Widget _buildContentArea(SearchViewModel vm) {
    switch (vm.contentState) {
      case SearchContentState.loading:
        return const StudentResultsSkeleton();

      case SearchContentState.error:
        return EmptyStateCard(
          title: 'Nenhum Aluno Encontrado',
          description: vm.errorMessage ?? 'Não foi possível encontrar o aluno.',
        );

      case SearchContentState.results:
        return _buildResults(vm);

      case SearchContentState.empty:
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          switchInCurve: Curves.easeInOutCubic,
          switchOutCurve: Curves.easeInOutCubic,
          child: EmptyStateCard(
            key: ValueKey(vm.searchType),
            title: 'Nenhum Aluno Selecionado',
            description: vm.searchType == SearchType.cpf
                ? 'Digite o CPF do aluno ou do responsável para localizar o cadastro.'
                : 'Utilize o campo acima para buscar pelo nome completo do aluno.',
          ),
        );
    }
  }

  Widget _buildResults(SearchViewModel vm) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...vm.students.map(
          (student) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: StudentAccordionCard(
              student: student,
              isExpanded: vm.isExpanded(student),
              onToggle: () => vm.toggleExpanded(student),
            ),
          ),
        ),
      ],
    );
  }
}
