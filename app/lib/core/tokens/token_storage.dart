import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class TokenStorage {
  // Persistir somente tokens (retrocompatível)
  Future<void> save({required String access, required String refresh});

  // Persistir tokens + perfil do usuário (preferível)
  Future<void> saveSession({
    required String access,
    required String refresh,
    required int userId,
    required String userName,
    required String userEmail,
  });

  // Leituras
  Future<String?> readAccess();
  Future<String?> readRefresh();
  Future<int?> readUserId();
  Future<String?> readUserName();
  Future<String?> readUserEmail();

  // Limpa tudo
  Future<void> clear();
}

class DefaultTokenStorage implements TokenStorage {
  static const _kAccess = 'access_token';
  static const _kRefresh = 'refresh_token';
  static const _kUserId = 'user_id';
  static const _kUserName = 'user_name';
  static const _kUserEmail = 'user_email';

  final FlutterSecureStorage? _secure; // mobile
  final SharedPreferences? _prefs; // web

  DefaultTokenStorage._(this._secure, this._prefs);

  /// Use isso para criar a instância correta para cada plataforma.
  static Future<DefaultTokenStorage> create() async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      return DefaultTokenStorage._(null, prefs);
    } else {
      return DefaultTokenStorage._(const FlutterSecureStorage(), null);
    }
  }

  // ------------------- helpers internos -------------------
  Future<void> _writeString(String key, String value) async {
    if (_prefs != null) {
      await _prefs!.setString(key, value);
    } else {
      await _secure!.write(key: key, value: value);
    }
  }

  Future<String?> _readString(String key) async {
    if (_prefs != null) {
      return _prefs!.getString(key);
    } else {
      return _secure!.read(key: key);
    }
  }

  Future<void> _remove(String key) async {
    if (_prefs != null) {
      await _prefs!.remove(key);
    } else {
      await _secure!.delete(key: key);
    }
  }

  // ------------------- TokenStorage -------------------
  @override
  Future<void> save({required String access, required String refresh}) async {
    await _writeString(_kAccess, access);
    await _writeString(_kRefresh, refresh);
  }

  @override
  Future<void> saveSession({
    required String access,
    required String refresh,
    required int userId,
    required String userName,
    required String userEmail,
  }) async {
    await _writeString(_kAccess, access);
    await _writeString(_kRefresh, refresh);
    await _writeString(_kUserId, userId.toString());
    await _writeString(_kUserName, userName);
    await _writeString(_kUserEmail, userEmail);
  }

  @override
  Future<String?> readAccess() => _readString(_kAccess);

  @override
  Future<String?> readRefresh() => _readString(_kRefresh);

  @override
  Future<int?> readUserId() async {
    final s = await _readString(_kUserId);
    if (s == null || s.isEmpty) return null;
    return int.tryParse(s);
  }

  @override
  Future<String?> readUserName() => _readString(_kUserName);

  @override
  Future<String?> readUserEmail() => _readString(_kUserEmail);

  @override
  Future<void> clear() async {
    await _remove(_kAccess);
    await _remove(_kRefresh);
    await _remove(_kUserId);
    await _remove(_kUserName);
    await _remove(_kUserEmail);
  }
}
