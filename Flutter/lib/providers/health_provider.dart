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

  //================================
  // API STATE
  //================================

  ApiState _state = ApiState.idle();

  ApiState get state => _state;

  //================================
  // ESP STATE
  //================================

  ESPState _espState = const ESPState(
    status: ESPStatus.idle,
    message: 'Press Start Monitoring',
  );

  ESPState get espState => _espState;

  //================================
  // HEALTH DATA
  //================================

  HealthResponse? _healthData;

  HealthResponse? get healthData => _healthData;

  //================================
  // START MONITORING
  //================================

  Future<bool> startMonitoring(
    UserInput userInput,
  ) async {
    try {
      _healthData = null;

      _state = ApiState.connecting();

      _espState = const ESPState(
        status: ESPStatus.idle,
        message: 'Connecting to ESP32...',
      );

      notifyListeners();

      // Check ESP32 connection
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

      // Send worker information
      await _espService.sendUserInput(
        userInput,
      );

      _state = ApiState.waitingSensor();

      _espState = const ESPState(
        status: ESPStatus.waitingFinger,
        message:
            'Place your finger on MAX30105 and MAX30205',
      );

      notifyListeners();

      // Start reading ESP32 states
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
  }

  //================================
  // MONITORING LOOP
  //================================

  void _startMonitoringLoop() {
    _monitorTimer?.cancel();

    _monitorTimer = Timer.periodic(
      const Duration(seconds: 1),
      (_) async {
        await _readESPStatus();
      },
    );
  }

  //================================
  // READ ESP32 STATUS
  //================================

  Future<void> _readESPStatus() async {
    try {
      final data =
          await _espService.readESPStatusJson();

      final espState =
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
      //================================
      // WAITING FOR FINGER
      //================================

      if (espState.isWaitingFinger) {
        _state =
            ApiState.waitingSensor();
      }

      //================================
      // MEASURING
      //================================

    else if (espState.isMeasuring) {
  _state = ApiState.readingData();

  // When measurement reaches 100%,
  // show AI analysis while ESP32 is sending
  // the data to the API.
  if (espState.progress != null &&
      espState.progress! >= 100) {
    _espState = ESPState(
      status: ESPStatus.processingAI,
      message: 'Analyzing measurements...',
      progress: 100,
    );

    _state = ApiState.processingAI;
  }
}

      //================================
      // PROCESSING AI
      //================================

      else if (espState.isProcessingAI) {
        _state =
            ApiState.processingAI();
      }

      //================================
      // COMPLETED
      //================================

      else if (espState.isCompleted) {
        _state = ApiState.success(
          'Health analysis completed',
        );

        // The completed JSON contains
        // the complete health report.
        if (data.containsKey('HR') &&
            data.containsKey('SpO2')) {
          _healthData =
              HealthResponse.fromJson(data);
        }

        stopMonitoring();
      }

      //================================
      // ERROR
      //================================

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
  }

  //================================
  // GET LAST DATA
  // Used by Dashboard
  //================================

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
  }

  //================================
  // STOP MONITORING
  //================================

  void stopMonitoring() {
    _monitorTimer?.cancel();
    _monitorTimer = null;
  }

  @override
  void dispose() {
    stopMonitoring();
    super.dispose();
  }
}
