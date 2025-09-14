# Firebase Setup Guide - Vet Biotics

Hướng dẫn này sẽ giúp bạn setup Firebase project cho ứng dụng Vet Biotics monorepo.

## 🚀 Bước 1: Tạo Firebase Project

1. Truy cập [Firebase Console](https://console.firebase.google.com/)
2. Click "Create a project" hoặc "Add project"
3. Điền thông tin project:
   - **Project name**: `vet-biotics-project`
   - **Project ID**: `vet-biotics-project` (tự động tạo)
4. Bật Google Analytics (khuyến nghị)
5. Chọn account Google Analytics
6. Click "Create project"

## 📱 Bước 2: Thêm các Platform Apps

### Android App
1. Trong Firebase Console, click vào biểu tượng Android
2. **Android package name**: `com.example.vet_biotics`
3. **App nickname**: `Vet Biotics Android`
4. **Debug signing certificate SHA-1**: (bỏ qua nếu chưa có)
5. Click "Register app"
6. Download `google-services.json` và đặt vào thư mục `android/app/`
7. Skip các bước còn lại

### iOS App
1. Click vào biểu tượng iOS
2. **iOS bundle ID**: `com.example.vetBiotics`
3. **App nickname**: `Vet Biotics iOS`
4. Click "Register app"
5. Download `GoogleService-Info.plist` và đặt vào thư mục `ios/Runner/`
6. Skip các bước còn lại

### Web App
1. Click vào biểu tượng Web (`</>`)
2. **App nickname**: `Vet Biotics Web`
3. **Also set up Firebase Hosting**: Có (nếu muốn deploy web)
4. Click "Register app"
5. Copy thông tin Firebase config (sẽ dùng ở bước tiếp theo)

## 🔧 Bước 3: Cập nhật Firebase Configuration

### Cập nhật firebase_options.dart files

Sau khi có thông tin từ Firebase Console, cập nhật các file sau:

#### packages/app_user/lib/firebase_options.dart
```dart
static const FirebaseOptions web = FirebaseOptions(
  apiKey: 'your-actual-web-api-key',
  appId: 'your-actual-web-app-id',
  messagingSenderId: 'your-sender-id',
  projectId: 'vet-biotics-project',
  authDomain: 'vet-biotics-project.firebaseapp.com',
  storageBucket: 'vet-biotics-project.appspot.com',
  measurementId: 'your-measurement-id',
);

static const FirebaseOptions android = FirebaseOptions(
  apiKey: 'your-actual-android-api-key',
  appId: 'your-actual-android-app-id',
  messagingSenderId: 'your-sender-id',
  projectId: 'vet-biotics-project',
  storageBucket: 'vet-biotics-project.appspot.com',
);

static const FirebaseOptions ios = FirebaseOptions(
  apiKey: 'your-actual-ios-api-key',
  appId: 'your-actual-ios-app-id',
  messagingSenderId: 'your-sender-id',
  projectId: 'vet-biotics-project',
  storageBucket: 'vet-biotics-project.appspot.com',
);
```

**Làm tương tự cho:**
- `packages/app_clinic/lib/firebase_options.dart`
- `packages/app_admin/lib/firebase_options.dart`

## 🔐 Bước 4: Setup Authentication

1. Trong Firebase Console, đi đến **Authentication**
2. Click tab **Sign-in method**
3. Bật các provider:
   - **Email/Password**: Enable
   - **Google**: Enable (cần setup OAuth)
   - **Phone**: Enable (tùy chọn)

### Setup Google Sign-In
1. Trong Authentication > Sign-in method > Google
2. Click "Enable"
3. Điền thông tin:
   - **Project name**: `Vet Biotics`
   - **Project support email**: your-email@gmail.com
4. Click "Save"

### Setup OAuth cho Web
1. Truy cập [Google Cloud Console](https://console.cloud.google.com/)
2. Tạo OAuth 2.0 Client ID
3. Thêm authorized origins: `https://vet-biotics-project.firebaseapp.com`
4. Copy Client ID và Secret

## 📊 Bước 5: Setup Firestore Database

1. Trong Firebase Console, đi đến **Firestore Database**
2. Click "Create database"
3. Chọn mode:
   - **Start in test mode**: Để development
   - **Start in production mode**: Để production
4. Chọn location: `asia-southeast1` (Singapore) hoặc location gần bạn nhất
5. Click "Done"

### Tạo Collections cơ bản

```javascript
// Users collection
{
  userId: "user_123",
  email: "user@example.com",
  firstName: "John",
  lastName: "Doe",
  role: "client", // client, receptionist, veterinarian, clinicAdmin, superAdmin
  clinicId: "clinic_456", // optional
  isActive: true,
  createdAt: Timestamp,
  updatedAt: Timestamp
}

// Clinics collection
{
  clinicId: "clinic_123",
  name: "Central Pet Clinic",
  address: "123 Main St, City",
  phone: "(555) 123-4567",
  email: "info@clinic.com",
  isActive: true,
  createdAt: Timestamp,
  updatedAt: Timestamp
}

// Pets collection
{
  petId: "pet_123",
  name: "Max",
  ownerId: "user_456",
  species: "dog", // dog, cat, bird, rabbit, other
  breed: "Golden Retriever",
  gender: "male", // male, female
  birthDate: Timestamp,
  weight: 25.5,
  isActive: true,
  createdAt: Timestamp,
  updatedAt: Timestamp
}
```

## 📁 Bước 6: Setup Cloud Storage

1. Trong Firebase Console, đi đến **Storage**
2. Click "Get started"
3. Chọn location (nên giống với Firestore)
4. Click "Done"

### Tạo Storage Rules

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /users/{userId}/{allPaths=**} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }

    match /clinics/{clinicId}/{allPaths=**} {
      allow read, write: if request.auth != null;
    }

    match /pets/{petId}/{allPaths=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

## 🔒 Bước 7: Setup Security Rules (Firestore)

### Firestore Rules

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can read/write their own data
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }

    // Admins can read all users
    match /users/{userId} {
      allow read: if request.auth != null &&
        get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role in ['clinicAdmin', 'superAdmin'];
      allow write: if request.auth != null &&
        get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'superAdmin';
    }

    // Clinics rules
    match /clinics/{clinicId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null &&
        get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role in ['clinicAdmin', 'superAdmin'];
    }

    // Pets rules - owners and clinic staff can access
    match /pets/{petId} {
      allow read, write: if request.auth != null &&
        (request.auth.uid == resource.data.ownerId ||
         get(/databases/$(database)/documents/users/$(request.auth.uid)).data.clinicId == resource.data.clinicId);
    }
  }
}
```

## 🧪 Bước 8: Test Firebase Integration

### Chạy apps để test

```bash
# Test app_user
cd packages/app_user && flutter run

# Test app_clinic
cd packages/app_clinic && flutter run

# Test app_admin
cd packages/app_admin && flutter run
```

### Kiểm tra Firebase Console
- Xem Authentication users
- Kiểm tra Firestore documents
- Xem Storage files

## 🚀 Bước 9: Deploy Rules

```bash
# Deploy Firestore rules
firebase deploy --only firestore:rules

# Deploy Storage rules
firebase deploy --only storage

# Deploy tất cả
firebase deploy
```

## 📝 Notes

- **Development**: Sử dụng test mode rules
- **Production**: Implement strict security rules
- **Backup**: Regularly backup Firestore data
- **Monitoring**: Setup Firebase monitoring và alerts

## 🆘 Troubleshooting

### Common Issues:

1. **PlatformException**: Check Firebase config trong `firebase_options.dart`
2. **Permission denied**: Check Firestore/Storage rules
3. **App not initialized**: Ensure Firebase.initializeApp() được gọi trước

### Debug Commands:

```bash
# Check Firebase status
firebase projects:list

# View current rules
firebase firestore:rules:list

# Test rules locally
firebase emulators:start --only firestore
```

---

🎉 **Firebase setup hoàn tất!** Bây giờ bạn có thể bắt đầu phát triển với real Firebase backend.
