import 'package:app/pages/about_page.dart';
import 'package:app/pages/auth/register_user_page.dart';
import 'package:app/pages/login/login_page.dart';
import 'package:app/pages/profile/profile_page.dart';
import 'package:app/pages/reports/feed_page.dart';
import 'package:app/pages/terms_page.dart';
import 'package:app/services/service_locator.dart';
import 'package:go_router/go_router.dart';

import 'pages/reports/new_report_page.dart';

class AppRouter {
  static const String login = '/login';
  static const String register = '/register';
  static const String main = '/main';
  static const String newReport = '/newreport';
  static const String about = '/about';
  static const String terms = '/terms';
  static const String profile = '/profile';

  static final GoRouter router = GoRouter(
    initialLocation: main,
    navigatorKey: appNavigatorKey,
    routes: [
      GoRoute(
        path: login,
        name: 'login',
        builder: (context, state) => const LoginUserPage(),
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
      GoRoute(
        path: about,
        name: 'about',
        builder: (context, state) => const AboutPage(),
      ),
      GoRoute(
        path: terms,
        name: 'terms',
        builder: (context, state) => const TermsPage(),
      ),
      GoRoute(
        path: profile,
        name: 'profile',
        builder: (context, state) {
          return const ProfilePage();
        },
      ),
    ],
  );
}
