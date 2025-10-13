import 'package:flutter/material.dart';
import 'theme/app_theme.dart';

// Tela alvo desta branch
import 'reports/new_report_page.dart';

// Infra compartilhada usada pela UI
import 'widgets/app_navbar.dart';
import 'widgets/app_footer.dart';
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

      // Nesta branch, abrimos direto a Nova Denúncia
      initialRoute: '/new-report',

      routes: {
        '/new-report': (_) => const NewReportPage(),
      },

      // Fallback: volta para a própria tela alvo desta branch
      onUnknownRoute: (_) => MaterialPageRoute(
        builder: (_) => const NewReportPage(),
      ),
    );
  }
}
