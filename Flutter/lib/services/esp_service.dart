import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/user_input.dart';
import 'network_exception.dart';

class ESPService {
  // ============================================================
  // ESP32 CONFIGURATION
  // ============================================================

  static const String baseUrl =
      'http://192.168.1.12';

  // ============================================================
  // TIMEOUTS
  // ============================================================

  static const Duration connectionTimeout =
      Duration(seconds: 5);

  static const Duration requestTimeout =
      Duration(seconds: 8);

  // ============================================================
  // CHECK ESP32 CONNECTION
  // ============================================================

  Future<bool> checkConnection() async {
    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/health'),
          )
          .timeout(connectionTimeout);

      if (response.statusCode != 200) {
        return false;
      }

      if (response.body.isEmpty) {
        return false;
      }

      final decoded = jsonDecode(response.body);

      if (decoded is Map<String, dynamic>) {
        return true;
      }

      return false;
    } catch (_) {
      return false;
    }
  }

  // ============================================================
  // SEND USER / WORKER PROFILE TO ESP32
  // ============================================================

  Future<void> sendUserInput(
    UserInput userInput,
  ) async {
    try {
      /*
       * Flutter sends the user profile to ESP32.
       *
       * IMPORTANT:
       * user_id is used by the Flutter application
       * to identify/authenticate the user.
       *
       * ESP32 receives it, but it does NOT need to
       * send user_id to the AI API.
       */

      final Map<String, dynamic> body = {
        'user_id': userInput.userId,

        'worker_type':
            userInput.workerType,

        'activity':
            userInput.activity,

        /*
         * UserInput currently uses "environment"
         * for the selected workplace.
         *
         * ESP32 expects the JSON field "workplace".
         */
        'workplace':
            userInput.environment,
      };

      print('=================================');
      print('Sending user profile to ESP32');
      print('=================================');
      print(
        const JsonEncoder.withIndent('  ')
            .convert(body),
      );
      print('=================================');

      final response = await http
          .post(
            Uri.parse('$baseUrl/start'),

            headers: {
              'Content-Type':
                  'application/json',
            },

            body: jsonEncode(body),
          )
          .timeout(requestTimeout);

      // --------------------------------------------------------
      // HTTP ERROR
      // --------------------------------------------------------

      if (response.statusCode != 200) {
        throw NetworkException(
          'ESP32 rejected the monitoring request '
          '(HTTP ${response.statusCode})',
        );
      }

      // --------------------------------------------------------
      // EMPTY RESPONSE
      // --------------------------------------------------------

      if (response.body.isEmpty) {
        throw NetworkException(
          'ESP32 returned an empty response',
        );
      }

      // --------------------------------------------------------
      // PARSE RESPONSE
      // --------------------------------------------------------

      final decoded =
          jsonDecode(response.body);

      if (decoded is! Map<String, dynamic>) {
        throw NetworkException(
          'Invalid response received from ESP32',
        );
      }

      final status =
          decoded['status']
              ?.toString()
              .toLowerCase();

      if (status != 'ok') {
        throw NetworkException(
          decoded['message']
                  ?.toString() ??
              'ESP32 failed to start monitoring',
        );
      }

      print(
        'ESP32 accepted monitoring request.',
      );
    } catch (e) {
      if (e is NetworkException) {
        rethrow;
      }

      throw NetworkException(
        'Unable to communicate with ESP32',
      );
    }
  }

  // ============================================================
  // READ ESP32 STATUS
  // ============================================================

  Future<Map<String, dynamic>>
      readESPStatusJson() async {
    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/health'),
          )
          .timeout(requestTimeout);

      // --------------------------------------------------------
      // HTTP ERROR
      // --------------------------------------------------------

      if (response.statusCode != 200) {
        throw NetworkException(
          'ESP32 returned HTTP '
          '${response.statusCode}',
        );
      }

      // --------------------------------------------------------
      // EMPTY RESPONSE
      // --------------------------------------------------------

      if (response.body.isEmpty) {
        throw NetworkException(
          'ESP32 returned an empty status',
        );
      }

      // --------------------------------------------------------
      // PARSE JSON
      // --------------------------------------------------------

      final decoded =
          jsonDecode(response.body);

      if (decoded is! Map<String, dynamic>) {
        throw NetworkException(
          'Invalid JSON received from ESP32',
        );
      }

      return decoded;
    } catch (e) {
      if (e is NetworkException) {
        rethrow;
      }

      throw NetworkException(
        'Lost connection with ESP32',
      );
    }
  }

  // ============================================================
  // READ FINAL HEALTH DATA
  // ============================================================

  Future<Map<String, dynamic>>
      readHealthStatus() async {
    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/health'),
          )
          .timeout(requestTimeout);

      // --------------------------------------------------------
      // HTTP ERROR
      // --------------------------------------------------------

      if (response.statusCode != 200) {
        throw NetworkException(
          'Unable to read health data '
          '(HTTP ${response.statusCode})',
        );
      }

      // --------------------------------------------------------
      // EMPTY RESPONSE
      // --------------------------------------------------------

      if (response.body.isEmpty) {
        throw NetworkException(
          'ESP32 returned empty health data',
        );
      }

      // --------------------------------------------------------
      // PARSE JSON
      // --------------------------------------------------------

      final decoded =
          jsonDecode(response.body);

      if (decoded is! Map<String, dynamic>) {
        throw NetworkException(
          'Invalid health JSON received',
        );
      }

      return decoded;
    } catch (e) {
      if (e is NetworkException) {
        rethrow;
      }

      throw NetworkException(
        'Failed to read health data from ESP32',
      );
    }
  }
}
```
