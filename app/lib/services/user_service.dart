import 'dart:convert';
import 'package:dio/dio.dart';
import '../core/tokens/token_store.dart';
import '../core/api_client.dart';

class UserService {
  final ApiClient api;
  final TokenStore tokenStore;

  UserService({required this.api, required this.tokenStore});

  /// GET /api/user/me
  Future<Map<String, dynamic>?> getMyProfile() async {
    print('[UserService] → getMyProfile iniciado...');
    try {
      final resp = await api.dio.get('/api/user/me');
      print('[UserService] ← resposta status: ${resp.statusCode}');
      print('[UserService] ← corpo: ${resp.data}');
      final data = resp.data is Map<String, dynamic>
          ? (resp.data['data'] ?? resp.data)
          : resp.data;
      return data is Map<String, dynamic> ? data : null;
    } on DioException catch (e) {
      print('[UserService] ✖ Erro Dio: ${e.message}');
      print('[UserService] ✖ Response: ${e.response?.data}');
      return null;
    } catch (e) {
      print('[UserService] ✖ Erro inesperado: $e');
      return null;
    }
  }

  /// PUT /api/user/{id}
  Future<bool> updateProfile({
    required int id,
    required String name,
    required String email,
    required String city,
    required String uf,
    String? base64Image,
  }) async {
    print('[UserService] → updateProfile chamado (id=$id)');
    try {
      final body = {
        "name": name,
        "phoneNumber": "",
        "city": city,
        "state": uf,
        "base64ProfileImage": base64Image ?? "",
      };
      print('[UserService] → body enviado: $body');

      final resp = await api.dio.put('/api/user/$id', data: body);
      print('[UserService] ← resposta status: ${resp.statusCode}');

      await tokenStore.setProfile(id: id, name: name, email: email);
      print('[UserService] ✔ tokenStore atualizado');

      return true;
    } on DioException catch (e) {
      print('[UserService] ✖ Erro Dio: ${e.message}');
      print('[UserService] ✖ Response: ${e.response?.data}');
      return false;
    } catch (e) {
      print('[UserService] ✖ Erro inesperado: $e');
      return false;
    }
  }

  String imageBytesToBase64(List<int> bytes) => base64Encode(bytes);
}
