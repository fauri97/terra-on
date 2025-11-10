import 'dart:convert';
import 'package:dio/dio.dart';
import '../core/tokens/token_store.dart';
import 'service_locator.dart';

class UserService {
  final Dio http;
  final TokenStore tokenStore;

  UserService({
    required this.http,
    required this.tokenStore,
  });

  /// GET /api/user/me
  Future<Map<String, dynamic>?> getMyProfile() async {
    try {
      final resp = await http.get('/api/user/me');
      final data = resp.data['data'];

      return data;
    } catch (e) {
      return null;
    }
  }

  /// PUT /api/user/{id}
  Future<bool> updateProfile({
    required int id,
    required String name,
    required String email,
    required String city,
    required String uf, // no front é UF, mas no back é state
    String? base64Image,
  }) async {
    try {
      final body = {
        "name": name,
        "phoneNumber": "",          // depois ajusta se tiver telefone
        "city": city,
        "state": uf,                // backend espera "state"
        "base64ProfileImage": base64Image ?? "",
      };

      await http.put('/api/user/$id', data: body);

      // atualiza local (nome e email)
      await tokenStore.setProfile(id: id, name: name, email: email);

      return true;
    } catch (e) {
      return false;
    }
  }

  /// utilitário (converte bytes → base64)
  String imageBytesToBase64(List<int> bytes) {
    return base64Encode(bytes);
  }
}

/// instancia global
late final UserService userService;

void setupUserService() {
  userService = UserService(
    http: apiClient.dio,
    tokenStore: tokenStore,
  );
}
