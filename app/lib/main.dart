import 'package:app/core/repositories/auth_repository.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/tokens/token_storage.dart';
import 'core/tokens/token_store.dart';
import 'core/api_client.dart';
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
