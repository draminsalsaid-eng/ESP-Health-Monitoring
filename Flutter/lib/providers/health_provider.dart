
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

  // ضع هنا IP الخاص بالـ ESP32
  static const String esp32BaseUrl =
      'http://192.168.1.12';

  static const Duration requestTimeout =
      Duration(seconds: 5);

  static const Duration pollingInterval =
      Duration(milliseconds: 500);

  // ============================================================
  // ESP STATE
  // ============================================================

  ESPState _espState = const ESPState(
    status: ESPStatus.idle,
    message: 'Ready',
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
  // START REQUEST LOCK
  // ============================================================

  bool _startRequestInProgress = false;

  // ============================================================
  // START MONITORING
  // ============================================================

  Future<bool> startMonitoring(
    UserInput userInput,
  ) async {
    // ----------------------------------------------------------
    // Prevent duplicate START requests
    // ----------------------------------------------------------

    if (_startRequestInProgress) {
      return false;
    }

    // ----------------------------------------------------------
    // If we are already monitoring the same session,
    // don't start another session.
    // ----------------------------------------------------------

    if (_polling &&
        _currentUserInput != null &&
        _espState.status != ESPStatus.completed &&
        _espState.status != ESPStatus.error) {
      return true;
    }

    _startRequestInProgress = true;

    _error = null;
    _healthData = null;
    _currentUserInput = userInput;
    _isLoading = true;

    _stopPolling();

    _setESPState(
      const ESPState(
        status: ESPStatus.idle,
        message: 'Connecting to ESP32...',
      ),
    );

    try {
      // ========================================================
      // STEP 1
      // Check ESP32
      // ========================================================

      final ESPState? healthState =
          await _getESPHealth();

      if (healthState == null) {
        _setError(
          _error ?? 'Cannot connect to ESP32',
        );

        return false;
      }

      // --------------------------------------------------------
      // Show current ESP32 state
      // --------------------------------------------------------

      _setESPState(
        healthState,
      );

      // ========================================================
      // STEP 2
      // Send worker profile to ESP32
      // ========================================================

      final bool success =
          await _sendStartRequest(
        userInput,
      );

      if (!success) {
        return false;
      }

      // ========================================================
      // STEP 3
      // Read the new ESP32 state
      // ========================================================

      final ESPState? latestState =
          await _getESPHealth();

      if (latestState != null) {
        _setESPState(
          latestState,
        );
      }

      // ========================================================
      // STEP 4
      // Start polling
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
  // GET ESP32 /health
  // ============================================================

  Future<ESPState?> _getESPHealth() async {
    try {
      final Uri uri = Uri.parse(
        '$esp32BaseUrl/health',
      );

      final http.Response response =
          await http.get(
        uri,
      ).timeout(
        requestTimeout,
      );

      debugPrint(
        'ESP32 /health HTTP: '
        '${response.statusCode}',
      );

      debugPrint(
        'ESP32 /health response: '
        '${response.body}',
      );

      if (response.statusCode != 200) {
        _setError(
          'ESP32 /health returned HTTP '
          '${response.statusCode}',
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

      // --------------------------------------------------------
      // Save complete JSON
      //
      // This is important because /health can contain
      // sensor values and AI results.
      // --------------------------------------------------------

      _healthData =
          Map<String, dynamic>.from(
        decoded,
      );

      return ESPState.fromJson(
        decoded,
      );
    } on TimeoutException {
      _setError(
        'ESP32 request timed out',
      );

      return null;
    } on FormatException {
      _setError(
        'Invalid JSON received from ESP32',
      );

      return null;
    } catch (e) {
      debugPrint(
        'ESP32 /health error: $e',
      );

      _setError(
        'Failed to read ESP32 status',
      );

      return null;
    }
  }

  // ============================================================
  // SEND /start
  // ============================================================

  Future<bool> _sendStartRequest(
    UserInput userInput,
  ) async {
    try {
      final Uri uri = Uri.parse(
        '$esp32BaseUrl/start',
      );

      final Map<String, dynamic> json =
          userInput.toJson();

      final String body =
          jsonEncode(
        json,
      );

      debugPrint(
        '================================',
      );

      debugPrint(
        'Sending START to ESP32',
      );

      debugPrint(
        'URL: $uri',
      );

      debugPrint(
        'BODY: $body',
      );

      debugPrint(
        '================================',
      );

      final http.Response response =
          await http.post(
        uri,

        headers: {
          'Content-Type':
              'application/json',

          'Accept':
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

      // ========================================================
      // HTTP ERROR
      // ========================================================

      if (response.statusCode < 200 ||
          response.statusCode >= 300) {
        _setError(
          'ESP32 refused start request '
          '(HTTP ${response.statusCode})',
        );

        return false;
      }

      // ========================================================
      // PARSE RESPONSE
      // ========================================================

      if (response.body.trim().isNotEmpty) {
        try {
          final dynamic decoded =
              jsonDecode(
            response.body,
          );

          if (decoded is Map<String, dynamic>) {
            // --------------------------------------------------
            // Save complete response
            // --------------------------------------------------

            _healthData =
                Map<String, dynamic>.from(
              decoded,
            );

            // --------------------------------------------------
            // If ESP32 explicitly returned a state,
            // update UI immediately.
            // --------------------------------------------------

            if (decoded.containsKey('status')) {
              final ESPState state =
                  ESPState.fromJson(
                decoded,
              );

              _setESPState(
                state,
              );
            }

            // --------------------------------------------------
            // Explicit ESP32 error
            // --------------------------------------------------

            final String? status =
                decoded['status']
                    ?.toString()
                    .trim()
                    .toLowerCase();

            if (status == 'error' ||
                status == 'wifi_error') {
              final String message =
                  decoded['message']
                          ?.toString() ??
                      'ESP32 returned an error';

              _setError(
                message,
              );

              return false;
            }
          }
        } on FormatException {
          // ----------------------------------------------------
          // If HTTP is successful but response is not JSON,
          // continue because /start itself succeeded.
          // ----------------------------------------------------

          debugPrint(
            'ESP32 /start response is not JSON',
          );
        }
      }

      return true;
    } on TimeoutException {
      _setError(
        'ESP32 /start request timed out',
      );

      return false;
    } catch (e) {
      debugPrint(
        'ESP32 /start error: $e',
      );

      _setError(
        'Failed to send data to ESP32',
      );

      return false;
    }
  }

  // ============================================================
  // START STATUS POLLING
  // ============================================================

  void _startPolling() {
    _stopPolling();

    _polling = true;

    // ----------------------------------------------------------
    // Read immediately
    // ----------------------------------------------------------

    _pollESPHealth();

    // ----------------------------------------------------------
    // Then continue every 500 ms
    // ----------------------------------------------------------

    _pollTimer =
        Timer.periodic(
      pollingInterval,
      (_) {
        if (!_polling) {
          return;
        }

        _pollESPHealth();
      },
    );
  }

  // ============================================================
  // POLL ESP32
  // ============================================================

  Future<void> _pollESPHealth() async {
    if (!_polling) {
      return;
    }

    final ESPState? state =
        await _getESPHealth();

    if (state == null) {
      return;
    }

    // ----------------------------------------------------------
    // Update UI
    // ----------------------------------------------------------

    _setESPState(
      state,
    );

    // ==========================================================
    // COMPLETED
    // ==========================================================

    if (state.isCompleted) {
      _stopPolling();

      _isLoading = false;

      // --------------------------------------------------------
      // Make one final request to obtain the complete
      // measurement + AI result.
      // --------------------------------------------------------

      await getLatestHealthData();

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
  // GET LATEST HEALTH DATA
  //
  // Used by DashboardScreen
  // ============================================================

  Future<void> getLatestHealthData() async {
    try {
      final Uri uri = Uri.parse(
        '$esp32BaseUrl/health',
      );

      final http.Response response =
          await http.get(
        uri,
      ).timeout(
        requestTimeout,
      );

      debugPrint(
        'Dashboard /health HTTP: '
        '${response.statusCode}',
      );

      debugPrint(
        'Dashboard /health response: '
        '${response.body}',
      );

      if (response.statusCode != 200) {
        _setError(
          'Failed to load latest health data '
          '(HTTP ${response.statusCode})',
        );

        return;
      }

      final dynamic decoded =
          jsonDecode(
        response.body,
      );

      if (decoded is! Map<String, dynamic>) {
        _setError(
          'Invalid health data received',
        );

        return;
      }

      // --------------------------------------------------------
      // Save complete ESP32 JSON
      // --------------------------------------------------------

      _healthData =
          Map<String, dynamic>.from(
        decoded,
      );

      // --------------------------------------------------------
      // Also update ESPState
      // --------------------------------------------------------

      final ESPState state =
          ESPState.fromJson(
        decoded,
      );

      _espState = state;

      _error = null;

      notifyListeners();
    } on TimeoutException {
      _setError(
        'Loading health data timed out',
      );
    } on FormatException {
      _setError(
        'Invalid JSON in health data',
      );
    } catch (e) {
      debugPrint(
        'getLatestHealthData error: $e',
      );

      _setError(
        'Failed to load health data',
      );
    }
  }

  // ============================================================
  // PUBLIC REFRESH ESP STATUS
  // ============================================================

  Future<void> refreshESPStatus() async {
    final ESPState? state =
        await _getESPHealth();

    if (state == null) {
      return;
    }

    _setESPState(
      state,
    );

    if (state.isCompleted) {
      _stopPolling();

      await getLatestHealthData();
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
    // If completed, keep polling stopped.
    // ----------------------------------------------------------

    if (state.isCompleted) {
      _stopPolling();
    }

    notifyListeners();
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

    _stopPolling();

    _isLoading = false;

    notifyListeners();
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
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    _stopPolling();

    super.dispose();
  }
}

