import 'package:dio/dio.dart';
import '../models/report_models.dart';
import '../api_client.dart'; // seu ApiClient que injeta o Authorization
import 'package:provider/provider.dart';
import 'package:flutter/widgets.dart';

class ReportsRepository {
  final Dio _dio;

  ReportsRepository(ApiClient client) : _dio = client.dio;

  Future<List<ReportItem>> getFeed() async {
    final resp = await _dio.get<Map<String, dynamic>>('/api/report'); 
    // ^ ajuste a rota aqui se for outra

    final api = ApiListResponse.fromJson(
      resp.data ?? const {},
      (m) => ReportItem.fromJson(m),
    );

    if (api.statusCode != 200) {
      throw Exception(api.message.isEmpty ? 'Falha ao carregar feed' : api.message);
    }

    return api.data;
  }
}

/// Conveniência para obter o repo via Provider:
extension ReportsRepoX on BuildContext {
  ReportsRepository reportsRepo() => ReportsRepository(read<ApiClient>());
}
