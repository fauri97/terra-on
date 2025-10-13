/// TerraON — LocationService
///
/// Interface para dados de localização.
/// Futuro: integrar IBGE (UF/municípios) e Nominatim (bairros/reverse).
/// Nesta fase, as implementações locais retornam estados neutros.

abstract class LocationService {
  /// Lista as UFs (ex.: ["RS", "SC", "PR"...]).
  Future<List<String>> listUFs();

  /// Busca cidades pela UF e termo (autocomplete).
  Future<List<String>> searchCities({
    required String uf,
    required String query,
  });

  /// Posição atual do usuário (quando permitido).
  /// Retorna (lat, lon) ou null se indisponível.
  Future<({double lat, double lon})?> currentPosition();
}
