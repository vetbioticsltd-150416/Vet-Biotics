import 'package:equatable/equatable.dart';

/// Base model class that all models should extend
abstract class BaseModel extends Equatable {
  const BaseModel();

  /// Convert object to JSON
  Map<String, dynamic> toJson();

  /// Create object from JSON
  factory BaseModel.fromJson(Map<String, dynamic> json) {
    throw UnimplementedError('fromJson must be implemented in subclasses');
  }

  /// Get the unique identifier for the model
  String? get id;

  /// Check if model is valid
  bool get isValid => true;

  /// Get validation errors
  List<String> get validationErrors => [];

  @override
  List<Object?> get props => [id];
}

/// Base model with common fields
abstract class BaseEntityModel extends BaseModel {
  @override
  final String? id;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final bool? isActive;

  const BaseEntityModel({this.id, this.createdAt, this.updatedAt, this.isActive});

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'isActive': isActive,
    };
  }

  @override
  List<Object?> get props => [id, createdAt, updatedAt, isActive];
}

/// Model for handling creation/update timestamps
class TimestampModel {
  final DateTime createdAt;
  final DateTime updatedAt;

  const TimestampModel({required this.createdAt, required this.updatedAt});

  factory TimestampModel.now() {
    final now = DateTime.now();
    return TimestampModel(createdAt: now, updatedAt: now);
  }

  factory TimestampModel.fromJson(Map<String, dynamic> json) {
    return TimestampModel(
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {'createdAt': createdAt.toIso8601String(), 'updatedAt': updatedAt.toIso8601String()};
  }

  TimestampModel copyWith({DateTime? createdAt, DateTime? updatedAt}) {
    return TimestampModel(createdAt: createdAt ?? this.createdAt, updatedAt: updatedAt ?? this.updatedAt);
  }
}
