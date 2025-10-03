class AppConstants {
  // API Endpoints
  static const String baseUrl = 'https://api.museum.com';
  static const String artifactsEndpoint = '/artifacts';

  // QR Code Formats
  static const String qrPrefix = 'MUSEUM:';
  static const String artifactUrlPattern = '/artifact/';

  // Asset Paths
  static const String imagesPath = 'assets/images/';
  static const String iconsPath = 'assets/icons/';

  // App Configuration
  static const String appName = 'Bảo Tàng Việt Nam';
  static const int searchDebounceMs = 500;
  static const int mockApiDelayMs = 1000;
}

