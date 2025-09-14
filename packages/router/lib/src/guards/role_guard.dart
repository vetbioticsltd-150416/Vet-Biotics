import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:core/core.dart';
import 'package:router/src/routes/route_paths.dart';

/// Role-based access guard for routes
class RoleGuard {
  final AuthRepository _authRepository;

  RoleGuard(this._authRepository);

  /// Static redirect method for use in GoRouter
  static String? redirect(BuildContext context, GoRouterState state, {required List<UserRole> allowedRoles}) {
    // First check if user is authenticated
    final authGuard = AuthGuard(
      AuthRepositoryImpl(
        remoteDataSource: AuthRemoteDataSourceImpl(),
        localDataSource: AuthLocalDataSourceImpl(),
        networkInfo: NetworkInfoImpl(),
      ),
    );

    final authRedirect = AuthGuard.redirect(context, state);
    if (authRedirect != null) {
      return authRedirect;
    }

    // Check user role
    final roleGuard = RoleGuard(
      AuthRepositoryImpl(
        remoteDataSource: AuthRemoteDataSourceImpl(),
        localDataSource: AuthLocalDataSourceImpl(),
        networkInfo: NetworkInfoImpl(),
      ),
    );

    final hasAccess = roleGuard.hasAnyRole(allowedRoles);
    if (!hasAccess) {
      return RoutePaths.home; // Or show access denied page
    }

    return null;
  }

  /// Check if current user has any of the allowed roles
  Future<bool> hasAnyRole(List<UserRole> roles) async {
    try {
      final user = await _authRepository.getCurrentUser();
      if (user == null) return false;

      return roles.contains(user.role);
    } catch (e) {
      return false;
    }
  }

  /// Check if current user has specific role
  Future<bool> hasRole(UserRole role) async {
    return hasAnyRole([role]);
  }

  /// Check if current user is admin
  Future<bool> isAdmin() async {
    return hasRole(UserRole.admin);
  }

  /// Check if current user can access clinic features
  Future<bool> canAccessClinic() async {
    return hasAnyRole([UserRole.admin, UserRole.doctor, UserRole.staff]);
  }

  /// Check if current user is clinic staff
  Future<bool> isClinicStaff() async {
    return hasAnyRole([UserRole.doctor, UserRole.staff]);
  }

  /// Check if current user is doctor
  Future<bool> isDoctor() async {
    return hasRole(UserRole.doctor);
  }

  /// Check if current user is client
  Future<bool> isClient() async {
    return hasRole(UserRole.client);
  }

  /// Get current user role
  Future<UserRole?> getCurrentUserRole() async {
    try {
      final user = await _authRepository.getCurrentUser();
      return user?.role;
    } catch (e) {
      return null;
    }
  }
}

/// Permission-based access guard
class PermissionGuard {
  final AuthRepository _authRepository;
  final UserRepository _userRepository;

  PermissionGuard(this._authRepository, this._userRepository);

  /// Check if user has specific permission
  Future<bool> hasPermission(String permission) async {
    try {
      final user = await _authRepository.getCurrentUser();
      if (user == null) return false;

      // For clinic staff, check clinic-specific permissions
      if (user.role == UserRole.doctor || user.role == UserRole.staff) {
        // This would check against clinic staff permissions
        // Implementation depends on how permissions are stored
        return true; // Simplified
      }

      // For admin, allow all
      if (user.role == UserRole.admin) {
        return true;
      }

      // For clients, check client permissions
      return _hasClientPermission(user, permission);
    } catch (e) {
      return false;
    }
  }

  /// Check if user has all permissions
  Future<bool> hasAllPermissions(List<String> permissions) async {
    for (final permission in permissions) {
      if (!await hasPermission(permission)) {
        return false;
      }
    }
    return true;
  }

  /// Check if user has any permission
  Future<bool> hasAnyPermission(List<String> permissions) async {
    for (final permission in permissions) {
      if (await hasPermission(permission)) {
        return true;
      }
    }
    return false;
  }

  bool _hasClientPermission(User user, String permission) {
    // Define client permissions
    const clientPermissions = [
      'view_own_pets',
      'book_appointments',
      'view_own_appointments',
      'view_own_medical_records',
      'update_profile',
    ];

    return clientPermissions.contains(permission);
  }
}

/// Route permission requirements
class RoutePermission {
  final List<String> requiredPermissions;
  final List<UserRole> allowedRoles;
  final bool requiresAuthentication;

  const RoutePermission({
    this.requiredPermissions = const [],
    this.allowedRoles = const [],
    this.requiresAuthentication = true,
  });

  /// Check if access is allowed
  Future<bool> isAllowed(AuthRepository authRepo, UserRepository userRepo) async {
    if (requiresAuthentication) {
      final isAuthenticated = authRepo.isLoggedIn;
      if (!isAuthenticated) return false;
    }

    if (allowedRoles.isNotEmpty) {
      final roleGuard = RoleGuard(authRepo);
      final hasRole = await roleGuard.hasAnyRole(allowedRoles);
      if (!hasRole) return false;
    }

    if (requiredPermissions.isNotEmpty) {
      final permissionGuard = PermissionGuard(authRepo, userRepo);
      final hasPermission = await permissionGuard.hasAllPermissions(requiredPermissions);
      if (!hasPermission) return false;
    }

    return true;
  }
}
