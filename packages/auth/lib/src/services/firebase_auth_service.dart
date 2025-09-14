import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:vet_biotics_core/core.dart';

/// Service for Firebase Authentication operations
class FirebaseAuthService {
  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;

  FirebaseAuthService({FirebaseAuth? firebaseAuth, GoogleSignIn? googleSignIn})
    : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
      _googleSignIn = googleSignIn ?? GoogleSignIn();

  /// Stream of authentication state changes
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  /// Current user
  User? get currentUser => _firebaseAuth.currentUser;

  /// Sign in with email and password
  Future<UserCredential> signInWithEmailAndPassword({required String email, required String password}) async {
    try {
      return await _firebaseAuth.signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthException(e);
    }
  }

  /// Create user with email and password
  Future<UserCredential> createUserWithEmailAndPassword({required String email, required String password}) async {
    try {
      return await _firebaseAuth.createUserWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthException(e);
    }
  }

  /// Sign in with Google
  Future<UserCredential> signInWithGoogle() async {
    try {
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        throw AuthException('Google sign in was cancelled');
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Once signed in, return the UserCredential
      return await _firebaseAuth.signInWithCredential(credential);
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException('Failed to sign in with Google: ${e.toString()}');
    }
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      await Future.wait([_firebaseAuth.signOut(), _googleSignIn.signOut()]);
    } catch (e) {
      throw AuthException('Failed to sign out: ${e.toString()}');
    }
  }

  /// Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthException(e);
    }
  }

  /// Verify email
  Future<void> sendEmailVerification() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
      }
    } catch (e) {
      throw AuthException('Failed to send email verification: ${e.toString()}');
    }
  }

  /// Reload current user
  Future<void> reload() async {
    try {
      await _firebaseAuth.currentUser?.reload();
    } catch (e) {
      throw AuthException('Failed to reload user: ${e.toString()}');
    }
  }

  /// Update user display name
  Future<void> updateDisplayName(String displayName) async {
    try {
      await _firebaseAuth.currentUser?.updateDisplayName(displayName);
    } catch (e) {
      throw AuthException('Failed to update display name: ${e.toString()}');
    }
  }

  /// Update user email
  Future<void> updateEmail(String email) async {
    try {
      await _firebaseAuth.currentUser?.updateEmail(email);
    } catch (e) {
      throw AuthException('Failed to update email: ${e.toString()}');
    }
  }

  /// Update password
  Future<void> updatePassword(String password) async {
    try {
      await _firebaseAuth.currentUser?.updatePassword(password);
    } catch (e) {
      throw AuthException('Failed to update password: ${e.toString()}');
    }
  }

  /// Delete user account
  Future<void> deleteAccount() async {
    try {
      await _firebaseAuth.currentUser?.delete();
    } catch (e) {
      throw AuthException('Failed to delete account: ${e.toString()}');
    }
  }

  /// Handle Firebase Auth exceptions
  AuthException _handleFirebaseAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-disabled':
        return AuthException('This user account has been disabled');
      case 'user-not-found':
        return AuthException('No user found with this email');
      case 'wrong-password':
        return AuthException('Wrong password provided');
      case 'email-already-in-use':
        return AuthException('An account already exists with this email');
      case 'invalid-email':
        return AuthException('Invalid email address');
      case 'weak-password':
        return AuthException('Password is too weak');
      case 'operation-not-allowed':
        return AuthException('This sign-in method is not enabled');
      case 'requires-recent-login':
        return AuthException('Please re-authenticate to perform this action');
      case 'too-many-requests':
        return AuthException('Too many requests. Please try again later');
      default:
        return AuthException('Authentication error: ${e.message}');
    }
  }
}

/// Custom exception for authentication errors
class AuthException implements Exception {
  final String message;

  AuthException(this.message);

  @override
  String toString() => message;
}
