class ApiConstants {
  // Base URL: only host + port (no trailing /api)
  static const String baseUrl = 'http://192.168.111.232:8080';

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
  static const String adminPendingProviders = '/api/admin/service-providers/pending';

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


 

  
}