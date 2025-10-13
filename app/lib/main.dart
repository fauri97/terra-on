import 'package:flutter/material.dart';
import 'theme/app_theme.dart';

// Telas do fluxo de autenticação (PF)
import 'pages/choose_login_page.dart';
import 'auth/login_user_page.dart';
import 'auth/register_user_page.dart';
import 'auth/recover_password_page.dart';

// Serviços (inicialização de singletons locais)
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

      initialRoute: '/choose-login',

      routes: {
        '/choose-login': (_) => const ChooseLoginPage(),
        '/login-user': (_) => const LoginUserPage(),
        '/register-user': (_) => const RegisterUserPage(),
        '/recover': (_) => const RecoverPasswordPage(),
      },

      // Fallback: volta para a tela inicial do fluxo
      onUnknownRoute: (_) => MaterialPageRoute(
        builder: (_) => const ChooseLoginPage(),
      ),
    );
  }
}
