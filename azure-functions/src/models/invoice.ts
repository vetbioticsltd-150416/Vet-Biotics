import { ObjectId } from 'mongodb';
import { AuditableEntity, PaymentStatus } from './base';

export interface Invoice extends AuditableEntity {
    invoiceNumber: string; // Auto-generated unique identifier

    // Client information
    ownerId: ObjectId | string;
    petId?: ObjectId | string; // Optional, for pet-specific invoices

    // Clinic information
    clinicId: ObjectId | string;
    veterinarianId?: ObjectId | string;

    // Invoice details
    issueDate: Date;
    dueDate: Date;
    appointmentId?: ObjectId | string;

    // Items
    items: InvoiceItem[];

    // Financial calculations
    subtotal: number;
    taxRate: number; // percentage
    taxAmount: number;
    discountAmount?: number;
    discountReason?: string;
    totalAmount: number;

    // Payment information
    paymentStatus: PaymentStatus;
    paymentMethod?: string;
    paymentDate?: Date;
    paymentReference?: string; // Stripe payment intent ID, check number, etc.
    paidAmount?: number;

    // Partial payments
    partialPayments?: PartialPayment[];

    // Notes and terms
    notes?: string;
    termsAndConditions?: string;

    // Status tracking
    sentDate?: Date;
    viewedDate?: Date;
    reminderSentDate?: Date;

    // Overdue tracking
    isOverdue?: boolean;
    overdueDays?: number;
    lastReminderDate?: Date;
    collectionStatus?: 'active' | 'sent_to_collections' | 'written_off' | 'paid';
}

export interface InvoiceItem {
    id: string;
    description: string;
    quantity: number;
    unitPrice: number;
    discount?: number; // percentage or amount
    taxRate?: number; // percentage
    totalAmount: number;
    category: 'consultation' | 'procedure' | 'medication' | 'vaccination' | 'laboratory' | 'imaging' | 'other';
    referenceId?: string; // appointment ID, medication ID, etc.
    notes?: string;
}

export interface PartialPayment {
    amount: number;
    paymentDate: Date;
    paymentMethod: string;
    paymentReference?: string;
    notes?: string;
    recordedBy: ObjectId | string;
}

export interface CreateInvoiceRequest {
    ownerId: string;
    petId?: string;
    clinicId: string;
    veterinarianId?: string;
    appointmentId?: string;
    dueDate: Date;
    items: Omit<InvoiceItem, 'id' | 'totalAmount'>[];
    taxRate?: number;
    discountAmount?: number;
    discountReason?: string;
    notes?: string;
    termsAndConditions?: string;
}

export interface UpdateInvoiceRequest {
    dueDate?: Date;
    items?: InvoiceItem[];
    taxRate?: number;
    discountAmount?: number;
    discountReason?: string;
    notes?: string;
    termsAndConditions?: string;
    paymentStatus?: PaymentStatus;
}

export interface InvoiceWithDetails extends Invoice {
    owner: {
        _id: ObjectId | string;
        displayName: string;
        email: string;
        phoneNumber?: string;
        address?: {
            street: string;
            city: string;
            state: string;
            postalCode: string;
        };
    };
    pet?: {
        _id: ObjectId | string;
        name: string;
        species: string;
        breed?: string;
    };
    clinic: {
        _id: ObjectId | string;
        name: string;
        address: {
            street: string;
            city: string;
            state: string;
            postalCode: string;
        };
        phoneNumber: string;
        email: string;
        taxId?: string;
    };
    veterinarian?: {
        _id: ObjectId | string;
        displayName: string;
        licenseNumber?: string;
    };
    appointment?: {
        appointmentNumber: string;
        scheduledDate: Date;
        serviceName: string;
    };
}

export interface InvoiceSummary {
    invoiceId: ObjectId | string;
    invoiceNumber: string;
    ownerName: string;
    petName?: string;
    clinicName: string;
    issueDate: Date;
    dueDate: Date;
    totalAmount: number;
    paymentStatus: PaymentStatus;
    isOverdue: boolean;
    overdueDays?: number;
}

export interface PaymentRequest {
    invoiceId: string;
    amount: number;
    paymentMethod: string;
    paymentReference?: string;
    notes?: string;
}

export interface InvoiceStats {
    clinicId: ObjectId | string;
    period: 'day' | 'week' | 'month' | 'year';
    startDate: Date;
    endDate: Date;
    totalInvoices: number;
    totalRevenue: number;
    paidInvoices: number;
    pendingInvoices: number;
    overdueInvoices: number;
    averageInvoiceAmount: number;
    paymentMethods: Record<string, number>; // payment method -> count
    topServices: Array<{
        serviceName: string;
        revenue: number;
        count: number;
    }>;
}

export interface RevenueReport {
    clinicId: ObjectId | string;
    period: 'daily' | 'weekly' | 'monthly' | 'yearly';
    startDate: Date;
    endDate: Date;
    totalRevenue: number;
    totalInvoices: number;
    averageInvoiceValue: number;
    revenueByCategory: Record<string, number>;
    revenueByPaymentMethod: Record<string, number>;
    outstandingInvoices: number;
    overdueAmount: number;
    collectionRate: number; // percentage of paid vs total invoices
}
