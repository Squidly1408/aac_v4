import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

class StorageService {
  static const _boxName = 'aac_best_box';

  late Box _box;

  Future<void> init() async {
    _box = await Hive.openBox(_boxName);
  }

  Future<void> putJson(String key, Object value) async {
    await _box.put(key, value);
  }

  T? get<T>(String key) {
    final v = _box.get(key);
    if (v is T) return v;
    return null;
  }

  Future<File> exportBackupJson({
    required Map<String, dynamic> payload,
  }) async {
    final dir = await getApplicationDocumentsDirectory();
    final ts = DateTime.now().toIso8601String().replaceAll(':', '-');
    final file = File('${dir.path}/aac_best_backup_$ts.json');
    await file.writeAsString(const JsonEncoder.withIndent('  ').convert(payload));
    return file;
  }

  Future<Map<String, dynamic>?> importBackupJson() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['json'],
      withData: false,
    );
    final path = result?.files.single.path;
    if (path == null) return null;

    final file = File(path);
    final raw = await file.readAsString();
    final decoded = jsonDecode(raw);
    if (decoded is Map<String, dynamic>) return decoded;
    return null;
  }
}
