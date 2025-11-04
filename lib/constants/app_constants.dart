import '../config/app_config.dart';

class AppConstants {
  // API Endpoints - Sử dụng từ AppConfig (.env)
  static String get baseUrl => AppConfig.apiBaseUrl;
  static String get museumsEndpoint => AppConfig.museumsEndpoint;
  static String get artifactsEndpoint => AppConfig.artifactsEndpoint;
  static String get visitorsEndpoint => AppConfig.visitorsEndpoint;
  static String get registerEndpoint => AppConfig.registerEndpoint;
  static String get loginEndpoint => AppConfig.loginEndpoint;
  static String get profileEndpoint => AppConfig.profileEndpoint;

  // QR Code Formats
  static const String qrPrefix = 'MUSEUM:';
  static const String artifactUrlPattern = '/artifact/';

  // Asset Paths
  static const String imagesPath = 'assets/images/';
  static const String iconsPath = 'assets/icons/';

  // App Configuration
  static String get appName => AppConfig.appName;
  static const String defaultAppName = 'Hệ Thống Bảo Tàng';
  static const int searchDebounceMs = 500;
  static const int mockApiDelayMs = 1000;

  // Shared Preferences Keys
  static const String keyAuthToken = 'auth_token';
  static const String keyUserId = 'user_id';
  static const String keyUsername = 'username';
  static const String keyUserStatus = 'user_status';
}



