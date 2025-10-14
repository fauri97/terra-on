import 'package:mobx/mobx.dart';
import 'token_storage.dart';

part 'token_store.g.dart';

class TokenStore = _TokenStore with _$TokenStore;

abstract class _TokenStore with Store {
  final TokenStorage storage;

  _TokenStore(this.storage);

  @observable
  String? token;

  @computed
  bool get isLoggedIn => token != null && token!.isNotEmpty;

  /// carrega do storage no boot
  Future<void> init() async {
    token = await storage.readAccess();
  }

  @action
  Future<void> setToken(String? value, {String? refresh}) async {
    if (value == null || value.isEmpty) {
      await storage.clear();
      token = null;
      return;
    }
    await storage.save(access: value, refresh: refresh ?? '');
    token = value;
  }

  @action
  Future<void> clear() async {
    await storage.clear();
    token = null;
  }
}
