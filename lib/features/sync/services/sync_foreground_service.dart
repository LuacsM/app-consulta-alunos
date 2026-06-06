import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';

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
            'Mostra o progresso da sincronização offline dos alunos.',
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

    final permission = await FlutterForegroundTask.checkNotificationPermission();
    if (permission != NotificationPermission.granted) {
      await FlutterForegroundTask.requestNotificationPermission();
    }
  }

  static Future<void> start() async {
    if (!_isSupported) return;

    if (await FlutterForegroundTask.isRunningService) {
      final result = await FlutterForegroundTask.restartService();
      if (result is ServiceRequestFailure) {
        throw Exception(result.error);
      }
      return;
    }

    final result = await FlutterForegroundTask.startService(
      serviceId: _serviceId,
      serviceTypes: [ForegroundServiceTypes.dataSync],
      notificationTitle: 'Consulta Alunos',
      notificationText: 'Iniciando sincronização...',
      callback: syncForegroundStartCallback,
    );
    if (result is ServiceRequestFailure) {
      throw Exception(result.error);
    }
  }

  static Future<void> updateProgress({
    required int itemsProcessed,
    int? total,
    required int pagesProcessed,
  }) async {
    if (!_isSupported) return;
    if (!await FlutterForegroundTask.isRunningService) return;

    final text = total != null
        ? 'Lote $pagesProcessed — $itemsProcessed de $total alunos'
        : 'Lote $pagesProcessed — $itemsProcessed alunos';

    await FlutterForegroundTask.updateService(
      notificationTitle: 'Sincronizando alunos',
      notificationText: text,
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
}
