import 'package:equatable/equatable.dart';

/// Base entity class for all domain entities
abstract class BaseEntity extends Equatable {
  const BaseEntity();

  /// Unique identifier for the entity
  String? get id;

  /// Check if entity is valid
  bool get isValid => true;

  /// Get validation errors
  List<String> get validationErrors => [];

  @override
  List<Object?> get props => [id];
}

/// Base entity with common audit fields
abstract class AuditableEntity extends BaseEntity {
  @override
  final String? id;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final bool? isActive;

  const AuditableEntity({this.id, this.createdAt, this.updatedAt, this.isActive});

  @override
  List<Object?> get props => [id, createdAt, updatedAt, isActive];

  /// Check if entity was recently created (within last hour)
  bool get isRecentlyCreated {
    if (createdAt == null) return false;
    return DateTime.now().difference(createdAt!).inHours < 1;
  }

  /// Check if entity was recently updated (within last hour)
  bool get isRecentlyUpdated {
    if (updatedAt == null) return false;
    return DateTime.now().difference(updatedAt!).inHours < 1;
  }
}

/// Base entity with soft delete capability
abstract class SoftDeletableEntity extends AuditableEntity {
  final DateTime? deletedAt;

  const SoftDeletableEntity({super.id, super.createdAt, super.updatedAt, super.isActive, this.deletedAt});

  @override
  List<Object?> get props => [...super.props, deletedAt];

  /// Check if entity is soft deleted
  bool get isDeleted => deletedAt != null;

  /// Check if entity is active (not soft deleted and isActive is true)
  @override
  bool get isValid => !isDeleted && (isActive ?? true);
}

/// Base entity with versioning
abstract class VersionedEntity extends AuditableEntity {
  final int? version;

  const VersionedEntity({super.id, super.createdAt, super.updatedAt, super.isActive, this.version});

  @override
  List<Object?> get props => [...super.props, version];

  /// Check if entity has been modified
  bool get isModified => version != null && version! > 1;
}

/// Generic result wrapper for operations
class EntityResult<T> {
  final T? data;
  final String? error;
  final bool success;

  const EntityResult.success(this.data) : success = true, error = null;

  const EntityResult.failure(this.error) : success = false, data = null;

  factory EntityResult.fromData(T data) => EntityResult.success(data);
  factory EntityResult.fromError(String error) => EntityResult.failure(error);

  bool get hasData => data != null;
  bool get hasError => error != null;
}

/// Pagination metadata for entity collections
class PaginationMeta {
  final int currentPage;
  final int totalPages;
  final int totalItems;
  final int itemsPerPage;
  final bool hasNextPage;
  final bool hasPreviousPage;

  const PaginationMeta({
    required this.currentPage,
    required this.totalPages,
    required this.totalItems,
    required this.itemsPerPage,
    required this.hasNextPage,
    required this.hasPreviousPage,
  });

  factory PaginationMeta.fromJson(Map<String, dynamic> json) {
    return PaginationMeta(
      currentPage: json['currentPage'] as int? ?? 1,
      totalPages: json['totalPages'] as int? ?? 1,
      totalItems: json['totalItems'] as int? ?? 0,
      itemsPerPage: json['itemsPerPage'] as int? ?? 20,
      hasNextPage: json['hasNextPage'] as bool? ?? false,
      hasPreviousPage: json['hasPreviousPage'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'currentPage': currentPage,
      'totalPages': totalPages,
      'totalItems': totalItems,
      'itemsPerPage': itemsPerPage,
      'hasNextPage': hasNextPage,
      'hasPreviousPage': hasPreviousPage,
    };
  }

  int get offset => (currentPage - 1) * itemsPerPage;
  int get limit => itemsPerPage;
}

/// Paginated result wrapper
class PaginatedResult<T> {
  final List<T> items;
  final PaginationMeta meta;

  const PaginatedResult({required this.items, required this.meta});

  factory PaginatedResult.fromJson(Map<String, dynamic> json, T Function(Map<String, dynamic>) fromJson) {
    final items =
        (json['items'] as List<dynamic>?)?.map((item) => fromJson(item as Map<String, dynamic>)).toList() ?? [];

    final meta = PaginationMeta.fromJson(json['meta'] as Map<String, dynamic>);

    return PaginatedResult(items: items, meta: meta);
  }

  Map<String, dynamic> toJson() {
    return {'items': items, 'meta': meta.toJson()};
  }

  bool get isEmpty => items.isEmpty;
  bool get isNotEmpty => items.isNotEmpty;
  int get length => items.length;
}
