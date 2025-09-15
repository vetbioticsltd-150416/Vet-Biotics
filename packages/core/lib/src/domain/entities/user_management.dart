import 'base_entity.dart';

/// User role with permissions
enum UserRole {
  superAdmin('super_admin', 'Super Admin', [
    Permission.manageUsers,
    Permission.manageClinics,
    Permission.manageSystem,
    Permission.viewAnalytics,
    Permission.manageBilling,
    Permission.manageAppointments,
    Permission.manageMedicalRecords,
    Permission.managePets,
  ]),
  clinicAdmin('clinic_admin', 'Clinic Admin', [
    Permission.manageClinicStaff,
    Permission.manageClinicServices,
    Permission.viewClinicAnalytics,
    Permission.manageClinicBilling,
    Permission.manageClinicAppointments,
    Permission.manageClinicMedicalRecords,
    Permission.manageClinicPets,
    Permission.viewClinicUsers,
  ]),
  veterinarian('veterinarian', 'Veterinarian', [
    Permission.manageMedicalRecords,
    Permission.manageAppointments,
    Permission.viewPets,
    Permission.viewClinicUsers,
  ]),
  receptionist('receptionist', 'Receptionist', [
    Permission.manageAppointments,
    Permission.viewClinicUsers,
    Permission.viewPets,
    Permission.viewMedicalRecords,
  ]),
  customer('customer', 'Customer', [
    Permission.viewOwnProfile,
    Permission.manageOwnPets,
    Permission.bookAppointments,
    Permission.viewOwnMedicalRecords,
    Permission.viewOwnBilling,
  ]);

  const UserRole(this.value, this.displayName, this.permissions);
  final String value;
  final String displayName;
  final List<Permission> permissions;

  static UserRole fromString(String value) => UserRole.values.firstWhere((role) => role.value == value, orElse: () => UserRole.customer);

  bool hasPermission(Permission permission) => permissions.contains(permission);
  bool hasAnyPermission(List<Permission> permissions) => permissions.any(hasPermission);
}

/// Permission enum
enum Permission {
  // User management
  manageUsers('manage_users'),
  manageClinicStaff('manage_clinic_staff'),
  viewClinicUsers('view_clinic_users'),
  viewOwnProfile('view_own_profile'),

  // Clinic management
  manageClinics('manage_clinics'),
  manageClinicServices('manage_clinic_services'),
  manageSystem('manage_system'),

  // Analytics
  viewAnalytics('view_analytics'),
  viewClinicAnalytics('view_clinic_analytics'),

  // Billing
  manageBilling('manage_billing'),
  manageClinicBilling('manage_clinic_billing'),
  viewOwnBilling('view_own_billing'),

  // Appointments
  manageAppointments('manage_appointments'),
  manageClinicAppointments('manage_clinic_appointments'),
  bookAppointments('book_appointments'),

  // Medical records
  manageMedicalRecords('manage_medical_records'),
  manageClinicMedicalRecords('manage_clinic_medical_records'),
  viewMedicalRecords('view_medical_records'),
  viewOwnMedicalRecords('view_own_medical_records'),

  // Pets
  managePets('manage_pets'),
  manageClinicPets('manage_clinic_pets'),
  manageOwnPets('manage_own_pets'),
  viewPets('view_pets');

  const Permission(this.value);
  final String value;

  static Permission fromString(String value) => Permission.values.firstWhere((permission) => permission.value == value);

  String get displayName {
    switch (this) {
      case Permission.manageUsers:
        return 'Quản lý người dùng';
      case Permission.manageClinicStaff:
        return 'Quản lý nhân viên phòng khám';
      case Permission.viewClinicUsers:
        return 'Xem người dùng phòng khám';
      case Permission.viewOwnProfile:
        return 'Xem hồ sơ cá nhân';
      case Permission.manageClinics:
        return 'Quản lý phòng khám';
      case Permission.manageClinicServices:
        return 'Quản lý dịch vụ phòng khám';
      case Permission.manageSystem:
        return 'Quản lý hệ thống';
      case Permission.viewAnalytics:
        return 'Xem báo cáo phân tích';
      case Permission.viewClinicAnalytics:
        return 'Xem báo cáo phòng khám';
      case Permission.manageBilling:
        return 'Quản lý thanh toán';
      case Permission.manageClinicBilling:
        return 'Quản lý thanh toán phòng khám';
      case Permission.viewOwnBilling:
        return 'Xem hóa đơn cá nhân';
      case Permission.manageAppointments:
        return 'Quản lý lịch hẹn';
      case Permission.manageClinicAppointments:
        return 'Quản lý lịch hẹn phòng khám';
      case Permission.bookAppointments:
        return 'Đặt lịch hẹn';
      case Permission.manageMedicalRecords:
        return 'Quản lý hồ sơ bệnh án';
      case Permission.manageClinicMedicalRecords:
        return 'Quản lý hồ sơ phòng khám';
      case Permission.viewMedicalRecords:
        return 'Xem hồ sơ bệnh án';
      case Permission.viewOwnMedicalRecords:
        return 'Xem hồ sơ bệnh án cá nhân';
      case Permission.managePets:
        return 'Quản lý thú cưng';
      case Permission.manageClinicPets:
        return 'Quản lý thú cưng phòng khám';
      case Permission.manageOwnPets:
        return 'Quản lý thú cưng cá nhân';
      case Permission.viewPets:
        return 'Xem thú cưng';
    }
  }
}

/// User profile entity with extended information
class UserProfile extends AuditableEntity {
  final String userId;
  final String email;
  final String? displayName;
  final String? phoneNumber;
  final String? avatarUrl;
  final DateTime? dateOfBirth;
  final String? gender;
  final String? address;
  final String? bio;
  final UserRole role;
  final String? clinicId;
  final bool isEmailVerified;
  @override
  final bool isActive;
  final DateTime? lastLoginAt;
  final Map<String, dynamic>? preferences;
  final Map<String, dynamic>? metadata;

  UserProfile({
    super.id = '',
    DateTime? createdAt,
    DateTime? updatedAt,
    super.isActive,
    required this.userId,
    required this.email,
    this.displayName,
    this.phoneNumber,
    this.avatarUrl,
    this.dateOfBirth,
    this.gender,
    this.address,
    this.bio,
    this.role = UserRole.customer,
    this.clinicId,
    this.isEmailVerified = false,
    this.lastLoginAt,
    this.preferences,
    this.metadata,
  }) : super(
          createdAt: createdAt ?? DateTime.now(),
          updatedAt: updatedAt ?? DateTime.now(),
        ),
        isActive = isActive;

  @override
  List<Object?> get props => [
    ...super.props,
    userId,
    email,
    displayName,
    phoneNumber,
    avatarUrl,
    dateOfBirth,
    gender,
    address,
    bio,
    role,
    clinicId,
    isEmailVerified,
    isActive,
    lastLoginAt,
    preferences,
    metadata,
  ];

  @override
  bool get isValid => super.isValid && userId.isNotEmpty && email.isNotEmpty && RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(email);

  @override
  List<String> get validationErrors {
    final errors = <String>[];

    if (userId.isEmpty) {
      errors.add('User ID không được để trống');
    }

    if (email.isEmpty) {
      errors.add('Email không được để trống');
    } else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(email)) {
      errors.add('Email không hợp lệ');
    }

    return errors;
  }

  @override
  UserProfile copyWith({
    String? id,
    String? userId,
    String? email,
    String? displayName,
    String? phoneNumber,
    String? avatarUrl,
    DateTime? dateOfBirth,
    String? gender,
    String? address,
    String? bio,
    UserRole? role,
    String? clinicId,
    bool? isEmailVerified,
    bool? isActive,
    DateTime? lastLoginAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? preferences,
    Map<String, dynamic>? metadata,
  }) => UserProfile(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      address: address ?? this.address,
      bio: bio ?? this.bio,
      role: role ?? this.role,
      clinicId: clinicId ?? this.clinicId,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      isActive: isActive ?? this.isActive,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      preferences: preferences ?? this.preferences,
      metadata: metadata ?? this.metadata,
    );

  /// Check if user has a specific permission
  bool hasPermission(Permission permission) => role.hasPermission(permission);

  /// Check if user has any of the specified permissions
  bool hasAnyPermission(List<Permission> permissions) => role.hasAnyPermission(permissions);

  /// Get user full name
  String get fullName => displayName ?? email;

  /// Get user age
  int? get age {
    if (dateOfBirth == null) return null;
    final now = DateTime.now();
    int age = now.year - dateOfBirth!.year;
    if (now.month < dateOfBirth!.month || (now.month == dateOfBirth!.month && now.day < dateOfBirth!.day)) {
      age--;
    }
    return age;
  }

  /// Check if user is admin level
  bool get isAdmin => role == UserRole.superAdmin || role == UserRole.clinicAdmin;

  /// Check if user is clinic staff
  bool get isClinicStaff =>
      role == UserRole.clinicAdmin || role == UserRole.veterinarian || role == UserRole.receptionist;

  /// Check if user is customer
  bool get isCustomer => role == UserRole.customer;

  @override
  Map<String, dynamic> toJson() => {
      'id': id,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isActive': isActive,
      'userId': userId,
      'email': email,
      'displayName': displayName,
      'phoneNumber': phoneNumber,
      'avatarUrl': avatarUrl,
      'dateOfBirth': dateOfBirth?.toIso8601String(),
      'gender': gender,
      'address': address,
      'bio': bio,
      'role': role.value,
      'clinicId': clinicId,
      'isEmailVerified': isEmailVerified,
      'lastLoginAt': lastLoginAt?.toIso8601String(),
      'preferences': preferences,
      'metadata': metadata,
    };
}

/// User activity log entity
class UserActivity extends AuditableEntity {
  final String userId;
  final ActivityType type;
  final String action;
  final String? description;
  final Map<String, dynamic>? details;
  final String? ipAddress;
  final String? userAgent;
  final String? clinicId;
  final String? relatedEntityId;
  final String? relatedEntityType;

  UserActivity({
    super.id = '',
    DateTime? createdAt,
    DateTime? updatedAt,
    super.isActive,
    required this.userId,
    required this.type,
    required this.action,
    this.description,
    this.details,
    this.ipAddress,
    this.userAgent,
    this.clinicId,
    this.relatedEntityId,
    this.relatedEntityType,
  }) : super(
          createdAt: createdAt ?? DateTime.now(),
          updatedAt: updatedAt ?? DateTime.now(),
        );

  @override
  List<Object?> get props => [
    ...super.props,
    userId,
    type,
    action,
    description,
    details,
    ipAddress,
    userAgent,
    clinicId,
    relatedEntityId,
    relatedEntityType,
  ];

  @override
  bool get isValid => super.isValid && userId.isNotEmpty && action.isNotEmpty;

  @override
  List<String> get validationErrors {
    final errors = <String>[];

    if (userId.isEmpty) {
      errors.add('User ID không được để trống');
    }

    if (action.isEmpty) {
      errors.add('Action không được để trống');
    }

    return errors;
  }

  @override
  UserActivity copyWith({
    String? id,
    String? userId,
    ActivityType? type,
    String? action,
    String? description,
    Map<String, dynamic>? details,
    String? ipAddress,
    String? userAgent,
    String? clinicId,
    String? relatedEntityId,
    String? relatedEntityType,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
  }) => UserActivity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      action: action ?? this.action,
      description: description ?? this.description,
      details: details ?? this.details,
      ipAddress: ipAddress ?? this.ipAddress,
      userAgent: userAgent ?? this.userAgent,
      clinicId: clinicId ?? this.clinicId,
      relatedEntityId: relatedEntityId ?? this.relatedEntityId,
      relatedEntityType: relatedEntityType ?? this.relatedEntityType,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
    );

  @override
  Map<String, dynamic> toJson() => {
      'id': id,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isActive': isActive,
      'userId': userId,
      'type': type.value,
      'action': action,
      'clinicId': clinicId,
      'description': description,
      'details': details,
      'ipAddress': ipAddress,
      'userAgent': userAgent,
      'relatedEntityId': relatedEntityId,
      'relatedEntityType': relatedEntityType,
      'metadata': metadata,
    };
}

/// Activity type enum
enum ActivityType {
  login('login', 'Đăng nhập'),
  logout('logout', 'Đăng xuất'),
  create('create', 'Tạo'),
  update('update', 'Cập nhật'),
  delete('delete', 'Xóa'),
  view('view', 'Xem'),
  export('export', 'Xuất dữ liệu'),
  import('import', 'Nhập dữ liệu'),
  payment('payment', 'Thanh toán'),
  appointment('appointment', 'Lịch hẹn'),
  medical('medical', 'Y tế'),
  system('system', 'Hệ thống');

  const ActivityType(this.value, this.displayName);
  final String value;
  final String displayName;

  static ActivityType fromString(String value) => ActivityType.values.firstWhere((type) => type.value == value, orElse: () => ActivityType.system);
}

/// Notification preferences entity
class NotificationPreferences extends AuditableEntity {
  final String userId;
  final bool emailNotifications;
  final bool pushNotifications;
  final bool smsNotifications;
  final bool appointmentReminders;
  final bool medicalReminders;
  final bool billingNotifications;
  final bool marketingEmails;
  final bool systemNotifications;
  final Map<String, dynamic>? customSettings;

  NotificationPreferences({
    super.id = '',
    DateTime? createdAt,
    DateTime? updatedAt,
    super.isActive,
    required this.userId,
    this.emailNotifications = true,
    this.pushNotifications = true,
    this.smsNotifications = false,
    this.appointmentReminders = true,
    this.medicalReminders = true,
    this.billingNotifications = true,
    this.marketingEmails = false,
    this.systemNotifications = true,
    this.customSettings,
  }) : super(
          createdAt: createdAt ?? DateTime.now(),
          updatedAt: updatedAt ?? DateTime.now(),
        );

  @override
  List<Object?> get props => [
    ...super.props,
    userId,
    emailNotifications,
    pushNotifications,
    smsNotifications,
    appointmentReminders,
    medicalReminders,
    billingNotifications,
    marketingEmails,
    systemNotifications,
    customSettings,
  ];

  @override
  bool get isValid => super.isValid && userId.isNotEmpty;

  @override
  List<String> get validationErrors {
    final errors = <String>[];

    if (userId.isEmpty) {
      errors.add('User ID không được để trống');
    }

    return errors;
  }

  @override
  NotificationPreferences copyWith({
    String? id,
    String? userId,
    bool? emailNotifications,
    bool? pushNotifications,
    bool? smsNotifications,
    bool? appointmentReminders,
    bool? medicalReminders,
    bool? billingNotifications,
    bool? marketingEmails,
    bool? systemNotifications,
    Map<String, dynamic>? customSettings,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
  }) => NotificationPreferences(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      emailNotifications: emailNotifications ?? this.emailNotifications,
      pushNotifications: pushNotifications ?? this.pushNotifications,
      smsNotifications: smsNotifications ?? this.smsNotifications,
      appointmentReminders: appointmentReminders ?? this.appointmentReminders,
      medicalReminders: medicalReminders ?? this.medicalReminders,
      billingNotifications: billingNotifications ?? this.billingNotifications,
      marketingEmails: marketingEmails ?? this.marketingEmails,
      systemNotifications: systemNotifications ?? this.systemNotifications,
      customSettings: customSettings ?? this.customSettings,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
    );

  @override
  Map<String, dynamic> toJson() => {
      'id': id,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isActive': isActive,
      'userId': userId,
      'emailNotifications': emailNotifications,
      'pushNotifications': pushNotifications,
      'smsNotifications': smsNotifications,
      'appointmentReminders': appointmentReminders,
      'marketingEmails': marketingEmails,
      'newsletter': newsletter,
      'metadata': metadata,
    };
}

/// Password reset token entity
class PasswordResetToken extends AuditableEntity {
  final String userId;
  final String token;
  final DateTime expiresAt;
  final bool isUsed;

  PasswordResetToken({
    super.id = '',
    DateTime? createdAt,
    DateTime? updatedAt,
    super.isActive,
    required this.userId,
    required this.token,
    required this.expiresAt,
    this.isUsed = false,
  }) : super(
          createdAt: createdAt ?? DateTime.now(),
          updatedAt: updatedAt ?? DateTime.now(),
        );

  @override
  List<Object?> get props => [...super.props, userId, token, expiresAt, isUsed];

  @override
  bool get isValid => super.isValid && userId.isNotEmpty && token.isNotEmpty && expiresAt.isAfter(DateTime.now());

  @override
  List<String> get validationErrors {
    final errors = <String>[];

    if (userId.isEmpty) {
      errors.add('User ID không được để trống');
    }

    if (token.isEmpty) {
      errors.add('Token không được để trống');
    }

    if (expiresAt.isBefore(DateTime.now())) {
      errors.add('Token đã hết hạn');
    }

    return errors;
  }

  bool get isExpired => expiresAt.isBefore(DateTime.now());

  @override
  PasswordResetToken copyWith({
    String? id,
    String? userId,
    String? token,
    DateTime? expiresAt,
    bool? isUsed,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
  }) => PasswordResetToken(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      token: token ?? this.token,
      expiresAt: expiresAt ?? this.expiresAt,
      isUsed: isUsed ?? this.isUsed,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
    );

  @override
  Map<String, dynamic> toJson() => {
      'id': id,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isActive': isActive,
      'userId': userId,
      'token': token,
      'expiresAt': expiresAt.toIso8601String(),
      'isUsed': isUsed,
    };
}
