import 'package:equatable/equatable.dart';

/// Base entity class that all domain entities should extend
/// Provides common functionality like ID, timestamps, and validation
abstract class BaseEntity extends Equatable {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;

  const BaseEntity({required this.id, required this.createdAt, required this.updatedAt, this.isActive = true});

  /// Create a copy with modified properties
  BaseEntity copyWith({String? id, DateTime? createdAt, DateTime? updatedAt, bool? isActive});

  /// Convert to JSON for serialization
  Map<String, dynamic> toJson();

  /// Create from JSON
  factory BaseEntity.fromJson(Map<String, dynamic> json) {
    throw UnimplementedError('fromJson must be implemented by subclasses');
  }

  /// Validate entity data
  bool get isValid;

  /// Get list of properties for Equatable comparison
  @override
  List<Object?> get props => [id, createdAt, updatedAt, isActive];

  /// Get string representation
  @override
  String toString() {
    return '$runtimeType(id: $id, createdAt: $createdAt, updatedAt: $updatedAt, isActive: $isActive)';
  }
}

/// Auditable entity that tracks creation and modification metadata
abstract class AuditableEntity extends BaseEntity {
  final String? createdBy;
  final String? updatedBy;

  const AuditableEntity({
    required super.id,
    required super.createdAt,
    required super.updatedAt,
    super.isActive,
    this.createdBy,
    this.updatedBy,
  });

  @override
  AuditableEntity copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
    String? createdBy,
    String? updatedBy,
  });

  @override
  Map<String, dynamic> toJson();

  @override
  List<Object?> get props => [...super.props, createdBy, updatedBy];
}

/// Soft delete entity with deletion tracking
abstract class SoftDeleteEntity extends AuditableEntity {
  final DateTime? deletedAt;
  final String? deletedBy;

  const SoftDeleteEntity({
    required super.id,
    required super.createdAt,
    required super.updatedAt,
    super.isActive,
    super.createdBy,
    super.updatedBy,
    this.deletedAt,
    this.deletedBy,
  });

  @override
  SoftDeleteEntity copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
    String? createdBy,
    String? updatedBy,
    DateTime? deletedAt,
    String? deletedBy,
  });

  @override
  Map<String, dynamic> toJson();

  @override
  List<Object?> get props => [...super.props, deletedAt, deletedBy];

  /// Check if entity is soft deleted
  bool get isDeleted => deletedAt != null;
}

/// Versioned entity for optimistic concurrency control
abstract class VersionedEntity extends BaseEntity {
  final int version;

  const VersionedEntity({
    required super.id,
    required super.createdAt,
    required super.updatedAt,
    super.isActive,
    this.version = 1,
  });

  @override
  VersionedEntity copyWith({String? id, DateTime? createdAt, DateTime? updatedAt, bool? isActive, int? version});

  @override
  Map<String, dynamic> toJson();

  @override
  List<Object?> get props => [...super.props, version];
}
