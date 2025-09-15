import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vet_biotics_admin/app_admin.dart';
import 'package:vet_biotics_auth/auth.dart';
import 'package:vet_biotics_core/core.dart';

import 'route_names.dart';
import 'route_paths.dart';

/// Admin-specific router for the Super Admin Panel
class AdminRouter {
  final AuthProvider _authProvider;

  AdminRouter(this._authProvider);

  GoRouter get router => GoRouter(
    initialLocation: RoutePaths.adminDashboard,
    debugLogDiagnostics: true,
    redirect: _handleRedirect,
    refreshListenable: _authProvider,
    routes: _buildRoutes(),
    errorBuilder: _buildErrorPage,
  );

  String? _handleRedirect(BuildContext context, GoRouterState state) {
    final user = _authProvider.currentUser;
    final isLoggedIn = _authProvider.isLoggedIn;

    // If not logged in, redirect to login
    if (!isLoggedIn) {
      return '/login';
    }

    // If logged in but not super admin, redirect to appropriate app
    if (user?.role != UserRole.superAdmin) {
      // This could redirect to user or clinic app based on role
      return '/login';
    }

    return null;
  }

  List<RouteBase> _buildRoutes() {
    return [
      // Admin Dashboard
      GoRoute(
        path: RoutePaths.adminDashboard,
        name: RouteNames.adminDashboard,
        builder: (context, state) => const DashboardScreen(),
      ),

      // Admin Clinics
      GoRoute(
        path: RoutePaths.adminClinics,
        name: RouteNames.adminClinics,
        builder: (context, state) => const ClinicsScreen(),
      ),

      // Admin Users
      GoRoute(
        path: RoutePaths.adminUsers,
        name: RouteNames.adminUsers,
        builder: (context, state) => const UserListScreen(),
        routes: [
          GoRoute(
            path: ':id',
            name: RouteNames.adminUserDetail,
            builder: (context, state) {
              final userId = state.pathParameters['id']!;
              return UserDetailScreen(userId: userId);
            },
          ),
        ],
      ),

      // Admin Analytics
      GoRoute(
        path: RoutePaths.adminAnalytics,
        name: RouteNames.adminAnalytics,
        builder: (context, state) => const AnalyticsScreen(),
      ),

      // Admin Settings
      GoRoute(
        path: RoutePaths.adminSettings,
        name: RouteNames.adminSettings,
        builder: (context, state) => const SettingsScreen(),
      ),

      // Login (for admin access)
      GoRoute(path: '/login', name: 'admin_login', builder: (context, state) => const LoginScreen()),
    ];
  }

  Widget _buildErrorPage(BuildContext context, GoRouterState state) {
    return Scaffold(
      appBar: AppBar(title: const Text('Error')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text('Page not found', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 8),
            Text('The page you are looking for does not exist.', style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go(RoutePaths.adminDashboard),
              child: const Text('Go to Dashboard'),
            ),
          ],
        ),
      ),
    );
  }
}
