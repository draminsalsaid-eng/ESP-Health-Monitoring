import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/esp_status.dart';
import '../models/health_response.dart';
import '../models/user_input.dart';
import '../services/esp_service.dart';
import '../services/network_exception.dart';

class HealthProvider extends ChangeNotifier {
  final ESPService _espService = ESPService();

  ESPState _espState = const ESPState(
    status: ESPStatus.idle,
    message: 'Ready',
  );

  HealthResponse? _healthData;

  Timer? _pollTimer;

  bool _isStarting = false;
  bool _isLoadingHealth = false;
  bool _requestInProgress = false;

  // ============================================================
  // GETTERS
  // ============================================================

  ESPState get espState => _espState;

  HealthResponse? get healthData => _healthData;

  bool get isStarting => _isStarting;

  bool get isLoadingHealth => _isLoadingHealth;

  // ============================================================
  // START MONITORING
  // ============================================================

  Future<void> startMonitoring(
    UserInput userInput,
  ) async {
    if (_isStarting) {
      return;
    }

    _isStarting = true;

    _pollTimer?.cancel();

    _healthData = null;

    _espState = const ESPState(
      status: ESPStatus.idle,
      message: 'Connecting to ESP32...',
    );

    notifyListeners();

    try {
      // ----------------------------------------------------------
      // Send worker information to ESP32
      // POST /start
      // ----------------------------------------------------------

      await _espService.sendUserInput(
        userInput,
      );

      // ----------------------------------------------------------
      // ESP32 accepted the session
      // ----------------------------------------------------------

      _espState = const ESPState(
        status: ESPStatus.waitingFinger,
        message: 'Place finger on both sensors',
      );

      notifyListeners();

      // ----------------------------------------------------------
      // Start reading /health
      // ----------------------------------------------------------

      _startPolling();
    } on NetworkException catch (e) {
      _setError(e.message);
    } catch (e) {
      _setError(
        'Failed to start monitoring: $e',
      );
    } finally {
      _isStarting = false;
      notifyListeners();
    }
  }

  // ============================================================
  // START POLLING
  // ============================================================

  void _startPolling() {
    _pollTimer?.cancel();

    // Read immediately.
    _pollESPStatus();

    // Continue every 500 ms.
    _pollTimer = Timer.periodic(
      const Duration(milliseconds: 500),
      (_) {
        _pollESPStatus();
      },
    );
  }

  // ============================================================
  // POLL ESP32 STATUS
  // ============================================================

  Future<void> _pollESPStatus() async {
    // Prevent overlapping HTTP requests.
    if (_requestInProgress) {
      return;
    }

    _requestInProgress = true;

    try {
      final json =
          await _espService.readESPStatusJson();

      final ESPState state =
          ESPState.fromJson(json);

      _espState = state;

      notifyListeners();

      // ========================================================
      // COMPLETED
      // ========================================================

      if (state.isCompleted) {
        _pollTimer?.cancel();

        try {
          _healthData =
              HealthResponse.fromJson(json);

          notifyListeners();
        } catch (e) {
          _setError(
            'Invalid completed health data: $e',
          );
        }

        return;
      }

      // ========================================================
      // ERROR
      // ========================================================

      if (state.isError) {
        _pollTimer?.cancel();
        return;
      }
    } on NetworkException catch (e) {
      _setError(e.message);
    } catch (e) {
      _setError(
        'Failed to read ESP32 status: $e',
      );
    } finally {
      _requestInProgress = false;
    }
  }

  // ============================================================
  // GET LATEST COMPLETED HEALTH DATA
  // Used by Dashboard
  // ============================================================

  Future<void> getLatestHealthData() async {
    if (_isLoadingHealth) {
      return;
    }

    _isLoadingHealth = true;

    notifyListeners();

    try {
      final HealthResponse data =
          await _espService.readHealthStatus();

      _healthData = data;

      _espState = const ESPState(
        status: ESPStatus.completed,
        message: 'Measurement completed',
        progress: 100,
      );
    } on NetworkException catch (e) {
      debugPrint(
        'Health data error: ${e.message}',
      );
    } catch (e) {
      debugPrint(
        'Health data error: $e',
      );
    } finally {
      _isLoadingHealth = false;

      notifyListeners();
    }
  }

  // ============================================================
  // ERROR
  // ============================================================

  void _setError(
    String message,
  ) {
    _pollTimer?.cancel();

    _espState = ESPState(
      status: ESPStatus.error,
      message: message,
    );

    notifyListeners();
  }

  // ============================================================
  // RESET
  // ============================================================

  void reset() {
    _pollTimer?.cancel();

    _healthData = null;

    _espState = const ESPState(
      status: ESPStatus.idle,
      message: 'Ready',
    );

    notifyListeners();
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    _pollTimer?.cancel();

    _espService.dispose();

    super.dispose();
  }
}
