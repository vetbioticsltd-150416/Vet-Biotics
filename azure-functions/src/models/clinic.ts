import { ObjectId } from 'mongodb';
import { AuditableEntity } from './base';

export interface Clinic extends AuditableEntity {
    name: string;
    description?: string;
    email: string;
    phoneNumber: string;
    website?: string;

    // Address
    address: ClinicAddress;

    // Business information
    licenseNumber: string;
    taxId?: string;
    businessHours: BusinessHours;

    // Owner/Admin
    ownerId: ObjectId | string;

    // Staff
    veterinarians: ObjectId[] | string[];
    receptionists: ObjectId[] | string[];

    // Services
    services: ClinicService[];
    specialties: string[];

    // Settings
    settings: ClinicSettings;

    // Images
    logoUrl?: string;
    images: string[];

    // Statistics
    totalPatients?: number;
    totalAppointments?: number;
    averageRating?: number;
    reviewCount?: number;
}

export interface ClinicAddress {
    street: string;
    city: string;
    state: string;
    postalCode: string;
    country: string;
    latitude?: number;
    longitude?: number;
}

export interface BusinessHours {
    monday: DaySchedule;
    tuesday: DaySchedule;
    wednesday: DaySchedule;
    thursday: DaySchedule;
    friday: DaySchedule;
    saturday: DaySchedule;
    sunday: DaySchedule;
}

export interface DaySchedule {
    isOpen: boolean;
    openTime?: string; // HH:mm format
    closeTime?: string; // HH:mm format
}

export interface ClinicService {
    id: string;
    name: string;
    description: string;
    duration: number; // minutes
    price: number;
    category: string;
    isActive: boolean;
}

export interface ClinicSettings {
    allowOnlineBooking: boolean;
    requireApprovalForBookings: boolean;
    cancellationPolicy: string;
    paymentMethods: PaymentMethod[];
    emergencyContact: EmergencyContact;
    timezone: string;
    currency: string;
    locale: string;
}

export interface PaymentMethod {
    type: 'cash' | 'credit_card' | 'debit_card' | 'bank_transfer' | 'digital_wallet';
    isActive: boolean;
    processingFee?: number;
}

export interface EmergencyContact {
    name: string;
    phoneNumber: string;
    email?: string;
    available24Hours: boolean;
}

export interface CreateClinicRequest {
    name: string;
    description?: string;
    email: string;
    phoneNumber: string;
    website?: string;
    address: ClinicAddress;
    licenseNumber: string;
    taxId?: string;
    businessHours: BusinessHours;
    ownerId: string;
    services?: ClinicService[];
    specialties?: string[];
    settings?: Partial<ClinicSettings>;
}

export interface UpdateClinicRequest {
    name?: string;
    description?: string;
    email?: string;
    phoneNumber?: string;
    website?: string;
    address?: Partial<ClinicAddress>;
    licenseNumber?: string;
    taxId?: string;
    businessHours?: Partial<BusinessHours>;
    services?: ClinicService[];
    specialties?: string[];
    settings?: Partial<ClinicSettings>;
    logoUrl?: string;
    images?: string[];
}

export interface ClinicWithStaff extends Clinic {
    owner: {
        _id: ObjectId | string;
        displayName: string;
        email: string;
    };
    veterinarians: Array<{
        _id: ObjectId | string;
        displayName: string;
        email: string;
        specialties?: string[];
    }>;
    receptionists: Array<{
        _id: ObjectId | string;
        displayName: string;
        email: string;
    }>;
}

export interface ClinicStats {
    clinicId: ObjectId | string;
    clinicName: string;
    totalPatients: number;
    totalAppointments: number;
    totalRevenue: number;
    averageRating: number;
    reviewCount: number;
    monthlyStats: MonthlyClinicStats[];
}

export interface MonthlyClinicStats {
    month: string; // YYYY-MM format
    appointments: number;
    revenue: number;
    newPatients: number;
    averageRating: number;
}
