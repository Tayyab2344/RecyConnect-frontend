# RecyConnect Frontend

A Flutter-based mobile application for the RecyConnect waste management and recycling platform.

## Prerequisites

Before you begin, ensure you have the following installed:

- **Flutter SDK** (v3.0.0 or higher)
- **Dart SDK** (v3.0.0 or higher)
- **Android Studio** (for Android development)
- **Xcode** (for iOS development - macOS only)
- **Git**
- **A code editor** (VS Code, Android Studio, or IntelliJ IDEA)

## Quick Start

### 1. Clone the Repository

```bash
git clone <repository-url>
cd RecyConnect-frontend
```

### 2. Install Flutter Dependencies

```bash
flutter pub get
```

### 3. Environment Configuration

Create a `.env` file in the root directory:

```env
API_URL=http://192.168.1.13:5000/api
```

> **Note:** Replace `192.168.1.13` with your local machine's IP address or production API URL.

### 4. Configure API Base URL

The API base URL is configured in `lib/core/constants/api_constants.dart`:

```dart
static const String baseUrl = String.fromEnvironment(
  'API_URL',
  defaultValue: 'http://192.168.1.13:5000/api'
);
```

To use a different URL at runtime:
```bash
flutter run --dart-define=API_URL=http://your-api-url:5000/api
```

### 5. Run the Application

**For Android Emulator:**
```bash
flutter run
```

**For Physical Device (USB Debugging):**
```bash
# Connect your device via USB and enable USB debugging
flutter devices  # List available devices
flutter run -d <device-id>
```

**For iOS Simulator (macOS only):**
```bash
flutter run -d iphone
```

## Building the App

### Android APK (Debug)

```bash
flutter build apk --debug
```

The APK will be located at: `build/app/outputs/flutter-apk/app-debug.apk`

### Android APK (Release)

```bash
flutter build apk --release
```

The APK will be located at: `build/app/outputs/flutter-apk/app-release.apk`

### Android App Bundle (For Google Play Store)

```bash
flutter build appbundle --release
```

### iOS App (macOS only)

```bash
flutter build ios --release
```

## Project Structure

```
RecyConnect-frontend/
├── lib/
│   ├── core/
│   │   ├── constants/         # App constants and API config
│   │   ├── models/            # Data models
│   │   ├── services/          # API and business logic services
│   │   ├── theme/             # App theme and styling
│   │   ├── utils/             # Utility functions
│   │   └── providers/         # State management providers
│   ├── presentation/
│   │   ├── screens/           # All app screens
│   │   │   ├── auth/          # Login, registration, OTP
│   │   │   ├── dashboard/     # Main dashboards
│   │   │   ├── individual/    # Individual user features
│   │   │   ├── onboarding/    # First-time user experience
│   │   │   ├── profile/       # User profile screens
│   │   │   └── ...
│   │   └── widgets/           # Reusable UI components
│   └── main.dart              # Application entry point
├── assets/
│   ├── images/                # Image assets
│   └── icons/                 # Icon assets
├── pubspec.yaml               # Dependencies configuration
├── .env                       # Environment variables
└── README.md
```

## Key Features

### User Roles
- **Individual Users:** Sell recyclables, browse marketplace
- **Warehouse Users:** Bulk operations, view all listings
- **Company Users:** Corporate recycling management
- **Admin Users:** User management, analytics dashboard

### Features by Role

#### Individual Users
- Create and manage recyclable listings (max 20kg)
- Browse marketplace for materials
- Track earnings and sales
- Manage purchases and orders

#### Warehouse Users
- List bulk recyclables (min 10kg)
- View listings from all user types
- Advanced inventory management

#### Company Users
- List bulk recyclables (min 10kg)
- View company and warehouse listings
- Corporate-level reporting

#### Admin
- User management and suspension
- System analytics and reporting
- Activity logs and monitoring

## Key Dependencies

| Package | Purpose |
|---------|---------|
| `provider` | State management |
| `http` | API communication |
| `shared_preferences` | Local storage |
| `image_picker` | Image uploads |
| `google_mlkit_text_recognition` | OCR for document scanning |
| `fl_chart` | Charts and graphs |
| `geolocator` & `geocoding` | Location services |
| `flutter_animate` | Animations |
| `glassmorphism` | Modern UI effects |
| `intl` | Internationalization |

## Configuration

### Connecting to Local Backend

1. Find your computer's local IP address:
   - **Windows:** Run `ipconfig` in Command Prompt
   - **macOS/Linux:** Run `ifconfig` in Terminal

2. Update `lib/core/constants/api_constants.dart`:
   ```dart
   static const String baseUrl = 'http://YOUR_LOCAL_IP:5000/api';
   ```

3. Ensure your backend is running and listening on `0.0.0.0`

4. Both devices (development machine and test device) must be on the same Wi-Fi network

### Android Permissions

The app requires the following permissions (configured in `android/app/src/main/AndroidManifest.xml`):
- Internet access
- Camera (for profile pictures and document scanning)
- Location (for address detection)
- Storage (for file uploads)

### iOS Permissions

Configure permissions in `ios/Runner/Info.plist`:
- NSCameraUsageDescription
- NSPhotoLibraryUsageDescription
- NSLocationWhenInUseUsageDescription

## Testing

```bash
# Run all tests
flutter test

# Run tests with coverage
flutter test --coverage

# View coverage report
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

## Themes

The app supports both **Light** and **Dark** themes:

- **Light Mode:** Glassmorphism with soft pastels
- **Dark Mode:** Neon accents with deep backgrounds

Toggle themes from the Profile → Settings screen.

## Special Features

### Onboarding Experience
First-time users see a 3-slide introduction explaining core features. This appears only once and is managed via `SharedPreferences`.

### Glassmorphism UI
Modern frosted-glass effect used throughout the app for cards and panels, providing a premium feel.

### Role-Based UI
Different dashboards and features based on user role (Individual, Warehouse, Company, Admin).

### Smart Location Detection
Automatic location detection with manual fallback using Pakistan cities and areas.

## Troubleshooting

### Common Issues

**1. "Connection timeout" error**
- Ensure backend is running
- Verify API base URL matches your backend IP
- Check both devices are on the same network

**2. Flutter doctor warnings**
```bash
flutter doctor -v  # Detailed diagnostics
flutter doctor --android-licenses  # Accept Android licenses
```

**3. Dependency conflicts**
```bash
flutter pub get
flutter clean
flutter pub get
```

**4. Build failures**
```bash
flutter clean
cd android && ./gradlew clean
cd ..
flutter build apk
```

**5. Hot reload not working**
```bash
# Stop and restart
flutter run
```

## Running on Physical Device

### Android

1. Enable Developer Options on your device
2. Enable USB Debugging
3. Connect via USB
4. Run: `flutter devices` to verify connection
5. Run: `flutter run`

### iOS (macOS only)

1. Open project in Xcode: `open ios/Runner.xcworkspace`
2. Select your device
3. Trust the developer certificate on device
4. Run from Xcode or use `flutter run`

## Deployment

### Google Play Store (Android)

1. Configure signing in `android/app/build.gradle`
2. Build app bundle: `flutter build appbundle --release`
3. Upload to Google Play Console

### Apple App Store (iOS)

1. Open in Xcode: `open ios/Runner.xcworkspace`
2. Configure signing and capabilities
3. Archive and upload via Xcode

## Performance Tips

- Use `const` constructors where possible
- Implement pagination for large lists
- Optimize images before uploading
- Use `ListView.builder` for long lists
- Enable code shrinking in release builds

## Security

- All API calls use HTTPS in production
- JWT tokens stored securely in SharedPreferences
- Sensitive data never logged in release builds
- Input validation on all forms

## Support

For issues, questions, or contributions, please contact the development team.

## License

This project is licensed under the ISC License.

---

**Built with Flutter**
