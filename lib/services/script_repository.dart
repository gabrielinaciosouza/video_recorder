import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../models/script.dart';

/// Persists the list of [Script]s as a JSON file in the app's private documents
/// directory. Each [Script] contains its own list of chunks.
class ScriptRepository {
  static const _fileName = 'scripts.json';

  Future<File> _file() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/$_fileName');
  }

  Future<List<Script>> load() async {
    try {
      final file = await _file();
      if (!await file.exists()) return [];
      final raw = await file.readAsString();
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((e) => Script.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> save(List<Script> scripts) async {
    final file = await _file();
    await file.writeAsString(
        jsonEncode(scripts.map((s) => s.toJson()).toList()));
  }
}
