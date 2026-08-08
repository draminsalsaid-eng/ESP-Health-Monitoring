import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/esp_status.dart';
import '../models/health_response.dart';
import '../models/user_input.dart';

class EspService {
  final String baseUrl;

  final Duration requestTimeout;
  final Duration pollingInterval;

  Timer? _pollingTimer;

  bool _isPolling = false;

  EspService({
    this.baseUrl = 'http://192.168.1.12',
    this.requestTimeout = const Duration(seconds: 5),
    this.pollingInterval = const Duration(milliseconds: 700),
  });

  // ============================================================
  // START MONITORING
  // ============================================================

  Future<bool> startMonitoring(UserInput userInput) async {
    try {
      final uri = Uri.parse('$baseUrl/start');

      final body = {
        'user_id': userInput.userId,
        'worker_type': userInput.workerType,
        'activity': userInput.activity,

        // ESP32 currently expects "workplace"
        'workplace': userInput.environment,
      };

      print('==========================================');
      print('ESP32 START MONITORING');
      print('URL: $uri');
      print('DATA: ${jsonEncode(body)}');
      print('==========================================');

      final response = await http
          .post(
            uri,
            headers: {
              'Content-Type': 'application/json',
            },
            body: jsonEncode(body),
          )
          .timeout(requestTimeout);

      print('ESP32 HTTP STATUS: ${response.statusCode}');
      print('ESP32 RESPONSE: ${response.body}');

      if (response.statusCode != 200) {
        return false;
      }

      if (response.body.isEmpty) {
        return true;
      }

      try {
        final decoded = jsonDecode(response.body);

        if (decoded is Map<String, dynamic>) {
          return decoded['status']?.toString().toLowerCase() == 'ok';
        }
      } catch (_) {
        // ESP32 may return a simple response.
      }

      return true;
    } on TimeoutException {
      print('ESP32 START ERROR: Connection timeout');
      return false;
    } catch (e) {
      print('ESP32 START ERROR: $e');
      return false;
    }
  }

  // ============================================================
  // GET ESP32 HEALTH / STATUS
  // ============================================================

  Future<Map<String, dynamic>?> getHealthJson() async {
    try {
      final uri = Uri.parse('$baseUrl/health');

      final response = await http
          .get(uri)
          .timeout(requestTimeout);

      print(
        'ESP32 HEALTH STATUS: ${response.statusCode}',
      );

      if (response.statusCode != 200) {
        return null;
      }

      if (response.body.isEmpty) {
        return null;
      }

      final decoded = jsonDecode(response.body);

      if (decoded is Map<String, dynamic>) {
        return decoded;
      }

      return null;
    } on TimeoutException {
      print('ESP32 HEALTH ERROR: Timeout');
      return null;
    } catch (e) {
      print('ESP32 HEALTH ERROR: $e');
      return null;
    }
  }

  // ============================================================
  // GET ESP STATE
  // ============================================================

  Future<ESPState?> getESPState() async {
    final json = await getHealthJson();

    if (json == null) {
      return null;
    }

    return ESPState.fromJson(json);
  }

  // ============================================================
  // GET FINAL HEALTH DATA
  // ============================================================

  Future<HealthResponse?> getHealthResponse() async {
    final json = await getHealthJson();

    if (json == null) {
      return null;
    }

    final status =
        json['status']?.toString().toLowerCase();

    if (status != 'completed') {
      return null;
    }

    try {
      return HealthResponse.fromJson(json);
    } catch (e) {
      print(
        'HEALTH RESPONSE PARSE ERROR: $e',
      );

      return null;
    }
  }

  // ============================================================
  // POLLING
  // ============================================================

  void startPolling({
    required void Function(ESPState state) onStateChanged,
    required void Function(HealthResponse response) onCompleted,
    required void Function(String message) onError,
  }) {
    stopPolling();

    _isPolling = true;

    Future<void> poll() async {
      if (!_isPolling) {
        return;
      }

      final json = await getHealthJson();

      if (!_isPolling) {
        return;
      }

      if (json == null) {
        onError(
          'Unable to communicate with ESP32',
        );
        return;
      }

      try {
        final espState =
            ESPState.fromJson(json);

        onStateChanged(espState);

        // ==========================================
        // FINAL RESULT
        // ==========================================

        if (espState.isCompleted) {
          final healthResponse =
              HealthResponse.fromJson(json);

          stopPolling();

          onCompleted(
            healthResponse,
          );

          return;
        }

        // ==========================================
        // ESP ERROR
        // ==========================================

        if (espState.isError) {
          stopPolling();

          onError(
            espState.message,
          );

          return;
        }
      } catch (e) {
        onError(
          'Invalid response from ESP32',
        );
      }
    }

    poll();

    _pollingTimer = Timer.periodic(
      pollingInterval,
      (_) {
        poll();
      },
    );
  }

  // ============================================================
  // STOP POLLING
  // ============================================================

  void stopPolling() {
    _isPolling = false;

    _pollingTimer?.cancel();

    _pollingTimer = null;
  }

  // ============================================================
  // CONNECTION TEST
  // ============================================================

  Future<bool> testConnection() async {
    try {
      final json = await getHealthJson();

      return json != null;
    } catch (_) {
      return false;
    }
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  void dispose() {
    stopPolling();
  }
}
