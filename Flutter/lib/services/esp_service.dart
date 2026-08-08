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

  // ضع هنا IP الخاص بالـ ESP32 في الشبكة المحلية.
  //
  // مثال:
  // http://192.168.1.12
  //
  // إذا تغير IP الخاص بالـ ESP32 قم بتغييره هنا.
  static const String esp32BaseUrl = 'http://192.168.1.12';

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
      final response = await _client
          .get(
            Uri.parse(
              '$esp32BaseUrl$healthEndpoint',
            ),
          )
          .timeout(requestTimeout);

      if (response.statusCode == 200) {
        return true;
      }

      return false;
    } on TimeoutException {
      return false;
    } on http.ClientException {
      return false;
    } catch (_) {
      return false;
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
        'user_id': userInput.userId,
        'worker_type': userInput.workerType,
        'activity': userInput.activity,

        // ESP32 currently expects "workplace"
        'workplace': userInput.environment,
      };

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

      if (response.statusCode != 200) {
        throw NetworkException(
          'ESP32 rejected start request '
          '(${response.statusCode})',
        );
      }

      // Try to verify ESP32 response
      if (response.body.isNotEmpty) {
        try {
          final decoded =
              jsonDecode(response.body);

          if (decoded is Map<String, dynamic>) {
            final status =
                decoded['status']?.toString();

            if (status != null &&
                status != 'ok') {
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

          // Ignore JSON parsing problems here
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
  //
  // This is the main communication channel during measurement.
  // ============================================================

  Future<Map<String, dynamic>>
      readESPStatusJson() async {
    try {
      final response = await _client
          .get(
            Uri.parse(
              '$esp32BaseUrl$healthEndpoint',
            ),
          )
          .timeout(requestTimeout);

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

      final decoded =
          jsonDecode(response.body);

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
  //
  // Used by Dashboard.
  // ============================================================

  Future<HealthResponse> readHealthStatus() async {
    try {
      final data =
          await readESPStatusJson();

      // Make sure this is a health report
      if (!data.containsKey('HR') ||
          !data.containsKey('SpO2')) {
        throw const NetworkException(
          'No completed health data available',
        );
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
```
