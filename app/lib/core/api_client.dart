import 'dart:async';
import 'package:dio/dio.dart';
import 'tokens/token_store.dart';

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
          if (t != null && t.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $t';
          }
          handler.next(options);
        },
        onError: (e, handler) async {
          final status = e.response?.statusCode;
          final path = e.requestOptions.path;
          final isAuthPath =
              path.contains('/auth/login') ||
              path.contains('/auth/refresh') ||
              path.contains('/api/login');

          if (status == 401 && !isAuthPath) {
            if (isRefreshing) {
              final c = Completer<void>();
              waiters.add(c);
              await c.future;
            } else {
              isRefreshing = true;
              try {
                await onUnauthorized(); // se implementar refresh no futuro
              } finally {
                isRefreshing = false;
                for (final c in waiters) {
                  if (!c.isCompleted) c.complete();
                }
                waiters.clear();
              }
            }
            final resp = await dio.fetch<dynamic>(e.requestOptions);
            return handler.resolve(resp);
          }
          handler.next(e);
        },
      ),
    );

    return ApiClient._(dio);
  }
}
