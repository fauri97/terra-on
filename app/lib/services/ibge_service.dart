import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// TerraON — IbgeService
///
/// Serviço para listar estados e cidades do Brasil
/// usando a API pública do IBGE.
///
/// Compatível com Web + Android.
/// Retorna listas simples de Strings (nomes).

class IbgeService {
  static const _baseUrl =
      'https://servicodados.ibge.gov.br/api/v1/localidades';

  /// Retorna a lista de estados (UFs) em ordem alfabética.
  Future<List<String>> getStates() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/estados'));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final states =
            data.map((e) => e['nome'] as String).toList()..sort();
        return states;
      } else {
        debugPrint('Erro IBGE estados: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Erro ao buscar estados: $e');
    }
    return [];
  }

  /// Retorna a sigla da UF (ex: "RS") dado o nome do estado.
  Future<String?> getUfSigla(String stateName) async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/estados'));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        for (final e in data) {
          if (e['nome'] == stateName) return e['sigla'];
        }
      }
    } catch (e) {
      debugPrint('Erro ao buscar sigla da UF: $e');
    }
    return null;
  }

  /// Retorna as cidades de uma UF.
  Future<List<String>> getCities(String uf) async {
    try {
      final response =
          await http.get(Uri.parse('$_baseUrl/estados/$uf/municipios'));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final cities =
            data.map((e) => e['nome'] as String).toList()..sort();
        return cities;
      } else {
        debugPrint('Erro IBGE cidades: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Erro ao buscar cidades: $e');
    }
    return [];
  }
}
