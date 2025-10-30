import 'package:flutter/material.dart';
import 'theme/app_theme.dart';

// Telas principais
import 'pages/choose_login_page.dart';
import 'auth/login_user_page.dart';
import 'auth/register_user_page.dart';
import 'auth/recover_password_page.dart';
import 'pages/explore_page.dart';
import 'reports/new_report_page.dart';

// Serviços globais
import 'services/service_locator.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupServiceLocator(); // <- aguarda se for async
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
      themeMode: ThemeMode.system,

      // 🏠 Tela inicial
      initialRoute: '/choose-login',

      // 🌐 Rotas principais
      routes: {
        '/choose-login': (context) => const ChooseLoginPage(),
        '/login-user': (context) => const LoginUserPage(),
        '/register-user': (context) => const RegisterUserPage(),
        '/recover': (context) => const RecoverPasswordPage(),
        '/explore': (context) => const ExplorePage(),
        '/new-report': (context) => const NewReportPage(),
      },

      // 🔄 Fallback — rota não encontrada
      onUnknownRoute: (settings) => MaterialPageRoute(
        builder: (_) => const ChooseLoginPage(),
      ),
    );
  }
}
