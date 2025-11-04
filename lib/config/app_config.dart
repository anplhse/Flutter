import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  // Singleton pattern
  static final AppConfig _instance = AppConfig._internal();
  factory AppConfig() => _instance;
  AppConfig._internal();

  // API Configuration
  static String get apiBaseUrl => dotenv.env['API_BASE_URL'] ?? 'https://museum-system-api-160202770359.asia-southeast1.run.app/api/v1';
  static String get apiSwaggerUrl => dotenv.env['API_SWAGGER_URL'] ?? 'https://museum-system-api-160202770359.asia-southeast1.run.app/swagger/v1/api';

  // App Configuration
  static String get appName => dotenv.env['APP_NAME'] ?? 'Hệ Thống Bảo Tàng';
  static String get appVersion => dotenv.env['APP_VERSION'] ?? '2.3.0';

  // Debug Mode
  static bool get debugMode => dotenv.env['DEBUG_MODE']?.toLowerCase() == 'true';

  // API Endpoints (tương thích với AppConstants cũ)
  static String get museumsEndpoint => '/museums';
  static String get artifactsEndpoint => '/artifacts';
  static String get visitorsEndpoint => '/visitors';
  static String get registerEndpoint => '/visitors/register';
  static String get loginEndpoint => '/visitors/login';
  static String get profileEndpoint => '/visitors/me';

  // Full URLs
  static String get museumsUrl => '$apiBaseUrl$museumsEndpoint';
  static String get artifactsUrl => '$apiBaseUrl$artifactsEndpoint';
  static String get visitorsUrl => '$apiBaseUrl$visitorsEndpoint';
  static String get registerUrl => '$apiBaseUrl$registerEndpoint';
  static String get loginUrl => '$apiBaseUrl$loginEndpoint';
  static String get profileUrl => '$apiBaseUrl$profileEndpoint';

  // Print all config (for debugging)
  static void printConfig() {
    if (!debugMode) return;
    debugPrint('=== App Configuration ===');
    debugPrint('API Base URL: $apiBaseUrl');
    debugPrint('API Swagger URL: $apiSwaggerUrl');
    debugPrint('App Name: $appName');
    debugPrint('App Version: $appVersion');
    debugPrint('Debug Mode: $debugMode');
    debugPrint('========================');
  }
}

