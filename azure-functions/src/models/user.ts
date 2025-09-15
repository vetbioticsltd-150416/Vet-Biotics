import { ObjectId } from 'mongodb';
import { AuditableEntity, UserRole } from './base';

export interface User extends AuditableEntity {
    email: string;
    displayName: string;
    firstName?: string;
    lastName?: string;
    phoneNumber?: string;
    dateOfBirth?: Date;
    gender?: 'male' | 'female' | 'other';
    address?: Address;
    role: UserRole;
    profileImageUrl?: string;

    // Role-specific fields
    clinicId?: ObjectId | string; // For veterinarians and receptionists
    licenseNumber?: string; // For veterinarians
    specialties?: string[]; // For veterinarians

    // Authentication
    azureB2CId?: string;
    emailVerified?: boolean;
    lastLoginAt?: Date;

    // Preferences
    preferredLanguage?: string;
    notificationSettings?: NotificationSettings;

    // Emergency contact
    emergencyContact?: EmergencyContact;
}

export interface Address {
    street: string;
    city: string;
    state: string;
    postalCode: string;
    country: string;
}

export interface NotificationSettings {
    emailNotifications: boolean;
    pushNotifications: boolean;
    smsNotifications: boolean;
    appointmentReminders: boolean;
    marketingEmails: boolean;
}

export interface EmergencyContact {
    name: string;
    relationship: string;
    phoneNumber: string;
    email?: string;
}

export interface CreateUserRequest {
    email: string;
    displayName: string;
    firstName?: string;
    lastName?: string;
    phoneNumber?: string;
    dateOfBirth?: Date;
    gender?: 'male' | 'female' | 'other';
    address?: Address;
    role: UserRole;
    clinicId?: string;
    licenseNumber?: string;
    specialties?: string[];
    azureB2CId?: string;
}

export interface UpdateUserRequest {
    displayName?: string;
    firstName?: string;
    lastName?: string;
    phoneNumber?: string;
    dateOfBirth?: Date;
    gender?: 'male' | 'female' | 'other';
    address?: Address;
    profileImageUrl?: string;
    notificationSettings?: NotificationSettings;
    emergencyContact?: EmergencyContact;
}

export interface UserProfile extends Omit<User, 'azureB2CId' | 'createdBy' | 'updatedBy' | 'deletedBy'> {
    // Profile view excludes sensitive authentication data
}
