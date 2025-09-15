import { ObjectId } from 'mongodb';
import { AppointmentStatus, AuditableEntity, PaymentStatus } from './base';

export interface Appointment extends AuditableEntity {
    appointmentNumber: string; // Auto-generated unique identifier

    // Participants
    petId: ObjectId | string;
    ownerId: ObjectId | string;
    veterinarianId: ObjectId | string;
    clinicId: ObjectId | string;

    // Scheduling
    scheduledDate: Date;
    duration: number; // minutes
    endDate?: Date; // calculated from scheduledDate + duration

    // Status
    status: AppointmentStatus;
    reason: string;
    notes?: string;

    // Service information
    serviceId?: string; // Reference to clinic service
    serviceName: string;
    price: number;

    // Payment
    paymentStatus: PaymentStatus;
    paymentMethod?: string;
    paymentId?: string; // Stripe payment intent ID
    paidAmount?: number;

    // Medical information
    symptoms?: string[];
    diagnosis?: string;
    treatment?: string;
    prescription?: Prescription;

    // Follow-up
    followUpRequired?: boolean;
    followUpDate?: Date;
    followUpNotes?: string;

    // Check-in/out
    checkInTime?: Date;
    checkOutTime?: Date;
    actualDuration?: number; // actual time spent

    // Ratings and feedback
    rating?: number; // 1-5 stars
    feedback?: string;

    // Emergency
    isEmergency?: boolean;
    priority?: 'low' | 'medium' | 'high' | 'urgent';
}

export interface Prescription {
    medications: MedicationPrescription[];
    instructions: string;
    prescribedBy: ObjectId | string;
    prescribedDate: Date;
    validUntil?: Date;
    pharmacyNotes?: string;
}

export interface MedicationPrescription {
    medicationId?: string;
    name: string;
    dosage: string;
    frequency: string;
    duration: number; // days
    quantity: number;
    instructions: string;
    refills?: number;
}

export interface CreateAppointmentRequest {
    petId: string;
    ownerId: string;
    veterinarianId: string;
    clinicId: string;
    scheduledDate: Date;
    duration: number;
    reason: string;
    serviceId?: string;
    serviceName: string;
    price: number;
    notes?: string;
    symptoms?: string[];
    isEmergency?: boolean;
    priority?: 'low' | 'medium' | 'high' | 'urgent';
}

export interface UpdateAppointmentRequest {
    scheduledDate?: Date;
    duration?: number;
    reason?: string;
    serviceId?: string;
    serviceName?: string;
    price?: number;
    notes?: string;
    symptoms?: string[];
    status?: AppointmentStatus;
    diagnosis?: string;
    treatment?: string;
    prescription?: Prescription;
    followUpRequired?: boolean;
    followUpDate?: Date;
    followUpNotes?: string;
    isEmergency?: boolean;
    priority?: 'low' | 'medium' | 'high' | 'urgent';
}

export interface AppointmentWithDetails extends Appointment {
    pet: {
        _id: ObjectId | string;
        name: string;
        species: string;
        breed?: string;
        owner: {
            _id: ObjectId | string;
            displayName: string;
            phoneNumber?: string;
        };
    };
    veterinarian: {
        _id: ObjectId | string;
        displayName: string;
        email: string;
        specialties?: string[];
    };
    clinic: {
        _id: ObjectId | string;
        name: string;
        address: {
            street: string;
            city: string;
            state: string;
        };
        phoneNumber: string;
    };
}

export interface AppointmentSlot {
    date: string; // YYYY-MM-DD
    time: string; // HH:mm
    veterinarianId: ObjectId | string;
    clinicId: ObjectId | string;
    isAvailable: boolean;
    appointmentId?: ObjectId | string;
}

export interface AvailableSlotsRequest {
    veterinarianId: string;
    clinicId: string;
    date: string; // YYYY-MM-DD
    duration?: number; // minutes
}

export interface AppointmentSummary {
    appointmentId: ObjectId | string;
    appointmentNumber: string;
    petName: string;
    ownerName: string;
    veterinarianName: string;
    clinicName: string;
    scheduledDate: Date;
    status: AppointmentStatus;
    serviceName: string;
    price: number;
    paymentStatus: PaymentStatus;
}

export interface AppointmentStats {
    clinicId: ObjectId | string;
    veterinarianId?: ObjectId | string;
    period: 'day' | 'week' | 'month' | 'year';
    startDate: Date;
    endDate: Date;
    totalAppointments: number;
    completedAppointments: number;
    cancelledAppointments: number;
    noShowAppointments: number;
    totalRevenue: number;
    averageAppointmentDuration: number;
    mostPopularServices: Array<{
        serviceName: string;
        count: number;
    }>;
}
