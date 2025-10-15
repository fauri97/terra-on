import 'package:app/pages/auth/register_user_page.dart';
import 'package:app/pages/feed_page.dart';
import 'package:app/pages/login/login_page.dart';
import 'package:go_router/go_router.dart';

import 'pages/explore_page.dart';
import 'pages/reports/new_report_page.dart';

class AppRouter {
  static const String login = '/login';
  static const String register = '/register';
  static const String main = '/main';
  static const String newReport = '/newreport';

  static final GoRouter router = GoRouter(
    initialLocation: main, // Página inicial do app
    routes: [
      GoRoute(
        path: login,
        name: 'login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: register,
        name: 'register',
        builder: (context, state) => const RegisterUserPage(),
      ),
      GoRoute(
        path: main,
        name: 'main',
        builder: (context, state) => const FeedPage(),
      ),
      GoRoute(
        path: newReport,
        name: 'newreport',
        builder: (context, state) => const NewReportPage(),
      ),
    ],
  );
}
