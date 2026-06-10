import 'package:go_router/go_router.dart';
import '../../features/venue/presentation/pages/home_page.dart';
import '../../features/auth/presentation/pages/profile_page.dart';

class AppRoutes {
  static const String home = '/';
  static const String profile = '/profile';
}

final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.home,
  routes: [
    GoRoute(
      path: AppRoutes.home,
      builder: (context, state) => const HomePage(),
    ),
    GoRoute(
      path: AppRoutes.profile,
      builder: (context, state) => const ProfilePage(),
    ),
  ],
);
