import { ObjectId } from 'mongodb';
import { AuditableEntity } from './base';

export interface Pet extends AuditableEntity {
    name: string;
    species: string; // dog, cat, bird, etc.
    breed?: string;
    dateOfBirth?: Date;
    gender?: 'male' | 'female' | 'unknown';
    color?: string;
    weight?: number; // in kg
    microchipNumber?: string;
    registrationNumber?: string;

    // Owner information
    ownerId: ObjectId | string;

    // Medical information
    isNeutered?: boolean;
    allergies?: string[];
    medications?: Medication[];
    vaccinationHistory?: VaccinationRecord[];
    medicalConditions?: string[];

    // Photos and documents
    profileImageUrl?: string;
    medicalDocumentUrls?: string[];

    // Emergency information
    emergencyVet?: EmergencyVet;
    bloodType?: string;

    // Statistics
    totalVisits?: number;
    lastVisitDate?: Date;
    nextAppointmentDate?: Date;
}

export interface Medication {
    name: string;
    dosage: string;
    frequency: string;
    startDate: Date;
    endDate?: Date;
    prescribedBy: ObjectId | string; // veterinarian ID
    notes?: string;
}

export interface VaccinationRecord {
    vaccineName: string;
    dateAdministered: Date;
    nextDueDate?: Date;
    administeredBy: ObjectId | string; // veterinarian ID
    batchNumber?: string;
    manufacturer?: string;
    notes?: string;
}

export interface EmergencyVet {
    name: string;
    clinicName: string;
    phoneNumber: string;
    address: string;
    notes?: string;
}

export interface CreatePetRequest {
    name: string;
    species: string;
    breed?: string;
    dateOfBirth?: Date;
    gender?: 'male' | 'female' | 'unknown';
    color?: string;
    weight?: number;
    microchipNumber?: string;
    registrationNumber?: string;
    ownerId: string;
    isNeutered?: boolean;
    allergies?: string[];
    medicalConditions?: string[];
    emergencyVet?: EmergencyVet;
    bloodType?: string;
}

export interface UpdatePetRequest {
    name?: string;
    breed?: string;
    dateOfBirth?: Date;
    gender?: 'male' | 'female' | 'unknown';
    color?: string;
    weight?: number;
    microchipNumber?: string;
    registrationNumber?: string;
    isNeutered?: boolean;
    allergies?: string[];
    medicalConditions?: string[];
    emergencyVet?: EmergencyVet;
    bloodType?: string;
    profileImageUrl?: string;
}

export interface PetWithOwner extends Pet {
    owner: {
        _id: ObjectId | string;
        displayName: string;
        email: string;
        phoneNumber?: string;
    };
}

export interface PetMedicalSummary {
    petId: ObjectId | string;
    petName: string;
    species: string;
    breed?: string;
    totalVisits: number;
    lastVisitDate?: Date;
    upcomingVaccinations: VaccinationRecord[];
    activeMedications: Medication[];
    allergies: string[];
    medicalConditions: string[];
}
