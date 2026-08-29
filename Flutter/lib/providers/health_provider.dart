
import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/esp_status.dart';
import '../models/user_input.dart';

class HealthProvider extends ChangeNotifier {
  // ============================================================
  // ESP32 CONFIGURATION
  // ============================================================

  // IMPORTANT:
  // Replace this IP with the IP address printed by ESP32 Serial Monitor.
  //
  // Example:
  // ESP32 IP Address: 192.168.1.50
  //
  // Then:
  // http://192.168.1.50
  //
  static const String esp32BaseUrl =
      'http://192.168.1.12';

  static const Duration requestTimeout =
      Duration(seconds: 5);

  static const Duration pollingInterval =
      Duration(milliseconds: 500);

  // ============================================================
  // STATE
  // ============================================================

  ESPState _espState = const ESPState(
    status: ESPStatus.idle,
    message: 'Connecting to ESP32...',
  );

  ESPState get espState => _espState;

  // ============================================================
  // HEALTH DATA
  // ============================================================

  Map<String, dynamic>? _healthData;

  Map<String, dynamic>? get healthData =>
      _healthData;

  // ============================================================
  // CURRENT USER INPUT
  // ============================================================

  UserInput? _currentUserInput;

  UserInput? get currentUserInput =>
      _currentUserInput;

  // ============================================================
  // LOADING
  // ============================================================

  bool _isLoading = false;

  bool get isLoading => _isLoading;

  // ============================================================
  // ERROR
  // ============================================================

  String? _error;

  String? get error => _error;

  // ============================================================
  // POLLING
  // ============================================================

  Timer? _pollTimer;

  bool _polling = false;

  // ============================================================
  // PREVENT DUPLICATE START
  // ============================================================

  bool _startRequestInProgress = false;

  // ============================================================
  // START MONITORING
  // ============================================================

  Future<bool> startMonitoring(
    UserInput userInput,
  ) async {
    // ----------------------------------------------------------
    // Prevent duplicate /start requests
    // ----------------------------------------------------------

    if (_startRequestInProgress) {
      return false;
    }

    _startRequestInProgress = true;

    _error = null;

    _healthData = null;

    _currentUserInput = userInput;

    _isLoading = true;

    _setESPState(
      const ESPState(
        status: ESPStatus.idle,
        message: 'Connecting to ESP32...',
      ),
    );

    // ----------------------------------------------------------
    // Stop any previous polling
    // ----------------------------------------------------------

    _stopPolling();

    try {
      // ========================================================
      // FIRST:
      // Check ESP32 /health
      // ========================================================

      final healthResponse =
          await _getESPHealth();

      if (healthResponse == null) {
        _setError(
          'Cannot connect to ESP32',
        );

        return false;
      }

      // ========================================================
      // SECOND:
      // Send worker information to ESP32 /start
      // ========================================================

      final success =
          await _sendStartRequest(
        userInput,
      );

      if (!success) {
        return false;
      }

      // ========================================================
      // ESP32 accepted the worker profile.
      //
      // ESP32 should now return:
      //
      // {
      //   "status":"waiting_finger",
      //   "message":"Place finger on both sensors"
      // }
      // ========================================================

      final latestState =
          await _getESPHealth();

      if (latestState != null) {
        _setESPState(
          latestState,
        );
      }

      // ========================================================
      // START CONTINUOUS STATUS POLLING
      // ========================================================

      _startPolling();

      return true;
    } catch (e) {
      _setError(
        'ESP32 connection error: $e',
      );

      return false;
    } finally {
      _isLoading = false;

      _startRequestInProgress = false;

      notifyListeners();
    }
  }

  // ============================================================
  // GET ESP32 HEALTH
  // ============================================================

  Future<ESPState?> _getESPHealth() async {
    try {
      final uri = Uri.parse(
        '$esp32BaseUrl/health',
      );

      final response =
          await http.get(
        uri,
      ).timeout(
        requestTimeout,
      );

      if (response.statusCode != 200) {
        _setError(
          'ESP32 /health returned HTTP ${response.statusCode}',
        );

        return null;
      }

      final dynamic decoded =
          jsonDecode(
        response.body,
      );

      if (decoded is! Map<String, dynamic>) {
        _setError(
          'Invalid response from ESP32',
        );

        return null;
      }

      return ESPState.fromJson(
        decoded,
      );
    } catch (e) {
      _setError(
        'Failed to read ESP32 status',
      );

      return null;
    }
  }

  // ============================================================
  // SEND START REQUEST
  // ============================================================

  Future<bool> _sendStartRequest(
    UserInput userInput,
  ) async {
    try {
      final uri = Uri.parse(
        '$esp32BaseUrl/start',
      );

      final body =
          jsonEncode(
        userInput.toJson(),
      );

      debugPrint(
        'Sending START to ESP32:',
      );

      debugPrint(
        body,
      );

      final response =
          await http.post(
        uri,

        headers: {
          'Content-Type':
              'application/json',
        },

        body: body,
      ).timeout(
        requestTimeout,
      );

      debugPrint(
        'ESP32 /start HTTP status: '
        '${response.statusCode}',
      );

      debugPrint(
        'ESP32 /start response: '
        '${response.body}',
      );

      if (response.statusCode != 200) {
        _setError(
          'ESP32 refused start request '
          '(HTTP ${response.statusCode})',
        );

        return false;
      }

      // --------------------------------------------------------
      // Parse ESP32 response
      // --------------------------------------------------------

      try {
        final dynamic decoded =
            jsonDecode(
          response.body,
        );

        if (decoded is Map<String, dynamic>) {
          final status =
              decoded['status']
                  ?.toString()
                  .toLowerCase();

          if (status == 'error') {
            final message =
                decoded['message']
                    ?.toString() ??
                'ESP32 returned an error';

            _setError(
              message,
            );

            return false;
          }
        }
      } catch (_) {
        // The /start response is expected to be JSON.
        // If parsing fails, we still continue because
        // HTTP 200 means the request was accepted.
      }

      return true;
    } catch (e) {
      _setError(
        'Failed to send data to ESP32',
      );

      return false;
    }
  }

  // ============================================================
  // START POLLING
  // ============================================================

  void _startPolling() {
    _stopPolling();

    _polling = true;

    _pollTimer =
        Timer.periodic(
      pollingInterval,
      (_) async {
        if (!_polling) {
          return;
        }

        await _pollESPHealth();
      },
    );
  }

  // ============================================================
  // POLL ESP32 STATUS
  // ============================================================

  Future<void> _pollESPHealth() async {
    final state =
        await _getESPHealth();

    if (state == null) {
      return;
    }

    _setESPState(
      state,
    );

    // ==========================================================
    // COMPLETED
    // ==========================================================

    if (state.isCompleted) {
      _stopPolling();

      _isLoading = false;

      notifyListeners();

      return;
    }

    // ==========================================================
    // ERROR
    // ==========================================================

    if (state.isError) {
      _stopPolling();

      _isLoading = false;

      notifyListeners();

      return;
    }
  }

  // ============================================================
  // SET ESP STATE
  // ============================================================

  void _setESPState(
    ESPState state,
  ) {
    _espState = state;

    // ----------------------------------------------------------
    // Keep the complete JSON when measurement is completed.
    //
    // ESP32 /health contains the sensor data + AI result.
    // ESPState only represents the UI state.
    // ----------------------------------------------------------

    if (state.isCompleted) {
      _readCompletedHealthData();
    }

    notifyListeners();
  }

  // ============================================================
  // READ COMPLETED DATA
  // ============================================================

  Future<void> _readCompletedHealthData() async {
    try {
      final uri = Uri.parse(
        '$esp32BaseUrl/health',
      );

      final response =
          await http.get(
        uri,
      ).timeout(
        requestTimeout,
      );

      if (response.statusCode != 200) {
        return;
      }

      final dynamic decoded =
          jsonDecode(
        response.body,
      );

      if (decoded is Map<String, dynamic>) {
        _healthData =
            Map<String, dynamic>.from(
          decoded,
        );

        notifyListeners();
      }
    } catch (_) {
      // Keep the ESPState completed state.
      // The dashboard can handle missing healthData.
    }
  }

  // ============================================================
  // PUBLIC REFRESH
  // ============================================================

  Future<void> refreshESPStatus() async {
    final state =
        await _getESPHealth();

    if (state == null) {
      return;
    }

    _setESPState(
      state,
    );
  }

  // ============================================================
  // RESET
  // ============================================================

  void reset() {
    _stopPolling();

    _healthData = null;

    _currentUserInput = null;

    _error = null;

    _isLoading = false;

    _startRequestInProgress = false;

    _espState =
        const ESPState(
      status: ESPStatus.idle,
      message: 'Ready',
    );

    notifyListeners();
  }

  // ============================================================
  // STOP POLLING
  // ============================================================

  void _stopPolling() {
    _polling = false;

    _pollTimer?.cancel();

    _pollTimer = null;
  }

  // ============================================================
  // SET ERROR
  // ============================================================

  void _setError(
    String message,
  ) {
    _error = message;

    _espState =
        ESPState(
      status: ESPStatus.error,
      message: message,
    );

    notifyListeners();
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    _stopPolling();

    super.dispose();
  }
}
