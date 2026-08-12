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

  // IP address displayed by ESP32 Serial Monitor:
  // 192.168.1.12
  //
  // IMPORTANT:
  // Use HTTP, not HTTPS.
  static const String esp32BaseUrl =
      'http://192.168.1.12';

  // ESP32 endpoints
  static const String startEndpoint =
      '/start';

  static const String healthEndpoint =
      '/health';

  // Network timeout
  static const Duration requestTimeout =
      Duration(seconds: 5);

  // ============================================================
  // HTTP CLIENT
  // ============================================================

  final http.Client _client =
      http.Client();

  // ============================================================
  // CHECK ESP32 CONNECTION
  // GET /health
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

    print('ESP32 STATUS CODE: ${response.statusCode}');
    print('ESP32 RESPONSE: ${response.body}');

    if (response.statusCode == 200) {
      return true;
    }

    return false;
  } on TimeoutException catch (e) {
    print('ESP32 TIMEOUT: $e');
    return false;
  } on http.ClientException catch (e) {
    print('ESP32 CLIENT ERROR: $e');
    return false;
  } catch (e) {
    print('ESP32 UNKNOWN ERROR: $e');
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

        'user_id':
            userInput.userId,

        'worker_type':
            userInput.workerType,

        'activity':
            userInput.activity,

        // ESP32 expects "workplace"
        'workplace':
            userInput.environment,
      };

      final response = await _client
          .post(
            Uri.parse(
              '$esp32BaseUrl$startEndpoint',
            ),

            headers: {
              'Content-Type':
                  'application/json',
            },

            body: jsonEncode(data),
          )
          .timeout(requestTimeout);

      // ========================================================
      // HTTP STATUS
      // ========================================================

      if (response.statusCode != 200) {

        throw NetworkException(
          'ESP32 rejected start request '
          '(${response.statusCode})',
        );
      }

      // ========================================================
      // VERIFY ESP32 RESPONSE
      // ========================================================

      if (response.body.isNotEmpty) {

        try {

          final decoded =
              jsonDecode(response.body);

          if (decoded
              is Map<String, dynamic>) {

            final status =
                decoded['status']
                    ?.toString();

            if (status != null &&
                status != 'ok') {

              throw NetworkException(
                decoded['message']
                        ?.toString() ??
                    'ESP32 failed to start monitoring',
              );
            }
          }

        } catch (e) {

          if (e is NetworkException) {
            rethrow;
          }

          // HTTP 200 is already successful.
          // Ignore JSON parsing problems here.
        }
      }
    }

    // ==========================================================
    // TIMEOUT
    // ==========================================================

    on TimeoutException {

      throw const NetworkException(
        'Connection timeout while starting monitoring',
      );
    }

    // ==========================================================
    // CLIENT ERROR
    // ==========================================================

    on http.ClientException catch (e) {

      throw NetworkException(
        'Could not connect to ESP32: '
        '${e.message}',
      );
    }

    // ==========================================================
    // NETWORK EXCEPTION
    // ==========================================================

    on NetworkException {
      rethrow;
    }

    // ==========================================================
    // OTHER ERROR
    // ==========================================================

    catch (e) {

      throw NetworkException(
        'Failed to start monitoring: $e',
      );
    }
  }

  // ============================================================
  // READ ESP32 STATUS
  // GET /health
  //
  // Main communication channel during measurement.
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

      // ========================================================
      // HTTP STATUS
      // ========================================================

      if (response.statusCode != 200) {

        throw NetworkException(
          'ESP32 returned HTTP '
          '${response.statusCode}',
        );
      }

      // ========================================================
      // EMPTY RESPONSE
      // ========================================================

      if (response.body.isEmpty) {

        throw const NetworkException(
          'ESP32 returned an empty response',
        );
      }

      // ========================================================
      // JSON
      // ========================================================

      final decoded =
          jsonDecode(response.body);

      if (decoded
          is! Map<String, dynamic>) {

        throw const NetworkException(
          'Invalid JSON received from ESP32',
        );
      }

      return decoded;
    }

    // ==========================================================
    // TIMEOUT
    // ==========================================================

    on TimeoutException {

      throw const NetworkException(
        'Timeout while reading ESP32 status',
      );
    }

    // ==========================================================
    // INVALID JSON
    // ==========================================================

    on FormatException {

      throw const NetworkException(
        'ESP32 returned invalid JSON',
      );
    }

    // ==========================================================
    // CLIENT ERROR
    // ==========================================================

    on http.ClientException catch (e) {

      throw NetworkException(
        'ESP32 connection error: '
        '${e.message}',
      );
    }

    // ==========================================================
    // NETWORK EXCEPTION
    // ==========================================================

    on NetworkException {
      rethrow;
    }

    // ==========================================================
    // OTHER ERROR
    // ==========================================================

    catch (e) {

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

  Future<HealthResponse>
      readHealthStatus() async {

    try {

      final data =
          await readESPStatusJson();

      // ========================================================
      // CHECK COMPLETED HEALTH DATA
      // ========================================================

      if (!data.containsKey('HR') ||
          !data.containsKey('SpO2')) {

        throw const NetworkException(
          'No completed health data available',
        );
      }

      return HealthResponse.fromJson(
        data,
      );
    }

    on NetworkException {
      rethrow;
    }

    catch (e) {

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
