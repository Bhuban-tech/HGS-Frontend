class ApiConstants {
  static const String baseUrl = 'http://192.168.100.99:8080';

  // All endpoints must be RELATIVE (start with /)
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

  static Duration? get connectionTimeout => null;

  static Duration? get receiveTimeout => null;
  static String adminUpdateCategory(String id) => '/api/admin/categories/$id';
  static String adminDeleteCategory(String id) => '/api/admin/categories/$id';
  static String categoryById(String id) => '/api/admin/categories/$id';

  static const String createBooking = '/api/bookings';
  static const String userBookings = '/api/bookings/my-bookings';
  static const String providerBookings = '/api/bookings/requests';
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
  static const String providers = '/api/providers';
  static String providerById(String id) => '/api/providers/$id';
  static const String becomeProvider = '/api/providers/register';

  // ==================== CHAT ENDPOINTS ====================
  static const String chatWebSocket = '/ws-chat';
  static String chatHistory(String bookingId) => '/api/chat/$bookingId';
  static String chatTopic(String userId) => '/topic/user/$userId';
  static String chatSend = '/app/chat';

  // ==================== USER PROFILE ENDPOINTS ====================
  static const String userProfile = '/api/users/me';          // @GetMapping("/me")
  static const String updateProfile = '/api/users/profile';

  static const String requestEmailChange = '/api/users/request-email-change';
  static const String confirmEmailChange = '/api/users/confirm-email-change';
}
