import 'base_entity.dart';

/// Appointment status
enum AppointmentStatus {
  scheduled('scheduled', 'Đã đặt lịch'),
  confirmed('confirmed', 'Đã xác nhận'),
  inProgress('in_progress', 'Đang diễn ra'),
  completed('completed', 'Hoàn thành'),
  cancelled('cancelled', 'Đã hủy'),
  noShow('no_show', 'Không đến');

  const AppointmentStatus(this.value, this.displayName);
  final String value;
  final String displayName;

  static AppointmentStatus fromString(String value) {
    return AppointmentStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => AppointmentStatus.scheduled,
    );
  }

  bool get isActive => this == AppointmentStatus.scheduled || this == AppointmentStatus.confirmed;
  bool get isCompleted => this == AppointmentStatus.completed;
  bool get isCancelled => this == AppointmentStatus.cancelled;
  bool get isNoShow => this == AppointmentStatus.noShow;
}

/// Appointment type
enum AppointmentType {
  consultation('consultation', 'Khám tổng quát'),
  vaccination('vaccination', 'Tiêm phòng'),
  surgery('surgery', 'Phẫu thuật'),
  dental('dental', 'Khám răng'),
  grooming('grooming', 'Làm đẹp'),
  emergency('emergency', 'Cấp cứu'),
  followUp('follow_up', 'Tái khám'),
  other('other', 'Khác');

  const AppointmentType(this.value, this.displayName);
  final String value;
  final String displayName;

  static AppointmentType fromString(String value) {
    return AppointmentType.values.firstWhere((type) => type.value == value, orElse: () => AppointmentType.consultation);
  }
}

/// Appointment entity
class Appointment extends AuditableEntity {
  final String petId;
  final String ownerId;
  final String? doctorId;
  final String clinicId;
  final DateTime scheduledDate;
  final int durationMinutes;
  final AppointmentType type;
  final AppointmentStatus status;
  final String? notes;
  final String? symptoms;
  final String? diagnosis;
  final String? treatment;
  final double? fee;
  final String? paymentStatus;
  final List<String>? attachments;
  final DateTime? checkInTime;
  final DateTime? checkOutTime;
  final Map<String, dynamic>? metadata;

  Appointment({
    super.id = '',
    DateTime? createdAt,
    DateTime? updatedAt,
    super.isActive,
    required this.petId,
    required this.ownerId,
    this.doctorId,
    required this.clinicId,
    required this.scheduledDate,
    required this.durationMinutes,
    required this.type,
    required this.status,
    this.notes,
    this.symptoms,
    this.diagnosis,
    this.treatment,
    this.fee,
    this.paymentStatus,
    this.attachments,
    this.checkInTime,
    this.checkOutTime,
    this.metadata,
  }) : super(createdAt: createdAt ?? DateTime.now(), updatedAt: updatedAt ?? DateTime.now());

  /// Get end time of appointment
  DateTime get endDate => scheduledDate.add(Duration(minutes: durationMinutes));

  /// Check if appointment is today
  bool get isToday {
    final now = DateTime.now();
    return scheduledDate.year == now.year && scheduledDate.month == now.month && scheduledDate.day == now.day;
  }

  /// Check if appointment is in the past
  bool get isPast => scheduledDate.isBefore(DateTime.now());

  /// Check if appointment is in the future
  bool get isFuture => scheduledDate.isAfter(DateTime.now());

  /// Check if appointment is currently happening
  bool get isCurrent {
    final now = DateTime.now();
    return now.isAfter(scheduledDate) && now.isBefore(endDate);
  }

  /// Get duration as formatted string
  String get durationString {
    if (durationMinutes < 60) {
      return '$durationMinutes phút';
    } else {
      final hours = durationMinutes ~/ 60;
      final minutes = durationMinutes % 60;
      if (minutes == 0) {
        return '$hours giờ';
      } else {
        return '$hours giờ $minutes phút';
      }
    }
  }

  /// Check if appointment can be cancelled
  bool get canBeCancelled => isActive && !isPast;

  /// Check if appointment can be rescheduled
  bool get canBeRescheduled => isActive && !isCurrent;

  @override
  List<Object?> get props => [
    ...super.props,
    petId,
    ownerId,
    doctorId,
    clinicId,
    scheduledDate,
    durationMinutes,
    type,
    status,
    notes,
    symptoms,
    diagnosis,
    treatment,
    fee,
    paymentStatus,
    attachments,
    checkInTime,
    checkOutTime,
    metadata,
  ];

  @override
  bool get isValid {
    return petId.isNotEmpty &&
        ownerId.isNotEmpty &&
        clinicId.isNotEmpty &&
        durationMinutes > 0 &&
        durationMinutes <= 480 && // Max 8 hours
        scheduledDate.isAfter(DateTime.now().subtract(const Duration(hours: 1)));
  }

  @override
  List<String> get validationErrors {
    final errors = <String>[];

    if (petId.isEmpty) {
      errors.add('Thú cưng không được để trống');
    }

    if (ownerId.isEmpty) {
      errors.add('Chủ sở hữu không được để trống');
    }

    if (clinicId.isEmpty) {
      errors.add('Phòng khám không được để trống');
    }

    if (scheduledDate.isBefore(DateTime.now().subtract(const Duration(hours: 1)))) {
      errors.add('Thời gian hẹn không được ở quá khứ');
    }

    if (durationMinutes <= 0) {
      errors.add('Thời lượng phải lớn hơn 0');
    } else if (durationMinutes > 480) {
      errors.add('Thời lượng không được vượt quá 8 giờ');
    }

    if (fee != null && fee! < 0) {
      errors.add('Phí không được âm');
    }

    return errors;
  }

  /// Create a copy with updated fields
  @override
  Appointment copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
    String? createdBy,
    String? updatedBy,
  }) {
    return Appointment(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
      petId: petId,
      ownerId: ownerId,
      doctorId: doctorId,
      clinicId: clinicId,
      scheduledDate: scheduledDate,
      durationMinutes: durationMinutes,
      type: type,
      status: status,
      notes: notes,
      symptoms: symptoms,
      diagnosis: diagnosis,
      treatment: treatment,
      fee: fee,
      paymentStatus: paymentStatus,
      attachments: attachments,
      checkInTime: checkInTime,
      checkOutTime: checkOutTime,
      metadata: metadata,
    );
  }

  /// Create a copy with updated appointment-specific fields
  Appointment copyWithAppointment({
    String? id,
    String? petId,
    String? ownerId,
    String? doctorId,
    String? clinicId,
    DateTime? scheduledDate,
    int? durationMinutes,
    AppointmentType? type,
    AppointmentStatus? status,
    String? notes,
    String? symptoms,
    String? diagnosis,
    String? treatment,
    double? fee,
    String? paymentStatus,
    List<String>? attachments,
    DateTime? checkInTime,
    DateTime? checkOutTime,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
    Map<String, dynamic>? metadata,
  }) {
    return Appointment(
      id: id ?? this.id,
      petId: petId ?? this.petId,
      ownerId: ownerId ?? this.ownerId,
      doctorId: doctorId ?? this.doctorId,
      clinicId: clinicId ?? this.clinicId,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      type: type ?? this.type,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      symptoms: symptoms ?? this.symptoms,
      diagnosis: diagnosis ?? this.diagnosis,
      treatment: treatment ?? this.treatment,
      fee: fee ?? this.fee,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      attachments: attachments ?? this.attachments,
      checkInTime: checkInTime ?? this.checkInTime,
      checkOutTime: checkOutTime ?? this.checkOutTime,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isActive': isActive,
      'petId': petId,
      'ownerId': ownerId,
      'doctorId': doctorId,
      'clinicId': clinicId,
      'scheduledDate': scheduledDate.toIso8601String(),
      'durationMinutes': durationMinutes,
      'type': type.value,
      'status': status.value,
      'notes': notes,
      'symptoms': symptoms,
      'diagnosis': diagnosis,
      'treatment': treatment,
      'fee': fee,
      'paymentStatus': paymentStatus,
      'attachments': attachments,
      'checkInTime': checkInTime?.toIso8601String(),
      'checkOutTime': checkOutTime?.toIso8601String(),
      'metadata': metadata,
    };
  }
}

/// Appointment slot for scheduling
class AppointmentSlot {
  final DateTime startTime;
  final DateTime endTime;
  final bool isAvailable;
  final String? doctorId;
  final String? appointmentId;

  const AppointmentSlot({
    required this.startTime,
    required this.endTime,
    required this.isAvailable,
    this.doctorId,
    this.appointmentId,
  });

  /// Get duration in minutes
  int get durationMinutes => endTime.difference(startTime).inMinutes;

  /// Check if slot is in the past
  bool get isPast => endTime.isBefore(DateTime.now());

  /// Check if slot conflicts with another slot
  bool conflictsWith(AppointmentSlot other) {
    return startTime.isBefore(other.endTime) && endTime.isAfter(other.startTime);
  }

  factory AppointmentSlot.fromJson(Map<String, dynamic> json) {
    return AppointmentSlot(
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: DateTime.parse(json['endTime'] as String),
      isAvailable: json['isAvailable'] as bool? ?? true,
      doctorId: json['doctorId'] as String?,
      appointmentId: json['appointmentId'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'isAvailable': isAvailable,
      'doctorId': doctorId,
      'appointmentId': appointmentId,
    };
  }
}

/// Appointment reminder
class AppointmentReminder {
  final String appointmentId;
  final String userId;
  final DateTime reminderTime;
  final String message;
  final bool isSent;
  final DateTime? sentAt;

  const AppointmentReminder({
    required this.appointmentId,
    required this.userId,
    required this.reminderTime,
    required this.message,
    this.isSent = false,
    this.sentAt,
  });

  factory AppointmentReminder.fromJson(Map<String, dynamic> json) {
    return AppointmentReminder(
      appointmentId: json['appointmentId'] as String,
      userId: json['userId'] as String,
      reminderTime: DateTime.parse(json['reminderTime'] as String),
      message: json['message'] as String,
      isSent: json['isSent'] as bool? ?? false,
      sentAt: json['sentAt'] != null ? DateTime.parse(json['sentAt'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'appointmentId': appointmentId,
      'userId': userId,
      'reminderTime': reminderTime.toIso8601String(),
      'message': message,
      'isSent': isSent,
      'sentAt': sentAt?.toIso8601String(),
    };
  }
}
