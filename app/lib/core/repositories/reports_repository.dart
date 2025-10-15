// lib/core/repositories/reports_repository.dart
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import '../api_client.dart';
import '../models/report_models.dart';
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

  Future<List<ReportItem>> getFeed() async {
    final resp = await _dio.get<Map<String, dynamic>>('/api/report');
    final json = resp.data ?? const {};
    if (!_isOkStatus(json['statusCode'])) {
      throw Exception((json['message'] as String?) ?? 'Falha ao carregar feed');
    }
    final api = ApiListResponse.fromJson(json, (m) => ReportItem.fromJson(m));
    return api.data;
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
    final authorId = _tokenStore.userId; // << pega do login salvo
    if (authorId == null) {
      throw Exception('Usuário não logado: authorId indisponível.');
    }

    final payload = <String, dynamic>{
      "description": description,
      "authorId": authorId, // << agora sempre vai como int
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
  ReportsRepository reportsRepo() => ReportsRepository(
    read<ApiClient>(),
    read<TokenStore>(), // <- injeta o TokenStore
  );
}
