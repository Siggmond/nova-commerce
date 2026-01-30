import 'dart:io';

import 'package:hive/hive.dart';

Directory? _hiveDir;

Future<void> initHiveForTests() async {
  if (_hiveDir != null) return;
  _hiveDir = await Directory.systemTemp.createTemp('hive_test_');
  Hive.init(_hiveDir!.path);
}

Future<void> disposeHiveForTests() async {
  await Hive.close();
  final dir = _hiveDir;
  _hiveDir = null;
  if (dir != null && await dir.exists()) {
    await dir.delete(recursive: true);
  }
}
