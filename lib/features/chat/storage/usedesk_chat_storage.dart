import 'dart:io';
import 'dart:typed_data';

import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:usedesk/usedesk.dart';

class UsedeskChatStorage implements UsedeskChatStorageProvider {
  UsedeskChatStorage(this._prefs);

  final SharedPreferences _prefs;

  static const _kTokenKey = 'usedesk_token';
  static const _kUploadMapKey = 'usedesk_upload_cache_map'; // filename -> path

  // ===== Token =====

  @override
  Future<String?> getToken() async => _prefs.getString(_kTokenKey);

  /// В твоей версии интерфейса может быть saveToken(...)
  @override
  Future<void> saveToken(String token) async {
    await _prefs.setString(_kTokenKey, token);
  }

  /// ...и/или setToken(...)
  @override
  Future<void> setToken(String token) async {
    // просто делаем алиас, чтобы не плодить логику
    await saveToken(token);
  }

  @override
  Future<void> clearToken() async {
    await _prefs.remove(_kTokenKey);
  }

  // ===== Upload cache =====
  // Это нужно Usedesk-у, чтобы кэшировать файл локально (для ретраев),
  // а потом удалять его, когда загрузка завершена.

  @override
  Future<String> prepareUploadCache(String filename, Uint8List data) async {
    final dir = await _getUploadCacheDir();
    final safeName = _sanitizeFilename(filename);

    final file = File('${dir.path}/$safeName');
    await file.writeAsBytes(data, flush: true);

    final map = _getUploadMap();
    map[filename] = file.path; // ключ оставляем "как пришёл"
    await _prefs.setString(_kUploadMapKey, _encodeMap(map));

    return file.path; // обычно SDK ждёт путь до файла
  }

  @override
  Future<void> removeUploadCache(String filename) async {
    final map = _getUploadMap();
    final path = map[filename];

    if (path != null && path.isNotEmpty) {
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
      }
    }

    map.remove(filename);
    await _prefs.setString(_kUploadMapKey, _encodeMap(map));
  }

  // ===== Helpers =====

  Future<Directory> _getUploadCacheDir() async {
    final tmp = await getTemporaryDirectory();
    final dir = Directory('${tmp.path}/usedesk_upload_cache');
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  String _sanitizeFilename(String filename) {
    // минимальная санитаризация, чтобы не поломать путь
    return filename.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_');
  }

  Map<String, String> _getUploadMap() {
    final raw = _prefs.getString(_kUploadMapKey);
    if (raw == null || raw.isEmpty) return {};
    return _decodeMap(raw);
  }

  // Чтобы не тянуть json, используем простой формат "k1=v1\nk2=v2"
  String _encodeMap(Map<String, String> map) {
    return map.entries.map((e) => '${e.key}=${e.value}').join('\n');
  }

  Map<String, String> _decodeMap(String raw) {
    final result = <String, String>{};
    for (final line in raw.split('\n')) {
      final idx = line.indexOf('=');
      if (idx <= 0) continue;
      final k = line.substring(0, idx);
      final v = line.substring(idx + 1);
      if (k.isNotEmpty && v.isNotEmpty) result[k] = v;
    }
    return result;
  }
}