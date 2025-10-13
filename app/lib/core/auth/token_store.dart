import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenPair {
  final String access;
  final String? refresh;
  const TokenPair(this.access, {this.refresh});
}

class TokenStore {
  static const _kAccess = 'access_token';
  static const _kRefresh = 'refresh_token';

  final _secure = const FlutterSecureStorage();
  TokenPair? _cached;

  Future<TokenPair?> read() async {
    if (_cached != null) return _cached;
    final access = await _secure.read(key: _kAccess);
    if (access == null) return null;
    final refresh = await _secure.read(key: _kRefresh);
    _cached = TokenPair(access, refresh: refresh);
    return _cached;
  }

  Future<void> save(String access, {String? refresh}) async {
    await _secure.write(key: _kAccess, value: access);
    if (refresh != null) await _secure.write(key: _kRefresh, value: refresh);
    _cached = TokenPair(access, refresh: refresh);
  }

  Future<void> clear() async {
    await _secure.delete(key: _kAccess);
    await _secure.delete(key: _kRefresh);
    _cached = null;
  }

  String? get accessInMemory => _cached?.access;
  String? get refreshInMemory => _cached?.refresh;
}
