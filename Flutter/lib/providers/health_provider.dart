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
      // Clear previous result
      _healthData = null;

      _state = ApiState.connecting();

      _espState = const ESPState(
        status: ESPStatus.idle,
        message: 'Connecting to ESP32...',
      );

      notifyListeners();

      // ----------------------------------------------------------
      // Check ESP32 connection
      // ----------------------------------------------------------

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

      // ----------------------------------------------------------
      // Send user information to ESP32
      // ----------------------------------------------------------

      await _espService.sendUserInput(
        userInput,
      );

      // ----------------------------------------------------------
      // ESP32 is now waiting for finger
      // ----------------------------------------------------------

      _state = ApiState.waitingSensor();

      _espState = const ESPState(
        status: ESPStatus.waitingFinger,
        message:
            'Place your finger on MAX30105 and MAX30205',
      );

      notifyListeners();

      // ----------------------------------------------------------
      // Start monitoring ESP32
      // ----------------------------------------------------------

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
    try {
      final data =
          await _espService.readESPStatusJson();

      // ----------------------------------------------------------
      // Convert JSON -> ESPState
      // ----------------------------------------------------------

      final espState =
          ESPState.fromJson(data);

      _espState = espState;

      // ----------------------------------------------------------
      // DEBUG
      // ----------------------------------------------------------

      debugPrint(
        '==========================================',
      );

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

      debugPrint(
        '==========================================',
      );

      // ==========================================================
      // WAITING FOR FINGER
      // ==========================================================

      if (espState.isWaitingFinger) {
        _state = ApiState.waitingSensor();

        debugPrint(
          'Flutter State: WAITING FOR FINGER',
        );
      }

      // ==========================================================
      // MEASURING
      // ==========================================================

      else if (espState.isMeasuring) {
        _state = ApiState.readingData();

        debugPrint(
          'Flutter State: MEASURING',
        );

        if (espState.progress != null) {
          debugPrint(
            'Measurement progress: '
            '${espState.progress}%',
          );
        }
      }

      // ==========================================================
      // PROCESSING AI
      // ==========================================================

      else if (espState.isProcessingAI) {
        _state = ApiState.processingAI();

        debugPrint(
          'Flutter State: PROCESSING AI',
        );

        debugPrint(
          'Message from ESP32: '
          '${espState.message}',
        );
      }

      // ==========================================================
      // COMPLETED
      // ==========================================================

      else if (espState.isCompleted) {
        debugPrint(
          'Flutter State: COMPLETED',
        );

        // --------------------------------------------------------
        // The ESP32 completed JSON should contain:
        //
        // HR
        // HRV
        // SpO2
        // body_temp
        // env_temp
        // humidity
        // MQ2
        // MQ5
        // MQ135
        // acc_mag
        // gyro_mag
        // prediction
        // risk_score
        // environment_stress
        // activity_stress
        // --------------------------------------------------------

        if (data.containsKey('HR') &&
            data.containsKey('SpO2')) {
          try {
            _healthData =
                HealthResponse.fromJson(data);

            debugPrint(
              'Health data received successfully',
            );

            debugPrint(
              'HR: ${data['HR']}',
            );

            debugPrint(
              'SpO2: ${data['SpO2']}',
            );

            debugPrint(
              'Body Temperature: '
              '${data['body_temp']}',
            );

            debugPrint(
              'Environment Temperature: '
              '${data['env_temp']}',
            );

            debugPrint(
              'Prediction: '
              '${data['prediction']}',
            );

            debugPrint(
              'Risk Score: '
              '${data['risk_score']}',
            );
          }

          catch (e) {
            debugPrint(
              'HealthResponse parsing error: $e',
            );

            _state = ApiState.error(
              'Invalid health data received',
            );

            notifyListeners();

            return;
          }
        }

        _state = ApiState.success(
          'Health analysis completed',
        );

        notifyListeners();

        // --------------------------------------------------------
        // Stop polling after completed result
        // --------------------------------------------------------

        stopMonitoring();

        return;
      }

      // ==========================================================
      // ERROR
      // ==========================================================

      else if (espState.isError) {
        _state = ApiState.error(
          espState.message,
        );

        debugPrint(
          'ESP32 ERROR: ${espState.message}',
        );

        stopMonitoring();
      }

      notifyListeners();
    }

    // ============================================================
    // NETWORK ERROR
    // ============================================================

    on NetworkException catch (e) {
      _state = ApiState.error(
        e.message,
      );

      _espState = ESPState(
        status: ESPStatus.error,
        message: e.message,
      );

      debugPrint(
        'NetworkException: ${e.message}',
      );

      stopMonitoring();

      notifyListeners();
    }

    // ============================================================
    // UNKNOWN ERROR
    // ============================================================

    catch (e) {
      _state = ApiState.error(
        'Unexpected error: $e',
      );

      _espState = ESPState(
        status: ESPStatus.error,
        message: 'Unexpected error: $e',
      );

      debugPrint(
        'Unexpected ESP monitoring error: $e',
      );

      stopMonitoring();

      notifyListeners();
    }
  }

  // ============================================================
  // GET LAST HEALTH DATA
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
        'Failed to load health data: $e',
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
