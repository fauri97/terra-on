import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

/// TerraON — GeoService
///
/// Serviço para obter a localização atual (latitude/longitude)
/// e converter para cidade e UF (estado) usando a API Nominatim
/// do OpenStreetMap. Compatível com Android e Web.
///
/// Uso:
/// ```dart
/// final geo = GeoService();
/// final result = await geo.getCurrentCityAndState();
/// print(result.city); // "Lajeado"
/// print(result.state); // "Rio Grande do Sul"
/// print(result.uf); // "RS"
/// ```

/// Modelo básico de localização.
class GeoResult {
  final double? latitude;
  final double? longitude;
  final String? city;
  final String? state;
  final String? uf;
  final bool permissionDenied;

  const GeoResult({
    this.latitude,
    this.longitude,
    this.city,
    this.state,
    this.uf,
    this.permissionDenied = false,
  });

  bool get hasLocation => latitude != null && longitude != null;
}

/// Serviço principal.
class GeoService {
  /// Solicita permissão e obtém coordenadas do usuário.
  Future<Position?> _getPosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Verifica se o serviço está ativo
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      debugPrint('⚠️ Serviço de localização desativado.');
      return null;
    }

    // Verifica e solicita permissão
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        debugPrint('❌ Permissão negada.');
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      debugPrint('❌ Permissão negada permanentemente.');
      return null;
    }

    // Obtém posição atual
    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  /// Converte latitude/longitude em cidade e UF usando Nominatim.
  Future<Map<String, String?>> _reverseGeocode(
      double lat, double lon) async {
    final url =
        'https://nominatim.openstreetmap.org/reverse?lat=$lat&lon=$lon&format=json&accept-language=pt-BR';

    try {
      final response = await http.get(Uri.parse(url), headers: {
        'User-Agent': 'TerraONApp/1.0 (flutter)',
      });

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final address = data['address'] ?? {};
        return {
          'city': address['city'] ??
              address['town'] ??
              address['village'] ??
              address['municipality'],
          'state': address['state'],
        };
      } else {
        debugPrint('Erro Nominatim: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Erro na chamada Nominatim: $e');
    }
    return {'city': null, 'state': null};
  }

  /// Mapa fixo de estados → siglas (para evitar segunda requisição IBGE)
  static const Map<String, String> _ufs = {
    'Acre': 'AC',
    'Alagoas': 'AL',
    'Amapá': 'AP',
    'Amazonas': 'AM',
    'Bahia': 'BA',
    'Ceará': 'CE',
    'Distrito Federal': 'DF',
    'Espírito Santo': 'ES',
    'Goiás': 'GO',
    'Maranhão': 'MA',
    'Mato Grosso': 'MT',
    'Mato Grosso do Sul': 'MS',
    'Minas Gerais': 'MG',
    'Pará': 'PA',
    'Paraíba': 'PB',
    'Paraná': 'PR',
    'Pernambuco': 'PE',
    'Piauí': 'PI',
    'Rio de Janeiro': 'RJ',
    'Rio Grande do Norte': 'RN',
    'Rio Grande do Sul': 'RS',
    'Rondônia': 'RO',
    'Roraima': 'RR',
    'Santa Catarina': 'SC',
    'São Paulo': 'SP',
    'Sergipe': 'SE',
    'Tocantins': 'TO',
  };

  /// Função principal pública.
  Future<GeoResult> getCurrentCityAndState() async {
    try {
      final pos = await _getPosition();
      if (pos == null) {
        return const GeoResult(permissionDenied: true);
      }

      final result = await _reverseGeocode(pos.latitude, pos.longitude);
      final city = result['city'];
      final state = result['state'];
      final uf = _ufs[state];

      return GeoResult(
        latitude: pos.latitude,
        longitude: pos.longitude,
        city: city,
        state: state,
        uf: uf,
      );
    } catch (e) {
      debugPrint('Erro ao obter cidade/UF: $e');
      return const GeoResult(permissionDenied: true);
    }
  }
}
