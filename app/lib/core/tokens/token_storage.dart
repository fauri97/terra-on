import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class TokenStorage {
  Future<void> save({required String access, required String refresh});
  Future<String?> readAccess();
  Future<String?> readRefresh();
  Future<void> clear();
}

class DefaultTokenStorage implements TokenStorage {
  static const _kAccess = 'access_token';
  static const _kRefresh = 'refresh_token';

  final FlutterSecureStorage? _secure;
  final SharedPreferences? _prefs;

  DefaultTokenStorage._(this._secure, this._prefs);

  static Future<DefaultTokenStorage> create() async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      return DefaultTokenStorage._(null, prefs);
    } else {
      return DefaultTokenStorage._(const FlutterSecureStorage(), null);
    }
  }

  @override
  Future<void> save({required String access, required String refresh}) async {
    if (_prefs != null) {
      await _prefs!.setString(_kAccess, access);
      await _prefs!.setString(_kRefresh, refresh);
    } else {
      await _secure!.write(key: _kAccess, value: access);
      await _secure!.write(key: _kRefresh, value: refresh);
    }
  }

  @override
  Future<String?> readAccess() async => _prefs != null
      ? _prefs!.getString(_kAccess)
      : _secure!.read(key: _kAccess);

  @override
  Future<String?> readRefresh() async => _prefs != null
      ? _prefs!.getString(_kRefresh)
      : _secure!.read(key: _kRefresh);

  @override
  Future<void> clear() async {
    if (_prefs != null) {
      await _prefs!.remove(_kAccess);
      await _prefs!.remove(_kRefresh);
    } else {
      await _secure!.delete(key: _kAccess);
      await _secure!.delete(key: _kRefresh);
    }
  }
}
