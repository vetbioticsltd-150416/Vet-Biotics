import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:router/src/routes/route_paths.dart';

/// Authentication guard for protected routes
class AuthGuard {
  final AuthRepository _authRepository;

  AuthGuard(this._authRepository);

  /// Static redirect method for use in GoRouter
  static String? redirect(BuildContext context, GoRouterState state) {
    // Get auth repository from provider or service locator
    // This is a simplified implementation - in real app you'd inject this
    final authRepository = AuthRepositoryImpl(
      remoteDataSource: AuthRemoteDataSourceImpl(),
      localDataSource: AuthLocalDataSourceImpl(),
      networkInfo: NetworkInfoImpl(),
    );

    final isLoggedIn = authRepository.isLoggedIn;

    if (!isLoggedIn) {
      // Store the attempted location for redirect after login
      final attemptedLocation = state.uri.toString();
      return attemptedLocation != RoutePaths.login ? RoutePaths.login : null;
    }

    return null;
  }

  /// Check if user is authenticated
  Future<bool> isAuthenticated() async {
    return _authRepository.isLoggedIn;
  }

  /// Get current user
  Future<User?> getCurrentUser() async {
    return _authRepository.getCurrentUser();
  }

  /// Logout user
  Future<void> logout() async {
    await _authRepository.logout();
  }
}

/// Authentication state listener
class AuthStateListener extends ChangeNotifier {
  final AuthRepository _authRepository;
  bool _isAuthenticated = false;

  AuthStateListener(this._authRepository) {
    _init();
  }

  bool get isAuthenticated => _isAuthenticated;

  void _init() {
    _checkAuthStatus();
    // Listen to auth state changes
    _authRepository.authStateChanges.listen((user) {
      _isAuthenticated = user != null;
      notifyListeners();
    });
  }

  Future<void> _checkAuthStatus() async {
    _isAuthenticated = _authRepository.isLoggedIn;
    notifyListeners();
  }
}
