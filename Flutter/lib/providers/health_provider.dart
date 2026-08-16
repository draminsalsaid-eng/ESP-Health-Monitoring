import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/api_state.dart';
import '../models/esp_status.dart';
import '../models/health_response.dart';
import '../models/user_input.dart';

import '../services/esp_service.dart';
import '../services/network_exception.dart';

class HealthProvider extends ChangeNotifier {
  final ESPService _espService = ESPService();

  Timer? _monitorTimer;

  bool _readingStatus = false;

  // ============================================================
  // API STATE
  // ============================================================

  ApiState _state = ApiState.idle();

  ApiState get state => _state;

  // ============================================================
  // ESP STATE
  // ============================================================

  ESPState _espState = const ESPState(
    status: ESPStatus.idle,
    message: 'Press Start Monitoring',
  );

  ESPState get espState => _espState;

  // ============================================================
  // HEALTH DATA
  // ============================================================

  HealthResponse? _healthData;

  HealthResponse? get healthData => _healthData;

  // ============================================================
  // START MONITORING
  // ============================================================

  Future<bool> startMonitoring(
    UserInput userInput,
  ) async {
    try {
      // Stop any old monitoring session.
      stopMonitoring();

      _healthData = null;

      _state = ApiState.connecting();

      _espState = const ESPState(
        status: ESPStatus.idle,
        message: 'Connecting to ESP32...',
      );

      notifyListeners();

      // ========================================================
      // CHECK ESP32 CONNECTION
      // ========================================================

      final connected =
          await _espService.checkConnection();

      if (!connected) {
        _state = ApiState.error(
          'ESP32 disconnected',
        );

        _espState = const ESPState(
          status: ESPStatus.error,
          message: 'ESP32 disconnected',
        );

        notifyListeners();

        return false;
      }

      // ========================================================
      // SEND USER INFORMATION
      // ========================================================

      await _espService.sendUserInput(
        userInput,
      );

      // ========================================================
      // WAITING FOR FINGER
      // ========================================================

      _state =
          ApiState.waitingSensor();

      _espState = const ESPState(
        status: ESPStatus.waitingFinger,
        message:
            'Place your finger on MAX30105 and MAX30205',
      );

      notifyListeners();

      // ========================================================
      // START STATUS MONITORING
      // ========================================================

      _startMonitoringLoop();

      return true;
    }

    on NetworkException catch (e) {
      _state = ApiState.error(
        e.message,
      );

      _espState = ESPState(
        status: ESPStatus.error,
        message: e.message,
      );

      notifyListeners();

      return false;
    }

    catch (e) {
      _state = ApiState.error(
        'Unexpected error: $e',
      );

      _espState = ESPState(
        status: ESPStatus.error,
        message: 'Unexpected error: $e',
      );

      notifyListeners();

      return false;
    }
  }

  // ============================================================
  // MONITORING LOOP
  // ============================================================

  void _startMonitoringLoop() {
    _monitorTimer?.cancel();

    _monitorTimer = Timer.periodic(
      const Duration(seconds: 1),
      (_) async {
        await _readESPStatus();
      },
    );
  }

  // ============================================================
  // READ ESP32 STATUS
  // ============================================================

  Future<void> _readESPStatus() async {
    // Prevent overlapping HTTP requests.
    if (_readingStatus) {
      return;
    }

    _readingStatus = true;

    try {
      final data =
          await _espService.readESPStatusJson();

      debugPrint(
        'ESP32 STATUS JSON: $data',
      );

      final ESPState espState =
          ESPState.fromJson(data);

      _espState = espState;

      debugPrint(
        'ESP32 STATUS: ${data['status']}',
      );

      debugPrint(
        'ESP32 MESSAGE: ${data['message']}',
      );

      if (data.containsKey('progress')) {
        debugPrint(
          'ESP32 PROGRESS: ${data['progress']}%',
        );
      }

      // ========================================================
      // WAITING FOR FINGER
      // ========================================================

      if (espState.isWaitingFinger) {
        _state =
            ApiState.waitingSensor();
      }

      // ========================================================
      // MEASURING
      // ========================================================

      else if (espState.isMeasuring) {
        _state =
            ApiState.readingData();

        // Do NOT mark completed here.
        //
        // progress == 100 means MAX30105 finished collecting
        // its samples, but ESP32 still needs to:
        //
        // 1. finish other sensors
        // 2. calculate final values
        // 3. send JSON to API
        // 4. receive AI response
        // 5. create final completed JSON
      }

      // ========================================================
      // PROCESSING AI
      // ========================================================

      else if (espState.isProcessingAI) {
        _state =
            ApiState.processingAI();
      }

      // ========================================================
      // COMPLETED
      // ========================================================

      else if (espState.isCompleted) {
        _state = ApiState.success(
          'Health analysis completed',
        );

        // ======================================================
        // IMPORTANT:
        // Parse the COMPLETE ESP32 JSON.
        // ======================================================

        if (data.containsKey('HR') &&
            data.containsKey('SpO2')) {
          try {
            _healthData =
                HealthResponse.fromJson(data);

            debugPrint(
              '==============================',
            );

            debugPrint(
              'FINAL HEALTH DATA RECEIVED',
            );

            debugPrint(
              'HR: ${_healthData!.heartRate}',
            );

            debugPrint(
              'SpO2: ${_healthData!.spo2}',
            );

            debugPrint(
              'Body Temperature: '
              '${_healthData!.bodyTemperature}',
            );

            debugPrint(
              'Environment Temperature: '
              '${_healthData!.environmentTemperature}',
            );

            debugPrint(
              'Prediction: '
              '${_healthData!.prediction}',
            );

            debugPrint(
              'Risk Score: '
              '${_healthData!.riskScore}',
            );

            debugPrint(
              '==============================',
            );
          }

          catch (e) {
            debugPrint(
              'Failed to parse health response: $e',
            );

            _state = ApiState.error(
              'Invalid health data received',
            );
          }
        }
        else {
          debugPrint(
            'Completed status received but '
            'HR/SpO2 are missing.',
          );

          _state = ApiState.error(
            'Incomplete health data received',
          );
        }

        // Stop polling after completed result.
        stopMonitoring();
      }

      // ========================================================
      // ERROR
      // ========================================================

      else if (espState.isError) {
        _state = ApiState.error(
          espState.message,
        );

        stopMonitoring();
      }

      notifyListeners();
    }

    on NetworkException catch (e) {
      _state = ApiState.error(
        e.message,
      );

      _espState = ESPState(
        status: ESPStatus.error,
        message: e.message,
      );

      stopMonitoring();

      notifyListeners();
    }

    catch (e) {
      debugPrint(
        'ESP status read error: $e',
      );

      _state = ApiState.error(
        'Failed to read ESP32 status',
      );

      _espState = ESPState(
        status: ESPStatus.error,
        message:
            'Failed to communicate with ESP32',
      );

      stopMonitoring();

      notifyListeners();
    }

    finally {
      _readingStatus = false;
    }
  }

  // ============================================================
  // GET LATEST HEALTH DATA
  // Used by Dashboard
  // ============================================================

  Future<void> getLatestHealthData() async {
    try {
      final result =
          await _espService.readHealthStatus();

      _healthData = result;

      _state = ApiState.success(
        'Data updated',
      );

      notifyListeners();
    }

    on NetworkException catch (e) {
      _state = ApiState.error(
        e.message,
      );

      notifyListeners();
    }

    catch (e) {
      _state = ApiState.error(
        'Failed to load health data',
      );

      notifyListeners();
    }
  }

  // ============================================================
  // STOP MONITORING
  // ============================================================

  void stopMonitoring() {
    _monitorTimer?.cancel();
    _monitorTimer = null;
    _readingStatus = false;
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    stopMonitoring();
    super.dispose();
  }
}
