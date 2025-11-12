import 'dart:convert'; // <- para pretty print
import 'package:app/core/models/login_models.dart';
import 'package:app/core/tokens/token_store.dart';
import 'package:flutter/foundation.dart'; // <- debugPrint
import 'package:dio/dio.dart';

class AuthRepository {
  final Dio _dio;
  final TokenStore tokenStore;

  AuthRepository({
    required this.tokenStore,
    String baseUrl = const String.fromEnvironment(
      'API_BASE_URL',
      defaultValue: 'http://10.0.2.2:5078',
    ),
  }) : _dio = Dio(
         BaseOptions(
           baseUrl: baseUrl,
           contentType: 'application/json',
           responseType: ResponseType.json,
         ),
       ) {
    // (Opcional) log do Dio em debug
    assert(() {
      _dio.interceptors.add(
        LogInterceptor(
          request: true,
          requestBody: true,
          responseBody: true,
          responseHeader: false,
        ),
      );
      return true;
    }());
  }

  String _pretty(Object? data) {
    try {
      if (data is String) {
        final dynamic decoded = jsonDecode(data);
        return const JsonEncoder.withIndent('  ').convert(decoded);
      }
      return const JsonEncoder.withIndent('  ').convert(data);
    } catch (_) {
      return data.toString();
    }
  }

  Future<void> login({required String email, required String password}) async {
    try {
      final resp = await _dio.post<Map<String, dynamic>>(
        '/api/login',
        data: {'email': email, 'password': password},
        options: Options(headers: {'Authorization': null}),
      );

      debugPrint('--- LOGIN RESPONSE --------------------------------');
      debugPrint('HTTP status: ${resp.statusCode}');
      debugPrint('RAW payload:\n${_pretty(resp.data)}');

      final api = ApiResponse.fromJson(
        resp.data!,
        (m) => LoginData.fromJson(m),
      );

      debugPrint(
        'PARSED: statusCode=${api.statusCode}  message="${api.message}"',
      );
      debugPrint(
        'PARSED: user.id=${api.data.id}  name=${api.data.name}  email=${api.data.email}',
      );
      debugPrint('PARSED: accessToken="${api.data.accessToken}"');

      // Sua API: sucesso quando statusCode == 0
      if (api.statusCode != 201) {
        throw Exception(api.message.isEmpty ? 'Falha de login' : api.message);
      }

      final token = api.data.accessToken;
      if (token.isEmpty) {
        throw Exception('Token não recebido da API.');
      }

      await tokenStore.setToken(token);
      try {
        // ignore: unawaited_futures
        tokenStore.setProfile(
          id: api.data.id,
          name: api.data.name,
          email: api.data.email,
          avatarBase64: api.data.avatarBase64,
        );
      } catch (_) {
        // Se ainda não implementou setProfile, ignore.
      }

      debugPrint('LOGIN OK → sessão salva.');
    } on DioException catch (e) {
      debugPrint('*** DIO ERROR ***');
      debugPrint('type=${e.type}');
      debugPrint('status=${e.response?.statusCode}');
      debugPrint('data=\n${_pretty(e.response?.data)}');
      debugPrint('message=${e.message}');
      throw Exception(
        e.response?.data is Map<String, dynamic>
            ? ((e.response?.data['message'] as String?) ?? 'Erro de rede')
            : (e.message ?? 'Erro de rede'),
      );
    } catch (e) {
      debugPrint('*** LOGIN ERROR (genérico) *** ${e.toString()}');
      rethrow;
    }
  }

  Future<bool> registerUser({
    required String name,
    required String email,
    required String password,
  }) async {
    final phoneId = 'nanfnfnqpinp31p4j1op4n1pnçoaçdaopn';

    final body = <String, dynamic>{
      'name': name,
      'email': email,
      'password': password,
      'phoneNumber': '981829368',
      if (phoneId != null && phoneId.isNotEmpty) 'phoneId': phoneId,
      // NÃO enviar phoneNumber, UF, cidade, etc.
    };

    final resp = await _dio.post<Map<String, dynamic>>(
      '/api/user', // troque pelo seu endpoint real
      data: body,
      options: Options(contentType: 'application/json'),
    );

    // Supondo que sua API siga o mesmo padrão:
    // { statusCode: 0, message: "...", data: {...} }
    final statusCode = resp.data?['statusCode'] as int? ?? 1;
    if (statusCode != 201) {
      final msg = resp.data?['message']?.toString() ?? 'Falha ao cadastrar.';
      throw Exception(msg);
    }
    return true;
  }

  Future<void> logout() => tokenStore.clear();

  Future<void> refresh() async {
    throw Exception('Refresh não implementado');
  }
}
