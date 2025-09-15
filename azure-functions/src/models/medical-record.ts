import { ObjectId } from 'mongodb';
import { AuditableEntity } from './base';

export interface MedicalRecord extends AuditableEntity {
    recordNumber: string; // Auto-generated unique identifier

    // Patient information
    petId: ObjectId | string;
    ownerId: ObjectId | string;

    // Visit information
    appointmentId?: ObjectId | string;
    visitDate: Date;
    veterinarianId: ObjectId | string;
    clinicId: ObjectId | string;

    // Medical information
    chiefComplaint: string;
    historyOfPresentIllness?: string;
    physicalExamination: PhysicalExamination;
    vitalSigns: VitalSigns;

    // Diagnosis
    diagnosis: Diagnosis[];
    differentialDiagnosis?: string[];

    // Treatment
    treatment: Treatment;
    medications: MedicationRecord[];
    procedures?: ProcedureRecord[];

    // Lab results
    labResults?: LabResult[];

    // Imaging
    imagingStudies?: ImagingStudy[];

    // Follow-up
    followUpInstructions?: string;
    followUpDate?: Date;
    prognosis?: string;

    // Documentation
    notes?: string;
    attachments?: string[]; // URLs to medical documents/images

    // Quality control
    reviewedBy?: ObjectId | string; // senior veterinarian
    reviewDate?: Date;
    reviewNotes?: string;
}

export interface PhysicalExamination {
    generalAppearance?: string;
    cardiovascular?: string;
    respiratory?: string;
    gastrointestinal?: string;
    urinary?: string;
    reproductive?: string;
    musculoskeletal?: string;
    neurological?: string;
    dermatological?: string;
    ophthalmic?: string;
    dental?: string;
    lymphNodes?: string;
    otherFindings?: string;
}

export interface VitalSigns {
    temperature?: number; // Celsius
    heartRate?: number; // BPM
    respiratoryRate?: number; // breaths per minute
    weight?: number; // kg
    bodyConditionScore?: number; // 1-9 scale
    painScore?: number; // 0-10 scale
    capillaryRefillTime?: number; // seconds
    mucousMembraneColor?: string;
    dehydrationLevel?: string;
}

export interface Diagnosis {
    icdCode?: string; // International Classification of Diseases code
    description: string;
    isPrimary: boolean;
    confidence?: 'suspected' | 'probable' | 'confirmed';
    notes?: string;
}

export interface Treatment {
    therapeuticPlan: string;
    responseToTreatment?: string;
    complications?: string[];
    outcome?: 'improved' | 'unchanged' | 'worsened' | 'deceased';
    dischargeDate?: Date;
}

export interface MedicationRecord {
    medicationId?: string;
    name: string;
    dosage: string;
    route: 'oral' | 'injectable' | 'topical' | 'inhaled' | 'otic' | 'ophthalmic' | 'rectal';
    frequency: string;
    duration: number; // days
    quantity: number;
    startDate: Date;
    endDate?: Date;
    indication: string;
    adverseEffects?: string[];
    compliance?: 'excellent' | 'good' | 'fair' | 'poor';
    notes?: string;
}

export interface ProcedureRecord {
    procedureName: string;
    description: string;
    datePerformed: Date;
    performedBy: ObjectId | string;
    anesthesiaUsed?: string;
    complications?: string[];
    outcome: string;
    followUpRequired?: boolean;
    cost?: number;
    notes?: string;
}

export interface LabResult {
    testName: string;
    category: 'hematology' | 'biochemistry' | 'urinalysis' | 'microbiology' | 'parasitology' | 'endocrinology' | 'other';
    result: string;
    unit?: string;
    referenceRange?: string;
    abnormal?: boolean;
    critical?: boolean;
    datePerformed: Date;
    labTechnician?: string;
    notes?: string;
}

export interface ImagingStudy {
    studyType: 'radiograph' | 'ultrasound' | 'ct' | 'mri' | 'other';
    bodyPart: string;
    findings: string;
    impression: string;
    datePerformed: Date;
    radiologist?: ObjectId | string;
    imageUrls?: string[];
    cost?: number;
    notes?: string;
}

export interface CreateMedicalRecordRequest {
    petId: string;
    ownerId: string;
    appointmentId?: string;
    visitDate: Date;
    veterinarianId: string;
    clinicId: string;
    chiefComplaint: string;
    historyOfPresentIllness?: string;
    physicalExamination: PhysicalExamination;
    vitalSigns: VitalSigns;
    diagnosis: Diagnosis[];
    differentialDiagnosis?: string[];
    treatment: Treatment;
    medications: MedicationRecord[];
    procedures?: ProcedureRecord[];
    labResults?: LabResult[];
    imagingStudies?: ImagingStudy[];
    followUpInstructions?: string;
    followUpDate?: Date;
    prognosis?: string;
    notes?: string;
    attachments?: string[];
}

export interface UpdateMedicalRecordRequest {
    chiefComplaint?: string;
    historyOfPresentIllness?: string;
    physicalExamination?: Partial<PhysicalExamination>;
    vitalSigns?: Partial<VitalSigns>;
    diagnosis?: Diagnosis[];
    differentialDiagnosis?: string[];
    treatment?: Partial<Treatment>;
    medications?: MedicationRecord[];
    procedures?: ProcedureRecord[];
    labResults?: LabResult[];
    imagingStudies?: ImagingStudy[];
    followUpInstructions?: string;
    followUpDate?: Date;
    prognosis?: string;
    notes?: string;
    attachments?: string[];
    reviewedBy?: string;
    reviewNotes?: string;
}

export interface MedicalRecordSummary {
    recordId: ObjectId | string;
    recordNumber: string;
    petName: string;
    petSpecies: string;
    ownerName: string;
    veterinarianName: string;
    clinicName: string;
    visitDate: Date;
    chiefComplaint: string;
    primaryDiagnosis?: string;
    treatment: string;
    medicationsCount: number;
    proceduresCount: number;
    followUpRequired: boolean;
    followUpDate?: Date;
}

export interface PetMedicalHistory {
    petId: ObjectId | string;
    petName: string;
    petSpecies: string;
    ownerName: string;
    totalRecords: number;
    lastVisitDate?: Date;
    records: MedicalRecordSummary[];
    chronicConditions: string[];
    allergies: string[];
    currentMedications: MedicationRecord[];
    vaccinationHistory: Array<{
        vaccineName: string;
        dateAdministered: Date;
        nextDueDate?: Date;
    }>;
}
