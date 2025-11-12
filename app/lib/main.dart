import 'package:app/services/geo_service.dart';
import 'package:app/services/ibge_service.dart';
import 'package:app/services/service_locator.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/tokens/token_storage.dart';
import 'core/tokens/token_store.dart';
import 'core/api_client.dart';
import 'core/repositories/auth_repository.dart';
import 'services/user_service.dart';
import 'app_router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final storage = await DefaultTokenStorage.create();
  final tokenStore = TokenStore(storage);
  await tokenStore.init();

  final authRepo = AuthRepository(tokenStore: tokenStore);

  final apiClient = ApiClient.create(
    tokenStore: tokenStore,
    onUnauthorized: () => authRepo.refresh(),
  );

  runApp(
    MultiProvider(
      providers: [
        Provider<TokenStore>.value(value: tokenStore),
        Provider<AuthRepository>.value(value: authRepo),
        Provider<ApiClient>.value(value: apiClient),
        Provider<IbgeService>(create: (_) => IbgeService()),
        Provider<GeoService>(create: (_) => GeoService()),
        Provider<UserService>(
          create: (ctx) => UserService(
            api: ctx.read<ApiClient>(),
            tokenStore: ctx.read<TokenStore>(),
          ),
        ),
      ],
      child: const TerraONApp(),
    ),
  );
}

class TerraONApp extends StatelessWidget {
  const TerraONApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'TerraON',
      routerConfig: AppRouter.router,
      debugShowCheckedModeBanner: false,
    );
  }
}
