import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/auth/presentation/screens/parent_dashboard_screen.dart';
import '../../features/tasks/presentation/child_dashboard_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/login',
  routes: [
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/parent-dashboard',
      builder: (context, state) => const ParentDashboardScreen(),
    ),
    GoRoute(
      path: '/child-dashboard',
      builder: (context, state) => const ChildDashboardScreen(),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterScreen(),
    ),
  ],
);
