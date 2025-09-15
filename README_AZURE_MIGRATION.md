# Azure Migration Roadmap - Vet Biotics

## 📊 **Current Firebase Implementation Assessment**

### ✅ **Implemented Firebase Services:**
- **Firebase Auth**: Authentication với email/password, Google Sign-In
- **Cloud Firestore**: Database cho tất cả entities (users, pets, appointments, clinics, medical records, invoices)
- **Firebase Storage**: File storage cho pet photos, medical documents

### 📈 **Data Volume Estimate:**
- Users: ~10K (clients, veterinarians, receptionists, admins)
- Pets: ~15K records
- Appointments: ~50K records/month
- Medical Records: ~100K records
- Clinics: ~500 records

---

## 🏗️ **Azure Architecture Plan**

### **1. Azure Services Mapping**

| Firebase Service | Azure Service | Migration Strategy |
|---|---|---|
| **Firebase Auth** | **Azure AD B2C** | Direct replacement với enhanced features |
| **Cloud Firestore** | **Azure Cosmos DB** (MongoDB API) | Schema-compatible migration |
| **Firebase Storage** | **Azure Blob Storage** | Direct file migration |
| **Firebase Cloud Functions** | **Azure Functions** | Serverless functions migration |
| **Firebase Hosting** | **Azure Static Web Apps** | SPA hosting |
| **Firebase Cloud Messaging** | **Azure Notification Hubs** | Push notification service |

### **2. Azure Resource Architecture**

```
📁 VetBiotics-Azure-RG (Resource Group)
├── 🔐 Azure AD B2C (Authentication)
├── 🗄️ Azure Cosmos DB (MongoDB API)
│   ├── vetbiotics-prod-db
│   └── vetbiotics-dev-db
├── ☁️ Azure Functions (Backend Logic)
│   ├── auth-functions
│   ├── notification-functions
│   └── business-logic-functions
├── 📦 Azure Blob Storage
│   ├── pet-photos-container
│   └── medical-docs-container
├── 📨 Azure Notification Hubs
│   └── vetbiotics-notifications
├── 🌐 Azure Static Web Apps
│   ├── admin-portal
│   ├── clinic-portal
│   └── user-portal
└── 📊 Azure Monitor & Application Insights
```

---

## 🚀 **Migration Phases**

### **Phase 1: Infrastructure Setup (1-2 weeks)**

#### **1.1 Azure Account & Resource Setup**
```bash
# Create resource group
az group create --name VetBiotics-RG --location "East US"

# Create Azure AD B2C tenant
az ad b2c tenant create --name vetbiotics.onmicrosoft.com

# Setup Azure CLI authentication
az login
az account set --subscription "VetBiotics-Subscription"
```

#### **1.2 Azure Cosmos DB Setup**
```bash
# Create Cosmos DB account
az cosmosdb create \
  --name vetbiotics-cosmos \
  --resource-group VetBiotics-RG \
  --kind MongoDB \
  --server-version 4.2

# Create databases
az cosmosdb mongodb database create \
  --account-name vetbiotics-cosmos \
  --name vetbiotics-prod-db \
  --resource-group VetBiotics-RG
```

#### **1.3 Azure Blob Storage Setup**
```bash
# Create storage account
az storage account create \
  --name vetbioticsstorage \
  --resource-group VetBiotics-RG \
  --location "East US" \
  --sku Standard_LRS \
  --kind StorageV2

# Create containers
az storage container create \
  --name pet-photos \
  --account-name vetbioticsstorage

az storage container create \
  --name medical-docs \
  --account-name vetbioticsstorage
```

### **Phase 2: Authentication Migration (1 week)**

#### **2.1 Azure AD B2C Configuration**
```json
// Azure AD B2C User Flows
{
  "signUpSignIn": {
    "name": "B2C_1_SignUpSignIn",
    "userAttributes": ["email", "givenName", "surname", "extension_role"],
    "applicationClaims": ["email", "givenName", "surname", "extension_role"]
  }
}
```

#### **2.2 Flutter Azure Auth Integration**
```yaml
# pubspec.yaml
dependencies:
  flutter_appauth: ^6.0.1  # Azure AD B2C OAuth
  http: ^1.2.1
```

### **Phase 3: Database Migration (2-3 weeks)**

#### **3.1 Data Export from Firebase**
```bash
# Export Firestore data
firebase firestore:export firestore-export

# Export Firebase Auth users
firebase auth:export users.json --project vet-biotics
```

#### **3.2 Cosmos DB Schema Design**
```javascript
// MongoDB Collections
db.users.createIndex({ "email": 1 }, { unique: true })
db.pets.createIndex({ "ownerId": 1 })
db.appointments.createIndex({ "clinicId": 1, "scheduledDate": 1 })
db.clinics.createIndex({ "ownerId": 1 })
```

#### **3.3 Data Migration Scripts**
```javascript
// Node.js migration script
const { MongoClient } = require('mongodb');

// Migrate users collection
async function migrateUsers() {
  const firebaseUsers = require('./firebase-users-export.json');
  const azureUsers = firebaseUsers.map(user => ({
    _id: user.uid,
    email: user.email,
    displayName: user.displayName,
    role: mapFirebaseRole(user.customClaims?.role),
    createdAt: new Date(user.metadata.creationTime),
    updatedAt: new Date(user.metadata.lastSignInTime)
  }));

  await azureCollection.insertMany(azureUsers);
}
```

### **Phase 4: Backend Services Migration (2 weeks)**

#### **4.1 Azure Functions Setup**
```javascript
// Azure Function - User Registration
module.exports = async function (context, req) {
    const user = req.body;

    // Validate user data
    // Send welcome email
    // Create user profile in Cosmos DB

    context.res = {
        status: 201,
        body: { message: "User created successfully" }
    };
};
```

#### **4.2 API Management Setup**
```json
// Azure API Management Configuration
{
  "apis": [
    {
      "name": "VetBiotics-API",
      "path": "api/v1",
      "protocols": ["https"],
      "authentication": {
        "type": "oauth2",
        "authorizationServerId": "azure-ad-b2c"
      }
    }
  ]
}
```

### **Phase 5: Flutter App Updates (1-2 weeks)**

#### **5.1 Update Dependencies**
```yaml
# pubspec.yaml
dependencies:
  # Remove Firebase packages
  # firebase_core: ^2.24.2
  # firebase_auth: ^4.16.0
  # cloud_firestore: ^4.14.0
  # firebase_storage: ^11.5.6

  # Add Azure packages
  flutter_appauth: ^6.0.1
  mongo_dart: ^0.10.0
  azure_storage_blob: ^1.1.0
```

#### **5.2 Update Service Classes**
```dart
// Replace FirebaseAuthService with AzureAuthService
class AzureAuthService implements AuthRepository {
  final FlutterAppAuth _appAuth;

  @override
  Future<Either<Failure, User>> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      final result = await _appAuth.authorizeAndExchangeCode(
        AuthorizationTokenRequest(
          'azure-ad-b2c-client-id',
          'com.vetbiotics.app://oauthredirect',
          serviceConfiguration: AuthorizationServiceConfiguration(
            authorizationEndpoint: Uri.parse('https://vetbiotics.b2clogin.com/oauth2/v2.0/authorize'),
            tokenEndpoint: Uri.parse('https://vetbiotics.b2clogin.com/oauth2/v2.0/token'),
          ),
          scopes: ['openid', 'profile', 'email'],
          additionalParameters: {'email': email, 'password': password},
        ),
      );

      // Parse result and return User
    } catch (e) {
      return Left(AuthFailure.invalidCredentials());
    }
  }
}
```

### **Phase 6: Testing & Deployment (1-2 weeks)**

#### **6.1 Testing Strategy**
```dart
// Integration tests for Azure services
void main() {
  group('Azure Auth Integration Tests', () {
    test('should authenticate user with Azure AD B2C', () async {
      // Test authentication flow
    });

    test('should fetch user data from Cosmos DB', () async {
      // Test database operations
    });
  });
}
```

#### **6.2 CI/CD Pipeline**
```yaml
# .github/workflows/azure-deploy.yml
name: Deploy to Azure
on:
  push:
    branches: [ main ]

jobs:
  build-and-deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3

      - name: Login to Azure
        uses: azure/login@v1
        with:
          creds: ${{ secrets.AZURE_CREDENTIALS }}

      - name: Deploy Functions
        uses: azure/functions-action@v1
        with:
          app-name: vetbiotics-functions

      - name: Deploy Web Apps
        uses: azure/static-web-apps-deploy@v1
        with:
          azure_static_web_apps_api_token: ${{ secrets.AZURE_STATIC_WEB_APPS_API_TOKEN }}
```

---

## 💰 **Cost Estimation (Monthly)**

| Service | Tier | Estimated Cost |
|---|---|---|
| **Azure AD B2C** | Premium P1 | $6/user (first 50K free) |
| **Cosmos DB** | 1K RU/s, 10GB | ~$25-50 |
| **Azure Functions** | Consumption | ~$0-10 (based on usage) |
| **Blob Storage** | Hot LRS | ~$5-15 |
| **Notification Hubs** | Basic | ~$10-20 |
| **Static Web Apps** | Free tier | $0 |
| **API Management** | Developer | ~$50 |

**Total Estimated Cost: $100-150/month** (for small-medium app)

---

## ⚡ **Migration Benefits**

### ✅ **Advantages of Azure:**
- **Enterprise-grade security** với Azure AD B2C
- **Better scalability** với Cosmos DB
- **Advanced analytics** với Azure Monitor
- **Hybrid cloud capabilities**
- **Strong compliance** (HIPAA, GDPR, etc.)
- **Integrated DevOps** với Azure DevOps

### ⚠️ **Migration Challenges:**
- **Learning curve** for Azure services
- **Data migration complexity**
- **API changes** in Flutter app
- **Testing overhead**
- **Cost monitoring** requirements

---

## 🎯 **Next Steps**

### **Immediate Actions (This Week):**
1. **Create Azure account** và setup free tier
2. **Design Azure architecture** chi tiết
3. **Create migration scripts** cho data export
4. **Setup Azure DevOps** project

### **Week 2-3:**
1. **Implement Azure AD B2C** authentication
2. **Setup Cosmos DB** với schema
3. **Create Azure Functions** prototypes

### **Week 4-6:**
1. **Migrate authentication** layer
2. **Data migration** từ Firebase sang Azure
3. **Update Flutter app** dependencies

**Bạn muốn bắt đầu với bước nào?** 🤔

**Option 1:** Setup Azure account và basic infrastructure  
**Option 2:** Create detailed Azure architecture plan  
**Option 3:** Start với Azure AD B2C authentication prototype

Tôi recommend **Option 1** để có concrete Azure resources để test! 🚀
