# Azure Functions Backend - Vet Biotics

Azure Functions backend cho ứng dụng Vet Biotics, cung cấp các API endpoints cho authentication, appointments, medical records, billing, và notifications.

## 📁 Cấu trúc Project

```
azure-functions/
├── src/
│   ├── models/           # TypeScript interfaces và models
│   │   ├── base.ts
│   │   ├── user.ts
│   │   ├── pet.ts
│   │   ├── clinic.ts
│   │   ├── appointment.ts
│   │   ├── medical-record.ts
│   │   └── invoice.ts
│   ├── services/         # Business logic services
│   │   ├── database.service.ts
│   │   └── auth.service.ts
│   └── functions/        # Azure Functions
│       ├── index.ts
│       ├── auth/
│       │   ├── login.ts
│       │   ├── refresh-token.ts
│       │   ├── get-profile.ts
│       │   └── update-profile.ts
│       ├── appointments/
│       │   ├── create-appointment.ts
│       │   └── get-appointments.ts
│       └── ... (other function groups)
├── host.json            # Azure Functions host configuration
├── local.settings.json  # Local development settings
├── package.json         # Node.js dependencies
└── tsconfig.json        # TypeScript configuration
```

## 🚀 Cài đặt và Chạy Local

### Prerequisites
- Node.js 18+
- Azure Functions Core Tools
- Azure CLI (optional, for deployment)

### 1. Cài đặt Dependencies
```bash
cd azure-functions
npm install
```

### 2. Cấu hình Environment Variables
Sao chép và cập nhật `local.settings.json`:
```json
{
  "IsEncrypted": false,
  "Values": {
    "AzureWebJobsStorage": "UseDevelopmentStorage=true",
    "FUNCTIONS_WORKER_RUNTIME": "node",
    "FUNCTIONS_WORKER_RUNTIME_VERSION": "~18",

    // Azure Cosmos DB
    "COSMOS_DB_ENDPOINT": "https://your-cosmos-account.documents.azure.com:443/",
    "COSMOS_DB_KEY": "your-cosmos-db-key",
    "COSMOS_DB_DATABASE": "vetbiotics-prod-db",

    // Azure Blob Storage
    "AZURE_STORAGE_CONNECTION_STRING": "DefaultEndpointsProtocol=https;...",
    "PET_PHOTOS_CONTAINER": "pet-photos",
    "MEDICAL_DOCS_CONTAINER": "medical-docs",

    // Azure Notification Hubs
    "NOTIFICATION_HUB_CONNECTION_STRING": "your-notification-hub-connection",
    "NOTIFICATION_HUB_NAME": "vetbiotics-notifications",

    // Azure AD B2C
    "AZURE_AD_B2C_TENANT_ID": "your-tenant.onmicrosoft.com",
    "AZURE_AD_B2C_CLIENT_ID": "your-b2c-client-id",
    "AZURE_AD_B2C_CLIENT_SECRET": "your-b2c-client-secret",
    "AZURE_AD_B2C_POLICY_NAME": "B2C_1_SignUpSignIn",

    // JWT và Email settings
    "JWT_SECRET": "your-jwt-secret",
    "EMAIL_CONNECTION_STRING": "your-email-service-connection"
  }
}
```

### 3. Chạy Local Development
```bash
# Build TypeScript
npm run build

# Chạy Azure Functions
npm start
# hoặc
func start
```

### 4. Test API Endpoints
```bash
# Authentication
curl -X POST http://localhost:7071/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"authorizationCode": "your-auth-code"}'

# Get appointments
curl -X GET http://localhost:7071/api/v1/appointments \
  -H "Authorization: Bearer your-access-token"
```

## 📡 API Endpoints

### Authentication (`/api/v1/auth`)
- `POST /auth/login` - Đăng nhập với Azure AD B2C
- `POST /auth/refresh-token` - Refresh access token
- `GET /auth/profile` - Lấy thông tin profile
- `PUT /auth/profile` - Cập nhật profile

### Appointments (`/api/v1/appointments`)
- `GET /appointments` - Lấy danh sách appointments (có phân trang)
- `POST /appointments` - Tạo appointment mới
- `PUT /appointments/{id}` - Cập nhật appointment
- `DELETE /appointments/{id}` - Hủy appointment

### Medical Records (`/api/v1/medical-records`)
- `GET /medical-records` - Lấy medical records
- `POST /medical-records` - Tạo medical record mới
- `PUT /medical-records/{id}` - Cập nhật medical record

### Billing (`/api/v1/billing`)
- `GET /invoices` - Lấy danh sách invoices
- `POST /invoices` - Tạo invoice mới
- `POST /payments` - Xử lý thanh toán

### Files (`/api/v1/files`)
- `POST /files/upload` - Upload file
- `GET /files/{id}/url` - Lấy signed URL để download

## 🔧 Development Scripts

```bash
# Build project
npm run build

# Watch mode (auto rebuild)
npm run watch

# Run tests
npm test

# Run tests in watch mode
npm test:watch

# Clean build artifacts
npm run clean
```

## 🚀 Deployment to Azure

### 1. Tạo Azure Function App
```bash
# Sử dụng Azure CLI
az functionapp create \
  --name vetbiotics-functions \
  --resource-group VetBiotics-RG \
  --consumption-plan-location "East US" \
  --runtime node \
  --runtime-version 18 \
  --functions-version 4 \
  --storage-account vetbioticsstorage
```

### 2. Deploy Functions
```bash
# Sử dụng Azure Functions Core Tools
func azure functionapp publish vetbiotics-functions

# hoặc sử dụng GitHub Actions (recommended)
# Push to main branch để trigger deployment
```

### 3. Cấu hình Environment Variables
```bash
az functionapp config appsettings set \
  --name vetbiotics-functions \
  --resource-group VetBiotics-RG \
  --setting COSMOS_DB_ENDPOINT="https://..." \
  --setting COSMOS_DB_KEY="your-key" \
  --setting AZURE_AD_B2C_CLIENT_ID="your-client-id" \
  # ... other settings
```

## 🔐 Authentication & Authorization

### Azure AD B2C Integration
- Sử dụng Authorization Code flow
- JWT tokens cho API authentication
- Role-based access control (RBAC)
- Permission-based authorization

### User Roles & Permissions
- **Client**: Đọc/ghi appointments, pets, invoices của mình
- **Veterinarian**: Đọc/ghi medical records, appointments
- **Receptionist**: Quản lý appointments, invoices
- **Clinic Admin**: Quản lý clinic, staff, reports
- **Super Admin**: Toàn quyền hệ thống

## 📊 Database Schema

### Collections trong Azure Cosmos DB:
- `users` - Thông tin users
- `pets` - Thông tin pets
- `clinics` - Thông tin clinics
- `appointments` - Lịch hẹn
- `medicalRecords` - Hồ sơ bệnh án
- `invoices` - Hóa đơn
- `notifications` - Thông báo

### Indexes quan trọng:
```javascript
// Users collection
db.users.createIndex({ "email": 1 }, { unique: true });
db.users.createIndex({ "azureB2CId": 1 }, { unique: true });

// Appointments collection
db.appointments.createIndex({ "clinicId": 1, "scheduledDate": 1 });
db.appointments.createIndex({ "veterinarianId": 1, "scheduledDate": 1 });
db.appointments.createIndex({ "ownerId": 1, "scheduledDate": 1 });
```

## 📧 Notifications

### Azure Notification Hubs
- Push notifications cho mobile apps
- Email notifications qua SendGrid
- SMS notifications (optional)

### Notification Types
- Appointment reminders
- Payment confirmations
- Medical record updates
- System announcements

## 🔍 Monitoring & Logging

### Azure Application Insights
- Request/response tracking
- Performance monitoring
- Error tracking
- Custom metrics

### Logging Levels
- ERROR: Critical errors
- WARN: Warnings và potential issues
- INFO: General information
- DEBUG: Detailed debugging (development only)

## 🧪 Testing

```bash
# Unit tests
npm test

# Integration tests (yêu cầu Azure resources)
npm run test:integration

# Load testing với Artillery
npm run test:load
```

## 🔒 Security Best Practices

- ✅ JWT token validation
- ✅ Input sanitization
- ✅ SQL injection prevention
- ✅ Rate limiting
- ✅ CORS configuration
- ✅ HTTPS only
- ✅ Sensitive data encryption

## 📚 Additional Resources

- [Azure Functions Documentation](https://docs.microsoft.com/en-us/azure/azure-functions/)
- [Azure Cosmos DB Documentation](https://docs.microsoft.com/en-us/azure/cosmos-db/)
- [Azure AD B2C Documentation](https://docs.microsoft.com/en-us/azure/active-directory-b2c/)
- [Azure Notification Hubs](https://docs.microsoft.com/en-us/azure/notification-hubs/)

---

**Ready to deploy! 🚀**

Azure Functions backend đã sẵn sàng cho production với đầy đủ authentication, database operations, và business logic cho ứng dụng Vet Biotics.
