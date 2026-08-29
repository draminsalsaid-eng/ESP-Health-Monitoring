import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/esp_status.dart';
import '../models/user_input.dart';
import '../models/health_response.dart';

class HealthProvider extends ChangeNotifier {
  // ============================================================
  // ESP32 CONFIGURATION
  // ============================================================

  // Replace this IP with the actual ESP32 IP address.
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

  HealthResponse? _healthData;

  HealthResponse? get healthData =>
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
    // Stop previous polling
    // ----------------------------------------------------------

    _stopPolling();

    try {
      // ========================================================
      // 1. CHECK ESP32
      // ========================================================

      final healthState =
          await _getESPHealth();

      if (healthState == null) {
        _setError(
          'Cannot connect to ESP32',
        );

        return false;
      }

      _setESPState(
        healthState,
      );

      // ========================================================
      // 2. SEND WORKER DATA
      // ========================================================

      final success =
          await _sendStartRequest(
        userInput,
      );

      if (!success) {
        return false;
      }

      // ========================================================
      // 3. READ CURRENT ESP32 STATUS
      // ========================================================

      final latestState =
          await _getESPHealth();

      if (latestState != null) {
        _setESPState(
          latestState,
        );
      }

      // ========================================================
      // 4. START POLLING
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
      final uri = Uri.parse(
        '$esp32BaseUrl/health',
      );

      final response =
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

      return ESPState.fromJson(
        decoded,
      );
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
      // Parse /start response
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
                  .trim()
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

          // If ESP32 already returns a state,
          // update the UI immediately.
          final espState =
              ESPState.fromJson(
            decoded,
          );

          _setESPState(
            espState,
          );
        }
      } catch (e) {
        debugPrint(
          'Could not parse /start response: $e',
        );

        // HTTP 200 is considered accepted.
      }

      return true;
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
  // POLL ESP32
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

      // Get complete health data.
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
  // SET ESP STATE
  // ============================================================

  void _setESPState(
    ESPState state,
  ) {
    _espState = state;

    notifyListeners();
  }

  // ============================================================
  // GET LATEST HEALTH DATA
  // ============================================================

  Future<void> getLatestHealthData() async {
    try {
      _error = null;

      final uri = Uri.parse(
        '$esp32BaseUrl/health',
      );

      final response =
          await http.get(
        uri,
      ).timeout(
        requestTimeout,
      );

      debugPrint(
        'GET latest health HTTP: '
        '${response.statusCode}',
      );

      debugPrint(
        'GET latest health response: '
        '${response.body}',
      );

      if (response.statusCode != 200) {
        _error =
            'Failed to get health data '
            '(HTTP ${response.statusCode})';

        notifyListeners();

        return;
      }

      final dynamic decoded =
          jsonDecode(
        response.body,
      );

      if (decoded is! Map<String, dynamic>) {
        _error =
            'Invalid health data received from ESP32';

        notifyListeners();

        return;
      }

      // --------------------------------------------------------
      // Convert JSON to HealthResponse
      // --------------------------------------------------------

      _healthData =
          HealthResponse.fromJson(
        decoded,
      );

      notifyListeners();
    } catch (e) {
      debugPrint(
        'getLatestHealthData error: $e',
      );

      _error =
          'Failed to retrieve health data';

      notifyListeners();
    }
  }

  // ============================================================
  // REFRESH ESP STATUS
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

    // If completed, also retrieve full data.
    if (state.isCompleted) {
      await getLatestHealthData();
    }
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
