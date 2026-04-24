import 'package:go_router/go_router.dart';
import 'package:focuszen/screens/home_page.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: AppRoutes.home,
    routes: [
      GoRoute(
        path: AppRoutes.home,
        name: 'home',
        pageBuilder: (context, state) => const NoTransitionPage(child: HomePage()),
      ),
    ],
  );
}

class AppRoutes {
  static const String home = '/';
}
