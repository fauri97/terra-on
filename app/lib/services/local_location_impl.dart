import 'location_service.dart';

/// TerraON — LocalLocationService
///
/// Implementação local mínima do LocationService.
/// Todos os métodos retornam estados neutros (listas vazias ou null),
/// sem integração real com IBGE/Nominatim.
/// A UI deve exibir estado "sem dados" ou "carregando" adequadamente.

class LocalLocationService implements LocationService {
  @override
  Future<List<String>> listUFs() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return []; // sem dados locais
  }

  @override
  Future<List<String>> searchCities({
    required String uf,
    required String query,
  }) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return []; // sem cidades locais
  }

  @override
  Future<({double lat, double lon})?> currentPosition() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return null; // sem localização automática local
  }
}
