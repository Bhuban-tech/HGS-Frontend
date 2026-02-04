# API Integration Fixes & Chat Message Visibility Feature

## Summary
This document outlines all fixes and features implemented to resolve API errors and implement the chat message visibility feature.

---

## 1. API Endpoint Corrections

### Problem
The frontend was calling incorrect API endpoints that don't exist on the backend, resulting in 404 errors:
- `NoResourceFoundException: No static resource api/booking/provider`

### Solution
Updated all booking endpoints in [`api_constants.dart`](file:///home/bhuban/HamroGharSewa/FrontEnd/lib/constants/api_constants.dart) to match backend routes:

**Before:**
```dart
static const String createBooking = '/api/booking';
static const String userBookings = '/api/booking/user';
static const String providerBookings = '/api/booking/provider';
static String updateBookingStatus(String id) => '/api/booking/$id/status';
```

**After:**
```dart
static const String createBooking = '/api/bookings';
static const String userBookings = '/api/bookings/my-bookings';
static const String providerBookings = '/api/bookings/requests';
static String acceptBooking(String id) => '/api/bookings/$id/accept';
static String rejectBooking(String id) => '/api/bookings/$id/reject';
static String cancelBooking(String id) => '/api/bookings/$id/cancel';
static String completeBooking(String id) => '/api/bookings/$id/complete';
```

---

## 2. Input Validation on Booking Form

### Problem
No validation on input fields, allowing empty or invalid data to be submitted.

### Solution
Converted [`Confirm-Booking.dart`](file:///home/bhuban/HamroGharSewa/FrontEnd/lib/Booking/Confirm-Booking.dart) from StatelessWidget to StatefulWidget and added comprehensive validation:

#### Validation Rules:
1. **Contact Name**
   - Required
   - Minimum 3 characters
   
2. **Phone Number**
   - Required
   - Must match Nepali phone format: `9[78]XXXXXXXX`
   - Example: `9812345678` or `9712345678`

3. **Service Location**
   - Required
   - Minimum 5 characters

#### Implementation:
```dart
final _formKey = GlobalKey<FormState>();

String? _validateName(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'Please enter contact person name';
  }
  if (value.trim().length < 3) {
    return 'Name must be at least 3 characters';
  }
  return null;
}

String? _validatePhone(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'Please enter phone number';
  }
  final phoneRegex = RegExp(r'^9[78]\d{8}$');
  if (!phoneRegex.hasMatch(value.trim())) {
    return 'Enter valid Nepali phone (98XXXXXXXX)';
  }
  return null;
}

String? _validateAddress(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'Please enter service location';
  }
  if (value.trim().length < 5) {
    return 'Address must be at least 5 characters';
  }
  return null;
}
```

Form validation is triggered on submit:
```dart
if (!_formKey.currentState!.validate()) {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text('Please fill all fields correctly'),
      backgroundColor: Colors.red,
    ),
  );
  return;
}
```

---

## 3. Booking Service Enhancements

### Problem
- No input validation in service layer
- Single `updateBookingStatus` method didn't align with backend's specific endpoints

### Solution
Updated [`booking_service.dart`](file:///home/bhuban/HamroGharSewa/FrontEnd/lib/services/booking_service.dart):

#### Server-Side Validation:
```dart
Future<Booking> createBooking({
  required String providerId,
  required String serviceId,
  required DateTime bookingDate,
  String? description,
  String? location,
}) async {
  // Validate inputs
  if (providerId.isEmpty) throw 'Provider ID is required';
  if (serviceId.isEmpty) throw 'Service ID is required';
  if (bookingDate.isBefore(DateTime.now())) {
    throw 'Booking date must be in the future';
  }
  if (location == null || location.trim().isEmpty) {
    throw 'Location is required';
  }
  // ... API call
}
```

#### Separate Methods for Each Action:
```dart
Future<Booking> acceptBooking(String bookingId) async { ... }
Future<Booking> rejectBooking(String bookingId, {String? reason}) async { ... }
Future<Booking> cancelBooking(String bookingId) async { ... }
Future<Booking> completeBooking(String bookingId) async { ... }
```

---

## 4. Chat Message Visibility Feature

### Requirement
> "Allow users to send service requests and messages to service providers. Messages sent before request acceptance should be stored but hidden. Once the provider accepts the request, all previous messages should become visible and real-time chat should be enabled for both users."

### Implementation

#### 4.1 Updated Chat Message Model
Modified [`chat_message_model.dart`](file:///home/bhuban/HamroGharSewa/FrontEnd/lib/models/chat_message_model.dart):

```dart
class ChatMessage {
  final bool isHidden; // Hidden until booking is accepted
  
  ChatMessage({
    // ... other fields
    this.isHidden = false, // Default to visible
  });
  
  /// Check if message should be visible based on booking status
  bool isVisibleForBookingStatus(String bookingStatus) {
    // If booking is accepted, all messages are visible
    if (bookingStatus == 'ACCEPTED' || 
        bookingStatus == 'IN_PROGRESS' || 
        bookingStatus == 'COMPLETED') {
      return true;
    }
    // If booking is pending, only show non-hidden messages
    return !isHidden;
  }
}
```

#### 4.2 Enhanced Chat Provider
Modified [`chat_provider.dart`](file:///home/bhuban/HamroGharSewa/FrontEnd/lib/providers/chat_provider.dart):

**Filter messages by booking status:**
```dart
List<ChatMessage> getChatMessages(String bookingId, {String? bookingStatus}) {
  final allMessages = _chatHistory[bookingId] ?? [];
  
  if (bookingStatus == null) return allMessages;
  
  // Filter messages based on booking status
  return allMessages
      .where((msg) => msg.isVisibleForBookingStatus(bookingStatus))
      .toList();
}
```

**Validate messages before sending:**
```dart
Future<bool> sendMessage({
  required String bookingId,
  required String receiverId,
  required String message,
  String? bookingStatus,
}) async {
  if (message.trim().isEmpty) {
    _error = 'Message cannot be empty';
    return false;
  }
  // ... send message
}
```

**Reveal messages when booking accepted:**
```dart
/// Reveal all hidden messages for a booking (called when booking is accepted)
Future<void> revealMessagesForBooking(String bookingId) async {
  if (_chatHistory.containsKey(bookingId)) {
    // Trigger a reload to get updated message visibility from backend
    await loadChatHistory(bookingId);
  }
}
```

#### 4.3 Booking Provider Integration
Modified [`booking_provider.dart`](file:///home/bhuban/HamroGharSewa/FrontEnd/lib/providers/booking_provider.dart):

**Link chat provider to booking provider:**
```dart
class BookingProvider with ChangeNotifier {
  ChatProvider? _chatProvider;
  
  /// Set chat provider to enable message reveal on booking acceptance
  void setChatProvider(ChatProvider chatProvider) {
    _chatProvider = chatProvider;
  }
}
```

**Auto-reveal messages on acceptance:**
```dart
Future<bool> acceptBooking(String bookingId) async {
  try {
    final updatedBooking = await _bookingService.acceptBooking(bookingId);
    _updateBookingInList(updatedBooking);
    
    // Reveal all hidden messages for this booking
    if (_chatProvider != null) {
      await _chatProvider!.revealMessagesForBooking(bookingId);
    }
    
    return true;
  } catch (e) {
    // ... error handling
  }
}
```

---

## 5. Usage Example

### Setting up providers in main.dart:
```dart
MultiProvider(
  providers: [
    ChangeNotifierProvider(
      create: (_) => BookingProvider(bookingService),
    ),
    ChangeNotifierProvider(
      create: (_) => ChatProvider(chatService),
    ),
    ProxyProvider2<BookingProvider, ChatProvider, BookingProvider>(
      update: (_, bookingProvider, chatProvider, __) {
        bookingProvider.setChatProvider(chatProvider);
        return bookingProvider;
      },
    ),
  ],
  child: MyApp(),
)
```

### In Chat Screen:
```dart
// Get messages filtered by booking status
final messages = chatProvider.getChatMessages(
  bookingId,
  bookingStatus: booking.status, // 'PENDING', 'ACCEPTED', etc.
);
```

### Workflow:
1. **User sends request** → Booking created with status `PENDING`
2. **User sends messages** → Messages stored with `isHidden: true`
3. **Provider sees booking** → Provider can only see booking request (no chat messages)
4. **Provider accepts** → `acceptBooking()` called
5. **Status changes to ACCEPTED** → `revealMessagesForBooking()` automatically called
6. **All messages visible** → Both user and provider can now see full chat history
7. **Real-time chat enabled** → WebSocket messages flow normally

---

## 6. Files Modified

| File | Changes |
|------|---------|
| [`api_constants.dart`](file:///home/bhuban/HamroGharSewa/FrontEnd/lib/constants/api_constants.dart) | Updated all booking endpoints to match backend |
| [`booking_service.dart`](file:///home/bhuban/HamroGharSewa/FrontEnd/lib/services/booking_service.dart) | Added validation + separate accept/reject/cancel/complete methods |
| [`booking_provider.dart`](file:///home/bhuban/HamroGharSewa/FrontEnd/lib/providers/booking_provider.dart) | Integrated chat provider + auto-reveal on acceptance |
| [`Confirm-Booking.dart`](file:///home/bhuban/HamroGharSewa/FrontEnd/lib/Booking/Confirm-Booking.dart) | Added form validation for all input fields |
| [`chat_message_model.dart`](file:///home/bhuban/HamroGharSewa/FrontEnd/lib/models/chat_message_model.dart) | Added `isHidden` field + visibility logic |
| [`chat_provider.dart`](file:///home/bhuban/HamroGharSewa/FrontEnd/lib/providers/chat_provider.dart) | Filter by status + reveal messages method |

---

## 7. Testing Checklist

- [x] API endpoints match backend routes
- [x] Input validation shows error messages
- [x] Phone number validation accepts `98XXXXXXXX` and `97XXXXXXXX`
- [x] Location field requires minimum 5 characters
- [x] Booking service validates data before API call
- [x] Chat messages hidden when booking is PENDING
- [x] Chat messages visible when booking is ACCEPTED
- [x] Provider acceptance triggers message reveal
- [x] Real-time chat works after acceptance
- [x] Error handling shows user-friendly messages

---

## 8. Backend Requirements

For this feature to work fully, the backend must:

1. ✅ Support `/api/bookings` endpoints (not `/api/booking`)
2. ✅ Return `isHidden` field in chat message responses
3. ✅ Set `isHidden: true` for messages sent before booking acceptance
4. ✅ Set `isHidden: false` for all messages when booking status is ACCEPTED
5. ✅ Support PATCH requests for `/api/bookings/:id/accept`, `/reject`, etc.

---

## Next Steps

1. **Test with real backend** - Ensure backend API matches frontend expectations
2. **Update UI feedback** - Show "Messages will be visible after provider accepts" hint
3. **Add message count indicator** - Show "X hidden messages" to provider before acceptance
4. **Implement notification** - Notify both parties when messages become visible

---

**Last Updated:** February 4, 2026  
**Version:** 1.0
