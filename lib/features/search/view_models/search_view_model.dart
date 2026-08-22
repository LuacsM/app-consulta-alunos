import 'package:flutter/material.dart';
import 'package:consulta_alunos/core/network/api_exception.dart';
import 'package:consulta_alunos/core/utils/formatters.dart';
import 'package:consulta_alunos/features/search/data/students_repository.dart';
import 'package:consulta_alunos/features/search/models/search_content_state.dart';
import 'package:consulta_alunos/features/search/models/search_type.dart';
import 'package:consulta_alunos/features/search/models/student.dart';

class SearchViewModel extends ChangeNotifier {
  SearchViewModel(this._repository);

  final StudentsRepository _repository;

  final queryController = TextEditingController();

  SearchType _searchType = SearchType.name;
  SearchContentState _contentState = SearchContentState.empty;
  bool _isSearching = false;
  List<Student> _students = [];
  String? _expandedCodAluno;
  String? _errorMessage;

  SearchType get searchType => _searchType;
  SearchContentState get contentState => _contentState;
  bool get isSearching => _isSearching;
  List<Student> get students => List.unmodifiable(_students);
  String? get errorMessage => _errorMessage;

  bool get canSearch {
    final query = queryController.text.trim();
    if (query.isEmpty) return false;
    if (_searchType == SearchType.cpf) {
      return Formatters.digitsOnly(query).length == 11;
    }
    return true;
  }

  bool isExpanded(Student student) => _expandedCodAluno == student.codAluno;

  void onQueryChanged() {
    if (_errorMessage != null) {
      _errorMessage = null;
    }
    notifyListeners();
  }

  void setSearchType(SearchType type) {
    if (_searchType == type) return;
    _searchType = type;
    queryController.clear();
    _resetResults();
    notifyListeners();
  }

  void toggleExpanded(Student student) {
    _expandedCodAluno =
        _expandedCodAluno == student.codAluno ? null : student.codAluno;
    notifyListeners();
  }

  Future<void> search() async {
    final query = queryController.text.trim();
    if (!canSearch || _isSearching) return;

    _isSearching = true;
    _contentState = SearchContentState.loading;
    _errorMessage = null;
    _students = [];
    _expandedCodAluno = null;
    notifyListeners();

    try {
      if (_searchType == SearchType.name) {
        _students = await _repository.searchByName(query);
      } else {
        _students = await _repository.searchByCpf(query);
      }

      _contentState = SearchContentState.results;
    } on ApiException catch (e) {
      _contentState = SearchContentState.error;
      _errorMessage = e.message;
    } catch (_) {
      _contentState = SearchContentState.error;
      _errorMessage =
          'Não foi possível consultar agora. Verifique sua internet.';
    } finally {
      _isSearching = false;
      notifyListeners();
    }
  }

  void _resetResults() {
    _contentState = SearchContentState.empty;
    _students = [];
    _expandedCodAluno = null;
    _errorMessage = null;
  }

  @override
  void dispose() {
    queryController.dispose();
    super.dispose();
  }
}
