import 'base_entity.dart';

/// Medical record type
enum MedicalRecordType {
  consultation('consultation', 'Khám bệnh'),
  vaccination('vaccination', 'Tiêm phòng'),
  surgery('surgery', 'Phẫu thuật'),
  dental('dental', 'Khám răng'),
  laboratory('laboratory', 'Xét nghiệm'),
  imaging('imaging', 'Chụp chiếu'),
  prescription('prescription', 'Đơn thuốc'),
  followUp('follow_up', 'Tái khám');

  const MedicalRecordType(this.value, this.displayName);
  final String value;
  final String displayName;

  static MedicalRecordType fromString(String value) =>
      MedicalRecordType.values.firstWhere((type) => type.value == value, orElse: () => MedicalRecordType.consultation);
}

/// Medical record entity
class MedicalRecord extends AuditableEntity {
  final String petId;
  final String appointmentId;
  final String doctorId;
  final String clinicId;
  final MedicalRecordType type;
  final DateTime recordDate;
  final String? symptoms;
  final String? diagnosis;
  final String? treatment;
  final String? notes;
  final List<String>? medications;
  final List<String>? attachments;
  final double? weight;
  final String? temperature;
  final Map<String, dynamic>? vitalSigns;
  final DateTime? followUpDate;
  final Map<String, dynamic>? metadata;

  MedicalRecord({
    super.id = '',
    DateTime? createdAt,
    DateTime? updatedAt,
    super.isActive,
    required this.petId,
    required this.appointmentId,
    required this.doctorId,
    required this.clinicId,
    required this.type,
    required this.recordDate,
    this.symptoms,
    this.diagnosis,
    this.treatment,
    this.notes,
    this.medications,
    this.attachments,
    this.weight,
    this.temperature,
    this.vitalSigns,
    this.followUpDate,
    this.metadata,
  }) : super(createdAt: createdAt ?? DateTime.now(), updatedAt: updatedAt ?? DateTime.now());

  @override
  List<Object?> get props => [
    ...super.props,
    petId,
    appointmentId,
    doctorId,
    clinicId,
    type,
    recordDate,
    symptoms,
    diagnosis,
    treatment,
    notes,
    medications,
    attachments,
    weight,
    temperature,
    vitalSigns,
    followUpDate,
    metadata,
  ];

  @override
  bool get isValid => petId.isNotEmpty && appointmentId.isNotEmpty && doctorId.isNotEmpty && clinicId.isNotEmpty;

  @override
  List<String> get validationErrors {
    final errors = <String>[];

    if (petId.isEmpty) errors.add('Thú cưng không được để trống');
    if (appointmentId.isEmpty) errors.add('Lịch hẹn không được để trống');
    if (doctorId.isEmpty) errors.add('Bác sĩ không được để trống');
    if (clinicId.isEmpty) errors.add('Phòng khám không được để trống');

    if (weight != null && (weight! <= 0 || weight! > 200)) {
      errors.add('Cân nặng phải từ 0.1 đến 200 kg');
    }

    return errors;
  }

  @override
  MedicalRecord copyWith({
    String? id,
    String? petId,
    String? appointmentId,
    String? doctorId,
    String? clinicId,
    MedicalRecordType? type,
    DateTime? recordDate,
    String? symptoms,
    String? diagnosis,
    String? treatment,
    String? notes,
    List<String>? medications,
    List<String>? attachments,
    double? weight,
    String? temperature,
    Map<String, dynamic>? vitalSigns,
    DateTime? followUpDate,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
    Map<String, dynamic>? metadata,
  }) => MedicalRecord(
    id: id ?? this.id,
    petId: petId ?? this.petId,
    appointmentId: appointmentId ?? this.appointmentId,
    doctorId: doctorId ?? this.doctorId,
    clinicId: clinicId ?? this.clinicId,
    type: type ?? this.type,
    recordDate: recordDate ?? this.recordDate,
    symptoms: symptoms ?? this.symptoms,
    diagnosis: diagnosis ?? this.diagnosis,
    treatment: treatment ?? this.treatment,
    notes: notes ?? this.notes,
    medications: medications ?? this.medications,
    attachments: attachments ?? this.attachments,
    weight: weight ?? this.weight,
    temperature: temperature ?? this.temperature,
    vitalSigns: vitalSigns ?? this.vitalSigns,
    followUpDate: followUpDate ?? this.followUpDate,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: createdAt ?? this.updatedAt,
    isActive: isActive ?? this.isActive,
    metadata: metadata ?? this.metadata,
  );

  @override
  Map<String, dynamic> toJson() => {
    'id': id,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
    'isActive': isActive,
    'petId': petId,
    'appointmentId': appointmentId,
    'doctorId': doctorId,
    'clinicId': clinicId,
    'recordDate': recordDate.toIso8601String(),
    'type': type.value,
    'symptoms': symptoms,
    'diagnosis': diagnosis,
    'treatment': treatment,
    'medications': medications,
    'notes': notes,
    'vitalSigns': vitalSigns,
    'attachments': attachments,
    'followUpDate': followUpDate?.toIso8601String(),
    'metadata': metadata,
  };
}

/// Prescription entity
class Prescription extends AuditableEntity {
  final String medicalRecordId;
  final String petId;
  final String doctorId;
  final List<PrescriptionItem> items;
  final String? instructions;
  final DateTime? validUntil;
  @override
  final bool isActive;

  Prescription({
    super.id = '',
    DateTime? createdAt,
    DateTime? updatedAt,
    super.isActive,
    required this.medicalRecordId,
    required this.petId,
    required this.doctorId,
    required this.items,
    this.instructions,
    this.validUntil,
  }) : super(createdAt: createdAt ?? DateTime.now(), updatedAt: updatedAt ?? DateTime.now()),
       isActive = isActive;

  @override
  List<Object?> get props => [
    ...super.props,
    medicalRecordId,
    petId,
    doctorId,
    items,
    instructions,
    validUntil,
    isActive,
  ];

  bool get isExpired => validUntil?.isBefore(DateTime.now()) ?? false;

  @override
  Map<String, dynamic> toJson() => {
    'id': id,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
    'isActive': isActive,
    'medicalRecordId': medicalRecordId,
    'petId': petId,
    'doctorId': doctorId,
    'items': items.map((item) => item.toJson()).toList(),
    'instructions': instructions,
    'validUntil': validUntil?.toIso8601String(),
  };
}

/// Prescription item
class PrescriptionItem {
  final String medicationId;
  final String medicationName;
  final String dosage;
  final String frequency;
  final int duration;
  final String? instructions;

  const PrescriptionItem({
    required this.medicationId,
    required this.medicationName,
    required this.dosage,
    required this.frequency,
    required this.duration,
    this.instructions,
  });

  factory PrescriptionItem.fromJson(Map<String, dynamic> json) => PrescriptionItem(
    medicationId: json['medicationId'] as String,
    medicationName: json['medicationName'] as String,
    dosage: json['dosage'] as String,
    frequency: json['frequency'] as String,
    duration: json['duration'] as int,
    instructions: json['instructions'] as String?,
  );

  Map<String, dynamic> toJson() => {
    'medicationId': medicationId,
    'medicationName': medicationName,
    'dosage': dosage,
    'frequency': frequency,
    'duration': duration,
    'instructions': instructions,
  };
}

/// Vaccination record
class VaccinationRecord extends AuditableEntity {
  final String petId;
  final String vaccineId;
  final String vaccineName;
  final DateTime vaccinationDate;
  final DateTime? nextDueDate;
  final String? batchNumber;
  final String? administeredBy;
  final String? notes;

  VaccinationRecord({
    super.id = '',
    DateTime? createdAt,
    DateTime? updatedAt,
    super.isActive,
    required this.petId,
    required this.vaccineId,
    required this.vaccineName,
    required this.vaccinationDate,
    this.nextDueDate,
    this.batchNumber,
    this.administeredBy,
    this.notes,
  }) : super(createdAt: createdAt ?? DateTime.now(), updatedAt: updatedAt ?? DateTime.now());

  @override
  List<Object?> get props => [
    ...super.props,
    petId,
    vaccineId,
    vaccineName,
    vaccinationDate,
    nextDueDate,
    batchNumber,
    administeredBy,
    notes,
  ];

  bool get isOverdue => nextDueDate?.isBefore(DateTime.now()) ?? false;

  @override
  Map<String, dynamic> toJson() => {
    'id': id,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
    'isActive': isActive,
    'petId': petId,
    'vaccineId': vaccineId,
    'vaccineName': vaccineName,
    'vaccinationDate': vaccinationDate.toIso8601String(),
    'nextDueDate': nextDueDate?.toIso8601String(),
    'batchNumber': batchNumber,
    'administeredBy': administeredBy,
    'notes': notes,
  };
}
