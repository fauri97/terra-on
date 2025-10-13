import 'package:app/core/network/api_client.dart';
import 'package:riverpod/riverpod.dart';
import '../auth/token_store.dart';

final baseUrlProvider = Provider<String>((_) => '10.0.2.2');

final tokenStoreProvider = Provider<TokenStore>((_) => TokenStore());

// Opcional: função de refresh usando seu endpoint
final refreshFnProvider = Provider<RefreshFn?>((ref) {
  return (String refreshToken) async {
    final api = ApiClient(
      baseUrl: ref.read(baseUrlProvider),
      tokens: ref.read(tokenStoreProvider),
    );
    final r = await api.post(
      '/auth/refresh',
      data: {'refreshToken': refreshToken},
      auth: false,
    );
    final data = r.data as Map<String, dynamic>;
    final access = data['accessToken'] as String?;
    final refresh = data['refreshToken'] as String?;
    if (access == null) return null;
    return TokenPair(access, refresh: refresh);
  };
});

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient(
    baseUrl: ref.watch(baseUrlProvider),
    tokens: ref.watch(tokenStoreProvider),
    onRefresh: ref.watch(refreshFnProvider),
  );
});
