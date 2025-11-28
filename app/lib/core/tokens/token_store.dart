import 'package:mobx/mobx.dart';
import 'token_storage.dart';

part 'token_store.g.dart';

class TokenStore = _TokenStore with _$TokenStore;

abstract class _TokenStore with Store {
  final TokenStorage storage;
  _TokenStore(this.storage);

  // --- estado da sessão em memória (observável) ---
  @observable
  String? token;

  @observable
  int? userId;

  @observable
  String? userName;

  @observable
  String? userEmail;

  @observable
  String? userAvatarBase64;

  @computed
  bool get isLoggedIn => (token ?? '').isNotEmpty;

  /// Carrega do storage no boot do app.
  @action
  Future<void> init() async {
    token = await storage.readAccess();
    userId = await storage.readUserId();
    userName = await storage.readUserName();
    userEmail = await storage.readUserEmail();
    userAvatarBase64 = await storage.readUserAvatarBase64();
  }

  /// Define **apenas** o token (retrocompatível). Prefira `setSession`.
  @action
  Future<void> setToken(String? value, {String? refresh}) async {
    if (value == null || value.isEmpty) {
      await clear();
      return;
    }
    await storage.save(access: value, refresh: refresh ?? '');
    token = value;
  }

  /// Define token **e** dados do usuário de uma vez (recomendado).
  @action
  Future<void> setSession({
    required String accessToken,
    String refreshToken = '',
    required int id,
    required String name,
    required String email,
    String? avatarBase64,
  }) async {
    await storage.saveSession(
      access: accessToken,
      refresh: refreshToken,
      userId: id,
      userName: name,
      userEmail: email,
      userAvatarBase64: avatarBase64,
    );
    token = accessToken;
    userId = id;
    userName = name;
    userEmail = email;
    userAvatarBase64 = avatarBase64;
  }

  @action
  Future<void> setProfile({
    required int id,
    required String name,
    required String email,
    String? avatarBase64,
  }) async {
    final currentToken = token ?? '';
    final currentRefresh = await storage.readRefresh() ?? '';
    await storage.saveSession(
      access: currentToken,
      refresh: currentRefresh,
      userId: id,
      userName: name,
      userEmail: email,
      userAvatarBase64: avatarBase64 ?? userAvatarBase64,
    );
    userId = id;
    userName = name;
    userEmail = email;
    if (avatarBase64 != null) userAvatarBase64 = avatarBase64;
  }

  @action
  Future<void> clear() async {
    await storage.clear();
    token = null;
    userId = null;
    userName = null;
    userEmail = null;
    userAvatarBase64 = null;
  }
}
