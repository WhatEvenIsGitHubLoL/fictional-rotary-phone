class Config {
  static const String backendUrl = String.fromEnvironment(
    'BACKEND_URL',
    defaultValue: 'http://127.0.0.1:5883',
  );

  static const bool isDevelopment = bool.fromEnvironment(
    'DEVELOPMENT',
    defaultValue: true,
  );

  // Add any additional configuration values here
  static const int maxHistoryItems = 10;
  static const Duration requestTimeout = Duration(seconds: 10);
}
