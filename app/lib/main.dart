import 'package:flutter/material.dart';

// pages
import 'admin/admin_dashboard_page.dart';
import 'auth/login_admin_page.dart';
import 'auth/login_user_page.dart';
import 'auth/recover_password_page.dart';
import 'auth/register_user_page.dart';
import 'pages/about_page.dart';
import 'pages/choose_login_page.dart';
import 'pages/explore_page.dart';
import 'profile/profile_page.dart';
import 'reports/my_reports_page.dart';
import 'reports/new_report_page.dart';
import 'reports/report_detail_page.dart';

void main() {
  runApp(const TerraOnDemo());
}

class TerraOnDemo extends StatelessWidget {
  const TerraOnDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'TerraON Demo',
      theme: ThemeData(useMaterial3: true),
      home: const DemoMenuPage(),
      routes: {
        '/admin-dashboard': (_) => const AdminDashboardPage(),
        '/login-admin': (_) => const LoginAdminPage(),
        '/login-user': (_) => const LoginUserPage(),
        '/recover-password': (_) => const RecoverPasswordPage(),
        '/register-user': (_) => const RegisterUserPage(),
        '/about': (_) => const AboutPage(),
        '/choose-login': (_) => const ChooseLoginPage(),
        '/explore': (_) => const ExplorePage(),
        '/profile': (_) => const ProfilePage(),
        '/my-reports': (_) => const MyReportsPage(),
        '/new-report': (_) => const NewReportPage(),
        '/report-detail': (_) => const ReportDetailPage(), // SEM PARAMETRO
      },
    );
  }
}

class DemoMenuPage extends StatelessWidget {
  const DemoMenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    final routes = {
      'Admin dashboard': '/admin-dashboard',
      'Login admin': '/login-admin',
      'Login user': '/login-user',
      'Recuperar senha': '/recover-password',
      'Registro de usuário': '/register-user',
      'Sobre': '/about',
      'Escolha login': '/choose-login',
      'Explorar': '/explore',
      'Perfil': '/profile',
      'Minhas denúncias': '/my-reports',
      'Nova denúncia': '/new-report',
      'Detalhe denúncia (demo)': '/report-detail',
    };

    return Scaffold(
      appBar: AppBar(title: const Text('MENU PRINTS')),
      body: ListView(
        children: routes.entries.map((e) {
          return ListTile(
            title: Text(e.key),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () => Navigator.pushNamed(context, e.value),
          );
        }).toList(),
      ),
    );
  }
}
