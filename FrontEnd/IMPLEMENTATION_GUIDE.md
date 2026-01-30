# HamroGharSewa Flutter Frontend - Implementation Guide

## 📋 Overview
This document provides a comprehensive guide for the HamroGharSewa Flutter frontend implementation with JWT authentication, role-based dashboards, booking system, and real-time chat.

## 🏗️ Architecture

### Tech Stack
- **Framework**: Flutter 3.9.0+
- **State Management**: Provider
- **HTTP Client**: Dio
- **Secure Storage**: flutter_secure_storage
- **WebSocket**: web_socket_channel
- **JWT**: jwt_decode

### Project Structure
```
lib/
├── constants/
│   ├── api_constants.dart       # API endpoints
│   ├── app_colors.dart          # Color palette
│   └── app_theme.dart           # Theme configuration
├── models/
│   ├── auth_response.dart       # Authentication response
│   ├── booking_model.dart       # Booking data model
│   ├── chat_message_model.dart  # Chat message model
│   ├── service_model.dart       # Service & Category models
│   ├── service_provider.dart    # Provider model
│   └── user_model.dart          # User model
├── services/
│   ├── auth_service.dart        # Authentication service
│   ├── booking_service.dart     # Booking API service
│   ├── chat_service.dart        # WebSocket chat service
│   ├── service_api_service.dart # Service & Category API
│   ├── api_client.dart          # Dio client wrapper
│   └── token_manager.dart       # JWT token management
├── providers/
│   ├── booking_provider.dart    # Booking state management
│   ├── chat_provider.dart       # Chat state management
│   └── service_provider.dart    # Service state management
├── repositories/
│   └── auth_repository.dart     # Auth data layer
├── view/
│   ├── Login/
│   ├── register/
│   ├── booking/
│   └── chat/
│       └── chat_screen.dart     # Real-time chat UI
├── DashBoard/
│   ├── User.dart                # User dashboard
│   ├── provider_dashboard_view.dart  # Provider dashboard
│   └── AdminDashboard_view.dart # Admin dashboard
├── common/
│   ├── custom_button.dart
│   ├── custom_text_field.dart
│   └── loading_widget.dart
├── route/
│   └── app_routes.dart          # Route configuration
└── main.dart                    # App entry point
```

## 🔐 Authentication System

### JWT Token Management
The `TokenManager` class handles:
- Storing JWT tokens securely using SharedPreferences
- Extracting user role from JWT payload
- Role-based navigation (USER, PROVIDER, SUPERADMIN)
- Token expiration checking
- Automatic logout on token expiry

### Supported Roles
1. **USER** → User Dashboard
2. **PROVIDER** / **SERVICE_PROVIDER** → Provider Dashboard
3. **SUPERADMIN** → Admin Dashboard

### Login Flow
```dart
1. User enters credentials
2. AuthService.login() → Backend API
3. Receive JWT token + user data
4. TokenManager.saveTokens()
5. Extract role from JWT
6. Navigate to role-specific dashboard
```

## 📱 Role-Based Dashboards

### 1. User Dashboard (`User.dart`)
**Features:**
- Browse available services
- Search services by name/category/location
- View service providers
- Create bookings
- View booking history
- Chat with providers (if booking accepted)
- Become a service provider option

**Key Components:**
```dart
- Service search bar
- Category icons (Plumber, Painter, Electrician, Carpenter)
- Popular services list
- Booking cards with "Book Now" button
```

### 2. Provider Dashboard (`provider_dashboard_view.dart`)
**Features:**
- View incoming booking requests
- Accept/Reject bookings
- View booking details
- Chat with users (if booking accepted)
- Manage profile
- View recent chats

**Key Components:**
```dart
- User request cards
- Accept/Decline buttons
- Recent chats list
- Profile section
- Bottom navigation
```

### 3. Admin Dashboard (`AdminDashboard_view.dart`)
**Features:**
- Manage service categories (Create/Edit/Delete)
- View all bookings
- Manage service providers (Approve/Reject)
- View system statistics

## 📦 Booking System

### Booking Model
```dart
class Booking {
  String? id;
  String userId;
  String providerId;
  String serviceId;
  String serviceName;
  String providerName;
  String userName;
  String status; // PENDING, ACCEPTED, REJECTED, COMPLETED
  DateTime bookingDate;
  String? description;
  String? location;
}
```

### Booking Flow

#### User Side:
1. Browse services
2. Select a service
3. Fill booking form (date, description, location)
4. Submit booking → `BookingService.createBooking()`
5. Booking status: PENDING
6. Wait for provider acceptance
7. If ACCEPTED → Chat enabled
8. If REJECTED → Booking closed

#### Provider Side:
1. Receive booking request
2. View booking details
3. Accept → `BookingService.updateBookingStatus(id, 'ACCEPTED')`
4. Or Reject → `BookingService.updateBookingStatus(id, 'REJECTED')`
5. If accepted → Chat enabled with user

### API Endpoints
```dart
POST   /api/booking              # Create booking
GET    /api/booking/user         # Get user bookings
GET    /api/booking/provider     # Get provider bookings
GET    /api/booking/{id}         # Get booking by ID
PUT    /api/booking/{id}/status  # Update booking status
```

## 💬 Real-Time Chat System

### WebSocket Integration

#### Connection Setup
```dart
1. User logs in → JWT token stored
2. Navigate to chat screen
3. ChatService.connect() → WebSocket connection
4. Subscribe to user topic: /topic/user/{userId}
5. Listen for incoming messages
```

#### Message Flow
```dart
// Sending a message
ChatProvider.sendMessage(
  bookingId: bookingId,
  receiverId: receiverId,
  message: message,
)

// Receiving messages
ChatProvider.messageStream.listen((message) {
  // Update UI with new message
})
```

#### Chat Availability
- Chat is **only enabled** when booking status = **ACCEPTED**
- Both user and provider can send messages
- Messages are stored in backend
- Chat history loaded on screen open

### WebSocket Endpoints
```dart
WS     /ws-chat                  # WebSocket connection
GET    /api/chat/{bookingId}     # Get chat history
Topic  /topic/user/{userId}      # User-specific topic
Send   /app/chat                 # Send message endpoint
```

### Chat UI Features
- Real-time message delivery
- Message bubbles (sent/received)
- Timestamp display
- Connection status indicator
- Auto-scroll to latest message
- Message input with send button

## 🛠️ Service & Category Management

### Service Model
```dart
class Service {
  String? id;
  String name;
  String description;
  String categoryId;
  String categoryName;
  String? imageUrl;
  double? basePrice;
  String? priceUnit; // per hour, per day, fixed
}
```

### Category Model
```dart
class Category {
  String? id;
  String name;
  String? description;
  String? iconName;
  bool isActive;
}
```

### Admin Operations
```dart
// Create category
ServiceProvider.createCategory(
  name: 'Plumbing',
  description: 'Water and drainage services',
  iconName: 'plumbing',
)

// Update category
ServiceProvider.updateCategory(
  categoryId: id,
  name: 'Updated Name',
)

// Delete category
ServiceProvider.deleteCategory(categoryId)
```

## 🔄 State Management with Provider

### BookingProvider
```dart
// Usage in widgets
final bookingProvider = Provider.of<BookingProvider>(context);

// Create booking
await bookingProvider.createBooking(
  providerId: providerId,
  serviceId: serviceId,
  bookingDate: DateTime.now(),
);

// Fetch bookings
await bookingProvider.fetchUserBookings();

// Accept booking (Provider)
await bookingProvider.acceptBooking(bookingId);
```

### ChatProvider
```dart
// Usage in widgets
final chatProvider = Provider.of<ChatProvider>(context);

// Connect to WebSocket
await chatProvider.connect();

// Send message
await chatProvider.sendMessage(
  bookingId: bookingId,
  receiverId: receiverId,
  message: 'Hello!',
);

// Get messages
final messages = chatProvider.getChatMessages(bookingId);
```

### ServiceProvider
```dart
// Usage in widgets
final serviceProvider = Provider.of<ServiceProvider>(context);

// Fetch services
await serviceProvider.fetchServices();

// Search services
final results = serviceProvider.searchServices('plumber');

// Fetch categories
await serviceProvider.fetchCategories();
```

## 🎨 UI/UX Design

### Color Scheme
```dart
Primary Color: #4F46E5 (Indigo)
Gradient Start: #3A7BFF (Blue)
Gradient End: #9745F5 (Purple)
Background: #FFFFFF (White)
Card Background: #EFF5FF (Light Blue)
```

### Design Principles
1. **Clean & Modern**: Material Design 3
2. **Consistent Spacing**: 8px grid system
3. **Rounded Corners**: 12px border radius
4. **Shadows**: Subtle elevation for cards
5. **Responsive**: Adapts to different screen sizes
6. **Accessibility**: High contrast, readable fonts

## 🚀 Getting Started

### 1. Install Dependencies
```bash
cd /home/bhuban/HamroGharSewa/FrontEnd
flutter pub get
```

### 2. Configure Backend URL
Update `lib/constants/api_constants.dart`:
```dart
static const String baseUrl = 'http://YOUR_BACKEND_IP:8080';
```

### 3. Run the App
```bash
flutter run
```

### 4. Build for Production
```bash
# Android
flutter build apk --release

# iOS
flutter build ios --release

# Web
flutter build web --release
```

## 📝 Usage Examples

### Creating a Booking
```dart
final bookingProvider = context.read<BookingProvider>();

final success = await bookingProvider.createBooking(
  providerId: '123',
  serviceId: '456',
  bookingDate: DateTime.now().add(Duration(days: 1)),
  description: 'Need plumbing service for kitchen sink',
  location: 'Kathmandu, Nepal',
);

if (success) {
  // Show success message
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Booking created successfully!')),
  );
}
```

### Opening Chat
```dart
// Only if booking is accepted
if (booking.isAccepted) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => ChatScreen(booking: booking),
    ),
  );
} else {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Chat available after booking acceptance')),
  );
}
```

### Provider Accepting Booking
```dart
final bookingProvider = context.read<BookingProvider>();

final success = await bookingProvider.acceptBooking(bookingId);

if (success) {
  // Booking accepted, chat now available
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text('Booking accepted! You can now chat with the user.'),
      backgroundColor: Colors.green,
    ),
  );
}
```

## 🔧 API Integration Checklist

### Authentication ✅
- [x] Login
- [x] Register
- [x] OTP Verification
- [x] JWT Token Storage
- [x] Role-based Routing
- [ ] Forgot Password
- [ ] Reset Password

### Booking System ✅
- [x] Create Booking
- [x] Get User Bookings
- [x] Get Provider Bookings
- [x] Update Booking Status
- [x] Booking Model

### Chat System ✅
- [x] WebSocket Connection
- [x] Send Message
- [x] Receive Message
- [x] Chat History
- [x] Topic Subscription

### Services & Categories ✅
- [x] Get All Services
- [x] Get Service by ID
- [x] Get Categories
- [x] Search Services
- [x] Admin: Create Category
- [x] Admin: Update Category
- [x] Admin: Delete Category

## 🐛 Troubleshooting

### WebSocket Connection Issues
```dart
// Check connection status
if (!chatProvider.isConnected) {
  await chatProvider.connect();
}

// Ensure JWT token is valid
final token = await TokenManager().getAccessToken();
if (token == null || Jwt.isExpired(token)) {
  // Redirect to login
}
```

### Token Expiration
```dart
// Automatic token check in TokenManager
Future<bool> isLoggedIn() async {
  final token = await getAccessToken();
  if (token == null || token.isEmpty) return false;
  
  try {
    return !Jwt.isExpired(token);
  } catch (_) {
    return false;
  }
}
```

### Dio Interceptor for Auto Token Attachment
```dart
// Add to api_client.dart
dio.interceptors.add(InterceptorsWrapper(
  onRequest: (options, handler) async {
    final token = await TokenManager().getAccessToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    return handler.next(options);
  },
));
```

## 📚 Additional Resources

### Flutter Documentation
- [Flutter Docs](https://docs.flutter.dev/)
- [Provider Package](https://pub.dev/packages/provider)
- [Dio Package](https://pub.dev/packages/dio)
- [WebSocket Channel](https://pub.dev/packages/web_socket_channel)

### Backend Integration
- Ensure backend is running on `http://192.168.111.232:8080`
- WebSocket endpoint: `ws://192.168.111.232:8080/ws-chat`
- All API endpoints must return proper JSON responses
- JWT tokens must include `role` field in payload

## ✅ Next Steps

1. **Complete UI Implementation**
   - Update User Dashboard with real API data
   - Update Provider Dashboard with real booking requests
   - Implement Admin Dashboard category management

2. **Testing**
   - Test all API endpoints
   - Test WebSocket connection
   - Test role-based routing
   - Test booking flow end-to-end

3. **Polish**
   - Add loading states
   - Add error handling
   - Add success/error notifications
   - Add pull-to-refresh

4. **Production Ready**
   - Remove DevicePreview
   - Update API base URL
   - Add proper error logging
   - Optimize performance

---

**Created**: 2026-01-29  
**Version**: 1.0.0  
**Author**: HamroGharSewa Development Team
