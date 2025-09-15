import 'base_entity.dart';

/// Clinic status
enum ClinicStatus {
  active('active', 'Hoạt động'),
  inactive('inactive', 'Không hoạt động'),
  suspended('suspended', 'Tạm ngừng'),
  closed('closed', 'Đã đóng cửa');

  const ClinicStatus(this.value, this.displayName);
  final String value;
  final String displayName;

  static ClinicStatus fromString(String value) =>
      ClinicStatus.values.firstWhere((status) => status.value == value, orElse: () => ClinicStatus.active);

  bool get isActive => this == ClinicStatus.active;
}

/// Clinic entity
class Clinic extends AuditableEntity {
  final String name;
  final String? description;
  final String? address;
  final String? phone;
  final String? email;
  final String? website;
  final String? logoUrl;
  final List<String>? imageUrls;
  final ClinicStatus status;
  final String ownerId;
  final Map<String, dynamic>? businessHours;
  final List<String>? services;
  final Map<String, dynamic>? contactInfo;
  final Map<String, dynamic>? settings;
  final Map<String, dynamic>? metadata;

  Clinic({
    super.id = '',
    DateTime? createdAt,
    DateTime? updatedAt,
    super.isActive,
    required this.name,
    this.description,
    this.address,
    this.phone,
    this.email,
    this.website,
    this.logoUrl,
    this.imageUrls,
    this.status = ClinicStatus.active,
    required this.ownerId,
    this.businessHours,
    this.services,
    this.contactInfo,
    this.settings,
    this.metadata,
  }) : super(createdAt: createdAt ?? DateTime.now(), updatedAt: updatedAt ?? DateTime.now());

  @override
  List<Object?> get props => [
    ...super.props,
    name,
    description,
    address,
    phone,
    email,
    website,
    logoUrl,
    imageUrls,
    status,
    ownerId,
    businessHours,
    services,
    contactInfo,
    settings,
    metadata,
  ];

  @override
  bool get isValid => name.isNotEmpty && ownerId.isNotEmpty;

  @override
  List<String> get validationErrors {
    final errors = <String>[];

    if (name.isEmpty) {
      errors.add('Tên phòng khám không được để trống');
    } else if (name.length > 100) {
      errors.add('Tên phòng khám không được vượt quá 100 ký tự');
    }

    if (ownerId.isEmpty) {
      errors.add('Chủ sở hữu không được để trống');
    }

    if (phone != null && !RegExp(r'^\+?[\d\s\-\(\)]{10,}$').hasMatch(phone!)) {
      errors.add('Số điện thoại không hợp lệ');
    }

    if (email != null && !RegExp(r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+').hasMatch(email!)) {
      errors.add('Email không hợp lệ');
    }

    return errors;
  }

  @override
  Clinic copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
    String? createdBy,
    String? updatedBy,
  }) => Clinic(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    isActive: isActive ?? this.isActive,
    name: name,
    ownerId: ownerId,
    description: description,
    address: address,
    phone: phone,
    email: email,
    website: website,
    logoUrl: logoUrl,
    imageUrls: imageUrls,
    status: status,
    businessHours: businessHours,
    services: services,
    contactInfo: contactInfo,
    settings: settings,
    metadata: metadata,
  );

  @override
  Map<String, dynamic> toJson() => {
    'id': id,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
    'isActive': isActive,
    'name': name,
    'ownerId': ownerId,
    'description': description,
    'address': address,
    'phone': phone,
    'email': email,
    'website': website,
    'logoUrl': logoUrl,
    'imageUrls': imageUrls,
    'status': status.value,
    'businessHours': businessHours,
    'services': services,
    'contactInfo': contactInfo,
    'settings': settings,
    'metadata': metadata,
  };
}

/// Clinic service
class ClinicService {
  final String id;
  final String name;
  final String? description;
  final double price;
  final int durationMinutes;
  final bool isActive;
  final String? category;
  final Map<String, dynamic>? metadata;

  const ClinicService({
    required this.id,
    required this.name,
    this.description,
    required this.price,
    required this.durationMinutes,
    this.isActive = true,
    this.category,
    this.metadata,
  });

  factory ClinicService.fromJson(Map<String, dynamic> json) => ClinicService(
    id: json['id'] as String,
    name: json['name'] as String,
    description: json['description'] as String?,
    price: (json['price'] as num).toDouble(),
    durationMinutes: json['durationMinutes'] as int,
    isActive: json['isActive'] as bool? ?? true,
    category: json['category'] as String?,
    metadata: json['metadata'] as Map<String, dynamic>?,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'price': price,
    'durationMinutes': durationMinutes,
    'isActive': isActive,
    'category': category,
    'metadata': metadata,
  };
}

/// Clinic staff
class ClinicStaff extends AuditableEntity {
  final String userId;
  final String clinicId;
  final String role;
  final List<String>? permissions;
  @override
  final bool isActive;
  final Map<String, dynamic>? schedule;
  final Map<String, dynamic>? metadata;

  ClinicStaff({
    super.id = '',
    DateTime? createdAt,
    DateTime? updatedAt,
    super.isActive,
    required this.userId,
    required this.clinicId,
    required this.role,
    this.permissions,
    this.schedule,
    this.metadata,
  }) : super(createdAt: createdAt ?? DateTime.now(), updatedAt: updatedAt ?? DateTime.now()),
       isActive = isActive;

  @override
  bool get isValid => userId.isNotEmpty && clinicId.isNotEmpty && role.isNotEmpty;

  @override
  List<String> get validationErrors {
    final errors = <String>[];

    if (userId.isEmpty) {
      errors.add('User ID không được để trống');
    }

    if (clinicId.isEmpty) {
      errors.add('Clinic ID không được để trống');
    }

    if (role.isEmpty) {
      errors.add('Role không được để trống');
    }

    return errors;
  }

  @override
  List<Object?> get props => [...super.props, userId, clinicId, role, permissions, schedule, metadata];

  bool hasPermission(String permission) => permissions?.contains(permission) ?? false;

  @override
  ClinicStaff copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
    String? createdBy,
    String? updatedBy,
    String? userId,
    String? clinicId,
    String? role,
    List<String>? permissions,
    Map<String, dynamic>? schedule,
    Map<String, dynamic>? metadata,
  }) => ClinicStaff(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    isActive: isActive ?? this.isActive,
    userId: userId ?? this.userId,
    clinicId: clinicId ?? this.clinicId,
    role: role ?? this.role,
    permissions: permissions ?? this.permissions,
    schedule: schedule ?? this.schedule,
    metadata: metadata ?? this.metadata,
  );

  @override
  Map<String, dynamic> toJson() => {
    'id': id,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
    'isActive': isActive,
    'userId': userId,
    'clinicId': clinicId,
    'role': role,
    'permissions': permissions,
    'schedule': schedule,
    'metadata': metadata,
  };
}
