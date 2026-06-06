import 'package:consulta_alunos/features/sync/data/students_local_dao.dart';
import 'package:consulta_alunos/features/sync/data/sync_storage.dart';

/// Serviço de sincronização — implementação ZIP/JSON será adicionada aqui.
class AlunoSyncService {
  AlunoSyncService({
    StudentsLocalDao? localDao,
    SyncStorage? syncStorage,
  })  : _localDao = localDao ?? StudentsLocalDao(),
        _syncStorage = syncStorage ?? SyncStorage();

  final StudentsLocalDao _localDao;
  final SyncStorage _syncStorage;

  Future<String?> getLastSyncAt() => _syncStorage.getLastSyncAt();

  Future<int> getLocalStudentCount() => _localDao.countStudents();
}
