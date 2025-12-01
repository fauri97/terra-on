import 'dart:async';
import 'package:dio/dio.dart';
import 'tokens/token_store.dart';
import 'package:flutter/foundation.dart'; // pra debugPrint

class ApiClient {
  final Dio dio;

  ApiClient._(this.dio);

  static ApiClient create({
    required TokenStore tokenStore,
    required Future<void> Function() onUnauthorized,
    String baseUrl = const String.fromEnvironment(
      'API_BASE_URL',
      defaultValue: 'http://10.0.2.2:5078',
    ),
  }) {
    final dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        contentType: 'application/json',
        responseType: ResponseType.json,
        connectTimeout: const Duration(milliseconds: 15000),
        receiveTimeout: const Duration(milliseconds: 20000),
      ),
    );

    bool isRefreshing = false;
    final waiters = <Completer<void>>[];

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final t = tokenStore.token;

          debugPrint('➡️ REQUEST: ${options.method} ${options.uri}');
          debugPrint('   Headers antes: ${options.headers}');
          if (options.data != null) {
            debugPrint('   Body: ${options.data}');
          }

          if (t != null && t.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $t';
            debugPrint('   Authorization: Bearer ${t.substring(0, 10)}...');
          } else {
            debugPrint('   ⚠️ Sem token no TokenStore');
          }

          handler.next(options);
        },
        onResponse: (response, handler) {
          debugPrint('✅ RESPONSE: [${response.statusCode}] ${response.requestOptions.uri}');
          if (response.data != null) {
            debugPrint('   Data: ${response.data}');
          }
          handler.next(response);
        },
        onError: (e, handler) async {
          final status = e.response?.statusCode;
          final path = e.requestOptions.path;

          debugPrint('❌ ERROR: [${status}] ${e.requestOptions.method} ${e.requestOptions.uri}');
          debugPrint('   Path: $path');
          if (e.response?.data != null) {
            debugPrint('   Response data: ${e.response!.data}');
          }

          final isAuthPath =
              path.contains('/auth/login') ||
              path.contains('/auth/refresh') ||
              path.contains('/api/login');

          // --- versão SEM retry automático, só chama onUnauthorized e repassa erro ---
          if (status == 401 && !isAuthPath) {
            debugPrint('   ⚠️ 401 recebido, chamando onUnauthorized()');
            await onUnauthorized();
            // não tenta refazer a requisição, só devolve o erro
            return handler.next(e);
            // ou: return handler.reject(e);
          }

          handler.next(e);
        },
      ),
    );

    return ApiClient._(dio);
  }
}
