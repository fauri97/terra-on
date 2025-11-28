// ibge_service.dart
import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class IbgeService {
  static const _base = 'https://servicodados.ibge.gov.br/api/v1/localidades';
  final http.Client _http;
  IbgeService({http.Client? client}) : _http = client ?? http.Client();

  Future<List<String>> getStates() async {
    final uri = Uri.parse('$_base/estados');
    debugPrint('[IBGE] GET $uri');
    try {
      final r = await _http.get(uri).timeout(const Duration(seconds: 8));
      debugPrint(
        '[IBGE] estados status=${r.statusCode} len=${r.bodyBytes.length}',
      );
      if (r.statusCode != 200) {
        throw Exception('HTTP ${r.statusCode} ao obter estados');
      }
      final list = (jsonDecode(r.body) as List).cast<Map<String, dynamic>>();
      list.sort((a, b) => a['nome'].toString().compareTo(b['nome'].toString()));
      return list.map((e) => e['nome'].toString()).toList();
    } on TimeoutException catch (_) {
      debugPrint('[IBGE] estados TIMEOUT');
      throw Exception('Timeout ao consultar estados do IBGE');
    } catch (e, s) {
      debugPrint('[IBGE] estados ERRO: $e\n$s');
      rethrow;
    }
  }

  Future<String?> getUfSigla(String stateName) async {
    final uri = Uri.parse('$_base/estados');
    debugPrint('[IBGE] GET $uri (sigla para "$stateName")');
    try {
      final r = await _http.get(uri).timeout(const Duration(seconds: 8));
      debugPrint(
        '[IBGE] siglas status=${r.statusCode} len=${r.bodyBytes.length}',
      );
      if (r.statusCode != 200) {
        throw Exception('HTTP ${r.statusCode} ao obter siglas');
      }
      final list = (jsonDecode(r.body) as List).cast<Map<String, dynamic>>();
      final found = list.firstWhere(
        (e) => e['nome'] == stateName,
        orElse: () => {},
      );
      // ignore: unnecessary_type_check
      return found is Map ? (found['sigla'] as String?) : null;
    } on TimeoutException {
      debugPrint('[IBGE] siglas TIMEOUT');
      throw Exception('Timeout ao consultar siglas do IBGE');
    } catch (e, s) {
      debugPrint('[IBGE] siglas ERRO: $e\n$s');
      rethrow;
    }
  }

  Future<List<String>> getCities(String ufSigla) async {
    final uri = Uri.parse('$_base/estados/$ufSigla/municipios');
    debugPrint('[IBGE] GET $uri');
    try {
      final r = await _http.get(uri).timeout(const Duration(seconds: 8));
      debugPrint(
        '[IBGE] cidades($ufSigla) status=${r.statusCode} len=${r.bodyBytes.length}',
      );
      if (r.statusCode != 200) {
        throw Exception('HTTP ${r.statusCode} ao obter cidades de $ufSigla');
      }
      final list = (jsonDecode(r.body) as List).cast<Map<String, dynamic>>();
      list.sort((a, b) => a['nome'].toString().compareTo(b['nome'].toString()));
      return list.map((e) => e['nome'].toString()).toList();
    } on TimeoutException {
      debugPrint('[IBGE] cidades TIMEOUT');
      throw Exception('Timeout ao consultar cidades do IBGE ($ufSigla)');
    } catch (e, s) {
      debugPrint('[IBGE] cidades ERRO: $e\n$s');
      rethrow;
    }
  }
}
