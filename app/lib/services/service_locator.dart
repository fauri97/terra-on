// sl_shim.dart
import 'package:app/core/api_client.dart';
import 'package:app/core/tokens/token_store.dart';
import 'package:app/services/auth_service.dart';
import 'package:app/services/geo_service.dart';
import 'package:app/services/ibge_service.dart';
import 'package:app/services/user_service.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

final GlobalKey<NavigatorState> appNavigatorKey = GlobalKey<NavigatorState>();

BuildContext _ctx() {
  final ctx = appNavigatorKey.currentContext;
  assert(
    ctx != null,
    'navigatorKey sem context — MaterialApp.navigatorKey não setado',
  );
  return ctx!;
}

/// Getters compatíveis com código legado que importava service_locator.dart
TokenStore get tokenStore => _ctx().read<TokenStore>();
ApiClient get apiClient => _ctx().read<ApiClient>();
UserService get userService => _ctx().read<UserService>();
AuthService get authService => _ctx().read<AuthService>();
GeoService get geoService => _ctx().read<GeoService>();
IbgeService get ibgeService => _ctx().read<IbgeService>();
