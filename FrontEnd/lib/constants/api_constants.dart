class ApiConstants {

  static const String baseUrl = 'http://192.168.1.77:8080';

  static const String login = '/api/auth/login';
  static const String register = '/api/auth/register';
  static const String verifyOtp = '/api/auth/register/verify-otp';
  static const String logout = '/api/auth/logout';
  static const String refreshToken = '/api/auth/refresh-token';
  static const String forgotPassword = '/api/auth/forgot-password';
  static const String resetPassword = '/api/auth/reset-password';

  static const String adminUsers = '/api/admin/users';
  static const String adminProviders = '/api/admin/service-providers';
  static const String adminPendingProviders =
      '/api/admin/service-providers/pending';

  static String adminApproveProvider(String id) => '/api/admin/approve/$id';
  static String adminRejectProvider(String id) => '/api/admin/reject/$id';
  static String adminActivateUser(String id) => '/api/admin/activate/$id';
  static String adminDeactivateUser(String id) => '/api/admin/deactivate/$id';

  static const String adminCategories = '/api/admin/categories';
  static const String categories = '/api/categories';
  
  // Timeout configurations
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  
  // Admin category management endpoints
  static String adminUpdateCategory(String id) => '/api/admin/categories/$id';
  static String adminDeleteCategory(String id) => '/api/admin/categories/$id';
  static String categoryById(String id) => '/api/admin/categories/$id';

  static const String createBooking = '/api/bookings';
  static const String userBookings = '/api/bookings/my-bookings';
  static const String providerBookings = '/api/bookings/requests';
  
  // Booking endpoints with status filters
  static String userBookingsByStatus(String status) => '/api/bookings/my-bookings?status=$status';
  static String providerBookingsByStatus(String status) => '/api/bookings/requests?status=$status';
  
  static String bookingById(String id) => '/api/bookings/$id';
  static String acceptBooking(String id) => '/api/bookings/$id/accept';
  static String rejectBooking(String id) => '/api/bookings/$id/reject';
  static String cancelBooking(String id) => '/api/bookings/$id/cancel';
  static String completeBooking(String id) => '/api/bookings/$id/complete';

  // ==================== SERVICE ENDPOINTS ====================
  static const String services = '/api/services';
  static String serviceById(String id) => '/api/services/$id';
  static const String servicesByCategory = '/api/services/category';

  // ==================== PROVIDER ENDPOINTS ====================
  static const String providers = '/api/users/providers';
  static String providerById(String id) => '/api/users/providers/$id';
  static const String becomeProvider = '/api/users/become-provider';

  // ==================== CHAT ENDPOINTS ====================
  static const String chatWebSocket = '/ws-chat';
  static String chatHistory(String bookingId) => '/api/chat/$bookingId';
  static String chatTopic(String userId) => '/topic/user/$userId';
  static String chatSend = '/app/chat';

  // ==================== USER PROFILE ENDPOINTS ====================
  static const String userProfile = '/api/users/me';
  static const String updateProfile = '/api/users/profile';

  static const String requestEmailChange = '/api/users/request-email-change';
  static const String confirmEmailChange = '/api/users/confirm-email-change';

  // ==================== PAYMENT & TRANSACTION ENDPOINTS ====================
  static const String userTransactions = '/api/payment/history';
  static String transactionById(String id) => '/api/payment/history/$id';
  
  // Khalti payment endpoints
  static const String khaltiInitiate = '/api/payment/khalti/initiate';
  static const String khaltiVerify = '/api/payment/khalti/verify';
  
  // eSewa payment endpoints
  static const String esewaInitiate = '/api/payment/esewa/initiate';
  static const String esewaVerify = '/api/payment/esewa/verify';
}