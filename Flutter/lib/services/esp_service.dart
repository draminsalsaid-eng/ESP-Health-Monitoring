import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/health_response.dart';
import '../models/user_input.dart';
import 'network_exception.dart';

class ESPService {
  // ============================================================
  // ESP32 CONFIGURATION
  // ============================================================

  static const String esp32BaseUrl =
      'http://192.168.1.12';

  // ESP32 endpoints
  static const String startEndpoint = '/start';
  static const String healthEndpoint = '/health';

  // Network timeout
  static const Duration requestTimeout =
      Duration(seconds: 5);

  // ============================================================
  // HTTP CLIENT
  // ============================================================

  final http.Client _client = http.Client();

  // ============================================================
  // CHECK ESP32 CONNECTION
  // ============================================================

  Future<bool> checkConnection() async {
    try {
      final url = Uri.parse(
        '$esp32BaseUrl$healthEndpoint',
      );

      print('========================================');
      print('ESP32 CONNECTION TEST');
      print('URL: $url');

      final response = await _client
          .get(url)
          .timeout(requestTimeout);

      print('STATUS CODE: ${response.statusCode}');
      print('RESPONSE BODY: ${response.body}');
      print('========================================');

      if (response.statusCode == 200) {
        return true;
      }

      throw NetworkException(
        'ESP32 returned HTTP ${response.statusCode}',
      );
    } on TimeoutException {
      throw const NetworkException(
        'ESP32 connection timeout',
      );
    } on http.ClientException catch (e) {
      throw NetworkException(
        'ESP32 client error: ${e.message}',
      );
    } on NetworkException {
      rethrow;
    } catch (e) {
      throw NetworkException(
        'ESP32 connection error: $e',
      );
    }
  }

  // ============================================================
  // SEND USER / WORKER INFORMATION TO ESP32
  // POST /start
  // ============================================================

  Future<void> sendUserInput(
    UserInput userInput,
  ) async {
    try {
     final Map<String, dynamic> data = {
  'worker_type': userInput.workerType,
  'activity': userInput.activity,
  'environment': userInput.environment,
   };

      print('========================================');
      print('ESP32 START REQUEST');
      print('URL: $esp32BaseUrl$startEndpoint');
      print('BODY: ${jsonEncode(data)}');

      final response = await _client
          .post(
            Uri.parse(
              '$esp32BaseUrl$startEndpoint',
            ),
            headers: {
              'Content-Type': 'application/json',
            },
            body: jsonEncode(data),
          )
          .timeout(requestTimeout);

      print('START STATUS CODE: ${response.statusCode}');
      print('START RESPONSE: ${response.body}');
      print('========================================');

      if (response.statusCode != 200) {
        throw NetworkException(
          'ESP32 rejected start request '
          '(${response.statusCode})',
        );
      }

      if (response.body.isNotEmpty) {
        try {
          final decoded = jsonDecode(response.body);

          if (decoded is Map<String, dynamic>) {
            final status =
                decoded['status']?.toString();

            if (status != null && status != 'ok') {
              throw NetworkException(
                decoded['message']?.toString() ??
                    'ESP32 failed to start monitoring',
              );
            }
          }
        } catch (e) {
          if (e is NetworkException) {
            rethrow;
          }

          // Ignore JSON parsing problems
          // if HTTP status was successful.
        }
      }
    } on TimeoutException {
      throw const NetworkException(
        'Connection timeout while starting monitoring',
      );
    } on http.ClientException catch (e) {
      throw NetworkException(
        'Could not connect to ESP32: ${e.message}',
      );
    } on NetworkException {
      rethrow;
    } catch (e) {
      throw NetworkException(
        'Failed to start monitoring: $e',
      );
    }
  }

  // ============================================================
  // READ ESP32 STATUS
  // GET /health
  // ============================================================

  Future<Map<String, dynamic>>
      readESPStatusJson() async {
    try {
      final url = Uri.parse(
        '$esp32BaseUrl$healthEndpoint',
      );

      final response = await _client
          .get(url)
          .timeout(requestTimeout);

      print('========================================');
      print('ESP32 HEALTH REQUEST');
      print('URL: $url');
      print('STATUS CODE: ${response.statusCode}');
      print('RESPONSE: ${response.body}');
      print('========================================');

      if (response.statusCode != 200) {
        throw NetworkException(
          'ESP32 returned HTTP '
          '${response.statusCode}',
        );
      }

      if (response.body.isEmpty) {
        throw const NetworkException(
          'ESP32 returned an empty response',
        );
      }

      final decoded = jsonDecode(response.body);

      if (decoded is! Map<String, dynamic>) {
        throw const NetworkException(
          'Invalid JSON received from ESP32',
        );
      }

      return decoded;
    } on TimeoutException {
      throw const NetworkException(
        'Timeout while reading ESP32 status',
      );
    } on FormatException {
      throw const NetworkException(
        'ESP32 returned invalid JSON',
      );
    } on http.ClientException catch (e) {
      throw NetworkException(
        'ESP32 connection error: ${e.message}',
      );
    } on NetworkException {
      rethrow;
    } catch (e) {
      throw NetworkException(
        'Failed to read ESP32 status: $e',
      );
    }
  }

  // ============================================================
  // READ LAST COMPLETED HEALTH DATA
  // Used by Dashboard
  // ============================================================

 // ============================================================
  // READ LAST COMPLETED HEALTH DATA
  // Used by Dashboard or Final Result Screen
  // ============================================================

  Future<HealthResponse?> readHealthStatus() async {
    try {
      final data = await readESPStatusJson();

      // إذا كانت القياسات لا تزال جارية ولم تصل النتائج النهائية بعد
      if (data['status'] == 'measuring' || 
          !data.containsKey('HR') || 
          !data.containsKey('SpO2')) {
        return null; // نعيد قيمة فارغة بدلاً من إحداث خطأ في التطبيق
      }

      return HealthResponse.fromJson(data);
    } on NetworkException {
      rethrow;
    } catch (e) {
      throw NetworkException(
        'Failed to read health data: $e',
      );
    }
  }

  // ============================================================
  // DISPOSE HTTP CLIENT
  // ============================================================

  void dispose() {
    _client.close();
  }
}
