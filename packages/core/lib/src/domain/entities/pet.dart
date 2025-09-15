import 'base_entity.dart';

/// Pet species
enum PetSpecies {
  dog('dog', 'Chó'),
  cat('cat', 'Mèo'),
  bird('bird', 'Chim'),
  rabbit('rabbit', 'Thỏ'),
  hamster('hamster', 'Hamster'),
  fish('fish', 'Cá'),
  reptile('reptile', 'Bò sát'),
  other('other', 'Khác');

  const PetSpecies(this.value, this.displayName);
  final String value;
  final String displayName;

  static PetSpecies fromString(String value) =>
      PetSpecies.values.firstWhere((species) => species.value == value, orElse: () => PetSpecies.other);
}

/// Pet gender
enum PetGender {
  male('male', 'Đực'),
  female('female', 'Cái'),
  unknown('unknown', 'Không xác định');

  const PetGender(this.value, this.displayName);
  final String value;
  final String displayName;

  static PetGender fromString(String value) =>
      PetGender.values.firstWhere((gender) => gender.value == value, orElse: () => PetGender.unknown);
}

/// Pet status
enum PetStatus {
  active('active', 'Hoạt động'),
  inactive('inactive', 'Không hoạt động'),
  deceased('deceased', 'Đã mất'),
  lost('lost', 'Bị mất');

  const PetStatus(this.value, this.displayName);
  final String value;
  final String displayName;

  static PetStatus fromString(String value) =>
      PetStatus.values.firstWhere((status) => status.value == value, orElse: () => PetStatus.active);

  bool get isActive => this == PetStatus.active;
  bool get isInactive => this == PetStatus.inactive;
  bool get isDeceased => this == PetStatus.deceased;
  bool get isLost => this == PetStatus.lost;
}

/// Pet entity
class Pet extends AuditableEntity {
  final String name;
  final PetSpecies species;
  final String? breed;
  final PetGender gender;
  final DateTime? dateOfBirth;
  final double? weight;
  final String? color;
  final String? microchipId;
  final List<String>? allergies;
  final List<String>? medications;
  final String? notes;
  final List<String>? photoUrls;
  final String ownerId;
  final PetStatus status;
  final DateTime? lastVisitDate;
  final Map<String, dynamic>? metadata;

  Pet({
    super.id = '',
    DateTime? createdAt,
    DateTime? updatedAt,
    super.isActive,
    required this.name,
    required this.species,
    this.breed,
    required this.gender,
    this.dateOfBirth,
    this.weight,
    this.color,
    this.microchipId,
    this.allergies,
    this.medications,
    this.notes,
    this.photoUrls,
    required this.ownerId,
    this.status = PetStatus.active,
    this.lastVisitDate,
    this.metadata,
  }) : super(createdAt: createdAt ?? DateTime.now(), updatedAt: updatedAt ?? DateTime.now());

  /// Get age in years
  int? get ageInYears {
    if (dateOfBirth == null) return null;
    final now = DateTime.now();
    int age = now.year - dateOfBirth!.year;
    if (now.month < dateOfBirth!.month || (now.month == dateOfBirth!.month && now.day < dateOfBirth!.day)) {
      age--;
    }
    return age;
  }

  /// Get age in months
  int? get ageInMonths {
    if (dateOfBirth == null) return null;
    final now = DateTime.now();
    final months = (now.year - dateOfBirth!.year) * 12 + now.month - dateOfBirth!.month;
    if (now.day < dateOfBirth!.day) {
      return months - 1;
    }
    return months;
  }

  /// Get age as formatted string
  String get ageString {
    final years = ageInYears;
    final months = ageInMonths;

    if (years == null || months == null) return 'Không xác định';

    if (years > 0) {
      if (months % 12 > 0) {
        return '$years năm ${months % 12} tháng';
      }
      return '$years năm';
    } else {
      return '$months tháng';
    }
  }

  /// Check if pet is puppy/kitten (under 1 year)
  bool get isYoung => ageInMonths != null && ageInMonths! < 12;

  /// Check if pet is senior (over 7 years for dogs, 10 years for cats)
  bool get isSenior {
    if (ageInYears == null) return false;
    final seniorAge = species == PetSpecies.cat ? 10 : 7;
    return ageInYears! >= seniorAge;
  }

  /// Get primary photo URL
  String? get primaryPhotoUrl => photoUrls?.isNotEmpty == true ? photoUrls!.first : null;

  /// Check if pet has allergies
  bool get hasAllergies => allergies?.isNotEmpty == true;

  /// Check if pet is on medication
  bool get isOnMedication => medications?.isNotEmpty == true;

  /// Check if pet needs vaccination (rough estimate)
  bool get needsVaccination {
    if (dateOfBirth == null) return true;
    final ageInDays = DateTime.now().difference(dateOfBirth!).inDays;
    // Basic vaccination schedule: every 1-3 years depending on type
    return ageInDays > 365; // Simplified check
  }

  @override
  List<Object?> get props => [
    ...super.props,
    name,
    species,
    breed,
    gender,
    dateOfBirth,
    weight,
    color,
    microchipId,
    allergies,
    medications,
    notes,
    photoUrls,
    ownerId,
    status,
    lastVisitDate,
    metadata,
  ];

  @override
  bool get isValid => name.isNotEmpty && ownerId.isNotEmpty;

  @override
  List<String> get validationErrors {
    final errors = <String>[];

    if (name.isEmpty) {
      errors.add('Tên thú cưng không được để trống');
    } else if (name.length > 50) {
      errors.add('Tên thú cưng không được vượt quá 50 ký tự');
    }

    if (ownerId.isEmpty) {
      errors.add('Chủ sở hữu không được để trống');
    }

    if (weight != null && (weight! <= 0 || weight! > 200)) {
      errors.add('Cân nặng phải từ 0.1 đến 200 kg');
    }

    if (microchipId != null && microchipId!.length > 20) {
      errors.add('Mã microchip không được vượt quá 20 ký tự');
    }

    return errors;
  }

  /// Create a copy with updated fields
  @override
  Pet copyWith({
    String? id,
    String? name,
    PetSpecies? species,
    String? breed,
    PetGender? gender,
    DateTime? dateOfBirth,
    double? weight,
    String? color,
    String? microchipId,
    List<String>? allergies,
    List<String>? medications,
    String? notes,
    List<String>? photoUrls,
    String? ownerId,
    PetStatus? status,
    DateTime? lastVisitDate,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
    Map<String, dynamic>? metadata,
  }) => Pet(
    id: id ?? this.id,
    name: name ?? this.name,
    species: species ?? this.species,
    breed: breed ?? this.breed,
    gender: gender ?? this.gender,
    dateOfBirth: dateOfBirth ?? this.dateOfBirth,
    weight: weight ?? this.weight,
    color: color ?? this.color,
    microchipId: microchipId ?? this.microchipId,
    allergies: allergies ?? this.allergies,
    medications: medications ?? this.medications,
    notes: notes ?? this.notes,
    photoUrls: photoUrls ?? this.photoUrls,
    ownerId: ownerId ?? this.ownerId,
    status: status ?? this.status,
    lastVisitDate: lastVisitDate ?? this.lastVisitDate,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    isActive: isActive ?? this.isActive,
    metadata: metadata ?? this.metadata,
  );

  @override
  Map<String, dynamic> toJson() => {
    'id': id,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
    'isActive': isActive,
    'name': name,
    'species': species.value,
    'breed': breed,
    'color': color,
    'dateOfBirth': dateOfBirth?.toIso8601String(),
    'gender': gender.value,
    'weight': weight,
    'microchipId': microchipId,
    'allergies': allergies,
    'medications': medications,
    'notes': notes,
    'photoUrls': photoUrls,
    'ownerId': ownerId,
    'status': status.value,
    'lastVisitDate': lastVisitDate?.toIso8601String(),
    'metadata': metadata,
  };
}

/// Pet breed information
class PetBreed {
  final String id;
  final String name;
  final PetSpecies species;
  final String? description;
  final double? averageWeight;
  final int? averageLifespan;
  final List<String>? characteristics;
  final String? origin;

  const PetBreed({
    required this.id,
    required this.name,
    required this.species,
    this.description,
    this.averageWeight,
    this.averageLifespan,
    this.characteristics,
    this.origin,
  });

  factory PetBreed.fromJson(Map<String, dynamic> json) => PetBreed(
    id: json['id'] as String,
    name: json['name'] as String,
    species: PetSpecies.fromString(json['species'] as String),
    description: json['description'] as String?,
    averageWeight: (json['averageWeight'] as num?)?.toDouble(),
    averageLifespan: json['averageLifespan'] as int?,
    characteristics: (json['characteristics'] as List<dynamic>?)?.cast<String>(),
    origin: json['origin'] as String?,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'species': species.value,
    'description': description,
    'averageWeight': averageWeight,
    'averageLifespan': averageLifespan,
    'characteristics': characteristics,
    'origin': origin,
  };
}

/// Pet medical history summary
class PetMedicalSummary {
  final String petId;
  final int totalVisits;
  final DateTime? lastVisitDate;
  final List<String> currentMedications;
  final List<String> allergies;
  final bool needsVaccination;
  final String? nextAppointmentDate;

  const PetMedicalSummary({
    required this.petId,
    required this.totalVisits,
    this.lastVisitDate,
    required this.currentMedications,
    required this.allergies,
    required this.needsVaccination,
    this.nextAppointmentDate,
  });

  factory PetMedicalSummary.fromJson(Map<String, dynamic> json) => PetMedicalSummary(
    petId: json['petId'] as String,
    totalVisits: json['totalVisits'] as int? ?? 0,
    lastVisitDate: json['lastVisitDate'] != null ? DateTime.parse(json['lastVisitDate'] as String) : null,
    currentMedications: (json['currentMedications'] as List<dynamic>?)?.cast<String>() ?? [],
    allergies: (json['allergies'] as List<dynamic>?)?.cast<String>() ?? [],
    needsVaccination: json['needsVaccination'] as bool? ?? false,
    nextAppointmentDate: json['nextAppointmentDate'] as String?,
  );

  Map<String, dynamic> toJson() => {
    'petId': petId,
    'totalVisits': totalVisits,
    'lastVisitDate': lastVisitDate?.toIso8601String(),
    'currentMedications': currentMedications,
    'allergies': allergies,
    'needsVaccination': needsVaccination,
    'nextAppointmentDate': nextAppointmentDate,
  };
}
