import 'dart:convert';
import 'dart:io';

import 'package:app/core/models/api_response.dart';
import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import '../api_client.dart';
import '../models/report_models.dart' hide ApiListResponse;
import '../tokens/token_store.dart';

class ReportsRepository {
  final Dio _dio;
  final TokenStore _tokenStore;

  ReportsRepository(ApiClient client, this._tokenStore) : _dio = client.dio;

  bool _isOkStatus(dynamic v) {
    if (v == null) return true;
    if (v is int) return v == 0 || v == 200 || v == 201;
    return false;
  }

  Future<void> reportPost(int postId, String reason) async {
    await _dio.post(
      '/api/reportposts',
      data: {'postId': postId, 'reason': reason},
    );
  }

  Future<List<ReportItem>> getFeed() async {
    final resp = await _dio.get<Map<String, dynamic>>('/api/report');
    final json = resp.data ?? const {};
    if (!_isOkStatus(json['statusCode'])) {
      throw Exception((json['message'] as String?) ?? 'Falha ao carregar feed');
    }
    final api = ApiListResponse.fromJson(json, (m) => ReportItem.fromJson(m));
    return api.data;
  }

  Future<List<ReportItem>> getMyReports() async {
    final resp = await _dio.get<Map<String, dynamic>>('/api/report/mine');
    final json = resp.data ?? const {};
    if (!_isOkStatus(json['statusCode'])) {
      throw Exception(
        (json['message'] as String?) ?? 'Falha ao minhas denuncias feed',
      );
    }
    final api = ApiListResponse.fromJson(json, (m) => ReportItem.fromJson(m));
    return api.data;
  }

  Future<ReportItem?> toggleLike(int reportId) async {
    final userId = _tokenStore.userId;
    if (userId == null) {
      throw Exception('Usuário não logado: userId indisponível.');
    }

    final url = '/api/report/$reportId/user/$userId/like';

    final resp = await _dio.post<Map<String, dynamic>>(url);
    final json = resp.data ?? const {};

    if (!_isOkStatus(json['statusCode'])) {
      throw Exception((json['message'] as String?) ?? 'Falha ao alternar like');
    }

    final data = json['data'];
    if (data is Map<String, dynamic>) {
      return ReportItem.fromJson(data);
    }
    return null;
  }

  Future<void> createCommentRaw({
    required int reportId,
    required int authorId,
    required String content,
  }) async {
    final body = {
      "reportId": reportId,
      "authorId": authorId,
      "content": content,
    };
    final resp = await _dio.post<Map<String, dynamic>>(
      '/api/comment',
      data: body,
    );

    if (resp.statusCode! < 200 || resp.statusCode! >= 300) {
      throw Exception('Falha ao enviar comentário (${resp.statusCode})');
    }
  }

  /// Cria denúncia já puxando o authorId do TokenStore
  Future<String?> createReportRaw({
    required String description,
    String longitude = '0',
    String latitude = '0',
    String address = '',
    required String city,
    String state = '',
    String bairro = '',
    String cep = '',
    List<String> imagesBase64 = const [],
  }) async {
    final authorId = _tokenStore.userId;
    if (authorId == null) {
      throw Exception('Usuário não logado: authorId indisponível.');
    }

    final payload = <String, dynamic>{
      "description": description,
      "authorId": authorId,
      "longitude": longitude,
      "latitude": latitude,
      "address": address,
      "city": city,
      "state": state,
      "bairro": bairro,
      "cep": cep,
      "imagesBase64": imagesBase64,
    };

    final resp = await _dio.post<Map<String, dynamic>>(
      '/api/report',
      data: payload,
    );
    final json = resp.data ?? const {};
    if (!_isOkStatus(json['statusCode'])) {
      throw Exception(
        (json['message'] as String?) ?? 'Falha ao criar denúncia',
      );
    }

    final data = json['data'];
    if (data is Map && data['id'] != null) {
      return '${data['id']}';
    }
    return null;
  }

  Future<String> filePathToBase64(String path) async {
    final bytes = await File(path).readAsBytes();
    return base64Encode(bytes);
  }
}

/// Conveniência via Provider
extension ReportsRepoX on BuildContext {
  ReportsRepository reportsRepo() =>
      ReportsRepository(read<ApiClient>(), read<TokenStore>());
}
