import 'package:core/src/domain/entities/base_entity.dart';

/// User roles in the system
enum UserRole {
  client('client'),
  receptionist('receptionist'),
  veterinarian('veterinarian'),
  clinicAdmin('clinic_admin'),
  superAdmin('super_admin');

  const UserRole(this.value);
  final String value;

  static UserRole fromString(String value) {
    return UserRole.values.firstWhere((role) => role.value == value, orElse: () => UserRole.client);
  }

  String get displayName {
    switch (this) {
      case UserRole.client:
        return 'Client';
      case UserRole.receptionist:
        return 'Receptionist';
      case UserRole.veterinarian:
        return 'Veterinarian';
      case UserRole.clinicAdmin:
        return 'Clinic Admin';
      case UserRole.superAdmin:
        return 'Super Admin';
    }
  }
}

/// User status
enum UserStatus {
  active('active'),
  inactive('inactive'),
  suspended('suspended'),
  pending('pending');

  const UserStatus(this.value);
  final String value;

  static UserStatus fromString(String value) {
    return UserStatus.values.firstWhere((status) => status.value == value, orElse: () => UserStatus.pending);
  }

  bool get isActive => this == UserStatus.active;
  bool get isInactive => this == UserStatus.inactive;
  bool get isSuspended => this == UserStatus.suspended;
  bool get isPending => this == UserStatus.pending;
}

/// User entity
class User extends AuditableEntity {
  final String email;
  final String? phoneNumber;
  final String? firstName;
  final String? lastName;
  final String? avatarUrl;
  final DateTime? dateOfBirth;
  final String? address;
  final UserRole role;
  final UserStatus status;
  final String? clinicId;
  final DateTime? lastLoginAt;
  final Map<String, dynamic>? metadata;

  const User({
    super.id,
    super.createdAt,
    super.updatedAt,
    super.isActive,
    required this.email,
    this.phoneNumber,
    this.firstName,
    this.lastName,
    this.avatarUrl,
    this.dateOfBirth,
    this.address,
    this.clinicId,
    this.role = UserRole.client,
    this.status = UserStatus.pending,
    this.lastLoginAt,
    this.metadata,
  });

  /// Get full name
  String get fullName {
    final first = firstName ?? '';
    final last = lastName ?? '';
    return '$first $last'.trim();
  }

  /// Get display name (full name or email)
  String get displayName => fullName.isNotEmpty ? fullName : email;

  /// Get initials for avatar
  String get initials {
    if (fullName.isNotEmpty) {
      final parts = fullName.split(' ');
      if (parts.length >= 2) {
        return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
      } else if (parts.isNotEmpty) {
        return parts[0].substring(0, 2).toUpperCase();
      }
    }
    return email.substring(0, 2).toUpperCase();
  }

  /// Get age from date of birth
  int? get age {
    if (dateOfBirth == null) return null;
    final now = DateTime.now();
    int age = now.year - dateOfBirth!.year;
    if (now.month < dateOfBirth!.month || (now.month == dateOfBirth!.month && now.day < dateOfBirth!.day)) {
      age--;
    }
    return age;
  }

  /// Check if user is verified
  bool get isVerified => status == UserStatus.active;

  /// Check if user can access clinic features
  bool get canAccessClinic => role == UserRole.doctor || role == UserRole.staff || role == UserRole.admin;

  /// Check if user is admin
  bool get isAdmin => role == UserRole.admin;

  /// Check if user is doctor
  bool get isDoctor => role == UserRole.doctor;

  /// Check if user is staff
  bool get isStaff => role == UserRole.staff;

  /// Check if user is client
  bool get isClient => role == UserRole.client;

  @override
  List<Object?> get props => [
    ...super.props,
    email,
    phoneNumber,
    firstName,
    lastName,
    avatarUrl,
    dateOfBirth,
    address,
    clinicId,
    role,
    status,
    lastLoginAt,
    metadata,
  ];

  @override
  bool get isValid {
    return super.isValid && email.isNotEmpty && (firstName?.isNotEmpty ?? true) && (lastName?.isNotEmpty ?? true);
  }

  @override
  List<String> get validationErrors {
    final errors = <String>[];

    if (email.isEmpty) {
      errors.add('Email không được để trống');
    } else if (!RegExp(r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+').hasMatch(email)) {
      errors.add('Email không hợp lệ');
    }

    if (phoneNumber != null && phoneNumber!.isNotEmpty) {
      if (!RegExp(r'^\+?[\d\s\-\(\)]{10,}$').hasMatch(phoneNumber!)) {
        errors.add('Số điện thoại không hợp lệ');
      }
    }

    if (firstName != null && firstName!.length > 50) {
      errors.add('Tên không được vượt quá 50 ký tự');
    }

    if (lastName != null && lastName!.length > 50) {
      errors.add('Họ không được vượt quá 50 ký tự');
    }

    return errors;
  }

  /// Create a copy with updated fields
  User copyWith({
    String? id,
    String? email,
    String? phoneNumber,
    String? firstName,
    String? lastName,
    String? avatarUrl,
    DateTime? dateOfBirth,
    String? address,
    String? clinicId,
    UserRole? role,
    UserStatus? status,
    DateTime? lastLoginAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
    Map<String, dynamic>? metadata,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      address: address ?? this.address,
      clinicId: clinicId ?? this.clinicId,
      role: role ?? this.role,
      status: status ?? this.status,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
      metadata: metadata ?? this.metadata,
    );
  }
}

/// User profile - simplified version for public display
class UserProfile {
  final String id;
  final String displayName;
  final String? avatarUrl;
  final UserRole role;
  final UserStatus status;
  final String? clinicId;

  const UserProfile({
    required this.id,
    required this.displayName,
    this.avatarUrl,
    required this.role,
    required this.status,
    this.clinicId,
  });

  factory UserProfile.fromUser(User user) {
    return UserProfile(
      id: user.id ?? '',
      displayName: user.displayName,
      avatarUrl: user.avatarUrl,
      role: user.role,
      status: user.status,
      clinicId: user.clinicId,
    );
  }
}

/// User authentication data
class UserAuth {
  final String uid;
  final String email;
  final String? displayName;
  final String? photoUrl;
  final bool emailVerified;
  final UserRole? role;

  const UserAuth({
    required this.uid,
    required this.email,
    this.displayName,
    this.photoUrl,
    this.emailVerified = false,
    this.role,
  });

  factory UserAuth.fromJson(Map<String, dynamic> json) {
    return UserAuth(
      uid: json['uid'] as String,
      email: json['email'] as String,
      displayName: json['displayName'] as String?,
      photoUrl: json['photoUrl'] as String?,
      emailVerified: json['emailVerified'] as bool? ?? false,
      role: json['role'] != null ? UserRole.fromString(json['role'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'emailVerified': emailVerified,
      'role': role?.value,
    };
  }
}
