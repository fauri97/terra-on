import '../core/tokens/token_store.dart';
import '../core/tokens/token_storage.dart';
import '../core/api_client.dart';

import 'auth_service.dart';
import 'report_service.dart';
import 'local_impl.dart';

import 'geo_service.dart';
import 'ibge_service.dart';
import 'user_service.dart'; // <-- adiciona isso

/// TerraON — Service Locator
///
/// Centraliza as instâncias dos serviços da aplicação.
/// Nesta fase, usamos implementações locais mínimas (sem dados fake),
/// apenas para permitir navegação e estados neutros na UI.
///
/// Para ligar ao backend C#, substitua por:
///   - HttpAuthService
///   - HttpReportService
///   - HttpGeoService / HttpIbgeService (Nominatim / IBGE)
///
/// Ex.:
///   final AuthService authService = HttpAuthService(baseUrl: 'https://api.seudominio');
///   final ReportService reportService = HttpReportService(baseUrl: 'https://api.seudominio');
///   final GeoService geoService = HttpGeoService();
///   final IbgeService ibgeService = HttpIbgeService();

final AuthService authService = LocalAuthService();
final ReportService reportService = LocalReportService();

// Serviços auxiliares (geolocalização e IBGE)
final GeoService geoService = GeoService();
final IbgeService ibgeService = IbgeService();

/// ========== NOVOS ==========
/// necessários pro UserService funcionar com token e api
late final TokenStore tokenStore;
late final ApiClient apiClient;
late final UserService userService;

/// chama isso no main antes de rodar o app
Future<void> setupCoreServices() async {
  // storage -> tokens web/mobile
  final storage = await DefaultTokenStorage.create();
  tokenStore = TokenStore(storage);
  await tokenStore.init();

  // cria http client
  apiClient = ApiClient.create(
    tokenStore: tokenStore,
    onUnauthorized: () async {
      await tokenStore.clear();
    },
  );

  // instancia o userService apontando para API
  userService = UserService(
    http: apiClient.dio,
    tokenStore: tokenStore,
  );
}
