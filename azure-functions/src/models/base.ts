import { ObjectId } from 'mongodb';

export interface BaseEntity {
    _id?: ObjectId | string;
    id?: string;
    createdAt?: Date;
    updatedAt?: Date;
    createdBy?: string;
    updatedBy?: string;
    isActive?: boolean;
    version?: number;
}

export interface AuditableEntity extends BaseEntity {
    deletedAt?: Date;
    deletedBy?: string;
    isDeleted?: boolean;
}

export interface PaginatedResponse<T> {
    data: T[];
    pagination: {
        currentPage: number;
        totalPages: number;
        totalItems: number;
        itemsPerPage: number;
        hasNextPage: boolean;
        hasPreviousPage: boolean;
    };
    metadata?: Record<string, any>;
}

export interface ApiResponse<T = any> {
    success: boolean;
    data?: T;
    message?: string;
    error?: string;
    statusCode?: number;
    metadata?: Record<string, any>;
}

export enum UserRole {
    CLIENT = 'client',
    VETERINARIAN = 'veterinarian',
    RECEPTIONIST = 'receptionist',
    CLINIC_ADMIN = 'clinicAdmin',
    SUPER_ADMIN = 'superAdmin'
}

export enum AppointmentStatus {
    PENDING = 'pending',
    CONFIRMED = 'confirmed',
    IN_PROGRESS = 'inProgress',
    COMPLETED = 'completed',
    CANCELLED = 'cancelled',
    NO_SHOW = 'noShow'
}

export enum PaymentStatus {
    PENDING = 'pending',
    PAID = 'paid',
    REFUNDED = 'refunded',
    FAILED = 'failed',
    CANCELLED = 'cancelled'
}

export enum NotificationType {
    APPOINTMENT_REMINDER = 'appointment_reminder',
    APPOINTMENT_CONFIRMED = 'appointment_confirmed',
    APPOINTMENT_CANCELLED = 'appointment_cancelled',
    PAYMENT_SUCCESSFUL = 'payment_successful',
    PAYMENT_FAILED = 'payment_failed',
    MEDICAL_RECORD_UPDATED = 'medical_record_updated',
    WELCOME_MESSAGE = 'welcome_message',
    SYSTEM_MAINTENANCE = 'system_maintenance'
}

export class ValidationError extends Error {
    constructor(
        message: string,
        public field: string,
        public code: string = 'VALIDATION_ERROR'
    ) {
        super(message);
        this.name = 'ValidationError';
    }
}

export class NotFoundError extends Error {
    constructor(
        message: string,
        public resource: string,
        public id?: string
    ) {
        super(message);
        this.name = 'NotFoundError';
    }
}

export class UnauthorizedError extends Error {
    constructor(message: string = 'Unauthorized access') {
        super(message);
        this.name = 'UnauthorizedError';
    }
}

export class ForbiddenError extends Error {
    constructor(message: string = 'Access forbidden') {
        super(message);
        this.name = 'ForbiddenError';
    }
}
