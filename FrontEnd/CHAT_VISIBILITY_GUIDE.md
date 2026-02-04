# Chat Message Visibility - Integration Guide

## Quick Start

### Step 1: Setup Providers in main.dart

```dart
import 'package:provider/provider.dart';
import 'package:HamroGharSewa/providers/booking_provider.dart';
import 'package:HamroGharSewa/providers/chat_provider.dart';
import 'package:HamroGharSewa/services/booking_service.dart';
import 'package:HamroGharSewa/services/chat_service.dart';

void main() {
  // Initialize services
  final bookingService = BookingService(dio);
  final chatService = ChatService(dio);

  runApp(
    MultiProvider(
      providers: [
        // Booking Provider
        ChangeNotifierProvider(
          create: (_) => BookingProvider(bookingService),
        ),
        
        // Chat Provider
        ChangeNotifierProvider(
          create: (_) => ChatProvider(chatService),
        ),
        
        // Link BookingProvider with ChatProvider
        ProxyProvider2<BookingProvider, ChatProvider, BookingProvider>(
          update: (context, bookingProvider, chatProvider, previous) {
            bookingProvider.setChatProvider(chatProvider);
            return bookingProvider;
          },
        ),
      ],
      child: MyApp(),
    ),
  );
}
```

---

## Step 2: Display Chat Messages Based on Booking Status

### In Chat Screen Widget:

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:HamroGharSewa/providers/chat_provider.dart';
import 'package:HamroGharSewa/models/booking_model.dart';

class ChatScreen extends StatelessWidget {
  final Booking booking;
  
  const ChatScreen({required this.booking});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat - ${booking.providerName}'),
      ),
      body: Consumer<ChatProvider>(
        builder: (context, chatProvider, child) {
          // Get messages filtered by booking status
          final messages = chatProvider.getChatMessages(
            booking.id,
            bookingStatus: booking.status, // PENDING, ACCEPTED, etc.
          );

          // Show info banner if booking is pending
          if (booking.status == 'PENDING') {
            return Column(
              children: [
                _buildPendingBanner(),
                Expanded(child: _buildMessageList(messages)),
              ],
            );
          }

          return _buildMessageList(messages);
        },
      ),
    );
  }

  Widget _buildPendingBanner() {
    return Container(
      padding: EdgeInsets.all(12),
      color: Colors.orange.shade100,
      child: Row(
        children: [
          Icon(Icons.info_outline, color: Colors.orange),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Messages will be visible to provider after they accept your request',
              style: TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageList(List<ChatMessage> messages) {
    // Display filtered messages
    return ListView.builder(
      reverse: true,
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final message = messages[index];
        return MessageBubble(message: message);
      },
    );
  }
}
```

---

## Step 3: Handle Provider Acceptance

### In Provider Dashboard (Accept Button):

```dart
class ProviderBookingCard extends StatelessWidget {
  final Booking booking;

  const ProviderBookingCard({required this.booking});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          // Booking details...
          
          if (booking.status == 'PENDING')
            Row(
              children: [
                // Accept Button
                Expanded(
                  child: ElevatedButton.icon(
                    icon: Icon(Icons.check),
                    label: Text('Accept'),
                    onPressed: () => _handleAccept(context),
                  ),
                ),
                
                SizedBox(width: 8),
                
                // Reject Button
                Expanded(
                  child: OutlinedButton.icon(
                    icon: Icon(Icons.close),
                    label: Text('Reject'),
                    onPressed: () => _handleReject(context),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Future<void> _handleAccept(BuildContext context) async {
    final bookingProvider = Provider.of<BookingProvider>(context, listen: false);
    
    final success = await bookingProvider.acceptBooking(booking.id);
    
    if (success && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Booking accepted! Chat is now active.'),
          backgroundColor: Colors.green,
        ),
      );
      
      // Note: Messages are automatically revealed by BookingProvider
      // No manual action needed!
    }
  }

  Future<void> _handleReject(BuildContext context) async {
    final bookingProvider = Provider.of<BookingProvider>(context, listen: false);
    
    final success = await bookingProvider.rejectBooking(
      booking.id,
      reason: 'Not available',
    );
    
    if (success && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Booking rejected')),
      );
    }
  }
}
```

---

## Step 4: Send Messages

### In Chat Input Field:

```dart
class ChatInputField extends StatefulWidget {
  final Booking booking;

  const ChatInputField({required this.booking});

  @override
  State<ChatInputField> createState() => _ChatInputFieldState();
}

class _ChatInputFieldState extends State<ChatInputField> {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);

    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: widget.booking.status == 'PENDING'
                    ? 'Send message (hidden until accepted)...'
                    : 'Type a message...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
              ),
              maxLines: null,
            ),
          ),
          SizedBox(width: 8),
          Consumer<ChatProvider>(
            builder: (context, provider, _) {
              return IconButton(
                icon: provider.isLoading
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Icon(Icons.send),
                color: Colors.blue,
                onPressed: provider.isLoading ? null : () => _sendMessage(context),
              );
            },
          ),
        ],
      ),
    );
  }

  Future<void> _sendMessage(BuildContext context) async {
    final message = _controller.text.trim();
    if (message.isEmpty) return;

    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    
    final success = await chatProvider.sendMessage(
      bookingId: widget.booking.id,
      receiverId: widget.booking.providerId,
      message: message,
      bookingStatus: widget.booking.status,
    );

    if (success) {
      _controller.clear();
    } else if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(chatProvider.error ?? 'Failed to send message'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
```

---

## Message Visibility Flow

### Visual Diagram:

```
┌─────────────────────────────────────────────────────────┐
│ PENDING STATUS (Before Provider Accepts)                │
├─────────────────────────────────────────────────────────┤
│                                                          │
│  User Side:                    Provider Side:           │
│  ✓ Can see own messages        ✗ Cannot see messages    │
│  ✓ Can send messages           ✓ Can see booking request│
│  ℹ  Messages marked as hidden  ✓ Can accept/reject      │
│                                                          │
└─────────────────────────────────────────────────────────┘
                          │
                          │ Provider clicks "Accept"
                          ▼
┌─────────────────────────────────────────────────────────┐
│ ACCEPTED STATUS (After Provider Accepts)                │
├─────────────────────────────────────────────────────────┤
│                                                          │
│  User Side:                    Provider Side:           │
│  ✓ Can see all messages        ✓ Can see all messages   │
│  ✓ Can send messages           ✓ Can send messages      │
│  ✓ Real-time chat enabled      ✓ Real-time chat enabled │
│  ✓ Previous msgs now visible   ✓ Previous msgs revealed │
│                                                          │
└─────────────────────────────────────────────────────────┘
```

---

## Backend Integration Points

### 1. When Booking is Created:
```json
POST /api/bookings
{
  "providerId": "provider123",
  "serviceId": "service456",
  "bookingDate": "2026-02-05T10:00:00Z",
  "location": "Kathmandu, Nepal",
  "status": "PENDING"
}
```

### 2. When User Sends Message (Booking PENDING):
```json
POST /api/chat/messages
{
  "bookingId": "booking789",
  "receiverId": "provider123",
  "message": "Hello, are you available?",
  "isHidden": true  // ← Backend sets this to true
}
```

### 3. When Provider Accepts Booking:
```json
PATCH /api/bookings/booking789/accept

Response:
{
  "id": "booking789",
  "status": "ACCEPTED",
  ...
}
```

### 4. Backend Auto-Updates Messages:
```sql
-- Backend should run this when booking is accepted:
UPDATE chat_messages 
SET is_hidden = false 
WHERE booking_id = 'booking789';
```

### 5. Frontend Fetches Updated Messages:
```json
GET /api/chat/bookings/booking789/messages

Response:
[
  {
    "id": "msg1",
    "message": "Hello, are you available?",
    "isHidden": false,  // ← Now false after acceptance
    "timestamp": "2026-02-04T12:00:00Z"
  }
]
```

---

## Error Handling

### Validation Errors:

```dart
// Empty message
if (message.trim().isEmpty) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Message cannot be empty')),
  );
  return;
}

// Booking not found
if (booking == null) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Booking not found')),
  );
  return;
}
```

### Network Errors:

```dart
try {
  await chatProvider.sendMessage(...);
} catch (e) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text('Network error: ${e.toString()}'),
      action: SnackBarAction(
        label: 'Retry',
        onPressed: () => _sendMessage(context),
      ),
    ),
  );
}
```

---

## Testing

### Test Scenarios:

1. **User sends message before acceptance**
   - ✓ Message appears in user's chat
   - ✓ Message does NOT appear in provider's chat
   - ✓ Info banner shows "Messages will be visible..."

2. **Provider accepts booking**
   - ✓ `acceptBooking()` API call succeeds
   - ✓ `revealMessagesForBooking()` is automatically called
   - ✓ Chat messages reload

3. **After acceptance**
   - ✓ All previous messages visible to both parties
   - ✓ Real-time messages work normally
   - ✓ No info banner displayed

4. **Provider rejects booking**
   - ✓ Booking status changes to REJECTED
   - ✓ Chat is disabled
   - ✓ Messages remain hidden

---

## Complete Example: Booking to Chat Flow

```dart
// 1. User creates booking
final bookingProvider = Provider.of<BookingProvider>(context, listen: false);
await bookingProvider.createBooking(
  providerId: provider.id,
  serviceId: service.id,
  bookingDate: selectedDate,
  location: locationController.text,
);

// 2. User sends pre-acceptance message
final chatProvider = Provider.of<ChatProvider>(context, listen: false);
await chatProvider.sendMessage(
  bookingId: booking.id,
  receiverId: provider.id,
  message: "Hello! When can you start?",
  bookingStatus: 'PENDING', // ← Message will be hidden
);

// 3. Provider accepts booking (in Provider Dashboard)
await bookingProvider.acceptBooking(booking.id);
// ↑ This automatically calls chatProvider.revealMessagesForBooking()

// 4. Messages are now visible - both can chat normally
final messages = chatProvider.getChatMessages(
  booking.id,
  bookingStatus: 'ACCEPTED', // ← All messages visible
);
```

---

## Summary Checklist

Before deploying to production:

- [ ] Provider setup with ProxyProvider linking BookingProvider and ChatProvider
- [ ] Chat screen filters messages by booking status
- [ ] Info banner displays for PENDING bookings
- [ ] Accept button calls `acceptBooking()`
- [ ] Backend sets `isHidden: true` for pre-acceptance messages
- [ ] Backend updates `isHidden: false` when booking accepted
- [ ] Frontend auto-reloads messages after acceptance
- [ ] Error handling for network failures
- [ ] Validation for empty messages
- [ ] UI feedback for all states (loading, success, error)

---

**Need Help?**
- Check [`FIXES_AND_FEATURES.md`](file:///home/bhuban/HamroGharSewa/FrontEnd/FIXES_AND_FEATURES.md) for detailed technical documentation
- Review [`chat_provider.dart`](file:///home/bhuban/HamroGharSewa/FrontEnd/lib/providers/chat_provider.dart) for implementation
- Check [`booking_provider.dart`](file:///home/bhuban/HamroGharSewa/FrontEnd/lib/providers/booking_provider.dart) for acceptance flow
