import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:consulta_alunos/app.dart';
import 'package:consulta_alunos/features/sync/services/sync_foreground_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  if (!kIsWeb && (Platform.isWindows || Platform.isLinux)) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  FlutterForegroundTask.initCommunicationPort();
  SyncForegroundService.init();

  runApp(const ConsultaAlunosApp());
}
