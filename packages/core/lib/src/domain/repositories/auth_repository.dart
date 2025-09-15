import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../entities/user.dart';

/// Repository interface for authentication operations
abstract class AuthRepository {
  /// Sign in with email and password
  Future<Either<Failure, User>> signInWithEmailAndPassword(String email, String password);

  /// Sign up with email and password
  Future<Either<Failure, User>> signUpWithEmailAndPassword(String email, String password, String displayName);

  /// Sign in with Google
  Future<Either<Failure, User>> signInWithGoogle();

  /// Sign out
  Future<Either<Failure, void>> signOut();

  /// Get current user
  Future<Either<Failure, User?>> getCurrentUser();

  /// Send password reset email
  Future<Either<Failure, void>> sendPasswordResetEmail(String email);

  /// Verify email
  Future<Either<Failure, void>> verifyEmail();

  /// Check if user is authenticated
  Future<Either<Failure, bool>> isAuthenticated();

  /// Update user profile
  Future<Either<Failure, User>> updateUserProfile(User user);

  /// Change password
  Future<Either<Failure, void>> changePassword(String currentPassword, String newPassword);

  /// Delete user account
  Future<Either<Failure, void>> deleteAccount();

  /// Refresh authentication token
  Future<Either<Failure, String>> refreshToken();
}
