// lib/core/network/api_client.dart
import 'package:dio/dio.dart';
import '../auth/token_store.dart';

typedef RefreshFn = Future<TokenPair?> Function(String refreshToken);

class ApiClient {
  final Dio dio;
  final TokenStore _tokens;
  final RefreshFn? _onRefresh; // opcional

  ApiClient({
    required String baseUrl,
    required TokenStore tokens,
    RefreshFn? onRefresh,
    Duration connectTimeout = const Duration(seconds: 15),
    Duration receiveTimeout = const Duration(seconds: 20),
  }) : dio = Dio(
         BaseOptions(
           baseUrl: baseUrl,
           connectTimeout: connectTimeout,
           receiveTimeout: receiveTimeout,
         ),
       ),
       _tokens = tokens,
       _onRefresh = onRefresh {
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final requireAuth = options.extra['auth'] as bool? ?? true;
          if (requireAuth) {
            final token =
                _tokens.accessInMemory ?? (await _tokens.read())?.access;
            if (token != null) {
              options.headers['Authorization'] = 'Bearer $token';
            }
          }
          handler.next(options);
        },
        onError: (e, handler) async {
          // Tenta refresh em 401 (uma única vez)
          final attempted = e.requestOptions.extra['__retry'] == true;
          final requireAuth = e.requestOptions.extra['auth'] as bool? ?? true;

          if (requireAuth &&
              e.response?.statusCode == 401 &&
              !attempted &&
              _onRefresh != null) {
            final refresh =
                _tokens.refreshInMemory ?? (await _tokens.read())?.refresh;
            if (refresh != null && refresh.isNotEmpty) {
              try {
                final newPair = await _onRefresh!.call(refresh);
                if (newPair != null) {
                  await _tokens.save(newPair.access, refresh: newPair.refresh);
                  final req = e.requestOptions;
                  req.headers['Authorization'] = 'Bearer ${newPair.access}';
                  req.extra['__retry'] = true;
                  final cloned = await dio.fetch(req);
                  return handler.resolve(cloned);
                }
              } catch (_) {}
            }
          }
          handler.next(e);
        },
      ),
    );
  }

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? query,
    bool auth = true,
  }) {
    return dio.get<T>(
      path,
      queryParameters: query,
      options: Options(extra: {'auth': auth}),
    );
  }

  Future<Response<T>> post<T>(String path, {dynamic data, bool auth = true}) {
    return dio.post<T>(
      path,
      data: data,
      options: Options(extra: {'auth': auth}),
    );
  }

  Future<Response<T>> put<T>(String path, {dynamic data, bool auth = true}) {
    return dio.put<T>(
      path,
      data: data,
      options: Options(extra: {'auth': auth}),
    );
  }

  Future<Response<T>> delete<T>(String path, {dynamic data, bool auth = true}) {
    return dio.delete<T>(
      path,
      data: data,
      options: Options(extra: {'auth': auth}),
    );
  }
}
