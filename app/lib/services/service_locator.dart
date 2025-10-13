import 'auth_service.dart';
import 'report_service.dart';
import 'local_impl.dart';

import 'geo_service.dart';
import 'ibge_service.dart';

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
