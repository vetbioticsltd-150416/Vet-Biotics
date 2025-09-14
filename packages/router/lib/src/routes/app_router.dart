// Import app screens for routing
import 'package:app_user/app_user.dart' as app_user;
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:router/src/guards/auth_guard.dart';
import 'package:router/src/guards/role_guard.dart';
import 'package:router/src/routes/route_names.dart';
import 'package:router/src/routes/route_paths.dart';

/// Main router configuration for the application
class AppRouter {
  final AuthRepository _authRepository;

  AppRouter(this._authRepository);

  late final GoRouter router = GoRouter(
    initialLocation: RoutePaths.home,
    debugLogDiagnostics: true,
    redirect: _handleRedirect,
    refreshListenable: _authRepository,
    routes: _buildRoutes(),
    errorBuilder: _buildErrorPage,
    observers: [
      // Add navigation observers here
    ],
  );

  /// Handle global redirects based on authentication state
  String? _handleRedirect(BuildContext context, GoRouterState state) {
    final isLoggedIn = _authRepository.isLoggedIn;
    final isAuthRoute = _isAuthRoute(state.uri.toString());
    final isPublicRoute = _isPublicRoute(state.uri.toString());

    // If user is not logged in and trying to access protected route
    if (!isLoggedIn && !isAuthRoute && !isPublicRoute) {
      return RoutePaths.login;
    }

    // If user is logged in and trying to access auth routes
    if (isLoggedIn && isAuthRoute) {
      return RoutePaths.home;
    }

    return null;
  }

  /// Check if route is an authentication route
  bool _isAuthRoute(String location) {
    return location.startsWith('/login') ||
        location.startsWith('/register') ||
        location.startsWith('/forgot-password') ||
        location.startsWith('/reset-password') ||
        location.startsWith('/verify-email');
  }

  /// Check if route is a public route (accessible without login)
  bool _isPublicRoute(String location) {
    return location == RoutePaths.home ||
        location.startsWith('/help') ||
        location.startsWith('/about') ||
        location == RoutePaths.notFound ||
        location == RoutePaths.error ||
        location == RoutePaths.maintenance;
  }

  /// Build all application routes
  List<RouteBase> _buildRoutes() {
    return [
      // Public routes
      GoRoute(path: RoutePaths.home, name: RouteNames.home, builder: _buildHomePage),

      // Auth routes
      GoRoute(path: RoutePaths.login, name: RouteNames.login, builder: _buildLoginPage),
      GoRoute(path: RoutePaths.register, name: RouteNames.register, builder: _buildRegisterPage),
      GoRoute(path: RoutePaths.forgotPassword, name: RouteNames.forgotPassword, builder: _buildForgotPasswordPage),
      GoRoute(path: RoutePaths.resetPassword, name: RouteNames.resetPassword, builder: _buildResetPasswordPage),

      // Protected routes (require authentication)
      GoRoute(
        path: RoutePaths.dashboard,
        name: RouteNames.dashboard,
        builder: _buildDashboardPage,
        redirect: (context, state) => AuthGuard.redirect(context, state),
      ),

      GoRoute(
        path: RoutePaths.profile,
        name: RouteNames.profile,
        builder: _buildProfilePage,
        redirect: (context, state) => AuthGuard.redirect(context, state),
      ),

      GoRoute(
        path: RoutePaths.settings,
        name: RouteNames.settings,
        builder: _buildSettingsPage,
        redirect: (context, state) => AuthGuard.redirect(context, state),
      ),

      // Pet routes
      GoRoute(
        path: RoutePaths.pets,
        name: RouteNames.pets,
        builder: _buildPetsPage,
        redirect: (context, state) => AuthGuard.redirect(context, state),
        routes: [
          GoRoute(path: 'add', name: RouteNames.addPet, builder: _buildAddPetPage),
          GoRoute(
            path: ':id',
            name: RouteNames.petDetail,
            builder: _buildPetDetailPage,
            routes: [GoRoute(path: 'edit', name: RouteNames.editPet, builder: _buildEditPetPage)],
          ),
        ],
      ),

      // Appointment routes
      GoRoute(
        path: RoutePaths.appointments,
        name: RouteNames.appointments,
        builder: _buildAppointmentsPage,
        redirect: (context, state) => AuthGuard.redirect(context, state),
        routes: [
          GoRoute(path: 'book', name: RouteNames.bookAppointment, builder: _buildBookAppointmentPage),
          GoRoute(
            path: ':id',
            name: RouteNames.appointmentDetail,
            builder: _buildAppointmentDetailPage,
            routes: [GoRoute(path: 'edit', name: RouteNames.editAppointment, builder: _buildEditAppointmentPage)],
          ),
        ],
      ),

      // Medical routes
      GoRoute(
        path: RoutePaths.medicalRecords,
        name: RouteNames.medicalRecords,
        builder: _buildMedicalRecordsPage,
        redirect: (context, state) => AuthGuard.redirect(context, state),
        routes: [
          GoRoute(path: 'add', name: RouteNames.addMedicalRecord, builder: _buildAddMedicalRecordPage),
          GoRoute(path: ':id', name: RouteNames.medicalRecordDetail, builder: _buildMedicalRecordDetailPage),
        ],
      ),

      // Clinic routes (require clinic access)
      GoRoute(
        path: RoutePaths.clinics,
        name: RouteNames.clinics,
        builder: _buildClinicsPage,
        redirect: (context, state) =>
            RoleGuard.redirect(context, state, allowedRoles: [UserRole.doctor, UserRole.staff, UserRole.admin]),
        routes: [
          GoRoute(
            path: ':id',
            name: RouteNames.clinicDetail,
            builder: _buildClinicDetailPage,
            routes: [
              GoRoute(path: 'dashboard', name: RouteNames.clinicDashboard, builder: _buildClinicDashboardPage),
              GoRoute(path: 'settings', name: RouteNames.clinicSettings, builder: _buildClinicSettingsPage),
            ],
          ),
        ],
      ),

      // Admin routes (require admin access)
      GoRoute(
        path: RoutePaths.admin,
        name: RouteNames.admin,
        redirect: (context, state) => RoleGuard.redirect(context, state, allowedRoles: [UserRole.admin]),
        routes: [
          GoRoute(path: 'dashboard', name: RouteNames.adminDashboard, builder: _buildAdminDashboardPage),
          GoRoute(path: 'users', name: RouteNames.adminUsers, builder: _buildAdminUsersPage),
          GoRoute(path: 'clinics', name: RouteNames.adminClinics, builder: _buildAdminClinicsPage),
          GoRoute(path: 'analytics', name: RouteNames.adminAnalytics, builder: _buildAdminAnalyticsPage),
          GoRoute(path: 'settings', name: RouteNames.adminSettings, builder: _buildAdminSettingsPage),
        ],
      ),

      // Common routes
      GoRoute(
        path: RoutePaths.notifications,
        name: RouteNames.notifications,
        builder: _buildNotificationsPage,
        redirect: (context, state) => AuthGuard.redirect(context, state),
      ),

      GoRoute(
        path: RoutePaths.search,
        name: RouteNames.search,
        builder: _buildSearchPage,
        redirect: (context, state) => AuthGuard.redirect(context, state),
      ),

      GoRoute(path: RoutePaths.help, name: RouteNames.help, builder: _buildHelpPage),

      GoRoute(path: RoutePaths.about, name: RouteNames.about, builder: _buildAboutPage),
    ];
  }

  // Page builders (these would be implemented in respective apps/packages)
  Widget _buildHomePage(BuildContext context, GoRouterState state) =>
      const Placeholder(); // Implement in app_user/app_clinic/app_admin

  Widget _buildLoginPage(BuildContext context, GoRouterState state) => const Placeholder();

  Widget _buildRegisterPage(BuildContext context, GoRouterState state) => const Placeholder();

  Widget _buildForgotPasswordPage(BuildContext context, GoRouterState state) => const Placeholder();

  Widget _buildResetPasswordPage(BuildContext context, GoRouterState state) => const Placeholder();

  Widget _buildDashboardPage(BuildContext context, GoRouterState state) => const Placeholder();

  Widget _buildProfilePage(BuildContext context, GoRouterState state) => const Placeholder();

  Widget _buildSettingsPage(BuildContext context, GoRouterState state) => const Placeholder();

  Widget _buildPetsPage(BuildContext context, GoRouterState state) => const Placeholder();

  Widget _buildAddPetPage(BuildContext context, GoRouterState state) => const Placeholder();

  Widget _buildPetDetailPage(BuildContext context, GoRouterState state) => const Placeholder();

  Widget _buildEditPetPage(BuildContext context, GoRouterState state) => const Placeholder();

  Widget _buildAppointmentsPage(BuildContext context, GoRouterState state) => const app_user.AppointmentsScreen();

  Widget _buildBookAppointmentPage(BuildContext context, GoRouterState state) => const app_user.BookAppointmentScreen();

  Widget _buildAppointmentDetailPage(BuildContext context, GoRouterState state) => const Placeholder();

  Widget _buildEditAppointmentPage(BuildContext context, GoRouterState state) => const Placeholder();

  Widget _buildMedicalRecordsPage(BuildContext context, GoRouterState state) => const Placeholder();

  Widget _buildAddMedicalRecordPage(BuildContext context, GoRouterState state) => const Placeholder();

  Widget _buildMedicalRecordDetailPage(BuildContext context, GoRouterState state) => const Placeholder();

  Widget _buildClinicsPage(BuildContext context, GoRouterState state) => const Placeholder();

  Widget _buildClinicDetailPage(BuildContext context, GoRouterState state) => const Placeholder();

  Widget _buildClinicDashboardPage(BuildContext context, GoRouterState state) => const Placeholder();

  Widget _buildClinicSettingsPage(BuildContext context, GoRouterState state) => const Placeholder();

  Widget _buildAdminDashboardPage(BuildContext context, GoRouterState state) => const Placeholder();

  Widget _buildAdminUsersPage(BuildContext context, GoRouterState state) => const Placeholder();

  Widget _buildAdminClinicsPage(BuildContext context, GoRouterState state) => const Placeholder();

  Widget _buildAdminAnalyticsPage(BuildContext context, GoRouterState state) => const Placeholder();

  Widget _buildAdminSettingsPage(BuildContext context, GoRouterState state) => const Placeholder();

  Widget _buildNotificationsPage(BuildContext context, GoRouterState state) => const Placeholder();

  Widget _buildSearchPage(BuildContext context, GoRouterState state) => const Placeholder();

  Widget _buildHelpPage(BuildContext context, GoRouterState state) => const Placeholder();

  Widget _buildAboutPage(BuildContext context, GoRouterState state) => const Placeholder();

  Widget _buildErrorPage(BuildContext context, GoRouterState state) => const Placeholder(); // Implement error page
}

/// Extension methods for GoRouter
extension GoRouterExtension on GoRouter {
  /// Navigate with error handling
  void safeGo(String location, {Object? extra}) {
    try {
      go(location, extra: extra);
    } catch (e) {
      // Handle navigation errors
      debugPrint('Navigation error: $e');
    }
  }

  /// Push with error handling
  void safePush(String location, {Object? extra}) {
    try {
      push(location, extra: extra);
    } catch (e) {
      // Handle navigation errors
      debugPrint('Navigation error: $e');
    }
  }
}
