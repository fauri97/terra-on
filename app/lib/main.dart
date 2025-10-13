import 'package:flutter/material.dart';
import 'theme/app_theme.dart';

// Fluxo público
import 'pages/choose_login_page.dart';
import 'auth/login_user_page.dart';
import 'auth/register_user_page.dart';
import 'auth/recover_password_page.dart';

// Serviços (mantém inicialização local)
import 'services/service_locator.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const TerraOnApp());
}

class TerraOnApp extends StatelessWidget {
  const TerraOnApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TerraON',
      debugShowCheckedModeBanner: false,
      theme: themeLight(),
      darkTheme: themeDark(),
      themeMode: ThemeMode.light,

      // Início na tela de escolha de acesso
      initialRoute: '/choose-login',

      routes: {
        '/choose-login': (_) => const ChooseLoginPage(),
        '/login-user': (_) => const LoginUserPage(),
        '/register-user': (_) => const RegisterUserPage(),
        '/recover': (_) => const RecoverPasswordPage(),
      },

      // Caso alguma rota ainda não exista
      onUnknownRoute: (_) => MaterialPageRoute(
        builder: (_) => const ChooseLoginPage(),
      ),
    );
  }
}
