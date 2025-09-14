# Vet Biotics - Monorepo

Dự án quản lý phòng khám thú y được xây dựng theo kiến trúc monorepo sử dụng Flutter và Melos.

## 📁 Cấu trúc dự án

```
vet_biotics/
├── packages/
│   ├── app_user/           # Ứng dụng dành cho khách hàng
│   ├── app_clinic/         # Ứng dụng dành cho phòng khám
│   ├── app_admin/          # Ứng dụng quản trị hệ thống
│   ├── auth/               # Package xác thực
│   ├── shared/             # Các thành phần chia sẻ
│   ├── core/               # Business logic và domain
│   └── router/             # Navigation và routing
├── docs/                   # Tài liệu dự án
├── .vscode/               # Cấu hình VS Code
├── melos.yaml            # Cấu hình Melos
└── pubspec.yaml          # Dependencies root
```

## 🚀 Cài đặt và thiết lập

### Yêu cầu hệ thống

- Flutter SDK >= 3.9.2
- Dart SDK >= 3.9.2
- Melos CLI

### Cài đặt

1. **Clone repository:**
   ```bash
   git clone <repository-url>
   cd vet_biotics
   ```

2. **Cài đặt Melos (nếu chưa có):**
   ```bash
   flutter pub global activate melos
   ```

3. **Bootstrap monorepo:**
   ```bash
   melos bootstrap
   ```

4. **Cài đặt dependencies:**
   ```bash
   melos run pub:get
   ```

## 📦 Packages

### 🔧 Core Packages

#### `shared`
Chứa các thành phần chia sẻ:
- Constants (API endpoints, UI constants)
- Extensions (String, DateTime, Context)
- Models cơ bản (API response, pagination)
- Utilities (validation, formatting, storage)
- Widgets cơ bản (buttons, text fields, loading indicators)
- Theme và colors

#### `core`
Business logic và domain layer:
- Domain entities (User, Pet, Appointment, etc.)
- Repositories interfaces
- Use cases
- Data sources
- State management (BLoC, Cubits)

#### `router`
Navigation và routing:
- GoRouter configuration
- Route guards (Auth, Role-based)
- Route definitions
- Navigation utilities

### 📱 App Packages

#### `app_user`
Ứng dụng dành cho khách hàng:
- Đặt lịch hẹn
- Xem hồ sơ thú cưng
- Theo dõi lịch sử khám
- Quản lý thông tin cá nhân

#### `app_clinic`
Ứng dụng dành cho phòng khám:
- Quản lý lịch hẹn
- Hồ sơ bệnh án điện tử
- Quản lý kho thuốc
- Báo cáo và thống kê

#### `app_admin`
Ứng dụng quản trị hệ thống:
- Quản lý phòng khám
- Quản lý người dùng
- Giám sát hệ thống
- Cấu hình hệ thống

#### `auth`
Package xử lý xác thực:
- Đăng nhập/đăng ký
- Quản lý session
- Firebase Authentication

## 🛠️ Development Workflow

### Chạy ứng dụng

```bash
# Chạy app_user
flutter run -d chrome packages/app_user/lib/main.dart

# Chạy app_clinic
flutter run -d chrome packages/app_clinic/lib/main.dart

# Chạy app_admin
flutter run -d chrome packages/app_admin/lib/main.dart
```

### Testing

```bash
# Test tất cả packages
melos run test

# Test package cụ thể
melos run test --scope=shared
```

### Code Analysis

```bash
# Analyze tất cả packages
melos run analyze

# Format code
melos run format
```

### Build

```bash
# Build tất cả apps
melos run build

# Build app cụ thể
melos run build --scope=app_user
```

## 📋 Coding Standards

### Clean Architecture

Dự án tuân theo Clean Architecture với 3 layers chính:

1. **Presentation Layer** (UI)
   - Widgets, Screens, BLoCs, State management
   - Dependencies: Domain, Shared

2. **Domain Layer** (Business Logic)
   - Entities, Use cases, Repositories interfaces
   - Dependencies: None (pure Dart)

3. **Data Layer** (External Interfaces)
   - Repository implementations, Data sources
   - Dependencies: Domain

### Naming Conventions

- **Classes**: PascalCase (UserRepository, LoginBloc)
- **Methods/Functions**: camelCase (getUser(), loginUser())
- **Variables**: camelCase (userName, isLoading)
- **Constants**: UPPER_SNAKE_CASE (API_BASE_URL)
- **Files**: snake_case (user_repository.dart)

### File Structure

```
lib/
├── presentation/
│   ├── blocs/
│   ├── cubits/
│   ├── pages/
│   └── widgets/
├── domain/
│   ├── entities/
│   ├── repositories/
│   └── usecases/
├── data/
│   ├── repositories/
│   ├── datasources/
│   └── models/
└── core/
    ├── error/
    ├── network/
    └── utils/
```

## 🔐 Authentication & Authorization

### User Roles

- **Client**: Khách hàng thông thường
- **Staff**: Nhân viên phòng khám
- **Doctor**: Bác sĩ thú y
- **Admin**: Quản trị hệ thống

### Route Guards

- `AuthGuard`: Bảo vệ routes yêu cầu đăng nhập
- `RoleGuard`: Bảo vệ routes theo role
- `PermissionGuard`: Bảo vệ routes theo permissions

## 📊 State Management

Sử dụng BLoC pattern với flutter_bloc:

```dart
class UserBloc extends Bloc<UserEvent, UserState> {
  final GetUserUseCase getUserUseCase;

  UserBloc(this.getUserUseCase) : super(UserInitial()) {
    on<GetUserEvent>(_onGetUser);
  }
}
```

## 🌐 API Integration

### Firebase Integration

- **Authentication**: Firebase Auth
- **Database**: Firestore
- **Storage**: Firebase Storage
- **Functions**: Cloud Functions

### API Structure

```dart
abstract class ApiClient {
  Future<ApiResponse<T>> get<T>(String path);
  Future<ApiResponse<T>> post<T>(String path, dynamic data);
  Future<ApiResponse<T>> put<T>(String path, dynamic data);
  Future<ApiResponse<T>> delete<T>(String path);
}
```

## 🎨 UI/UX Guidelines

### Design System

- **Colors**: Material 3 color scheme
- **Typography**: Custom font family (Inter)
- **Components**: Consistent button, input, card styles
- **Spacing**: 4px grid system (4, 8, 16, 24, 32, 48)

### Responsive Design

- Mobile-first approach
- Adaptive layouts cho tablet/desktop
- Consistent breakpoints

## 📝 Documentation

### Code Documentation

- Sử dụng Dart doc comments cho public APIs
- Document complex business logic
- Update README cho các packages

### API Documentation

- RESTful API endpoints
- Request/Response schemas
- Authentication requirements

## 🚀 Deployment

### CI/CD Pipeline

```yaml
# GitHub Actions workflow
name: CI/CD
on: [push, pull_request]
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
      - run: melos run test
      - run: melos run analyze
```

### Build Commands

```bash
# Android APK
flutter build apk --release

# iOS IPA
flutter build ios --release

# Web
flutter build web --release
```

## 🤝 Contributing

1. Fork repository
2. Tạo feature branch: `git checkout -b feature/new-feature`
3. Commit changes: `git commit -am 'Add new feature'`
4. Push to branch: `git push origin feature/new-feature`
5. Tạo Pull Request

### Commit Convention

```
feat: add new user authentication
fix: resolve login issue
docs: update API documentation
style: format code
refactor: restructure user repository
test: add unit tests for user service
chore: update dependencies
```

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 📞 Support

- **Issues**: GitHub Issues
- **Discussions**: GitHub Discussions
- **Email**: support@vetbiotics.com

---

*Built with ❤️ using Flutter and Melos*
