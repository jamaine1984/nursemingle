// API Configuration for Nurse Mingle
const String baseUrl = 'https://nurse-mingle.com';

// API Endpoints - Updated to match backend
class ApiEndpoints {
  static const String auth = '/api/auth';
  static const String signin = '$auth/signin';
  static const String signup = '$auth/signup';
  static const String logout = '$auth/logout';
  static const String refreshToken = '$auth/refresh';
  static const String verifyEmail = '$auth/verify-email';
  static const String resetPassword = '$auth/reset-password';
  static const String me = '$auth/me';
  
  static const String users = '/api/users';
  static const String profile = '$users/profile';
  static const String discover = '$users/discover';
  static const String like = '$users/like';
  static const String superLike = '$users/super-like';
  static const String pass = '$users/pass';
  
  // Subscription endpoints
  static const String subscription = '/api/subscription';
  static const String upgradePlan = '$subscription/upgrade';
  static const String usageStats = '$subscription/usage';
  
  // Monetization endpoints
  static const String gifts = '/api/gifts';
  static const String sendGift = '$gifts/send';
  static const String rewards = '/api/rewards';
  static const String watchAd = '$rewards/watch-ad';
  
  // Live streaming endpoints
  static const String streaming = '/api/streaming';
  static const String startStream = '$streaming/start';
  static const String endStream = '$streaming/end';
  static const String joinStream = '$streaming/join';
  
  // Communication endpoints
  // Notifications endpoints
  static const String notifications = '/api/notifications';
  static const String sendNotification = '$notifications/send';
  static const String subscribeToTopic = '$notifications/subscribe';
  static const String unsubscribeFromTopic = '$notifications/unsubscribe';
}

// API Configuration
class ApiConfig {
  static const String contentType = 'application/json';
  static const int connectionTimeout = 30000; // 30 seconds
  static const int receiveTimeout = 30000; // 30 seconds
  
  // Headers
  static Map<String, String> get defaultHeaders => {
    'Content-Type': contentType,
    'Accept': contentType,
  };
  
  static Map<String, String> getAuthHeaders(String token) => {
    ...defaultHeaders,
    'Authorization': 'Bearer $token',
  };
}

// Environment Configuration
class Environment {
  static const String development = 'development';
  static const String staging = 'staging';
  static const String production = 'production';
  
  static const String current = development; // Change this for different environments
  
  static bool get isDevelopment => current == development;
  static bool get isStaging => current == staging;
  static bool get isProduction => current == production;
}

// Error Messages
class ApiErrorMessages {
  static const String networkError = 'Network error. Please check your connection.';
  static const String serverError = 'Server error. Please try again later.';
  static const String unauthorized = 'Unauthorized. Please log in again.';
  static const String forbidden = 'Access denied.';
  static const String notFound = 'Resource not found.';
  static const String badRequest = 'Invalid request.';
  static const String timeout = 'Request timeout. Please try again.';
  static const String unknown = 'An unknown error occurred.';
} 
