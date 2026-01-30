# 🏠 HamroGharSewa - Flutter Frontend

> A comprehensive home service booking platform built with Flutter, featuring JWT authentication, role-based dashboards, real-time chat, and booking management.

[![Flutter](https://img.shields.io/badge/Flutter-3.9.0+-02569B?logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.0+-0175C2?logo=dart)](https://dart.dev)
[![Provider](https://img.shields.io/badge/State-Provider-orange)](https://pub.dev/packages/provider)
[![WebSocket](https://img.shields.io/badge/Chat-WebSocket-green)](https://pub.dev/packages/web_socket_channel)

---

## 📋 Table of Contents

- [Features](#-features)
- [Tech Stack](#-tech-stack)
- [Getting Started](#-getting-started)
- [Project Structure](#-project-structure)
- [Documentation](#-documentation)
- [API Integration](#-api-integration)
- [Screenshots](#-screenshots)
- [Contributing](#-contributing)

---

## ✨ Features

### 🔐 Authentication & Authorization
- ✅ JWT-based authentication
- ✅ Role-based access control (USER, PROVIDER, ADMIN)
- ✅ Secure token storage
- ✅ Automatic token expiration handling
- ✅ OTP verification for registration

### 📱 User Features
- ✅ Browse available services
- ✅ Search and filter services
- ✅ Create service bookings
- ✅ View booking history
- ✅ Real-time chat with service providers
- ✅ Become a service provider

### 🛠️ Provider Features
- ✅ View incoming booking requests
- ✅ Accept/Reject bookings
- ✅ Manage booking status
- ✅ Real-time chat with customers
- ✅ View booking history
- ✅ Profile management

### 👨‍💼 Admin Features
- ✅ Manage service categories (CRUD)
- ✅ Approve/Reject service providers
- ✅ View all bookings
- ✅ System analytics
- ✅ User management

### 💬 Real-Time Chat
- ✅ WebSocket-based messaging
- ✅ Real-time message delivery
- ✅ Chat history
- ✅ Connection status indicator
- ✅ Message timestamps
- ✅ Auto-scroll to latest message

---

## 🛠️ Tech Stack

| Category | Technology |
|----------|-----------|
| **Framework** | Flutter 3.9.0+ |
| **Language** | Dart 3.0+ |
| **State Management** | Provider |
| **HTTP Client** | Dio |
| **WebSocket** | web_socket_channel |
| **Secure Storage** | flutter_secure_storage |
| **JWT Handling** | jwt_decode |
| **UI Components** | Material Design 3 |

---

## 🚀 Getting Started

### Prerequisites

- Flutter SDK 3.9.0 or higher
- Dart SDK 3.0 or higher
- Android Studio / VS Code
- Backend server running (Spring Boot)

### Installation

1. **Clone the repository**
   ```bash
   cd /home/bhuban/HamroGharSewa/FrontEnd
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure backend URL**
   
   Update `lib/constants/api_constants.dart`:
   ```dart
   static const String baseUrl = 'http://YOUR_BACKEND_IP:8080';
   ```

4. **Run the app**
   ```bash
   flutter run
   ```

### Build for Production

```bash
# Android APK
flutter build apk --release

# iOS
flutter build ios --release

# Web
flutter build web --release
```

---

## 📁 Project Structure

```
lib/
├── main.dart                    # App entry point with MultiProvider
├── constants/                   # App constants
│   ├── api_constants.dart       # API endpoints
│   ├── app_colors.dart          # Color palette
│   └── app_theme.dart           # Theme configuration
├── models/                      # Data models
│   ├── booking_model.dart
│   ├── chat_message_model.dart
│   ├── service_model.dart
│   └── user_model.dart
├── services/                    # Business logic layer
│   ├── auth_service.dart
│   ├── booking_service.dart
│   ├── chat_service.dart
│   ├── service_api_service.dart
│   └── token_manager.dart
├── providers/                   # State management
│   ├── booking_provider.dart
│   ├── chat_provider.dart
│   └── service_provider.dart
├── view/                        # UI screens
│   ├── Login/
│   ├── register/
│   ├── booking/
│   └── chat/
├── DashBoard/                   # Role-based dashboards
│   ├── User.dart
│   ├── provider_dashboard_view.dart
│   └── AdminDashboard_view.dart
├── common/                      # Reusable widgets
└── route/                       # Navigation
```

---

## 📚 Documentation

Comprehensive documentation is available in the following files:

| Document | Description |
|----------|-------------|
| [IMPLEMENTATION_GUIDE.md](IMPLEMENTATION_GUIDE.md) | Complete implementation guide with architecture details |
| [API_QUICK_REFERENCE.md](API_QUICK_REFERENCE.md) | Quick reference for API integration with code examples |
| [IMPLEMENTATION_SUMMARY.md](IMPLEMENTATION_SUMMARY.md) | Summary of implemented features and next steps |
| [ARCHITECTURE_DIAGRAMS.md](ARCHITECTURE_DIAGRAMS.md) | Visual diagrams of app architecture and data flow |

---

## 🔌 API Integration

### Backend Configuration

The app connects to a Spring Boot backend:
- **Base URL**: `http://192.168.111.232:8080`
- **WebSocket**: `ws://192.168.111.232:8080/ws-chat`

### Key Endpoints

#### Authentication
```
POST   /api/auth/login
POST   /api/auth/register
POST   /api/auth/register/verify-otp
```

#### Bookings
```
POST   /api/booking
GET    /api/booking/user
GET    /api/booking/provider
PUT    /api/booking/{id}/status
```

#### Services & Categories
```
GET    /api/services
GET    /api/categories
POST   /api/admin/categories
PUT    /api/admin/categories/{id}
DELETE /api/admin/categories/{id}
```

#### Chat
```
WS     /ws-chat
GET    /api/chat/{bookingId}
```

---

## 🎨 Design System

### Color Palette

```dart
Primary Color:    #4F46E5 (Indigo)
Gradient Start:   #3A7BFF (Blue)
Gradient End:     #9745F5 (Purple)
Background:       #FFFFFF (White)
Card Background:  #EFF5FF (Light Blue)
```

### Typography

- **Font Family**: Roboto
- **Headings**: Bold, 24-40px
- **Body**: Regular, 14-16px
- **Captions**: Regular, 12px

---

## 📖 Usage Examples

### Creating a Booking

```dart
final bookingProvider = context.read<BookingProvider>();

await bookingProvider.createBooking(
  providerId: '123',
  serviceId: '456',
  bookingDate: DateTime.now().add(Duration(days: 1)),
  description: 'Need plumbing service for kitchen sink',
  location: 'Kathmandu, Nepal',
);
```

### Sending a Chat Message

```dart
final chatProvider = context.read<ChatProvider>();

await chatProvider.sendMessage(
  bookingId: booking.id!,
  receiverId: receiverId,
  message: 'Hello! When can you start?',
);
```

### Accepting a Booking (Provider)

```dart
final bookingProvider = context.read<BookingProvider>();

await bookingProvider.acceptBooking(bookingId);
```

For more examples, see [API_QUICK_REFERENCE.md](API_QUICK_REFERENCE.md).

---

## 🧪 Testing

### Run Tests

```bash
flutter test
```

### Test Coverage

```bash
flutter test --coverage
```

---

## 📱 Screenshots

### User Dashboard
- Browse services
- Search functionality
- Service categories
- Booking cards

### Provider Dashboard
- Incoming requests
- Accept/Reject buttons
- Recent chats
- Profile section

### Chat Screen
- Real-time messaging
- Message bubbles
- Connection status
- Auto-scroll

### Admin Dashboard
- Category management
- Provider approval
- System statistics

---

## 🔧 Configuration

### Environment Variables

Create a `.env` file (optional):
```
API_BASE_URL=http://192.168.111.232:8080
WS_URL=ws://192.168.111.232:8080/ws-chat
```

### Firebase (Optional)

For push notifications, configure Firebase:
1. Add `google-services.json` (Android)
2. Add `GoogleService-Info.plist` (iOS)
3. Update `pubspec.yaml` with Firebase packages

---

## 🐛 Troubleshooting

### Common Issues

**WebSocket Connection Failed**
- Ensure backend is running
- Check firewall settings
- Verify WebSocket endpoint URL

**Token Expired**
- App automatically redirects to login
- Check token expiration time in backend

**Chat Not Available**
- Chat is only enabled when booking status is ACCEPTED
- Verify booking status before opening chat

For more troubleshooting tips, see [IMPLEMENTATION_GUIDE.md](IMPLEMENTATION_GUIDE.md).

---

## 🚀 Deployment

### Android

```bash
flutter build apk --release
# APK location: build/app/outputs/flutter-apk/app-release.apk
```

### iOS

```bash
flutter build ios --release
# Open in Xcode for App Store submission
```

### Web

```bash
flutter build web --release
# Deploy the build/web folder to your hosting service
```

---

## 📝 Changelog

### Version 1.0.0 (2026-01-29)

**Added**
- JWT authentication with role-based routing
- Booking system (create, view, accept/reject)
- Real-time WebSocket chat
- Service and category management
- Provider state management
- User, Provider, and Admin dashboards
- Comprehensive documentation

---

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

---

## 📄 License

This project is part of an academic project for HamroGharSewa.

---

## 👥 Team

- **Development Team**: HamroGharSewa
- **Tech Stack**: Flutter + Spring Boot + MySQL
- **Project Type**: Academic Project

---

## 📞 Support

For questions or issues:
1. Check the [IMPLEMENTATION_GUIDE.md](IMPLEMENTATION_GUIDE.md)
2. Review [API_QUICK_REFERENCE.md](API_QUICK_REFERENCE.md)
3. Check Flutter console for errors
4. Review backend logs

---

## 🎯 Roadmap

### Phase 1 (Current) ✅
- [x] Authentication system
- [x] Booking management
- [x] Real-time chat
- [x] Role-based dashboards

### Phase 2 (Next)
- [ ] Push notifications
- [ ] Image upload for services
- [ ] Payment integration
- [ ] Rating and reviews
- [ ] Service provider verification

### Phase 3 (Future)
- [ ] Advanced search filters
- [ ] Service recommendations
- [ ] Analytics dashboard
- [ ] Multi-language support
- [ ] Dark mode

---

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Provider package for state management
- Dio for HTTP client
- WebSocket Channel for real-time communication

---

**Built with ❤️ using Flutter**

**Version**: 1.0.0  
**Last Updated**: 2026-01-29  
**Status**: ✅ Production Ready
