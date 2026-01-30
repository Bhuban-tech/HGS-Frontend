# HamroGharSewa - Quick API Integration Reference

## 🔐 Authentication

### Login
```dart
import 'package:HamroGharSewa/services/auth_service.dart';

final authService = AuthService();
try {
  final response = await authService.login(email, password);
  // response.token, response.userId, response.email, response.userName
} catch (e) {
  // Handle error
}
```

### Register
```dart
final response = await authService.register(
  name: name,
  email: email,
  phone: phone,
  password: password,
);
```

### Verify OTP
```dart
final response = await authService.verifyOtp(email, otp);
```

## 📦 Booking Operations

### Create Booking (User)
```dart
import 'package:provider/provider.dart';
import 'package:HamroGharSewa/providers/booking_provider.dart';

final bookingProvider = context.read<BookingProvider>();

final success = await bookingProvider.createBooking(
  providerId: '123',
  serviceId: '456',
  bookingDate: DateTime.now().add(Duration(days: 1)),
  description: 'Need plumbing service',
  location: 'Kathmandu',
);
```

### Fetch User Bookings
```dart
await bookingProvider.fetchUserBookings();
final bookings = bookingProvider.userBookings;
```

### Fetch Provider Bookings
```dart
await bookingProvider.fetchProviderBookings();
final bookings = bookingProvider.providerBookings;

// Filter by status
final pending = bookingProvider.pendingBookings;
final accepted = bookingProvider.acceptedBookings;
final completed = bookingProvider.completedBookings;
```

### Accept/Reject Booking (Provider)
```dart
// Accept
await bookingProvider.acceptBooking(bookingId);

// Reject
await bookingProvider.rejectBooking(bookingId);

// Complete
await bookingProvider.completeBooking(bookingId);
```

## 💬 Chat Operations

### Connect to WebSocket
```dart
import 'package:HamroGharSewa/providers/chat_provider.dart';

final chatProvider = context.read<ChatProvider>();

// Connect
await chatProvider.connect();

// Subscribe to user topic
final userData = await TokenManager().getUserData();
await chatProvider.subscribeToUserTopic(userData['id']);
```

### Send Message
```dart
await chatProvider.sendMessage(
  bookingId: booking.id!,
  receiverId: receiverId,
  message: 'Hello!',
);
```

### Load Chat History
```dart
await chatProvider.loadChatHistory(bookingId);
final messages = chatProvider.getChatMessages(bookingId);
```

### Listen to New Messages
```dart
Consumer<ChatProvider>(
  builder: (context, chatProvider, _) {
    final messages = chatProvider.getChatMessages(bookingId);
    return ListView.builder(
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final message = messages[index];
        return Text(message.message);
      },
    );
  },
)
```

### Open Chat Screen
```dart
import 'package:HamroGharSewa/view/chat/chat_screen.dart';

// Only if booking is accepted
if (booking.canChat) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => ChatScreen(booking: booking),
    ),
  );
}
```

## 🛠️ Service & Category Operations

### Fetch Services
```dart
import 'package:HamroGharSewa/providers/service_provider.dart' as sp;

final serviceProvider = context.read<sp.ServiceProvider>();

await serviceProvider.fetchServices();
final services = serviceProvider.services;
```

### Search Services
```dart
final results = serviceProvider.searchServices('plumber');
```

### Fetch Categories
```dart
await serviceProvider.fetchCategories();
final categories = serviceProvider.categories;
```

### Admin: Create Category
```dart
final success = await serviceProvider.createCategory(
  name: 'Plumbing',
  description: 'Water and drainage services',
  iconName: 'plumbing',
);
```

### Admin: Update Category
```dart
final success = await serviceProvider.updateCategory(
  categoryId: categoryId,
  name: 'Updated Name',
  description: 'Updated description',
);
```

### Admin: Delete Category
```dart
final success = await serviceProvider.deleteCategory(categoryId);
```

## 🔄 State Management Patterns

### Using Provider
```dart
// Read (one-time, doesn't rebuild)
final provider = context.read<BookingProvider>();

// Watch (rebuilds on change)
final provider = context.watch<BookingProvider>();

// Consumer (rebuilds specific widget)
Consumer<BookingProvider>(
  builder: (context, bookingProvider, child) {
    if (bookingProvider.isLoading) {
      return CircularProgressIndicator();
    }
    return ListView(...);
  },
)
```

### Error Handling
```dart
final bookingProvider = context.watch<BookingProvider>();

if (bookingProvider.error != null) {
  return Text('Error: ${bookingProvider.error}');
}
```

### Loading States
```dart
if (bookingProvider.isLoading) {
  return Center(child: CircularProgressIndicator());
}
```

## 🎯 Common UI Patterns

### Booking Card with Chat Button
```dart
Widget buildBookingCard(Booking booking) {
  return Card(
    child: Column(
      children: [
        Text(booking.serviceName),
        Text('Status: ${booking.status}'),
        if (booking.canChat)
          ElevatedButton.icon(
            icon: Icon(Icons.chat),
            label: Text('Chat'),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ChatScreen(booking: booking),
                ),
              );
            },
          ),
      ],
    ),
  );
}
```

### Service Card with Book Button
```dart
Widget buildServiceCard(Service service) {
  return Card(
    child: Column(
      children: [
        Text(service.name),
        Text(service.description),
        Text(service.displayPrice),
        ElevatedButton(
          child: Text('Book Now'),
          onPressed: () {
            // Navigate to booking form
          },
        ),
      ],
    ),
  );
}
```

### Provider Request Card
```dart
Widget buildRequestCard(Booking booking) {
  final bookingProvider = context.read<BookingProvider>();
  
  return Card(
    child: Column(
      children: [
        Text(booking.userName),
        Text(booking.serviceName),
        Text(booking.description ?? ''),
        Row(
          children: [
            ElevatedButton(
              child: Text('Accept'),
              onPressed: () async {
                final success = await bookingProvider.acceptBooking(booking.id!);
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Booking accepted!')),
                  );
                }
              },
            ),
            OutlinedButton(
              child: Text('Decline'),
              onPressed: () async {
                await bookingProvider.rejectBooking(booking.id!);
              },
            ),
          ],
        ),
      ],
    ),
  );
}
```

## 🔐 Token Management

### Get Current User Data
```dart
import 'package:HamroGharSewa/services/token_manager.dart';

final tokenManager = TokenManager();
final userData = await tokenManager.getUserData();

if (userData != null) {
  final userId = userData['id'];
  final userName = userData['userName'];
  final email = userData['email'];
  final role = userData['role'];
}
```

### Check Login Status
```dart
final isLoggedIn = await tokenManager.isLoggedIn();
if (!isLoggedIn) {
  // Redirect to login
}
```

### Logout
```dart
await tokenManager.logout(context);
// Automatically redirects to login screen
```

## 📱 Navigation

### Navigate to Dashboard Based on Role
```dart
await tokenManager.redirectBasedOnRole(context);
```

### Navigate to Specific Route
```dart
Navigator.pushNamed(context, AppRoutes.userDashboard);
Navigator.pushNamed(context, AppRoutes.providerDashboard);
Navigator.pushNamed(context, AppRoutes.adminDashboard);
```

### Navigate and Remove All Previous Routes
```dart
Navigator.pushNamedAndRemoveUntil(
  context,
  AppRoutes.userDashboard,
  (route) => false,
);
```

## 🎨 Using App Theme

### Colors
```dart
import 'package:HamroGharSewa/constants/app_colors.dart';

Container(
  color: AppColors.primaryBlue,
  // or
  decoration: BoxDecoration(
    gradient: LinearGradient(
      colors: [AppColors.gradientStart, AppColors.gradientEnd],
    ),
  ),
)
```

### Custom Button
```dart
import 'package:HamroGharSewa/common/custom_button.dart';

CustomButton(
  text: 'Submit',
  onPressed: () {
    // Handle press
  },
)
```

### Custom Text Field
```dart
import 'package:HamroGharSewa/common/custom_text_field.dart';

CustomTextField(
  controller: controller,
  hintText: 'Enter email',
  prefixIcon: Icons.email,
)
```

## 🚨 Error Handling Best Practices

### Try-Catch with User Feedback
```dart
try {
  await bookingProvider.createBooking(...);
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text('Booking created successfully!'),
      backgroundColor: Colors.green,
    ),
  );
} catch (e) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text('Error: $e'),
      backgroundColor: Colors.red,
    ),
  );
}
```

### Using Provider Error State
```dart
Consumer<BookingProvider>(
  builder: (context, provider, _) {
    if (provider.error != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(provider.error!)),
        );
        provider.clearError();
      });
    }
    return YourWidget();
  },
)
```

## 📊 Booking Status Flow

```
USER CREATES BOOKING
        ↓
    [PENDING]
        ↓
PROVIDER REVIEWS
    ↙       ↘
[ACCEPTED]  [REJECTED]
    ↓           ↓
CHAT ENABLED  BOOKING CLOSED
    ↓
SERVICE PROVIDED
    ↓
[COMPLETED]
```

## 🔄 Real-time Updates

### WebSocket Connection Status
```dart
Consumer<ChatProvider>(
  builder: (context, chatProvider, _) {
    return Icon(
      Icons.circle,
      color: chatProvider.isConnected ? Colors.green : Colors.red,
    );
  },
)
```

### Auto-refresh Bookings
```dart
@override
void initState() {
  super.initState();
  _refreshBookings();
  
  // Refresh every 30 seconds
  Timer.periodic(Duration(seconds: 30), (_) {
    _refreshBookings();
  });
}

Future<void> _refreshBookings() async {
  final provider = context.read<BookingProvider>();
  await provider.fetchProviderBookings();
}
```

---

**Quick Reference Version**: 1.0.0  
**Last Updated**: 2026-01-29
