class ApiConfig {
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://go-fit-production-1a8c.up.railway.app',
  );

  static const Duration timeout = Duration(seconds: 30);
}
