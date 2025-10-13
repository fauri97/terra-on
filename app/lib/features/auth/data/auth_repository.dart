import 'package:app/core/network/api_client.dart';
import 'package:app/core/network/core_providers.dart';
import 'package:riverpod/riverpod.dart';

import '../../../core/auth/token_store.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(
    ref.read(apiClientProvider),
    ref.read(tokenStoreProvider),
  );
});

class AuthRepository {
  final ApiClient _api;
  final TokenStore _tokens;
  AuthRepository(this._api, this._tokens);

  Future<void> login(String email, String password) async {
    final r = await _api.post(
      '/api/login',
      data: {'email': email, 'password': password},
      auth: false,
    );
    final json = r.data as Map<String, dynamic>;
    print(json);
    final access = json['accessToken'] as String;
    final refresh = json['refreshToken'] as String?;
    await _tokens.save(access, refresh: refresh);
  }
}
