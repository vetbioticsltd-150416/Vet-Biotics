// Azure Functions main entry point
// This file imports all function definitions

// Authentication functions
export * from './auth/get-profile';
export * from './auth/login';
export * from './auth/refresh-token';
export * from './auth/update-profile';

// Appointment functions
export * from './appointments/cancel-appointment';
export * from './appointments/create-appointment';
export * from './appointments/get-appointments';
export * from './appointments/update-appointment';

// Medical record functions
export * from './medical-records/create-record';
export * from './medical-records/get-records';
export * from './medical-records/update-record';

// Billing functions
export * from './billing/create-invoice';
export * from './billing/get-invoices';
export * from './billing/process-payment';

// Notification functions
export * from './notifications/schedule-reminder';
export * from './notifications/send-notification';

// File upload functions
export * from './files/get-file-url';
export * from './files/upload-file';

