import 'package:dartz/dartz.dart';

import '../../core/error/failures.dart';
import '../entities/user.dart' show User, UserRole;
import '../entities/user_management.dart' show UserProfile, UserActivity, NotificationPreferences, PasswordResetToken;

/// Repository interface for user operations
abstract class UserRepository {
  /// Get user by ID
  Future<Either<Failure, User>> getUserById(String userId);

  /// Get all users (admin only)
  Future<Either<Failure, List<User>>> getAllUsers();

  /// Search users by name or email
  Future<Either<Failure, List<User>>> searchUsers(String query);

  /// Update user information
  Future<Either<Failure, User>> updateUser(User user);

  /// Delete user
  Future<Either<Failure, void>> deleteUser(String userId);

  /// Get users by role
  Future<Either<Failure, List<User>>> getUsersByRole(UserRole role);

  /// Get users by clinic
  Future<Either<Failure, List<User>>> getUsersByClinic(String clinicId);

  /// Update user role
  Future<Either<Failure, void>> updateUserRole(String userId, UserRole newRole);

  /// Deactivate user
  Future<Either<Failure, void>> deactivateUser(String userId);

  /// Reactivate user
  Future<Either<Failure, void>> reactivateUser(String userId);

  /// Get user profile
  Future<Either<Failure, UserProfile>> getUserProfile(String userId);

  /// Update user profile
  Future<Either<Failure, void>> updateUserProfile(String userId, Map<String, dynamic> updates);

  /// Get user activities
  Future<Either<Failure, List<UserActivity>>> getUserActivities(String userId, {int limit = 50});

  /// Log user activity
  Future<Either<Failure, void>> logUserActivity(UserActivity activity);

  /// Get notification preferences
  Future<Either<Failure, NotificationPreferences>> getNotificationPreferences(String userId);

  /// Update notification preferences
  Future<Either<Failure, void>> updateNotificationPreferences(String userId, NotificationPreferences preferences);

  /// Create password reset token
  Future<Either<Failure, PasswordResetToken>> createPasswordResetToken(String email);

  /// Verify password reset token
  Future<Either<Failure, bool>> verifyPasswordResetToken(String token);

  /// Use password reset token
  Future<Either<Failure, void>> usePasswordResetToken(String token, String newPassword);

  /// Get user statistics
  Future<Either<Failure, Map<String, dynamic>>> getUserStatistics();
}
