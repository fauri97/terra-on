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
          responseBody: true, // cuidado com dados sensíveis
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

      // === LOG CRU (HTTP + payload)
      debugPrint('--- LOGIN RESPONSE --------------------------------');
      debugPrint('HTTP status: ${resp.statusCode}');
      debugPrint('RAW payload:\n${_pretty(resp.data)}');

      // === Parse p/ seus modelos
      final api = ApiResponse.fromJson(
        resp.data!,
        (m) => LoginData.fromJson(m),
      );

      // === LOG PARSEADO
      debugPrint(
        'PARSED: statusCode=${api.statusCode}  message="${api.message}"',
      );
      debugPrint(
        'PARSED: user.id=${api.data.id}  name=${api.data.name}  email=${api.data.email}',
      );
      debugPrint('PARSED: accessToken="${api.data.accessToken}"');

      // === Regra de sucesso (recomendo usar token como fonte da verdade)
      final token = api.data.accessToken;
      if (token.isNotEmpty) {
        await tokenStore.setToken(token);
        debugPrint('LOGIN OK → token salvo.');
        return;
      }

      // Se não veio token, considere erro e use a mensagem da API
      throw Exception(api.message.isEmpty ? 'Falha de login' : api.message);
    } on DioException catch (e) {
      // === LOG de erro Dio (inclui response do servidor, se houver)
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
      // === Outros erros (parse, etc.)
      debugPrint('*** LOGIN ERROR (genérico) *** ${e.toString()}');
      rethrow;
    }
  }

  Future<void> logout() => tokenStore.clear();

  Future<void> refresh() async {
    throw Exception('Refresh não implementado');
  }
}
