class ApiConstants {
  ApiConstants._();

  // ESP32 Base URL
  static const String baseUrl = 'http://192.168.1.12';

  // Endpoints
  static const String health = '/health';

  // Timeouts
  static const Duration connectionTimeout =
      Duration(seconds: 10);

  static const Duration receiveTimeout =
      Duration(seconds: 15);
}
