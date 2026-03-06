# Transaction History Feature

## Overview
This feature displays all payment transactions made by the user through eSewa and Khalti payment gateways.

## Files Created

### 1. Transaction Model
**File:** `lib/models/transaction_model.dart`

Represents a payment transaction with:
- Transaction ID
- Payment method (Khalti/eSewa)
- Amount (auto-converts Khalti paisa to rupees)
- Status (Completed/Pending/Failed)
- Payment references (pidx for Khalti, referenceId for eSewa)
- Timestamps (paidAt, createdAt)

### 2. Transaction Service
**File:** `lib/services/payment/transaction_service.dart`

API service for transaction operations:
- `getUserTransactions()` - Get all user transactions
- `getTransactionById(id)` - Get specific transaction

### 3. Transaction History Page
**File:** `lib/view/payment/transaction_history_page.dart`

UI page displaying:
- List of all transactions
- Transaction details (amount, status, payment method)
- Pull-to-refresh functionality
- Empty state when no transactions
- Error handling with retry

## Features

### Transaction Card Display
Each transaction shows:
- ✅ Payment method icon (Khalti purple / eSewa green)
- ✅ Transaction status with color coding
- ✅ Amount in rupees (auto-converted)
- ✅ Transaction ID / Payment ID
- ✅ Date and time
- ✅ Status badge (Completed/Pending/Failed)

### Status Colors
- **Completed**: Green (success)
- **Pending**: Orange (warning)
- **Failed**: Red (error)

### Payment Method Colors
- **Khalti**: Purple (#5D2E8E)
- **eSewa**: Green (#60BB46)

## API Endpoint

### Get User Transactions
```
GET /api/payment/transactions
Authorization: Bearer {JWT_TOKEN}
```

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "id": "1",
      "userId": "user123",
      "paymentMethod": "KHALTI",
      "amount": 10000,
      "status": "Completed",
      "transactionId": "txn_xyz789",
      "pidx": "abc123xyz",
      "paidAt": "2026-03-06T10:30:00",
      "createdAt": "2026-03-06T10:25:00"
    }
  ]
}
```

## Usage

### Navigate to Transaction History

**From User Dashboard:**
```dart
// Click on Bookings card (now clickable)
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (_) => const TransactionHistoryPage(),
  ),
);
```

**Direct Navigation:**
```dart
import 'package:HamroGharSewa/view/payment/transaction_history_page.dart';

Navigator.push(
  context,
  MaterialPageRoute(
    builder: (_) => const TransactionHistoryPage(),
  ),
);
```

## UI Components

### AppBar
- Back button
- Title: "Transaction History"
- Refresh button

### Transaction List
- Scrollable list of transactions
- Pull-to-refresh enabled
- Each card shows full transaction details

### Empty State
- Icon: Receipt outline
- Message: "No Transactions Yet"
- Subtitle: "Your payment history will appear here"

### Error State
- Error icon
- Error message
- Retry button

### Loading State
- Circular progress indicator
- Centered on screen

## Integration

### User Dashboard Integration
The Bookings card is now clickable and navigates to Transaction History:

```dart
// Bookings Card (Dynamic Count)
Expanded(
  child: GestureDetector(
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const TransactionHistoryPage(),
        ),
      );
    },
    child: Container(
      // ... card design
      child: Column(
        children: [
          Icon(Icons.check_circle_rounded),
          Text('${bookingProvider.userBookings.length}'),
          Text('Bookings'),
        ],
      ),
    ),
  ),
)
```

## Testing

### Test Flow
1. Make a payment through eSewa or Khalti
2. Payment gets verified and saved
3. Click on Bookings card in User Dashboard
4. See transaction in history list
5. Pull down to refresh
6. See updated transaction list

### Test Data
Backend should return transactions with:
- Different payment methods (Khalti/eSewa)
- Different statuses (Completed/Pending/Failed)
- Various amounts
- Recent timestamps

## Error Handling

### Network Errors
- Shows error message
- Provides retry button
- Maintains user-friendly messaging

### Empty Response
- Shows empty state
- Encourages user to make payments

### Loading States
- Shows loading indicator
- Prevents multiple simultaneous requests

## Future Enhancements

- [ ] Filter by payment method
- [ ] Filter by status
- [ ] Filter by date range
- [ ] Search transactions
- [ ] Export transaction history
- [ ] Transaction details page
- [ ] Download receipt
- [ ] Share transaction

## Notes

- Khalti amounts are stored in paisa (1 rupee = 100 paisa)
- eSewa amounts are stored in rupees
- Auto-conversion handled in Transaction model
- JWT token required for all API calls
- Transactions sorted by date (newest first)
- Pull-to-refresh updates the list

## Dependencies

Already included in project:
- `dio` - HTTP client
- `intl` - Date formatting
- `flutter/material.dart` - UI components

## Security

- JWT authentication required
- User can only see their own transactions
- No sensitive payment data exposed
- Transaction IDs are masked if needed
