import 'package:equatable/equatable.dart';

/// Base failure class
abstract class Failure extends Equatable {
  final String message;
  final String? code;

  const Failure(this.message, {this.code});

  @override
  List<Object?> get props => [message, code];
}

/// Server failure
class ServerFailure extends Failure {
  const ServerFailure(super.message, {super.code});

  factory ServerFailure.network() => const ServerFailure('Network connection failed');
  factory ServerFailure.server() => const ServerFailure('Server error occurred');
  factory ServerFailure.timeout() => const ServerFailure('Request timeout');
}

/// Cache failure
class CacheFailure extends Failure {
  const CacheFailure(super.message, {super.code});

  factory CacheFailure.notFound() => const CacheFailure('Data not found in cache');
  factory CacheFailure.storage() => const CacheFailure('Storage operation failed');
}

/// Validation failure
class ValidationFailure extends Failure {
  const ValidationFailure(super.message, {super.code});

  factory ValidationFailure.invalidData() => const ValidationFailure('Invalid data provided');
  factory ValidationFailure.requiredField() => const ValidationFailure('Required field is missing');
}

/// Authentication failure
class AuthFailure extends Failure {
  const AuthFailure(super.message, {super.code});

  factory AuthFailure.invalidCredentials() => const AuthFailure('Invalid credentials');
  factory AuthFailure.unauthorized() => const AuthFailure('Unauthorized access');
  factory AuthFailure.sessionExpired() => const AuthFailure('Session expired');
}

/// Permission failure
class PermissionFailure extends Failure {
  const PermissionFailure(super.message, {super.code});

  factory PermissionFailure.insufficient() => const PermissionFailure('Insufficient permissions');
  factory PermissionFailure.forbidden() => const PermissionFailure('Access forbidden');
}

/// Not found failure
class NotFoundFailure extends Failure {
  const NotFoundFailure(super.message, {super.code});

  factory NotFoundFailure.entity() => const NotFoundFailure('Entity not found');
}

/// Conflict failure
class ConflictFailure extends Failure {
  const ConflictFailure(super.message, {super.code});

  factory ConflictFailure.duplicate() => const ConflictFailure('Duplicate entry');
  factory ConflictFailure.version() => const ConflictFailure('Version conflict');
}


