import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/tasks/presentation/screens/manage_tasks_screen.dart';
import '../../features/rewards/presentation/screens/manage_rewards_screen.dart';
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
    GoRoute(
      path: '/manage-tasks/:childId',
      builder: (context, state) {
        final childId = state.pathParameters['childId']!;
        final extras = state.extra as Map<String, dynamic>;
        return ManageTasksScreen(
          parentId: extras['parentId'],
          childId: childId,
          childName: extras['childName'],
        );
      },
    ),
    GoRoute(
      path: '/manage-rewards/:parentId',
      builder: (context, state) {
        final parentId = state.pathParameters['parentId']!;
        return ManageRewardsScreen(parentId: parentId);
      },
    ),
  ],
);
