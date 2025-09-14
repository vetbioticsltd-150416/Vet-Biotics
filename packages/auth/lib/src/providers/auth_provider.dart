import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vet_biotics_core/core.dart';

import '../services/firebase_auth_service.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthProvider extends ChangeNotifier {
  final FirebaseAuthService _authService;
  final SharedPreferences _prefs;

  AuthStatus _status = AuthStatus.initial;
  String? _errorMessage;
  User? _currentUser;

  AuthProvider(this._prefs, {FirebaseAuthService? authService}) : _authService = authService ?? FirebaseAuthService() {
    _init();
  }

  AuthStatus get status => _status;
  String? get errorMessage => _errorMessage;
  User? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;

  void _init() {
    _authService.authStateChanges.listen((User? user) {
      _currentUser = user;
      _status = user != null ? AuthStatus.authenticated : AuthStatus.unauthenticated;
      notifyListeners();

      if (user != null) {
        _saveUserSession(user);
      } else {
        _clearUserSession();
      }
    });
  }

  Future<void> signInWithEmailAndPassword(String email, String password) async {
    try {
      _setLoading();
      await _authService.signInWithEmailAndPassword(email: email, password: password);
    } on AuthException catch (e) {
      _setError(e.message);
    } catch (e) {
      _setError('An unexpected error occurred');
    }
  }

  Future<void> signUpWithEmailAndPassword(String email, String password) async {
    try {
      _setLoading();
      final result = await _authService.createUserWithEmailAndPassword(email: email, password: password);

      // Send email verification
      await _authService.sendEmailVerification();
    } on AuthException catch (e) {
      _setError(e.message);
    } catch (e) {
      _setError('An unexpected error occurred');
    }
  }

  Future<void> signInWithGoogle() async {
    try {
      _setLoading();
      await _authService.signInWithGoogle();
    } on AuthException catch (e) {
      _setError(e.message);
    } catch (e) {
      _setError('Failed to sign in with Google');
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      _setLoading();
      await _authService.sendPasswordResetEmail(email);
      _status = AuthStatus.initial; // Reset to initial state
      notifyListeners();
    } on AuthException catch (e) {
      _setError(e.message);
    } catch (e) {
      _setError('Failed to send password reset email');
    }
  }

  Future<void> sendEmailVerification() async {
    try {
      _setLoading();
      await _authService.sendEmailVerification();
      _status = AuthStatus.initial;
      notifyListeners();
    } on AuthException catch (e) {
      _setError(e.message);
    } catch (e) {
      _setError('Failed to send email verification');
    }
  }

  Future<void> reloadUser() async {
    try {
      await _authService.reload();
      _currentUser = _authService.currentUser;
      notifyListeners();
    } catch (e) {
      _setError('Failed to reload user data');
    }
  }

  Future<void> signOut() async {
    try {
      await _authService.signOut();
    } on AuthException catch (e) {
      _setError(e.message);
    } catch (e) {
      _setError('Failed to sign out');
    }
  }

  void _setLoading() {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();
  }

  void _setError(String message) {
    _status = AuthStatus.error;
    _errorMessage = message;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> _saveUserSession(User user) async {
    try {
      await _prefs.setString('user_id', user.uid);
      await _prefs.setString('user_email', user.email ?? '');
      await _prefs.setBool('email_verified', user.emailVerified);
    } catch (e) {
      // Handle storage error silently
    }
  }

  Future<void> _clearUserSession() async {
    try {
      await _prefs.remove('user_id');
      await _prefs.remove('user_email');
      await _prefs.remove('email_verified');
    } catch (e) {
      // Handle storage error silently
    }
  }
}
