import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:consulta_alunos/features/sync/models/sync_progress.dart';

const _serviceId = 256;
const _channelId = 'aluno_sync_channel';

bool get _isSupported =>
    !kIsWeb && (Platform.isAndroid || Platform.isIOS);

@pragma('vm:entry-point')
void syncForegroundStartCallback() {
  FlutterForegroundTask.setTaskHandler(SyncKeepAliveTaskHandler());
}

class SyncKeepAliveTaskHandler extends TaskHandler {
  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {}

  @override
  void onRepeatEvent(DateTime timestamp) {}

  @override
  Future<void> onDestroy(DateTime timestamp, bool isTimeout) async {}
}

class SyncForegroundService {
  static void init() {
    if (!_isSupported) return;

    FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        channelId: _channelId,
        channelName: 'Sincronização de alunos',
        channelDescription:
            'Acompanhe o andamento da atualização dos dados dos alunos.',
        channelImportance: NotificationChannelImportance.LOW,
        priority: NotificationPriority.LOW,
        onlyAlertOnce: true,
      ),
      iosNotificationOptions: const IOSNotificationOptions(
        showNotification: true,
        playSound: false,
      ),
      foregroundTaskOptions: ForegroundTaskOptions(
        eventAction: ForegroundTaskEventAction.nothing(),
        autoRunOnBoot: false,
        autoRunOnMyPackageReplaced: false,
        allowWakeLock: true,
        allowWifiLock: true,
      ),
    );
  }

  static Future<void> requestPermissions() async {
    if (!_isSupported) return;

    final permission =
        await FlutterForegroundTask.checkNotificationPermission();
    if (permission != NotificationPermission.granted) {
      await FlutterForegroundTask.requestNotificationPermission();
    }
  }

  static Future<void> start({bool resume = false}) async {
    if (!_isSupported) return;

    final initialText = resume
        ? 'Etapa 3 de 3 — Continuando...'
        : 'Etapa 1 de 3 — Preparando...';

    if (await FlutterForegroundTask.isRunningService) {
      await FlutterForegroundTask.updateService(
        notificationTitle: 'Sincronizando alunos',
        notificationText: initialText,
      );
      return;
    }

    final result = await FlutterForegroundTask.startService(
      serviceId: _serviceId,
      serviceTypes: [ForegroundServiceTypes.dataSync],
      notificationTitle: 'Sincronizando alunos',
      notificationText: initialText,
      callback: syncForegroundStartCallback,
    );
    if (result is ServiceRequestFailure) {
      throw Exception(result.error);
    }
  }

  static Future<void> updateProgress(SyncProgress progress) async {
    if (!_isSupported) return;
    if (!await FlutterForegroundTask.isRunningService) return;

    await FlutterForegroundTask.updateService(
      notificationTitle: 'Sincronizando alunos',
      notificationText: _notificationText(progress),
    );
  }

  static Future<void> finish({required String message}) async {
    if (!_isSupported) return;
    if (!await FlutterForegroundTask.isRunningService) return;

    await FlutterForegroundTask.updateService(
      notificationTitle: 'Consulta Alunos',
      notificationText: message,
    );
    await FlutterForegroundTask.stopService();
  }

  static Future<void> stop() async {
    if (!_isSupported) return;
    if (!await FlutterForegroundTask.isRunningService) return;
    await FlutterForegroundTask.stopService();
  }

  static String _notificationText(SyncProgress progress) {
    return switch (progress.phase) {
      SyncPhase.preparing => 'Etapa 1 de 3 — Preparando os dados...',
      SyncPhase.downloading => progress.downloadProgress != null
          ? 'Etapa 2 de 3 — Baixando '
              '${(progress.downloadProgress! * 100).toStringAsFixed(0)}%'
          : 'Etapa 2 de 3 — Baixando dados...',
      SyncPhase.importing => progress.total != null
          ? 'Etapa 3 de 3 — Salvando dados '
              '(${_percent(progress.importProgressFraction)})'
          : 'Etapa 3 de 3 — Salvando dados...',
    };
  }

  static String _percent(double? fraction) {
    if (fraction == null) return '...';
    return '${(fraction * 100).toStringAsFixed(0)}%';
  }
}
