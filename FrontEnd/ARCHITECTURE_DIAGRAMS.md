# HamroGharSewa Flutter Architecture Diagram

## 📐 Application Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                         FLUTTER APP                              │
│                         (main.dart)                              │
│                                                                   │
│  ┌────────────────────────────────────────────────────────────┐ │
│  │                    MultiProvider                            │ │
│  │  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐    │ │
│  │  │   Booking    │  │     Chat     │  │   Service    │    │ │
│  │  │   Provider   │  │   Provider   │  │   Provider   │    │ │
│  │  └──────────────┘  └──────────────┘  └──────────────┘    │ │
│  └────────────────────────────────────────────────────────────┘ │
│                                                                   │
│  ┌────────────────────────────────────────────────────────────┐ │
│  │                    UI LAYER (Views)                         │ │
│  │  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐  │ │
│  │  │  Login   │  │ Register │  │   User   │  │ Provider │  │ │
│  │  │  Screen  │  │  Screen  │  │Dashboard │  │Dashboard │  │ │
│  │  └──────────┘  └──────────┘  └──────────┘  └──────────┘  │ │
│  │  ┌──────────┐  ┌──────────┐  ┌──────────┐                │ │
│  │  │  Admin   │  │   Chat   │  │ Booking  │                │ │
│  │  │Dashboard │  │  Screen  │  │  Screen  │                │ │
│  │  └──────────┘  └──────────┘  └──────────┘                │ │
│  └────────────────────────────────────────────────────────────┘ │
│                                                                   │
│  ┌────────────────────────────────────────────────────────────┐ │
│  │                  SERVICE LAYER                              │ │
│  │  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐    │ │
│  │  │   Booking    │  │     Chat     │  │   Service    │    │ │
│  │  │   Service    │  │   Service    │  │ API Service  │    │ │
│  │  └──────────────┘  └──────────────┘  └──────────────┘    │ │
│  │  ┌──────────────┐  ┌──────────────┐                      │ │
│  │  │     Auth     │  │    Token     │                      │ │
│  │  │   Service    │  │   Manager    │                      │ │
│  │  └──────────────┘  └──────────────┘                      │ │
│  └────────────────────────────────────────────────────────────┘ │
│                                                                   │
│  ┌────────────────────────────────────────────────────────────┐ │
│  │                   DATA LAYER (Models)                       │ │
│  │  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐  │ │
│  │  │ Booking  │  │   Chat   │  │ Service  │  │   User   │  │ │
│  │  │  Model   │  │ Message  │  │  Model   │  │  Model   │  │ │
│  │  └──────────┘  └──────────┘  └──────────┘  └──────────┘  │ │
│  └────────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────┘
                              ↕
                         HTTP / WebSocket
                              ↕
┌─────────────────────────────────────────────────────────────────┐
│                    SPRING BOOT BACKEND                           │
│                  http://192.168.111.232:8080                     │
│                                                                   │
│  ┌────────────────────────────────────────────────────────────┐ │
│  │                    REST API ENDPOINTS                        │ │
│  │  • POST   /api/auth/login                                   │ │
│  │  • POST   /api/auth/register                                │ │
│  │  • POST   /api/booking                                      │ │
│  │  • GET    /api/booking/user                                 │ │
│  │  • GET    /api/booking/provider                             │ │
│  │  • PUT    /api/booking/{id}/status                          │ │
│  │  • GET    /api/services                                     │ │
│  │  • GET    /api/categories                                   │ │
│  │  • GET    /api/chat/{bookingId}                             │ │
│  └────────────────────────────────────────────────────────────┘ │
│                                                                   │
│  ┌────────────────────────────────────────────────────────────┐ │
│  │                  WEBSOCKET ENDPOINT                          │ │
│  │  • WS     /ws-chat                                          │ │
│  │  • Topic  /topic/user/{userId}                              │ │
│  │  • Send   /app/chat                                         │ │
│  └────────────────────────────────────────────────────────────┘ │
│                                                                   │
│  ┌────────────────────────────────────────────────────────────┐ │
│  │                      DATABASE                                │ │
│  │                    MySQL 8.0+                                │ │
│  └────────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────┘
```

---

## 🔄 Data Flow Diagrams

### 1. Authentication Flow

```
┌──────────┐         ┌──────────┐         ┌──────────┐         ┌──────────┐
│  Login   │         │   Auth   │         │  Token   │         │   Role   │
│  Screen  │────────▶│ Service  │────────▶│ Manager  │────────▶│  Based   │
│          │         │          │         │          │         │  Routing │
└──────────┘         └──────────┘         └──────────┘         └──────────┘
     │                     │                     │                     │
     │  Enter Email/Pass   │                     │                     │
     ├────────────────────▶│                     │                     │
     │                     │  POST /api/auth/    │                     │
     │                     │       login         │                     │
     │                     ├────────────────────▶│                     │
     │                     │                     │  Save JWT Token     │
     │                     │                     ├────────────────────▶│
     │                     │                     │  Extract Role       │
     │                     │                     │                     │
     │                     │                     │  Navigate to        │
     │                     │                     │  Dashboard          │
     │◀────────────────────┴─────────────────────┴─────────────────────┤
     │                                                                  │
     ▼                                                                  ▼
┌──────────┐                                                    ┌──────────┐
│   User   │                                                    │ Provider │
│Dashboard │                                                    │Dashboard │
└──────────┘                                                    └──────────┘
```

### 2. Booking Flow

```
USER SIDE                                    PROVIDER SIDE
┌──────────┐                                 ┌──────────┐
│  Browse  │                                 │ Provider │
│ Services │                                 │Dashboard │
└────┬─────┘                                 └────┬─────┘
     │                                            │
     ▼                                            │
┌──────────┐                                      │
│  Select  │                                      │
│ Service  │                                      │
└────┬─────┘                                      │
     │                                            │
     ▼                                            │
┌──────────┐                                      │
│   Fill   │                                      │
│ Booking  │                                      │
│   Form   │                                      │
└────┬─────┘                                      │
     │                                            │
     │  createBooking()                           │
     ├───────────────────────────────────────────▶│
     │                                            │
     │  POST /api/booking                         │
     │  Status: PENDING                           │
     │                                            │
     │                                            ▼
     │                                     ┌──────────┐
     │                                     │   View   │
     │                                     │ Booking  │
     │                                     │ Request  │
     │                                     └────┬─────┘
     │                                          │
     │                                          ▼
     │                                     ┌──────────┐
     │                                     │ Accept / │
     │                                     │  Reject  │
     │                                     └────┬─────┘
     │                                          │
     │  PUT /api/booking/{id}/status            │
     │◀─────────────────────────────────────────┤
     │  Status: ACCEPTED                        │
     │                                          │
     ▼                                          ▼
┌──────────┐                              ┌──────────┐
│   Chat   │◀────────────────────────────▶│   Chat   │
│ Enabled  │      WebSocket /ws-chat      │ Enabled  │
└──────────┘                              └──────────┘
```

### 3. Real-Time Chat Flow

```
USER                          WEBSOCKET SERVER                    PROVIDER
┌──────────┐                  ┌──────────┐                       ┌──────────┐
│   Chat   │                  │   Chat   │                       │   Chat   │
│  Screen  │                  │ Service  │                       │  Screen  │
└────┬─────┘                  └────┬─────┘                       └────┬─────┘
     │                             │                                  │
     │  connect()                  │                                  │
     ├────────────────────────────▶│                                  │
     │  WS /ws-chat?token=xxx      │                                  │
     │                             │                                  │
     │  subscribeToUserTopic()     │                                  │
     ├────────────────────────────▶│                                  │
     │  /topic/user/{userId}       │                                  │
     │                             │                                  │
     │  loadChatHistory()          │                                  │
     ├────────────────────────────▶│                                  │
     │  GET /api/chat/{bookingId}  │                                  │
     │◀────────────────────────────┤                                  │
     │  [Previous Messages]        │                                  │
     │                             │                                  │
     │  sendMessage()              │                                  │
     ├────────────────────────────▶│                                  │
     │  {bookingId, message, ...}  │                                  │
     │                             │  Forward to Provider             │
     │                             ├─────────────────────────────────▶│
     │                             │  /topic/user/{providerId}        │
     │                             │                                  │
     │                             │  Provider sends reply            │
     │  Receive message            │◀─────────────────────────────────┤
     │◀────────────────────────────┤                                  │
     │  /topic/user/{userId}       │                                  │
     │                             │                                  │
     ▼                             ▼                                  ▼
[Message Displayed]          [Message Stored]              [Message Displayed]
```

---

## 🗂️ File Structure Tree

```
lib/
├── main.dart                           # App entry + MultiProvider setup
│
├── constants/
│   ├── api_constants.dart              # All API endpoints
│   ├── app_colors.dart                 # Color palette (#4F46E5)
│   └── app_theme.dart                  # Material theme config
│
├── models/
│   ├── auth_response.dart              # Login/Register response
│   ├── booking_model.dart              # Booking with status helpers
│   ├── chat_message_model.dart         # Chat message + timestamp
│   ├── service_model.dart              # Service + Category
│   ├── service_provider.dart           # Provider profile
│   └── user_model.dart                 # User profile
│
├── services/
│   ├── auth_service.dart               # Login, Register, OTP
│   ├── booking_service.dart            # Booking CRUD operations
│   ├── chat_service.dart               # WebSocket chat
│   ├── service_api_service.dart        # Service/Category API
│   ├── api_client.dart                 # Dio wrapper
│   ├── api_service.dart                # Generic API service
│   └── token_manager.dart              # JWT storage + role routing
│
├── providers/
│   ├── booking_provider.dart           # Booking state (ChangeNotifier)
│   ├── chat_provider.dart              # Chat state (ChangeNotifier)
│   └── service_provider.dart           # Service state (ChangeNotifier)
│
├── repositories/
│   └── auth_repository.dart            # Auth data layer
│
├── view/
│   ├── Login/
│   │   └── login_view.dart             # Login screen
│   ├── register/
│   │   └── register_view.dart          # Registration screen
│   ├── booking/
│   │   └── bookingPage_view.dart       # Booking form
│   ├── chat/
│   │   └── chat_screen.dart            # Real-time chat UI ✨ NEW
│   ├── forgetpassword/
│   ├── resetpassword/
│   └── verifyotpscreen/
│
├── DashBoard/
│   ├── User.dart                       # User dashboard
│   ├── provider_dashboard_view.dart    # Provider dashboard
│   └── AdminDashboard_view.dart        # Admin dashboard
│
├── common/
│   ├── custom_button.dart              # Reusable button
│   ├── custom_text_field.dart          # Reusable text field
│   └── loading_widget.dart             # Loading indicator
│
└── route/
    └── app_routes.dart                 # Route configuration
```

---

## 🎯 Component Interaction Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                         UI SCREENS                               │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐       │
│  │   User   │  │ Provider │  │  Admin   │  │   Chat   │       │
│  │Dashboard │  │Dashboard │  │Dashboard │  │  Screen  │       │
│  └────┬─────┘  └────┬─────┘  └────┬─────┘  └────┬─────┘       │
└───────┼─────────────┼─────────────┼─────────────┼──────────────┘
        │             │             │             │
        │   context.read<Provider>()              │
        ▼             ▼             ▼             ▼
┌─────────────────────────────────────────────────────────────────┐
│                        PROVIDERS                                 │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐          │
│  │   Booking    │  │     Chat     │  │   Service    │          │
│  │   Provider   │  │   Provider   │  │   Provider   │          │
│  └──────┬───────┘  └──────┬───────┘  └──────┬───────┘          │
└─────────┼──────────────────┼──────────────────┼─────────────────┘
          │                  │                  │
          │   Calls service methods             │
          ▼                  ▼                  ▼
┌─────────────────────────────────────────────────────────────────┐
│                        SERVICES                                  │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐          │
│  │   Booking    │  │     Chat     │  │   Service    │          │
│  │   Service    │  │   Service    │  │ API Service  │          │
│  └──────┬───────┘  └──────┬───────┘  └──────┬───────┘          │
└─────────┼──────────────────┼──────────────────┼─────────────────┘
          │                  │                  │
          │   HTTP / WebSocket                  │
          ▼                  ▼                  ▼
┌─────────────────────────────────────────────────────────────────┐
│                    BACKEND API                                   │
│                http://192.168.111.232:8080                       │
└─────────────────────────────────────────────────────────────────┘
```

---

## 📊 State Management Flow

```
┌─────────────────────────────────────────────────────────────────┐
│                    USER INTERACTION                              │
│              (Button Press, Form Submit, etc.)                   │
└────────────────────────┬─────────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────────┐
│                    UI WIDGET                                     │
│         context.read<BookingProvider>()                          │
│         await provider.createBooking(...)                        │
└────────────────────────┬─────────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────────┐
│                  PROVIDER (State Manager)                        │
│  1. Set loading = true                                           │
│  2. Call service method                                          │
│  3. Update state with result                                     │
│  4. Set loading = false                                          │
│  5. notifyListeners()                                            │
└────────────────────────┬─────────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────────┐
│                    SERVICE LAYER                                 │
│  1. Prepare request data                                         │
│  2. Get JWT token from TokenManager                              │
│  3. Make HTTP/WebSocket call                                     │
│  4. Parse response                                               │
│  5. Return data or throw error                                   │
└────────────────────────┬─────────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────────┐
│                    BACKEND API                                   │
│  1. Validate JWT token                                           │
│  2. Process request                                              │
│  3. Update database                                              │
│  4. Return response                                              │
└────────────────────────┬─────────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────────┐
│                    UI UPDATE                                     │
│  Consumer<BookingProvider> rebuilds                              │
│  Display new data / error / loading state                        │
└─────────────────────────────────────────────────────────────────┘
```

---

**Diagram Version**: 1.0.0  
**Last Updated**: 2026-01-29
